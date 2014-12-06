package iCAD_Services;

use strict;

$| = 1;

BEGIN
{
    use constant DOCROOT => "/var/www/services.fhwm.net";
	use constant LOG_FILE	=> 'icad-services.log';
	use constant LOG_STDERR => 'icad-services.err';
	use constant TEMP_DIR	=> '/tmp';

    use vars qw( $DOCROOT $CHECKSUM $DEBUG $log %PIDS $DBH );

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
}

use POSIX;
use URI::Escape;
use File::Spec;
use File::Temp qw( tempfile );

use LWP::UserAgent;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

$DEBUG = 1;

&init_log;

$SIG{HUP} = sub {
	&log("Caught SIGHUP:  exiting gracefully");
};
$SIG{INT} = sub {
	&log("Caught SIGINT:  exiting gracefully");
};
$SIG{QUIT} = sub {
	&log("Caught SIGQUIT:  exiting gracefully");
};
$SIG{TERM} = sub {
	&log("Caught SIGTERM:  exiting gracefully");
};

$SIG{CHLD} = sub {
	local ($!, $?);

	my $pid = waitpid(-1, WNOHANG);
	return if $pid == -1;
	return unless defined $PIDS{$pid};
	delete $PIDS{$pid};

	&log("Child process [$pid] ended with exit code $?");
};

sub set_timezone
{
	return undef unless $DBH;
	
	eval {
		$DBH->run( sub {
			$_->do("SET time_zone='US/Eastern'");
		} );
	};	
}

sub init_log
{
	if ( $log = Log::Dispatch->new )
	{
		if ( $0 =~ /iCAD_ServicesHandler\.pl$/ )
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
					filename	=> File::Spec->catfile( DOCROOT . '/log', LOG_FILE ),
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

sub init_dbConnection
{
    my $pass = 'yT0WFr5DwDn';
    my $user = 'icad_services';
    my $dsn = "DBI:mysql:ICAD_SERVICES;socket=/var/lib/mysql/mysql.sock";

	&log("Opening database connection to [ $dsn ]");

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			$dsn,
	        $user,
	        $pass,
	        {
	        	PrintError	=> 0,
	        	RaiseError	=> 0,
	        	HandleError	=> Exception::Class::DBI->handler,
	    	    AutoCommit	=> 1
	        }
		)
	) {

		&log("Database connection error: " . $DBI::errstr, E_ERROR);
		print STDERR "Database connection error: " . $DBI::errstr;
		
		exit 1;
	}

	&log("Setting default DBIx mode => 'fixup' ");

	unless ( $conn->mode('fixup') )
	{
		&log("Error received when attempting to set default mode " . $DBI::errstr, E_ERROR);
		print STDERR "Unable to set default SQL mode on line " . __LINE__ . ". Fatal.";
		
		exit 1;
	}	

	return $conn;
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

sub NewUrlMap
{
	my $self = shift;
    my $params = shift;
    
    $DBH = &init_dbConnection;
    
    my $UrlKey = $params->{'UrlKey'};
    my $Url = $params->{'Url'};
    my $ForwardUrl = $params->{'ForwardUrl'};
    
    return "Database error [1001]" unless $DBH;
    return "Missing required parameters [2001]" unless $UrlKey && $Url && $ForwardUrl;
    
	my $AuthKey = '151F290A50BCC1F290A50BF9D0A50BC';
    my $CHECKSUM = $params->{'checksum'};

    &log("New URL mapping service requested w/ authentication checksum [$CHECKSUM]");
    
    my $sth;
	eval {
		$sth = $DBH->run( sub {
			return $_->prepare( qq{
				INSERT INTO iCadUrlMap
				( UrlKey, Url, ForwardUrl )
				VALUES ( ?, ?, ? )
			} );
		} )
	};		
	
	if ( my $ex = $@ || ! $sth ) 
	{ 
		&log("Database exception received during URL forward map statement prepare " . ( $ex ? $ex->error : undef ), E_CRIT);
		return "Database error, can't proceed with URL mapping request [" . ( $ex ? "1003" : "10047" ) . "]"; 
	}
    
    if ( $sth->execute( $UrlKey, $Url, $ForwardUrl ) )
    {
    	return 1;
    }
    
    &log("Insert error - Unable to proceed with URL mapping request " . ( $DBI::errstr ? $DBI::errstr : undef ), E_CRIT);
    return "Insert error - Unable to proceed with URL mapping request [1005]"; 	    
}

sub NextUrlKey
{
	my $self = shift;
    my $params = shift;
    
    $DBH = &init_dbConnection;
    
    return "Database error [1001]" unless $DBH;
    
	my $AuthKey = '151F290A50BCC1F290A50BF9D0A50BC';
    my $CHECKSUM = $params->{'checksum'};

    &log("Next URL key service requested w/ authentication checksum [$CHECKSUM]");
	
	&log("Purging old URL keys older than 4 days");
	
    eval {
		$DBH->run( sub {
			$_->do( qq{
				DELETE FROM iCadUrlMap
				WHERE DATEDIFF( NOW(), Timestamp ) > 4 AND UrlKey > 1
			} );										
		} )
    };
    
    if ( my $ex = $@ )
    {
    	&log("Database exception received during URL puging " . ( $ex ? $ex->error : undef ), E_ERROR);
    }
	
	my $url_key;
	
    eval {
		$url_key = $DBH->run( sub {
			return $_->selectrow_hashref( qq{
				SELECT ( MIN(UrlKey) + 1 ) AS f
				FROM (
					SELECT DISTINCT t0.UrlKey, t1.UrlKey AS number_plus_one
					FROM iCadUrlMap AS t0
					LEFT JOIN iCadUrlMap AS t1 ON ( t0.UrlKey + 1 ) = t1.UrlKey
				) AS temp1
				WHERE ISNULL( number_plus_one )
			} );										
		} )
    };

   	if ( my $ex = $@ ) 
   	{ 
   		&log("Database exception received during URL forward map processing " . $ex->error, E_CRIT);
   		return "Database exception received during URL forward map processing "; 
   	}   		
	
	&log("Returning next available URL map key [$url_key->{f}]");
	
	return $url_key->{'f'}	
}

sub SmsDeliveryStatus
{
	my $self = shift;
    my $params = shift;
 
 	&log("Test Message Requested\n");   
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

sub trim
{
    my $string = shift;
    if ( $string ) {
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
    }
}
1;