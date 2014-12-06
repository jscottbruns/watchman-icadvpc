#!/usr/bin/perl
use strict;
use warnings;

#
# iCAD Notification Service 
#

$| = 1;

BEGIN 
{

	use constant DAEMON		=> 'icad-notifier';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-notifier.log';
	use constant PID_FILE	=> '/var/run/icad-notifier.pid';
	use constant CONF_FILE	=> '/etc/icad.ini';
	use constant DEBUG_DIR	=> '/usr/local/watchman-icad/debug';

	use vars qw( %PIDS $log $CONTINUE $DEBUG $LICENSE $dbh $DB_ICAD $Config $DAEMON );

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
use File::Spec;
use File::Touch;
use File::Path;
use File::Temp qw/ tempfile /;
use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;
use Geo::GeoNames;
use REST::Client;
use MIME::Base64;
use URI::Escape;
use DateTime;
use HTML::Entities;
use SOAP::Lite;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;

make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
make_path( DEBUG_DIR, { mode => 0777 } ) if ( ! -d DEBUG_DIR ); # Create debug directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=>	'/',
	child_STDOUT	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	child_STDERR	=>	File::Spec->catfile( LOG_DIR, LOG_FILE . '.syslog' ),
	pid_file		=>	PID_FILE
} ) unless $0 =~ /$DAEMON\.pl$/;

