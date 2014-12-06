#!/usr/bin/perl
use strict;
use warnings;
 
$| = 1;

BEGIN
{
	push @INC, "/usr/local/watchman-alerting/lib";			

	use constant DAEMON		=> 'icad-monitor';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant CONF_FILE	=> '/etc/icad.ini';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-monitor.log';
	use constant PID_FILE	=> '/var/run/icad-monitor.pid';

	use vars qw( $DBH $STH $HOST $DAEMON $log $CONTINUE );
	
	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
	
	$DAEMON = DAEMON;	
}

use Proc::Daemon;
use Proc::PID::File;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;
use POSIX;
use File::Tail;
use File::Spec;
use File::Touch;
use File::Path;
use File::Temp qw/ :POSIX /;
use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;
use DateTime;

File::Path::make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=>	'/',
	child_STDOUT	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	child_STDERR	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	pid_file		=>	PID_FILE
} ) unless $0 =~ /$DAEMON\.pl$/;

if ( Proc::PID::File->running() )
{
	print STDERR "ICAD-Monitor is already running\n";
	die "ICAD-Monitor is already running";
}

&init_log;

$SIG{HUP} = sub {
	&main::log("Caught SIGHUP:  exiting gracefully");
	$CONTINUE = 0;
	exit 0;
};
$SIG{INT} = sub {
	&main::log("Caught SIGINT:  exiting gracefully");
	$CONTINUE = 0;
	exit 0;
};
$SIG{QUIT} = sub {
	&main::log("Caught SIGQUIT:  exiting gracefully");
	$CONTINUE = 0;
	exit 0;
};
$SIG{TERM} = sub {
	&main::log("Caught SIGTERM:  exiting gracefully");
	$CONTINUE = 0;
	
	exit 0;
};
$SIG{CHLD} = 'IGNORE';

&log("Initiating iCAD-Monitor");

my ($ini, $Config);

unless (
	$ini = new Config::General(
		-ConfigFile           => CONF_FILE,
		-InterPolateVars      => 1,
	)
)
{
	print STDERR "Unable to load system configuration file $@ $!";
	die "Unable to load system configuration file $@ $!";
}

unless ( $Config = { $ini->getall } )
{
	print STDERR "Error parsing CAD Connector settings file icad.ini. Unable to continue. $@ ";
	die "Error parsing CAD Connector settings file icad.ini. Unable to continue.";
}

$HOST = `hostname`;
$DBH = &main::init_db;

unless ( $STH = &dbh_prepare )
{
	print STDERR "Error preparing insert statement, can't continue without valid statement handle\n";
	exit 1;
}

unless ( $Config->{'icad'}->{'monitor'}->{'enabled'} )
{
	&log("iCAD-Monitor is not enabled. Check icad.ini configuration");
	print STDERR "iCAD-Monitor is not enabled. Check icad.ini configuration";
	
	exit 0;	
}

foreach my $svc ( @{ $Config->{'icad'}->{'monitor'}->{'service'} } )
{
	if ( ! ( my $pid = fork ) )
	{
		my $mon;
		my $levels = $svc->{'levels'};
		
		&log("Setting up monitor on service [$svc->{name}] for events [$levels]");		
		
		unless ( $mon = File::Tail->new( $svc->{'logfile'} ) )
		{
			&log("Error setting up file tail on logfile [$svc->{logfile}] $@ $!", E_ERROR);
			exit 1;	
		}
		
		while ( defined( my $line = $mon->read ) )
		{
		    if ( $line =~ /^([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})\s($levels)\s\[(.*?)\]\s(.*)/ )
		    {    	
		    	my $timestamp = $1;
		    	my $type = $2;
		    	my $file = $3;
		    	my $error = $4;
		    	
		    	print "$timestamp, $file, $type, $error \n";
		    	
		    	#eval {
			    #	$STH->execute( $timestamp, $file, $type, $error )
		    	#};
		    	#if ( my $ex = $@ )
		    	#{
		    	#	print STDERR "DBI execute error: " . ( $ex->can('error') ? $ex->error : $ex ) . "\n";
		    	#}
		    	    	
		    	#&smtp_alert( "$type $file $error" ) if ( $type eq 'CRITICAL' );
		    	#`echo "$type $file $error" | /opt/aws/bin/ses-send-email.pl -k /home/ec2-user/.ssh/aws-credential-file -f $recip_to $recip_to`;
		    }
		}		
	}	
}

sub smtp_alert
{
	my $message = shift;

	#my $res = `echo "$_" | /opt/aws/bin/ses-send-email.pl -k /home/ec2-user/.ssh/aws-credential-file -b "Watchman Incident Notification [$IncidentNo]" -b $recip_bcc -f $recip_to $recip_to`;
	
}

sub dbh_prepare
{
	my $sth;
	
	eval {
		$sth = $DBH->run( sub {
			return $_->prepare(
				qq{
					INSERT INTO ErrorLog
					( Timestamp, LogFile, Level, ErrorText )
					VALUES ( ?, ?, ?, ? )
				}
			);
		} )
	};
	
	if ( my $ex = $@ )
	{
		print STDERR "Error preparing database statement " . $ex->error;
		return undef;
	} 	
	
	return $sth;
}

sub init_db
{
	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			"dbi:$Config->{db_link}->{'db_icad'}->{driver}:$Config->{db_link}->{'db_icad'}->{dsn}",
	        $Config->{'db_link'}->{'db_icad'}->{'user'},
	        $Config->{'db_link'}->{'db_icad'}->{'pass'},
	        {
	        	PrintError	=> 0,
	        	RaiseError	=> 0,
	        	HandleError	=> Exception::Class::DBI->handler,
	    	    AutoCommit	=> 1
	        }
		)
	) {

		print STDERR "Database connection error: " . $DBI::errstr;
		die "Database connection error: " . $DBI::errstr;
	}

	unless ( $conn->mode('fixup') )
	{
		print STDERR "Error received when attempting to set default mode on line " . __LINE__ . ": " . $DBI::errstr;
	}

	if ( $Config->{database}->{debug} )
	{
		$conn->{Callbacks} =
		{
	    	connected	=> sub
	    	{
	    		my ($_dbh, $_sql, $_attr) = @_;
	    	    print STDERR "[SQL DEBUG] DBI connection established";
	    	    return;
			},
	    	prepare		=> sub
	    	{
				my ($_dbh, $_sql, $_attr) = @_;
				print STDERR "[SQL DEBUG] q{$_sql}";
				return;
			}
		}
	}

	return $conn;
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

    $msg = "[icad-monitor:$line] $msg ($$)";

	$log->$level($msg) if defined $log;
	print STDERR "$msg \n" unless defined $log;
}

sub ex
{
    my $ex = shift;
    return ( $ex->can('error') ? $ex->error : $ex );
}
