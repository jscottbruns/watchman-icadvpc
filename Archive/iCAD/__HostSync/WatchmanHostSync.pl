#!/usr/bin/perl
use strict;

use POSIX qw(strftime);
use POSIX qw(setsid);
use Date::Format;
use DBI;
use Config::IniFiles;

my $service = 'WatachmanHostSync';

$| = 1;

BEGIN {

    push(@INC, "./lib");

    use constant VERSION => "1.0.0";
    use constant PATH => "/var/lib/watchman";
    use constant TEMP_DIR => "tmp";

    use vars qw( $PATH $DEBUG $DB_FILE );

    if ( ! $0 || $0 ne 'WatchmanHostSync.pl' ) {

	    if ( -f PATH . "/logs/hostsync.log" && -s PATH . "/logs/hostsync.log" > 10485760 ) {

	        copy( PATH . "/logs/hostsync.log.1", PATH . "/logs/hostsync.log.2" ) if -f PATH . "/logs/hostsync.log.1";
	        copy( PATH . "/logs/hostsync.log", PATH . "/logs/hostsync.log.1" );

	        open(FH, '>'. PATH . "/logs/hostsync.log");
	        close FH;
	    }

	    open STDOUT, '>>', PATH . "/logs/hostsync.log" or die "Couldn't dup stdout to filelog: $!\n";

	    if ( -f PATH . "/logs/hostsync.err" && -s PATH . "/hostsync.err" > 10485760 ) {

	        copy( PATH . "/logs/hostsync.err.1", PATH . "/logs/hostsync.err.2" ) if -f PATH . "/logs/hostsync.err.1";
	        copy( PATH . "/logs/hostsync.err", PATH . "/logs/hostsync.err.1" );

	        open(FH, '>'. PATH . "/logs/hostsync.err");
	        close FH;
	    }

	    open STDERR, '>>', PATH . "/logs/hostsync.err" or die "Couldn't dup stderr to filelog: $!\n";

	    chdir '/';
	    umask 0;
	    open STDIN, '/dev/null';
    }
}

$PATH = PATH;

defined ( my $pid = fork );
exit if $pid;
setsid() or die "Can't start a new session: $!";

my $progname  = "WatchmanAlerting AlertQueue HostSync Client";
my $copyright = "(c) Firehouse Automation 2011";
my $watchman_exec = basename( $0 );

our(%Config, $Verbose);

$SIG{'TERM'} = 'term_handler';

&write_log("Starting $progname from $PATH\n");

my ($sth, %row);
my $self = {
	'dbh'              => 
	{
        'mysql'     =>  undef,
        'mssql'		=>	undef,
	},
	'settings'         =>  {}
};

my $cfg = Config::IniFiles->new( 
	-file => "/var/lib/watchman/hostsync.ini"
) or die "Error parsing INI file from /var/lib/watchman/hostsync.ini";

my $delay = $cfg->val( 'hostsync', 'interval') || 10;

unless ( &init_mysql(
    'username'  =>  $cfg->val( 'mysql_database', 'db_user'),
    'password'  =>  $cfg->val( 'mysql_database', 'db_pass'),
    'database'  =>  $cfg->val( 'mysql_database', 'db_name'),
    'host'		=>  $cfg->val( 'mysql_database', 'db_host'),
    'port'		=>  $cfg->val( 'mysql_database', 'db_port')
) ) {

    &write_log("Fatal errors connecting to MySQL database. Unable to proceed.\n", 1);
    exit;
}

unless ( &init_mssql(
    'username'  =>  $cfg->val( 'mssql_database', 'db_user'),
    'password'  =>  $cfg->val( 'mssql_database', 'db_pass'),
    'database'  =>  $cfg->val( 'mssql_database', 'db_name'),
    'host'		=>  $cfg->val( 'mssql_database', 'db_host'),
    'port'		=>  $cfg->val( 'mssql_database', 'db_port')
) ) {

    &write_log("Fatal errors connecting to MSSQL database. Unable to proceed.\n", 1);
    exit;
}

print __LINE__;exit;

unless ( defined &ContinueRun ) {

    my $sleep;

    *ContinueRun = sub {

		sleep( 1000 * shift ) if $sleep && @_;
		$sleep = 1;

		return 1;
    };

    *RunningAsService = sub { return 0 };

    Interactive();
}

sub configure
{
	%Config = (
		ServiceName	=>	$service,
	    DisplayName =>	"WatchmanAlerting AlertQueue HostSync Service",
	    Parameters  =>	"--delay $delay",
	    Description =>	"CAD Incident Polling Synchronization Service"
	);
}

sub Interactive
{
    configure();
    Startup();
}