if ( Proc::PID::File->running() )
{
	print STDERR "WatchmanAlerting iCAD Notifier is already running\n";
	die "WatchmanAlerting iCAD Notifier is already running";
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

my $ini;
&log("Reading system configuration file [ " . CONF_FILE . "]");

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

$DB_ICAD = $Config->{'db_link'}->{'db_icad'}->{'db_name'};
$CONTINUE = 1;

unless ( $DB_ICAD )
{
	&log("*ERROR* iCAD database name not defined - Fatal", E_CRIT);
	die "*ERROR* iCAD database name not defined - Fatal";
}

$DEBUG = $Config->{'debug'};
&log("Setting DEBUG flag => [$DEBUG]");

$LICENSE = $Config->{'license'};
&log("Setting license => [$LICENSE]");

$dbh = &main::init_dbConnection('db_icad');

eval {
	$dbh->run( sub {
		$_->do("SET time_zone='US/Eastern'");
	} );
};

&log("Loading regex formatting rules");

my $regex_ref = [];
my $regex_rules = {};

eval {
	$regex_ref = $dbh->run( sub {
		return $_->selectall_arrayref(
			qq{
				SELECT t1.SearchKey, t1.ReplaceKey, t1.Category
				FROM FormattingRules t1
			},
			{ Slice => {} }
		);
	} )
};

if ( my $ex = $@ )
{
	&log("Database exception received while fetching unit regexp table " . &ex( $ex ), E_ERROR);	
}

foreach my $_reg ( @$regex_ref )
{				
	$regex_rules->{ $_reg->{'Category'} } = [] unless defined @{ $regex_rules->{ $_reg->{'Category'} } };
	  			
	push @{ $regex_rules->{ $_reg->{Category} } }, {
		'search'	=> $_reg->{'SearchKey'},
		'replace'	=> $_reg->{'ReplaceKey'}
	};							
}

my ($sth, $pid, @__PIDS);

&log("Beginning icad-notifier main system block");

MAIN:
while ( $CONTINUE )
{

	my $IncRef;
	eval {
		$IncRef = $dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT 
						t1.EventNo, 
						t1.EventTime, 
						t1.EventType, 
						CASE WHEN COUNT( t2.EventNo ) > 0 THEN 
							1 ELSE -- Invoked by CARSCALL
							2	   -- Invoked by CALLEVENT
						END AS TriggerType
					FROM $DB_ICAD.NotifyIncidentQueue t1
					LEFT JOIN $DB_ICAD.Incident t2 ON t2.EventNo = t1.EventNo
					LEFT JOIN $DB_ICAD.CALLEVENT t3 ON t3.CallNo = t1.EventNo AND t3.EventTime = t1.EventTime
					GROUP BY t1.EventNo, t1.EventTime, t1.EventType
				},
				{ Slice => {} }
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received while preparing incident notification statement: " . &ex( $ex ), E_ERROR);
		sleep 3;

		next MAIN;
	}
	
	foreach my $_i ( @{ $IncRef } )
	{
		&log("New iCAD notification EventNo => [$_i->{EventNo}] EventTime => [$_i->{EventTime}] EventType => [$_i->{EventType}] TriggerType => [$_i->{TriggerType}]");

		my $NotifyId;
		eval {
			$NotifyId = $dbh->run( sub {
				$_->do( qq{
						DELETE FROM NotifyIncidentQueue 
						WHERE EventNo = ? AND EventTime = ? AND EventType = ?
					},
					undef,
					$_i->{'EventNo'},
					$_i->{'EventTime'},
					$_i->{'EventType'}
				);
								
				$_->do( qq{
						INSERT INTO NotifyIncident
						( EventNo, EventTime, EventType )
						VALUES ( ?, ?, ? )
					},
					undef,
					$_i->{'EventNo'},
					$_i->{'EventTime'},
					$_i->{'EventType'}
				);
				
				return $_->selectrow_hashref("SELECT LAST_INSERT_ID() AS NotifyId");
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[iCAD] Database exception received when setting notification [$_i->{EventNo}] transaction status flag for event type [$_i->{EventType}] - Can't initiate iCAD notifier " . &ex( $ex ), E_ERROR);
			next;
		}

		if ( $pid = fork ) # Parent process
		{
			push @__PIDS, $pid;
		}
		elsif ( defined $pid ) # Child process
		{			
			&icad_notify($dbh, $NotifyId->{'NotifyId'}, $_i->{'EventNo'}, $_i->{'EventTime'}, $_i->{'EventType'}, $_i->{'TriggerType'});
			exit 0;
		}
	}

	sleep 1;
}

sub init_dbConnection
{
	my $label = shift;

	my $dsn = "dbi:$Config->{db_link}->{$label}->{driver}:$Config->{db_link}->{$label}->{db_name};" .
	( $Config->{db_link}->{$label}->{'socket'} ?
		"socket=$Config->{db_link}->{$label}->{socket}" : "host=$Config->{db_link}->{$label}->{host};port=$Config->{db_link}->{$label}->{port}"
	);

	&log("Opening database connection to [ $dsn ]");

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			$dsn,
	        $Config->{db_link}->{$label}->{'user'},
	        $Config->{db_link}->{$label}->{'pass'},
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

	if ( $Config->{db_link}->{$label}->{'debug'} )
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

	return $conn;
}

sub END
{

}

sub icad_notify
{
	my ($_dbh, $NotifyId, $EventNo, $EventTime, $Type, $TriggerType) = @_;
	
	&log("Initiating iCAD Notification for Event => [$EventNo] Time => [$EventTime] Type => [$Type] TriggerTYpe => [$TriggerType]");
	
	&log("Fetching incident detail for Event => $EventNo") if $DEBUG;

	my $incref;
	eval {
		if ( $TriggerType == 1 )
		{
			$incref = $_dbh->run( sub {
				return $_->selectrow_hashref(
					qq{
						SELECT
							t1.*,
							DATE_FORMAT( FROM_UNIXTIME( t1.EntryTime ), '%Y-%m-%d %T') AS EntryTime,
							DATE_FORMAT( FROM_UNIXTIME( t1.CreatedTime ), '%Y-%m-%d %T') AS CreatedTime,
							IFNULL( DATE_FORMAT( FROM_UNIXTIME( t1.DispatchTime ), '%Y-%m-%d %T'), NULL) AS DispatchTime,
							IFNULL( DATE_FORMAT( FROM_UNIXTIME( t1.EnrouteTime ), '%Y-%m-%d %T'), NULL) AS EnrouteTime,
							IFNULL( DATE_FORMAT( FROM_UNIXTIME( t1.OnsceneTime ), '%Y-%m-%d %T'), NULL) AS OnsceneTime,
							IFNULL( DATE_FORMAT( FROM_UNIXTIME( t1.CloseTime ), '%Y-%m-%d %T'), NULL) AS CloseTime,
							t1.IncStatus AS Status,
							IFNULL( t1.CallType, t1.CallTypeOrig ) AS CallType,
							t4.CallGroup AS CallGroup,
							t1.Nature AS CallNature,
							IFNULL(t4.Label, t1.Nature) AS Nature,
							t4.Ignore,
							REPLACE(t1.BoxArea, CONCAT( IFNULL(t1.Agency, t1.CityCode), '-'), '') AS FormattedBox,
							REPLACE(t1.LocationDescr, CONCAT(', ', IFNULL( t1.CityCode, t1.Agency ) ), '') AS FormattedLocationDescr,
							REPLACE(t1.LocationAddress, CONCAT(', ', IFNULL( t1.CityCode, t1.Agency ) ), '') AS FormattedLocationAddress,						
							t3.Status AS Geo_Status,
							t3.CrossStreet1 AS CrossSt1,
							t3.CrossStreet2 AS CrossSt2,
							t1.MapGrid
						FROM $DB_ICAD.Incident t1					
						LEFT JOIN IncidentGeoInfo t3 ON t1.IncidentNo = t3.IncidentNo
						LEFT JOIN CallType t4 ON t1.CallType = t4.TypeCode			
						WHERE t1.EventNo = ?
						GROUP BY t1.EventNo
					},
					undef,
					$EventNo
				);
			} )
		}
		elsif ( $TriggerType == 2 )
		{
			$incref = $_dbh->run( sub {
				return $_->selectrow_hashref(
					qq{
						SELECT
							t1.*,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%d %T') AS EntryTime,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%d %T') AS CreatedTime,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%d %T') AS DispatchTime,
							'' AS EnrouteTime,
							'' AS OnsceneTime,
							'' AS CloseTime,
							CASE 
							WHEN COUNT( t2.UnitId ) > 0 THEN 
								1 
							WHEN COUNT( t2.UnitId ) = 0 THEN
								-1
							END AS Status,
							t1.Type AS CallType,
							t4.CallGroup AS CallGroup,
							t1.Nature AS CallNature,
							IFNULL(t4.Label, t1.Nature) AS Nature,
							t4.Ignore,
							IF( t1.Agency IS NOT NULL, REPLACE(t1.Box, CONCAT( t1.Agency, '-'), ''), t1.Box) AS FormattedBox,
							t1.Location AS FormattedLocationDescr,
							t1.LocationAddress AS FormattedLocationAddress,						
							t3.Status AS Geo_Status,
							'' AS CrossSt1,
							'' AS CrossSt2,							
							'' AS MapGrid
						FROM $DB_ICAD.CALLEVENT t1
						LEFT JOIN $DB_ICAD.CALLUNITEVENT t2 ON t1.CallNo = t2.CallNo AND t1.EventTime = t2.DispatchTime
						LEFT JOIN IncidentGeoInfo t3 ON t1.CallNo = t3.IncidentNo
						LEFT JOIN CallType t4 ON t1.Type = t4.TypeCode			
						WHERE t1.CallNo = ? AND t1.EventTime = ?
						GROUP BY t1.CallNo
					},
					undef,
					$EventNo,
					$EventTime
				);
			} )			
		}
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received during incident detail lookup - Unable to continue with iCAD notification " . &ex( $ex ), E_CRIT);
	}
	
	if ( $incref->{'Ignore'} )
	{
		&main::log("Incident type [$incref->{CallType}] flagged w/ignore, aborting notifications");
		return;	
	}
	
	if ( $TriggerType == 1 )
	{
	
		my $incref2;
		
		eval {			
			$incref2 = $_dbh->run( sub {
				return $_->selectrow_hashref(
					qq{
						SELECT EntryCrossStreets AS XStreets 
						FROM IncidentNotes
						WHERE EventNo = ? AND EntryCrossStreets IS NOT NULL
						GROUP BY EventNo
						ORDER BY EntrySequence DESC	
					},
					undef,
					$EventNo
				)
			} )				
		};
		
		if ( my $ex = $@ )
		{
			&log("Database exception received during incident mapgrid lookup " . &ex( $ex ), E_ERROR);
		}	
		
		$incref->{'CrossStreets'} = $incref2->{'XStreets'};
		
		if ( ! $incref->{'MapGrid'} )
		{	
			eval {			
				$incref2 = $_dbh->run( sub {
					return $_->selectrow_hashref(
						qq{
							SELECT EntryMapGrid AS MapGrid 
							FROM IncidentNotes
							WHERE EventNo = ? AND EntryMapGrid IS NOT NULL
							GROUP BY EventNo
							ORDER BY EntrySequence DESC
						},
						undef,
						$EventNo
					)
				} )				
			};
			
			if ( my $ex = $@ )
			{
				&log("[iCAD] Database exception received during incident mapgrid lookup " . &ex( $ex ), E_ERROR);
			}
			
			$incref->{'MapGrid'} = $incref2->{'MapGrid'};
		}
	}
		
	my ($message, $PriorFlag, $UnitArray, $unitref);
		
	if ( $Type == 1 )
	{
		&log("Fetching unit detail for Event => $EventNo") if $DEBUG;
	
		eval {
			if ( $TriggerType == 1 )
			{
				$unitref = $_dbh->run( sub {
					return $_->selectall_arrayref(
						qq{
							SELECT
								t1.Unit,
								REPLACE( t1.Unit, IFNULL(t2.Agency, ''), '' ) AS UnitFormatted
							FROM IncidentUnit t1
							LEFT JOIN Incident t2 ON t1.EventNo = t2.EventNo
							LEFT JOIN IncidentNotes t3 ON t1.EventNo = t3.EventNo AND t1.Unit = t3.EntryUnit AND t3.EntryType IN ('DISP', 'DISPER', 'DISPOS', 'XDISP', 'BACKER', 'BACKUP', 'BACKOS')
							WHERE t1.EventNo = ?
							ORDER BY t3.EntrySequence ASC
						},
						{ Slice => {} },
						$EventNo
					);
				} )
			}
			elsif ( $TriggerType == 2 )
			{
				$unitref = $_dbh->run( sub {
					return $_->selectall_arrayref(
						qq{
							SELECT
								t1.UnitId,
								IF(t2.Agency IS NOT NULL, REPLACE( t1.UnitId, IFNULL(t2.Agency, ''), '' ), t1.UnitId) AS UnitFormatted
							FROM CALLUNITEVENT t1
							LEFT JOIN CALLEVENT t2 ON t1.CallNo = t2.CallNo AND t1.DispatchTime = t2.EventTime
							WHERE t1.CallNo = ? AND t1.DispatchTime = ?
						},
						{ Slice => {} },
						$EventNo,
						$EventTime
					);
				} )				
			}
		};
			
		if ( my $ex = $@ )
		{
			&log("[iCAD] *ERROR* Database exception received during incident detail lookup - Unable to continue with iCAD notification " . &ex( $ex ), E_CRIT);
		}
		
		push @{ $UnitArray }, $_->{'Unit'} foreach ( @{ $unitref } );
	}

	my $IncidentNo = $incref->{'IncidentNo'};
	my $LocationDescr = $incref->{'LocationDescr'};
	my $Address = $incref->{'FormattedLocationAddress'} || $incref->{'LocationAddress'};
	my $LocationAddr = $Address;	
	my $LocationNote = $incref->{'LocationNote'};
	my $LocationApartment = $incref->{'LocationApartment'};
	
	if ( $incref->{'CrossStreets'} )
	{
		if ( $incref->{'CrossStreets'} =~ /^btwn\s(.*?)\sand\s(.*)$/ )
		{
			$LocationAddr .= " ($1 & $2)";
		}
		else
		{
			$LocationAddr .= " $incref->{CrossStreets}";
		}
	}
	elsif ( $incref->{'CrossSt1'} || $incref->{'CrossSt2'} )
	{ 
		$LocationAddr .= " ($incref->{CrossSt1} & $incref->{CrossSt2})" if $incref->{'CrossSt1'} && $incref->{'CrossSt2'};
		$LocationAddr .= " near $incref->{CrossSt1}" if $incref->{'CrossSt1'} && ! $incref->{'CrossSt2'};
		$LocationAddr .= " near $incref->{CrossSt2}" if ! $incref->{'CrossSt1'} && $incref->{'CrossSt2'};
	}

	my ($ActiveAlert, $ref);

    if ( $Type == 0 )
    {
    	&main::log("[$EventNo] Querying any previous pending notifications w/entry time [$EventTime]");
    	
		my $sth = $_dbh->run( sub {
			return $_->prepare( 
				qq{
			    	SELECT t1.NotifyId, t1.EventData 
					FROM NotifyIncident t1 
					WHERE t1.EventNo = ? AND t1.EventTime = ? AND t1.EventType = 0
					ORDER BY t1.NotifyId DESC
					LIMIT 1
				}					
			);
		} );
		
		eval {
			$ref = $sth->fetchrow_hashref if $sth->execute( $EventNo, $EventTime );
		};
    	
    	if ( my $ex = $@ )
    	{
    		&main::log("Database exception received during execution of previous pending incident notification - Unable to fetch previous notifications " . $ex->error, E_ERROR);
    	}
    	
    	$message = "** Pending ** [$incref->{BoxArea}] $incref->{Nature} $Address";
    	
    	if ( $ActiveAlert = $ref->{'NotifyId'} && $ref->{'EventData'} )
    	{     	
    		&main::log("Previous pending incident notifications sent against this incident, adjusting message"); 
    		
    		$message = "** Pending Update **";
    		my $PrevData = [ split '\n', $ref->{'EventData'} ]; # BOX_AREA||NATURE|LOCATION
    		
    		$message .= " [" . ( $PrevData->[0] ne $incref->{'BoxArea'} ? $PrevData->[0] . "=>" : undef ) . "$incref->{BoxArea}] ";
    		$message .= ( $PrevData->[1] ne $incref->{'CallNature'} ? $PrevData->[1] . "=>" : undef ) . "$incref->{CallNature} ";
    		$message .= ( $PrevData->[2] ne $Address ? $PrevData->[2] . "=>" : undef ) . "$Address "; 
    	}

		my $ActiveIncData = [ $incref->{'BoxArea'}, $incref->{'CallNature'}, $Address ];

		&main::log("Saving pending incident call data for future reference [" . join(':', @{ $ActiveIncData } ) . "]");

    	eval {
			$_dbh->run( sub {
				$_->do( 
					qq{
				    	UPDATE NotifyIncident
				    	SET EventData = ?
				    	WHERE NotifyId = ? 
					},
					undef,
					join('\n', @{ $ActiveIncData } ),
					$NotifyId
				);
			} )
    	};
    	
    	if ( my $ex = $@ )
    	{
    		&main::log("Database exception received during NotifyIncident table update - Unable to save pending call data for future pending call update reference " . $ex->error, E_ERROR);
    	}
    }
	elsif ( $Type == 1 )
	{
		$message = "[$incref->{BoxArea}] " if $incref->{'BoxArea'};
        $message .= "$incref->{Nature} $LocationAddr ";
        $message .= join ' ', @{ $UnitArray };
    }
    
    my ($smssth, $Prev_Recip, $Recipients); 
    my $TotalRecip = 0;    
    
    if ( $Type == 1 ) # Dispatched Incident
    {    	
    	&main::log("Looking up previous notifications for dispatched incident [$incref->{IncidentNo}]"); 
    	
    	my $prevsth;
    	eval {
			$prevsth = $_dbh->run( sub {
				return $_->prepare( qq{
					SELECT 
						t1.NotifyId,
						t2.MemberId
					FROM NotifyIncident t1
					RIGHT JOIN NotifyIncidentRecipients t2 ON t1.NotifyId = t2.NotifyId
					WHERE t1.EventNo = ? AND t1.EventType = ?
				} );					
			} )
    	};

    	if ( my $ex = $@ )
    	{
    		&main::log("Database exception received during prior SMS notification lookup - Unable to fetch previous notifications " . $ex->error, E_ERROR);
    	}
		
	    if ( $prevsth->execute( $EventNo, $Type ) )
	    {
	    	my $prev_i = 0;
	    	while ( my $ref = $prevsth->fetchrow_hashref )
	    	{
	    		$prev_i++;
	    		$Prev_Recip->{ $ref->{'MemberId'} } = $ref->{'NotifyId'};
	    	}	    
	    	
	    	&main::log("Found [$prev_i] previous notifications for this incident"); 		    	
		}
		else
		{
			&main::log("Database execute exception caught when attempting to query previous notifications against this incident $DBI::errstr", E_ERROR);
		}
		
		$smssth = $_dbh->run( sub {
			return $_->prepare( qq{
				SELECT 
					t2.ObjId AS MemberId,
					t2.NotifyMethod,
					t2.NotifyAddr,
					t2.NotifySchedule
				FROM NotifyMemberRules t1
				LEFT JOIN NotifyMember t2 ON t1.MemberObjId = t2.ObjId
				WHERE 
				(
					(
						? REGEXP t1.NotifyArea 
						AND 
						( 
							CONCAT('type:', ?) REGEXP t1.NotifyRuleset OR CONCAT('group:', ?) REGEXP t1.NotifyRuleset
						)
					)
					OR ? REGEXP t1.NotifyUnits
				)
				AND t1.NotifyOnDispatch = 1 AND t2.Inactive = 0
				GROUP BY t2.ObjId
			});
		} );
    }
    elsif ( $Type == 0 )
    {
    	if ( $ActiveAlert )
    	{
    		&main::log("Previous pending notifications exist, loading previous recipient list for pending updates");
    		
	    	my $sth;    	
	    	eval {
				$sth = $_dbh->run( sub {
					return $_->prepare( 
						qq{
					    	SELECT 
								t2.ObjId AS MemberId,
								t2.NotifyMethod,
								t2.NotifyAddr,
								t2.NotifySchedule				    	 
							FROM NotifyIncidentRecipients t1
							LEFT JOIN  NotifyMember t2 ON t1.ObjId = t2.MemberId 
							WHERE t1.NotifyId = ? 
						}					
					);
				} )
	    	};
	    	
	    	if ( my $ex = $@ )
	    	{
	    		&main::log("Database exception received during statement preparation of previous pending incident notification - Unable to fetch previous notifications " . $ex->error, E_ERROR);
	    	}
	    	
	    	if ( $sth->execute( $ActiveAlert ) )
	    	{
				while ( my $ref = $sth->fetchrow_hashref )
				{		
					$TotalRecip++;
					push @{ $Recipients }, {
						'MemberId'		=> $ref->{'MemberId'},
						'NotifyAddr'	=> $ref->{'NotifyAddr'},
						'NotifyMethod'	=> $ref->{'NotifyMethod'}
					};
					
					$Prev_Recip->{ $ref->{'MemberId'} } = $ActiveAlert;
				}
	    	}
	    	
	    	if ( my $ex = $@ )
	    	{
	    		&main::log("Database exception received during execution of previous pending incident notification - Unable to fetch previous notifications " . $ex->error, E_ERROR);
	    	}
    	}    	    	
    	
		$smssth = $_dbh->run( sub {
			return $_->prepare( qq{
				SELECT 
					t2.ObjId AS MemberId,
					t2.NotifyMethod,
					t2.NotifyAddr,
					t2.NotifySchedule
				FROM NotifyMemberRules t1
				LEFT JOIN NotifyMember t2 ON t1.MemberObjId = t2.ObjId
				WHERE 
				(
					? REGEXP t1.NotifyArea 
					AND 
					( 
						CONCAT('type:', ?) REGEXP t1.NotifyRuleset OR CONCAT('group:', ?) REGEXP t1.NotifyRuleset
					)
				)
				AND t1.NotifyOnActive = 1 AND t2.Inactive = 0
				GROUP BY t2.ObjId
			});
		} );
    }       
    
    &main::log("Loading recipient list"); 

	eval {
		$smssth->execute( $incref->{'BoxArea'}, $incref->{'CallType'}, $incref->{'CallGroup'}, join ' ', @{ $UnitArray } ) if $Type == 1;
		$smssth->execute( $incref->{'BoxArea'}, $incref->{'CallType'}, $incref->{'CallGroup'} ) if $Type == 0;
	};
	
	if ( my $ex = $@ )
    {
    	&main::log("Database exception received during execution of SMS recipient lookup - Unable to proceed with notifications " . $ex->error, E_CRIT);
    	return undef;
    }

	while ( my $smsref = $smssth->fetchrow_hashref )
	{
		if ( $Type == 0 || ( $Type == 1 && ! $Prev_Recip->{ $smsref->{'MemberId'} } ) ) # TODO: Add scheduling mechanism here
		{				
			$TotalRecip++;
			push @{ $Recipients }, {
				'MemberId'		=> $smsref->{'MemberId'},
				'NotifyAddr'	=> $smsref->{'NotifyAddr'},
				'NotifyMethod'	=> $smsref->{'NotifyMethod'}
			};
		}
	}

	unless ( $TotalRecip > 0 )
	{
		&main::log("Recipient list empty, notifications not required for this event");
		return;			
	}

	&main::log("Creating URL mapping for SMS assets - Requesting URL key for geomapping asset");	
	
    if ( 
    	my $s = SOAP::Lite
    		->uri( '/iCAD_Services' )
    		->proxy( 'http://services.fhwm.net:8090' )
			->on_fault
			(
				sub
				{
					my ($soap, $res) = @_;
					&main::log("Errors connecting to iCAD services proxy server - " . ( ref $res ? $res->faultstring : $soap->transport->status ) . " - URL mapping request failed", E_CRIT);
				}
			)    		 
    )
    {
    	eval {
	        if ( my $urlkey = $s->NextUrlKey->result )
	        {
	        	my $ShortUri = "http://fhwm.net/g/$urlkey";
	        	my $LongUri = "https://maps.google.com/maps?z=16&t=m&q=$incref->{GPSLongitude}+$incref->{GPSLatitude}";
	        	
	        	if ( my $res = $s->NewUrlMap( {
	        		'UrlKey'		=> $urlkey,
	        		'Url'			=> $ShortUri,
	        		'ForwardUrl'	=> $LongUri
	        	} ) == 1 )
	        	{
	        		&main::log("Geomapping URL key assigned => [$urlkey]");
	        		$message .= " http://fhwm.net/g/$urlkey";
	        	}
	        }
	        
	        if ( my $urlkey = $s->NextUrlKey->result )
	        {
	        	my $ShortUri = "http://fhwm.net/c/$urlkey";
	        	my $LongUri = "http://icad.pittsburghpa.fhwm.net:8080/detail/$incref->{EventNo}";
	        	
	        	if ( my $res = $s->NewUrlMap( {
	        		'UrlKey'		=> $urlkey,
	        		'Url'			=> $ShortUri,
	        		'ForwardUrl'	=> $LongUri
	        	} ) == 1 )
	        	{
	        		&main::log("iCAD Detail URL key assigned => [$urlkey]");
	        		$message .= " http://fhwm.net/c/$urlkey";
	        	}
	        }
    	};
    	
    	if ( $@ )
    	{
    		&main::log("SOAP request error $@", E_ERROR);	
    	}
    }

	my ($smtp_sth, $smtp_list, $sms_list, $wctp_list, $email_list);
	
	eval {
		$smtp_sth = $_dbh->run( sub {
			return $_->prepare( qq{
				INSERT INTO NotifyIncidentRecipients
				( NotifyId, MemberId )
				VALUES ( ?, ? )
			} );
		} )
	};		
	
	if ( my $ex = $@ ) { &main::log("Database exception received during URL forward map statement prepare " . $ex->error, E_ERROR); }	
	
	foreach my $_i ( @{ $Recipients } )
	{
	    $smtp_sth->execute( $NotifyId, $_i->{'MemberId'} ) or &main::log("Database execute error $@", E_ERROR);
	    	    
	    push @{ $sms_list }, $_i->{'NotifyAddr'} if $_i->{'NotifyMethod'} eq 'SMS';
	    push @{ $email_list }, $_i->{'NotifyAddr'} if $_i->{'NotifyMethod'} eq 'EMAIL';
	    push @{ $wctp_list }, {
	    	'PhoneNo'	=> $_i->{'NotifyAddr'},
	    	'WctpHost'	=> $_i->{'NotifyMethodCarrier'}
	    } if $_i->{'NotifyMethod'} eq 'WCTPSMS';
	    
	    push @{ $smtp_list }, {
	    	'PhoneNo'	=> $_i->{'NotifyAddr'},
	    	'Gateway'	=> $_i->{'NotifyMethodCarrier'}	
	    } if $_i->{'NotifyMethod'} eq 'SMTPSMS';	    	    
	}		
	
	&SendSmtpSms($_dbh, $IncidentNo, $smtp_list, $message) if @{ $smtp_list }; # TODO: Group SMTP/SMS recipients by carrier gateway	
	&SendPlivoSms($_dbh, $IncidentNo, $sms_list, $message) if @{ $sms_list };
	&SendEmail($_dbh, $IncidentNo, $email_list, $message) if @{ $email_list };
	&SendWctpSms($_dbh, $IncidentNo, $wctp_list, $message) if @{ $wctp_list }; # TODO: Group WCTP recipients by host
	        	
    eval {
    	$_dbh->run( sub {
    		$_->do( 
    			qq{
	    			UPDATE NotifyIncident 
		    		SET Status = ?, SendTime = NOW()
		    		WHERE NotifyId = ?
	    		},
	    		undef,
	    		$?,
	    		$NotifyId
    		)
    	} )    
    };
    	
    return;
}

sub sendEmailSms
{
	my ($_dbh, $IncidentNo, $recips, $message) = @_;
	
	&main::log("Initiating Email Message Delivery");

	my $recip_to = 'i@fhwm.net';	
	my $recip_bcc = join ',', @{ $recips };      

	$message = &rtrim( $message );
		
	&main::log("[$IncidentNo] Submitting Email message for delivery: [$message]");

    my $res = `echo "$_" | /opt/aws/bin/ses-send-email.pl -k /home/ec2-user/.ssh/aws-credential-file -b "Watchman Incident Notification [$IncidentNo]" -b $recip_bcc -f $recip_to $recip_to`;
    	
    &main::log("Email Delivery Result ($?) $res");

	return;
}

sub SendSmtpSms
{
	my ($_dbh, $IncidentNo, $recips, $message) = @_;
	
	&main::log("Initiating SMTP/SMS Message Delivery");

	my $recip_to = 'i@fhwm.net';	
	my $recip_bcc = join ',', @{ $recips };      
	
	my $msg_exec = &SplitMsg( $message, 146 );	
	
	my $i = 1;
	
	MSG_LOOP:
	foreach ( @{ $msg_exec } )
	{
		$_ = &rtrim( $_ );
		
	    &main::log("[$IncidentNo] Submitting SMTP/SMS message (" . $i++ . " of " . scalar @{ $msg_exec } . ") for delivery: [$_]");
    
    	my $res = `echo "$_" | /opt/aws/bin/ses-send-email.pl -k /home/ec2-user/.ssh/aws-credential-file -b $recip_bcc -f $recip_to $recip_to`;
    	
    	&main::log("SMTP Delivery Result ($?) $res");
    	last MSG_LOOP unless $? == 0;
	}        	
	
	return;
}

sub SplitMsg
{
	my ($msg, $max) = @_;
	
	&main::log("Formatting message for max length [$max]");
		
	return [ $msg ] if ( length( $msg ) <= $max );
	
	my @str = split ' ', $msg;
	my $t = [];
	my $i = 0;
	
	foreach ( @str )
	{
		$i++ if ( length( $t->[ $i ] ) + length( "$_ " ) > $max );
		$t->[ $i ] .= "$_ ";
	}
	
	return $t;
}

sub PlivoSendSms
{
	my ($_dbh, $IncidentNo, $recips, $message) = @_;
	
	&main::log("Initiating Plivo SMS API");		
	
	my $uri = 'https://MAMTI0YZCZOGM3YWQ2MZ:MDNlYWFiM2FiNmM4NTNhMzJiNjcxOGNmNWEwMTJh@api.plivo.com/v1/Account/MAMTI0YZCZOGM3YWQ2MZ/Message/';
	my $msg_exec = &SplitMsg( $message, 160 );
	
	my $lvn_pool = [];
	
	eval {
		$lvn_pool = $_dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT Number
					FROM SmsNumberPool
					WHERE Provider = 'plivo' AND Inactive = 0
				}
			);
		} )
	};		
	
	if ( my $ex = $@ ) 
	{ 
		&main::log("Database exception received during LVN pool lookup - Can't continue with plivo SMS delivery " . $ex->error, E_CRIT);
		return undef; 
	}	
	
	my $total_lvn = scalar @{ $lvn_pool };
	my $total_dst = scalar @{ $recips };
	my($groups, $k, $j, $i, $args);
	my $lvn_groups = [];	
	
	unless ( $total_lvn > 0 )
	{
		&main::log("No available SMS source numbers found in LVN Number pool. Can't continue with plivo SMS delivery", E_CRIT);
		return undef; 	
	}	
	
	foreach ( @{ $lvn_pool } )
	{
	    push @{ $lvn_groups },
	        {
	            'lvn'   => $_->[0],
	            'dst'   => []
	        };
	}
	
	$groups = ceil( $total_dst / $total_lvn );
	$groups = 1 if $groups < 1;

	&main::log("Preparing message for delivery across " . scalar @{ $lvn_pool } . " LVN numbers");

	$i = $k = $j = 0;
	
	foreach my $_recip ( @{ $recips } )
	{
	    $j++;
	    push @{ $lvn_groups->[ $k ]->{'dst'} }, $_recip;
	
	    if ( $j >= $groups )
	    {
	        $j = 0;
	        $k++;
	    }
	}		
	
	my $ua = LWP::UserAgent->new;
	my ($request, $response, $result);	
	
	LVN_LOOP:
	foreach my $_lvn ( @{ $lvn_groups } )
	{		
		MSG_LOOP:
		foreach my $_msg ( @{ $msg_exec } )
		{
			$_msg = &rtrim( $_msg );
			
		    &main::log("[$IncidentNo] Submitting Plivo SMS message (" . $i++ . " of " . scalar @{ $msg_exec } . ") for delivery to [" . scalar( @{ $_lvn->{'dst'} } ) . "] recipients via LVN [$_lvn->{lvn}]: [$_msg]");
	    
			$args = {
				'src'	=> $_lvn->{'lvn'},
				'dst'	=> join '<', @{ $_lvn->{'dst'} },
				'text'	=> $_msg,
				'type'	=> 'sms',
				'url'	=> 'http://services.fhwm.net/sms/63ac4f25'
			};
	    	
			$request = HTTP::Request->new( POST => $uri );
			$request->content_type( 'application/json' );
			$request->content( to_json( $args ) );
			
			$response = $ua->request( $request );		
			$result = from_json( $response->content );
			
			sleep 1;    	
		}     
	}
	
	return;
}

