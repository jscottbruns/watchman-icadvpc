#!/usr/bin/perl
use strict;
use warnings;

#
# iCAD Controller Service - Base
#

$| = 1;

BEGIN
{
	push @INC, '/usr/local/watchman-icad/lib';

	use constant DAEMON		=> 'icad-controller';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-controller.log';
	use constant PID_FILE	=> '/var/run/icad-controller.pid';
	use constant CONF_FILE	=> '/etc/icad.ini';
	use constant DEBUG_DIR	=> '/usr/local/watchman-icad/debug';

	use vars qw( %PIDS $log $CONTINUE $DEBUG $DEBUG_DIR $LICENSE $DB_ICAD $Config $CONF_FILE $DAEMON $SQS $DB_NAME );

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';

	$DAEMON = DAEMON;
}

use Module::Load;
use Module::Loaded;
use Proc::Daemon;
use Proc::PID::File;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;
use POSIX;
use File::Spec;
use File::Touch;
use File::Path;
use File::Temp qw/ :POSIX /;
use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;
use DateTime;
use Digest::MD5 qw(md5_hex);
use JSON;
use Amazon::SQS::Simple;

File::Path::make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
File::Path::make_path( DEBUG_DIR, { mode => 0777 } ) if ( ! -d DEBUG_DIR ); # Create debug directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=>	'/',
	child_STDOUT	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	child_STDERR	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	pid_file		=>	PID_FILE
} ) unless $0 =~ /$DAEMON\.pl$/;

if ( Proc::PID::File->running() )
{
	print STDERR "WatchmanAlerting iCAD Controller service is already running\n";
	die "WatchmanAlerting iCAD Controller service is already running";
}

&init_log;