sub Startup
{

	while ( 1 ) {

		$self->{'hostsync_update'} = undef;
		$self->{'hostsync_cache'} = [];

		my ($sth, %row);

		unless (
			$sth = $self->{'dbh'}->{'mssql'}->prepare( qq{
				SELECT
					IncidentNo,
					IncDate,
					CallType,
					Grid,
					Location,
					Trucks
				FROM tblActiveFireCalls
			} )
        ) {

            &write_log("HostSync client database error: (" . $DBI::errstr . ") " . $DBI::errstr . "\n", 1);
        }

		if ( $sth->execute ) {

		    while ( my $ref = $sth->fetchrow_hashref() ) {

                    $self->{'dbh'}->{'mysql'}->prepare( qq{
                    	REPLACE INTO incidentpoll
                        VALUES
                        (
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?
                        )
                    } )->execute(
	                    $$ref{'IncidentNo'},
                        $$ref{'IncDate'},
                        $$ref{'CallType'},
                        $$ref{'Grid'},
                        $$ref{'Location'},
                        $$ref{'Trucks'}
                    );
		    }
		}

        if ( $self->{'hostsync_update'} ) {

            unless ( &hostsync ) {

                &write_log("Errors returned during hostsync request\n", 1);
            }
        }
	}
}

sub hostsync
{
    my $response;
	my $k = 0;

	no strict 'refs';
	no warnings qw(redefine);

	&write_log("Running HostSync service for " . ( $#{ $self->{'hostsync_cache'} } + 1 ) . " incidents\n");

	$self->{'settings'}->{'hostsync_timeout'} = 15 if ( ! $self->{'settings'}->{'hostsync_timeout'} );

    eval {
        $response = SOAP::Lite
        	->uri( $self->{'settings'}->{'hostsync_uri'} )
	        ->proxy
	        (
	            $self->{'settings'}->{'hostsync_proxy'},
	            'timeout' => $self->{'settings'}->{'hostsync_timeout'}
	        )
			->on_fault
			(
				sub
				{
					my ($soap, $res) = @_;
					&write_log( ( ref $res ? $res->faultstring : $soap->transport->status ) . " - HostSync SOAP service request failed \n", 1);
				}
			)
	        ->init
	        (
		        {
		            'service'   =>  'hostsync',
		            'testparam'	=>	'testparam_1234',
		            'license'   =>  $self->{'settings'}->{'license'},
		            'incident'  =>  $self->{'hostsync_cache'}
		        }
	        )->result
    };

    if ( $@ ) {

        &write_log("HostSync SOAP request failed with uncaught exception: $response \n", 1);
        return undef;
    }

    if ( $response =~ /(-?[0-9])\n?(.*)?/m ) {

    	my $res = $1;
    	my $msg = $2;

    	if ( $res < 1 )
    	{

            &write_log("HostSync service failed: ($res) $msg \n", 1);
            return undef;
    	}

    	&write_log("HostSync service completed successfully\n");
    	return 1;

    }

	&write_log("Cannot parse HostSync server response: $response\n", 1);

    return undef;
}

sub init_mssql
{
    my %params = @_;
    my $data_src = q/dbi:ODBC:Cambria_CAD/;

    &write_log("Establishing connection to MSSQL database $params{database} on $params{host}:$params{port} \n");

    unless (
        $self->{'dbh'}->{'mssql'} = DBI->connect(
            $data_src,
            $params{'username'},
            $params{'password'},
            {
               PrintError => 0,
               AutoCommit	=>	1
            }
    ) ) {

        &write_log("Can't connect to MSSQL database. MSSQL said ($DBI::err) $DBI::errstr", 1);
        return undef;
    }

	&write_log("Connected to MSSQL database\n");
    return 1;	
}

sub init_mysql
{
    my %params = @_;

    &write_log("Establishing connection to MySQL database $params{database} on $params{host}:$params{port} \n");

    unless (
        $self->{'dbh'}->{'mysql'} = DBI->connect(
            "DBI:mysql:$params{database}:$params{host}:$params{port}",
            $params{'username'},
            $params{'password'},
            {
               PrintError => 0
            }
    ) ) {

        &write_log("Can't connect to MySQL database. MySQL said ($DBI::err) $DBI::errstr", 1);

        return undef;
    }

	&write_log("Connected to MySQL database\n");

    return 1;
}

sub write_log
{
    my $msg = shift;
    my $err = shift;
    my ($package, $file, $line) = caller;

    $msg =~ s/\n$//;
    $msg .= " (" . $$ . ")" if substr($$, 0, 1) eq '-';
    $msg = "[" . POSIX::strftime("%a %b %e %H:%M:%S %Y", localtime) . "] [" . $package . ":" . $line . "] " . ($err ? "[error] " : undef) . " $msg\n";

    print STDOUT $msg;
}

sub term_handler
{

	&write_log("Received termination request... Closing Watchman HostSync client service \n");

	sleep 1;

	exit;
}