sub NexmoSendSms
{
	my ($_dbh, $IncidentNo, $recips, $message) = @_;		
	
	&main::log("Initiating Nexmo SMS API");
	
	my $uri = 'http://rest.nexmo.com/sms/json';		
	my $lvn_pool = [];
	
	eval {
		$lvn_pool = $_dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT Number
					FROM SmsNumberPool
					WHERE Provider = 'nexmo' AND Inactive = 0
				}
			);
		} )
	};		
	
	if ( my $ex = $@ ) 
	{ 
		&main::log("Database exception received during LVN pool lookup - Can't continue with nexmo SMS delivery " . $ex->error, E_CRIT);
		return undef; 
	}	
	
	my $total_lvn = scalar @{ $lvn_pool };
	my $total_dst = scalar @{ $recips };
	my($groups, $k, $j, $i, $args);
	my $lvn_groups = [];	
	
	unless ( $total_lvn > 0 )
	{
		&main::log("No available SMS source numbers found in LVN Number pool. Can't continue with nexmo SMS delivery", E_CRIT);
		return undef; 	
	}	
	
	foreach ( @{ $lvn_pool } )
	{
	    push @{ $lvn_groups },
	        {
	            'lvn'   => $_->[0],
	            'dst'   => []
	        };
	}
	
	$groups = ceil( $total_dst / $total_lvn );
	$groups = 1 if $groups < 1;

	&main::log("Preparing message for delivery across " . scalar @{ $lvn_pool } . " LVN numbers");

	$i = $k = $j = 0;
	
	foreach my $_recip ( @{ $recips } )
	{
	    $j++;
	    push @{ $lvn_groups->[ $k ]->{'dst'} }, $_recip;
	
	    if ( $j >= $groups )
	    {
	        $j = 0;
	        $k++;
	    }
	}	
	
	$args = {
		'api_key'			=> '07243b69',
		'api_secret'		=> 'a0018d9b',
		'from'				=> undef,
		'to'				=> undef,
		'text'				=> &rtrim( $message ),
		'status-report-req'	=> 1,
		'client-ref'		=> $IncidentNo || undef	
	};
	
	my $ua = LWP::UserAgent->new;
	my ($request, $response, $result);	
	
	LVN_LOOP:
	foreach my $_lvn ( @{ $lvn_groups } )
	{		
		&main::log("[$IncidentNo] Preparing Nexmo SMS message for individual message delivery to [" . scalar( @{ $_lvn->{'dst'} } ) . "] recipients via LVN [$_lvn->{lvn}]: [$message]");
	    
	    $args->{'from'} = $_lvn->{'lvn'};
	    
	    RECIP_LOOP:
	    foreach my $_recip ( @{ $_lvn->{'dst'} } )
	    {	   		 
			$args->{'to'} 	= $_recip;		
	    	
			$request = HTTP::Request->new( POST => $uri );
			$request->content_type( 'application/json' );
			$request->content( to_json( $args ) );
				
			$response = $ua->request( $request );		
			$result = from_json( $response->content );  
	    }
	}		
	
	return;
	#{
	#	'message_id'	=> $result->{'message_id'},
	#	'status'		=> $result->{'status'}
	#};	
}