$SIG{HUP} = sub {
	&main::log("Caught SIGHUP:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{INT} = sub {
	&main::log("Caught SIGINT:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{QUIT} = sub {
	&main::log("Caught SIGQUIT:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{TERM} = sub {
	&main::log("Caught SIGTERM:  exiting gracefully");
	$CONTINUE = 0;
};

$SIG{CHLD} = 'IGNORE';

$SQS = {};

$CONF_FILE = CONF_FILE;
$CONF_FILE = $ARGV[0] if $ARGV[0] && -f $ARGV[0];

my $ini;
&main::log("Reading system configuration file [$CONF_FILE]");

unless (
	$ini = new Config::General(
		-ConfigFile           => $CONF_FILE,
		-InterPolateVars      => 1,
	)
)
{
	&main::log("Unable to load system configuration file $@ $!", E_ERROR);
	die "Unable to load system configuration file $@ $!";
}

unless ( $Config = { $ini->getall } )
{
	&main::log("Error parsing CAD Connector settings file icad-controller.ini. Unable to continue. $@ ", E_ERROR);
	die "Error parsing CAD Connector settings file icad-controller.ini. Unable to continue.";
}

$DEBUG_DIR = DEBUG_DIR;
$DEBUG = $Config->{'debug'};
&main::log("Setting DEBUG flag => [$DEBUG]");

$DB_ICAD = $Config->{'db_link'}->{'db_icad'}->{'db_name'};
$CONTINUE = 1;

my $INTERVAL = $Config->{'interval'} || 10;
my $COUNT = 1;

if ( $Config->{'db_link'}->{'db_eoc'}->{'tds_version'} )
{
	&main::log("Setting environment TDS version => [$Config->{db_link}->{db_eoc}->{tds_version}]");
	$ENV{TDSVER} = $Config->{'db_link'}->{'db_eoc'}->{'tds_version'}
}

sub trim($);
sub rtrim($);
sub ltrim($);

&main::log("Loading vendor iCAD module [$Config->{icad}->{controller}->{LoadModule}]");

unless ( $Config->{'icad'}->{'controller'}->{'LoadModule'} )
{
	&main::log("Error loading vendor iCAD module - LoadModule config parameter empty", E_ERROR);
	die "Error loading vendor iCAD module - LoadModule config parameter empty";
}

eval {
	load $Config->{'icad'}->{'controller'}->{'LoadModule'} unless is_loaded( $Config->{'icad'}->{'controller'}->{'LoadModule'} )
};

if ( $@ )
{
    &log("Error loading vendor icad-controller module: $@", E_CRIT);
    exit;
}

my $icad;
unless ( $icad = $Config->{'icad'}->{'controller'}->{'LoadModule'}->new )
{
	&main::log("Fatal errors received during vendor iCAD module instantiation - Unable to proceed with icad-controller", E_CRIT);
	print STDERR "Fatal errors received during vendor iCAD module instantiation - Unable to proceed with icad-controller";
	exit -1;
}

my ($_sql, $new_incidents);

MAIN:
while ( $CONTINUE )
{
	sleep ( $INTERVAL );

	next MAIN unless $icad->IncidentSync;

	$COUNT++;
}

sub cache_timestamp
{
	my $_dbh = shift;

	my $OffsetTime = $Config->{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'offset_time'} || 0;
	my $Timestamp;

	eval {
		($Timestamp) = $_dbh->run( sub {
			return $_->selectrow_array("SELECT CONVERT(VARCHAR, DATEADD( second, $OffsetTime, CURRENT_TIMESTAMP ), 121)");
		} )
	};

	if ( my $ex = $@ )
	{
		&main::log("[EOC911] Database exception received while fetching database timestamp - Defaulting to iCAD system timestamp " . &ex( $ex ), E_ERROR);
	}

	$Timestamp = strftime("%Y-%m-%d %H:%M:%S", localtime( time - $OffsetTime )) unless ( $Timestamp );

	return $Timestamp;
}

sub init_log
{
	if ( $log = Log::Dispatch->new )
	{
		if ( $0 =~ /$DAEMON\.pl$/ )
		{
			unless (
				$log->add(
					Log::Dispatch::Screen->new(
						name		=> 'screen',
						min_level	=> 'debug',
						callbacks	=> sub {
							my %h = @_;
							return uc ( $h{level} ) . " $h{message} \n";
						}
					)
				)
			)
			{
				print STDERR "Error appending system logging to console output $! $@ \n";
			}
		}

		unless (
			$log->add(
				Log::Dispatch::File->new(
					name		=> 'file',
					min_level	=> 'debug',
					mode		=> 'append',
					filename	=> File::Spec->catfile( LOG_DIR, LOG_FILE ),
					callbacks	=> sub {
						my %h = @_;
						return strftime("%Y-%m-%d %H:%M:%S", localtime()) . " " . uc ( $h{level} ) . " $h{message} \n";
					}
				)
			)
		)
		{
			print STDERR "Error appending system logging to log file output $! $@ ($$) \n";
		}

		return 1;
	}

	print STDERR "Unable to initiate system logging $! $@ ($$) \n";
	return undef;
}


sub END
{
}

sub rtrim($)
{
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}

sub ltrim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub log
{
    my $msg = shift;
    my $level = shift;
    my ($package, $file, $line) = caller;

	$level = E_INFO if ! $level;

    $msg = "[$package:$line] $msg ($$)";

	$log->$level($msg) if defined $log;
	print STDERR "$msg \n" unless defined $log;
}

sub ex
{
    my $ex = shift;
    return ( $ex->can('error') ? $ex->error : $ex );
}


sub init_dbConnection
{
	my ($db_label, $db_flags) = @_;

	my $dsn = "dbi:$Config->{db_link}->{$db_label}->{driver}:$Config->{db_link}->{$db_label}->{dsn}:$db_flags";

	&main::log("Opening database connection to [ $dsn ] Autocommit => " . ( defined $Config->{'db_link'}->{$db_label}->{'autocommit'} ? $Config->{'db_link'}->{$db_label}->{'autocommit'} : 1 ) );

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			"dbi:$Config->{db_link}->{$db_label}->{driver}:$Config->{db_link}->{$db_label}->{dsn}",
	        $Config->{'db_link'}->{$db_label}->{'user'},
	        $Config->{'db_link'}->{$db_label}->{'pass'},
	        {
	        	PrintError	=> 0,
	        	RaiseError	=> 0,
	        	HandleError	=> Exception::Class::DBI->handler,
	    	    AutoCommit	=> ( defined $Config->{'db_link'}->{$db_label}->{'autocommit'} ? $Config->{'db_link'}->{$db_label}->{'autocommit'} : 1 ),
	    	    LongTruncOk	=> 1,
	    	    LongReadLen	=> 500000
	        }
		)
	) {

		&main::log("Database connection error: " . $DBI::errstr, E_ERROR);
		die "Database connection error: " . $DBI::errstr;
	}

	&main::log("Setting default DBIx mode => 'fixup' ");
	unless ( $conn->mode('fixup') )
	{
		&main::log("Error received when attempting to set default mode  " . $DBI::errstr, E_ERROR);
		die "Unable to set default SQL mode on line " . __LINE__ . ". Fatal.";
	}

	if ( $Config->{'db_link'}->{$db_label}->{'debug'} )
	{
		&main::log("Registering database handler callback debugging functions");
		$conn->{Callbacks} =
		{
	    	'connected'	=> sub
	    	{
	    		my ($_dbh, $_sql, $_attr) = @_;
	    	    &main::log("DBI connection established", E_DEBUG);
	    	    return;
			},
	    	'prepare'	=> sub
	    	{
				my ($_dbh, $_sql, $_attr) = @_;
				&main::log("q{$_sql}", E_DEBUG);
				return;
			}
		}
	}

	$DB_NAME = $Config->{'db_link'}->{ $db_label }->{'db_name'};

	return $conn;
}

sub init_sqs
{
	my $queue = shift;

	unless ( defined $Config->{'icad'}->{ $queue }->{'SQS_Uri'} )
	{
		&main::log("Error initiating SQS queue - Invalid queue name specified or missing URI endpoint [$queue]", E_CRIT);
		return undef;
	}

	&main::log("Initiating SQS queue [$queue] => [$Config->{icad}->{ $queue }->{SQS_Uri}]");

	unless ( $SQS->{ $queue } = new Amazon::SQS::Simple($Config->{'icad'}->{ $queue }->{'SQS_AccessKey'}, $Config->{'icad'}->{ $queue }->{'SQS_SecretKey'})->GetQueue( $Config->{'icad'}->{ $queue }->{'SQS_Uri'} ) )
	{
		&main::log("SQS Connection Error - Can't initiate SQS queue [$queue] $@ $!", E_CRIT);
		return undef;
	}

	return 1;
}

sub sqs_send
{
	my ($queue, $params) = @_;

	&main::log("Preparing message delivery for SQS queue => [$queue]") if $DEBUG;

	&main::init_sqs( $queue ) unless $SQS->{ $queue };

	unless ( $SQS->{ $queue } )
	{
		&main::log("Failed to initialize SQS queue - Can't continue with SQS message delivery", E_CRIT);
		return undef;
	}

	my $sqs_payload = JSON->new->utf8->encode( {
		EventSrc	=> 'controller',
		EventDB		=> $DB_NAME,
		EventNo		=> $params->{'EventNo'},
		EventRef	=> $params->{'EventRef'}
	} );

	my $rc = $SQS->{ $queue }->SendMessage( $sqs_payload );

	unless ( $rc->MessageId() )
	{
		&main::log("SQS notifier request failed to return valid response", E_CRIT);
		return undef;
	}

	unless ( $rc->MD5OfMessageBody() eq md5_hex( $sqs_payload ) )
	{
		&main::log("SQS MD5 message validation failed - SQS_MD5 => [" . $rc->MD5OfMessageBody() . "] LOCAL_MD5 => [" . md5_hex( $sqs_payload ) . "]", E_CRIT);
	}

	return $rc->MessageId();
}


