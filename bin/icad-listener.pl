#!/usr/bin/perl --
use strict;
use warnings;

#
# iCAD Listener Service
#

$| = 1;

BEGIN
{
	push @INC, '/usr/local/watchman-icad/lib';

	use constant DAEMON		=> 'icad-listener';
	use constant ROOT_DIR	=> '/usr/local/watchman-icad';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-listener.log';
	use constant PID_FILE	=> '/var/run/icad-listener.pid';
	use constant CONF_FILE	=> '/etc/icad.ini';
	use constant DEBUG_DIR	=> '/usr/local/watchman-icad/debug';

	use vars qw( %PIDS $log $CONTINUE $DEBUG $LICENSE $dbh $DB_ICAD $Config $DAEMON $DB_NAME $SQS );

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';

	$DAEMON = DAEMON;
	$CONTINUE = 1;
}

use POSIX;
use Module::Load;
use Module::Loaded;
use Proc::Daemon;
use Proc::PID::File;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;
use Net::SMTP::Server;
use Net::SMTP::Server::Client2;
use Email::Simple;
use MIME::QuotedPrint;
use File::Temp qw( tempfile );
use File::Spec;
use File::Touch;
use File::Path;
use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;
use DateTime;
use Digest::MD5 qw( md5_hex );
use JSON;
use Amazon::SQS::Simple;

make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
make_path( DEBUG_DIR, { mode => 0777 } ) if ( ! -d DEBUG_DIR ); # Create debug directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=> '/',
	child_STDOUT	=> File::Spec->catfile( LOG_DIR, LOG_FILE . '.sysout' ),
	child_STDERR	=> File::Spec->catfile( LOG_DIR, LOG_FILE . '.syserr' ),
	pid_file		=> PID_FILE
} ) unless $0 =~ /$DAEMON\.pl$/;

if ( Proc::PID::File->running() )
{
	print STDERR "WatchmanAlerting iCAD Listener is already running\n";
	die "WatchmanAlerting iCAD Dispatcher is already running";
}

&init_log;