sub WctpSendSms
{
    my ($_dbh, $IncidentNo, $recips, $message, $wctp_host) = @_;

    &main::log("Initiating WCTP delivery service to gateway [$wctp_host] ");

	my $proto = 'http';
	my ($uri, $user, $pass);
	
	if ( $wctp_host =~ /^(http(?:s)?):\/\/(?:{(.*)?:(.*)?})@(.*)$/ )
	{
		$proto = $1;
		$uri = $4;
		$user = $2;
		$pass = $3;			
	}
	
	unless ( $uri )
	{
		&main::log("WCTP params missing host URI", E_CRIT);
		return undef;
	}
	
	my $host = $proto . "://" . $uri;
    my $gmt_time = POSIX::strftime("%Y-%m-%dT%H:%M:%S", gmtime);

    my $ua = LWP::UserAgent->new(
        'timeout'   =>      25
    );

    &main::log("Initiating HTTP request to [$host] ");

    my $request;
    unless (
        $request = HTTP::Request->new(
            POST    =>  $host,
            HTTP::Headers->new(
                'Content-Type'  =>  'text/xml'
            )
        )
    ) {
		&main::log("Error initiating HTTP request", E_CRIT);
        return undef;
    }

	my $recip_xml;
    my $msg_id = $IncidentNo || undef;
    my $wctp_user = $user || undef;
    my $wctp_pass = $pass || undef;

	$msg_id = "messageID=\"$msg_id\"" if $msg_id;
	$wctp_user = "senderID=\"$wctp_user\"" if $wctp_user;
	$wctp_pass = "securityCode=\"$wctp_pass\"" if $wctp_pass;
    
    $recip_xml .= "<wctp-Recipient recipientID=\"$_\" />\n" foreach ( @{ $recips } );

    $message = HTML::Entities::encode_entities( $message );

    my $xml = <<XML;
<?xml version="1.0" ?>
<!DOCTYPE wctp-Operation SYSTEM "http://dtd.wctp.org/wctp-dtd-v1r1.dtd">
<wctp-Operation wctpVersion="wctp-dtd-v1r3">
    <wctp-SendMsgMulti>
        <wctp-MsgMultiHeader submitTimestamp="$gmt_time">
            <wctp-Originator $wctp_user $wctp_pass />
            <wctp-MsgMultiControl $msg_id allRecipsRequired="false" />
            $recip_xml
        </wctp-MsgMultiHeader>
        <wctp-Payload>
            <wctp-Alphanumeric>$message</wctp-Alphanumeric>
        </wctp-Payload>
    </wctp-SendMsgMulti>
</wctp-Operation>
XML

    $request->content( $xml );
    my $response = $ua->request( $request );

	&main::log("WCTP Request (" . $response->status_line . ")");

    if ( $response->status_line eq '200 OK' ) 
    {       
        my $content = $response->content;
        if ( $content =~ m/<!DOCTYPE/ ) 
        {
            $content =~ s/(<!DOCTYPE .*?>)//;
        }

        my $xp = XML::XPath->new(
            'xml'   =>  $content
        );

        my ($resp_code, $resp_text, $result, $valid);
        my $failed_rcp = [];

		if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure") || $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success") ) {

		    $valid = 1;
		    if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure") ) {

		        undef $result;
		        $resp_code = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure/\@errorCode");
		        $resp_text = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure/\@errorText");

		    } else {

		        $result = 1;
		        $resp_code = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success/\@successCode");
		        $resp_text = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success/\@successText");

		    }

		    if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-FailedRecipient") ) {

		        $result = -1 if ( defined $result );

		        my $nodeset = $xp->findnodes("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-FailedRecipient");
		        foreach my $node ( $nodeset->get_nodelist ) {

		            push( @{ $failed_rcp }, {
		                'recipient'     =>      $node->getAttribute('recipientID'),
		                'errCode'       =>      $node->getAttribute('errorCode'),
		                'errText'       =>      $node->getAttribute('errorText')
		            } );
		        }
		    }
		}

		if ( $valid ) 
		{
            return ( defined $result ? 1 : undef );
		}

    } 
    
    return;
}

sub indexArray
{
    1 while $_[0] ne pop;
    @_-1;
}


sub formatTextString
{
	my $string = shift;
	my $category = shift;
	
	$string = &trim( $string );	
	return unless $string;
	
	&log("Applying formatting rules to string [$string] against category [$category]");
	
	foreach my $_reg ( @{ $regex_rules->{ $category } } )
	{	
		my $regex_s = qr/$_reg->{search}/;						
		if ( $string =~ m/$regex_s/ )
		{			
			my $regex_r = eval $_reg->{replace};
			$string =~ s/$regex_s/$regex_r->()/ei;
		}
	}						

	return $string;
}

sub gpsDecToDeg
{
	my $dec = shift;

	return (0, 0, 0) unless ( $dec );

	my ($degree, $fraction, $minute, $second);

	if ( $dec =~ /^(\d{0,})\.(\d*)$/ )
	{
		$degree = $1;
		$fraction = $2;
	}

	$dec = ( ( $dec - $degree ) * 60 );
	$minute = $1 if ( $dec =~ /^(\d{0,})\.(\d*)$/ );
	$second = ( ( $dec - $minute ) * 60 );

	return ($degree, $minute, sprintf('%.6f', $second));
}

sub log
{
    my $msg = shift;
    my $level = shift;
    my ($package, $file, $line) = caller;

	$level = E_INFO if ! $level;

    $msg = "[icad-notifier:$line] $msg ($$)";

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

sub ex
{
    my $ex = shift;
    my $err = $ex->error;
    my $state = $ex->state;
    
    $err =~ s/\n//g;
    $err =~ s/\s{3,}/ /g;
    
    return ( $ex->can('error') ? "($state) $err" : $ex );
}



