$SIG{HUP} = sub {
	&log("Caught SIGHUP:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{INT} = sub {
	&log("Caught SIGINT:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{QUIT} = sub {
	&log("Caught SIGQUIT:  exiting gracefully");
	$CONTINUE = 0;
};
$SIG{TERM} = sub {
	&log("Caught SIGTERM:  exiting gracefully");
	$CONTINUE = 0;
};

$SIG{CHLD} = 'IGNORE';

$SQS = {};

my ($ini, $server, $conn, $local_domains);

&log("Starting iCAD Incident Event Listener ");

&log("Reading icad configuration from ini file => [ " . CONF_FILE . "]");

unless (
	$ini = new Config::General(
		-ConfigFile           => CONF_FILE,
		-InterPolateVars      => 1,
	)
)
{
	&log("Unable to load system configuration file $@ $!", E_ERROR);
	die "Unable to load system configuration file $@ $!";
}

unless ( $Config = { $ini->getall } )
{
	&log("Error parsing CAD Connector settings file icad.ini. Unable to continue. $@ ", E_ERROR);
	die "Error parsing CAD Connector settings file icad.ini. Unable to continue.";
}

$_ =~ /@(.*)$/ and push @{ $local_domains }, $1 for ( keys %{ $Config->{'icad'}->{'listener'}->{'destination'} } );

$DB_ICAD = $Config->{'db_link'}->{'db_icad'}->{'db_name'};

unless ( $DB_ICAD )
{
	&log("*ERROR* iCAD database name not defined - Fatal", E_CRIT);
	die "*ERROR* iCAD database name not defined - Fatal";
}

$DEBUG = $Config->{'icad'}->{'listener'}->{'Debug'};

&log("DEBUG flag is enabled") if $DEBUG;
&log("DEBUG flag is disabled") unless $DEBUG;

unless ( $server = new Net::SMTP::Server( $Config->{'icad'}->{'listener'}->{'LocalAddr'} => $Config->{'icad'}->{'listener'}->{'LocalPort'} ) )
{
	&log("Unable to initiate SMTP server [$Config->{icad}->{listener}->{LocalAddr}:$Config->{icad}->{listener}->{LocalPort}] $! $@ - Fatal", E_CRIT);
	exit 1;
}

&log("Listening for incoming [$Config->{icad}->{listener}->{Protocol}] connections on " . $server->{SOCK}->sockhost() . ":" . $server->{SOCK}->sockport());

while( $conn = $server->accept() )
{
    fork and last;
    $conn->close;
};

unless ( $conn )
{
	&log("Closing SMTP connection listener");
	exit;
}

if ( my $client = new Net::SMTP::Server::Client2( $conn ) )
{
	&log("Incoming connection from " . $client->{SOCK}->sockhost());

	$client->set_callback(RCPT => \&validate_recipient);
	$client->greet;

	while ($client->get_message)
	{
    	if ( length($client->{MSG}) > 1400000 )
    	{
            &log("SMTP client reporting payload exceeds max length", E_ERROR);
        	$client->too_long;
    	}
    	else
    	{
    		my $dest_addr;
			my $recip_addr = $client->{TO};
			my $sender_addr = lc( $client->{FROM} );
			my $message = $client->{MSG};

			$client->okay("goodbye");

			foreach ( @{ $recip_addr } )
			{
				print "Validating destination address [$_]\n";

				if ( $_ =~ /\@.*?\.fhwm\.net$/i )
				{
					$dest_addr = lc( $_ );
					last;
				}
			}

			&log("Processing message payload from [$sender_addr] destined for [$dest_addr]");

            my $m;
            unless ( $m = Email::Simple->new( MIME::QuotedPrint::decode( $message ) ) )
            {
                &log("Error parsing SMTP payload $@ $!", E_CRIT);
                last;
            }

			if ( $DEBUG )
			{
                my ($fh, $filename) = tempfile(
                    'CadEvent_' . time . '_XXXX',
                    DIR     => '/usr/local/watchman-icad/smtp-capture',
                    SUFFIX  => '.txt'
                );

                if ( $fh )
                {
                    &log("Writing message payload to file => $filename", E_DEBUG);

                    print $fh MIME::QuotedPrint::decode( $message );
                    close $fh;

                    chmod 0644, $filename;
                }
			}

			&log("Checking subject header [" . $m->header('Subject') . "]");

			unless ( $Config->{'icad'}->{'listener'}->{'destination'}->{ $dest_addr }->{'Module'} )
			{
				&log("No module specified for event processor, can't continue", E_CRIT);
				exit;
			}

			&log("Loading event processor [$Config->{icad}->{listener}->{destination}->{ $dest_addr }->{Module}] for [$Config->{icad}->{listener}->{destination}->{ $dest_addr }->{Name}]");

			eval {
			    load $Config->{'icad'}->{'listener'}->{'destination'}->{ $dest_addr }->{'Module'} unless is_loaded( $Config->{'icad'}->{'listener'}->{'destination'}->{ $dest_addr }->{'Module'} )
			};

			if ( $@ )
			{
			    &log("Error loading event processor module: $@", E_CRIT);
			    exit;
			}

			$Config->{'icad'}->{'listener'}->{'destination'}->{ $dest_addr }->{'Module'}->new( {
				'Dest'	=> $dest_addr,
				'Data'	=> $m->body,
				'Subj'	=> $m->header('Subject')
			} );
    	}
    }
}

sub validate_recipient
{
    my($self, $recip) = @_;

    my $domain;

    my @_r = Net::SMTP::Server::Client2::find_addresses(@{$recip});

    if ( $_r[0] =~ /@(.*)>?\s*$/ )
    {
        $domain = $1;
    }

    if(not defined $domain)
    {
        $self->fail("Syntax error");
        $self->basta;
    }
    elsif ( not ( grep $domain eq $_, @{ $local_domains } ) )
    {
        $self->fail("Recipient address rejected: Relay access denied");
        $self->basta;
    }

    push @{ $self->{TO} }, @_r;
    $self->okay("sending to recip @{$self->{TO}}");
}

sub ex
{
    my $ex = shift;
    my $err = $ex->error;
    my $state = $ex->state;

    $err =~ s/\n//g;
    $err =~ s/\s{3,}/ /g;

    return ( $ex->can('error') ? "($state) $err" : $ex );
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
    return unless $string;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
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
						return POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime()) . " " . uc ( $h{level} ) . " $h{message} \n";
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

sub init_dbConnection
{
	my ($db_name, $db_flags) = @_;

	$db_name = $Config->{'db_link'}->{'db_icad'}->{'db_name'} unless $db_name;

	my $dsn = "dbi:$Config->{db_link}->{db_icad}->{driver}:$db_name;" .
	( $Config->{'db_link'}->{'db_icad'}->{'socket'} ?
		"socket=$Config->{db_link}->{db_icad}->{socket};" : "host=$Config->{db_link}->{db_icad}->{host};port=$Config->{db_link}->{db_icad}->{port};"
	);

	$dsn .= $db_flags if $db_flags;

	&log("Opening database connection to [ $dsn ]");

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			$dsn,
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

		&log("Database connection error: " . $DBI::errstr, E_ERROR);
		die "Database connection error: " . $DBI::errstr;
	}

	&log("Setting default DBIx mode => 'fixup' ");

	unless ( $conn->mode('fixup') )
	{
		&log("Error received when attempting to set default mode " . $DBI::errstr, E_ERROR);
		die "Unable to set default SQL mode on line " . __LINE__ . ". Fatal.";
	}

	if ( $Config->{'db_link'}->{'db_icad'}->{'debug'} )
	{
		&log("Registering database handler callback debugging functions");
		$conn->{Callbacks} =
		{
	    	connected	=> sub
	    	{
	    		my ($_dbh, $_sql, $_attr) = @_;
	    	    &log("[SQL DEBUG] DBI connection established");
	    	    return;
			},
	    	prepare		=> sub
	    	{
				my ($_dbh, $_sql, $_attr) = @_;
				&log("[SQL DEBUG] q{$_sql}");
				return;
			}
		}
	}

	$DB_NAME = $Config->{'db_link'}->{'db_icad'}->{'db_name'};

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