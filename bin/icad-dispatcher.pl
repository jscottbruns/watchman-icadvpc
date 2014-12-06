#!/usr/bin/perl
use strict;
use warnings;

#
# iCAD Dispatcher Service
#

$| = 1;

BEGIN
{

	use constant DAEMON		=> 'icad-dispatcher';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-dispatcher.log';
	use constant PID_FILE	=> '/var/run/icad-dispatcher.pid';
	use constant CONF_FILE	=> '/etc/icad.ini';
	use constant DEBUG_DIR	=> '/usr/local/watchman-icad/debug';

	use vars qw( %PIDS $log $CONTINUE $DEBUG $LICENSE $dbh $DB_ICAD $Config $DAEMON $SQS );

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
use XML::Generator;
use IO::Socket qw(:DEFAULT :crlf);
use Geo::GeoNames;
use REST::Client;
use MIME::Base64;
use URI::Escape;
use DateTime;
use HTML::Entities;
use Amazon::SQS::Simple;
use JSON;
use Digest::MD5 qw( md5_hex );
use Try::Tiny;

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
	print STDERR "WatchmanAlerting iCAD Dispatcher is already running\n";
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

$SIG{CHLD} = sub {
	local ($!, $?);

	my $pid = waitpid(-1, WNOHANG);
	return if $pid == -1;
	return unless defined $PIDS{$pid};
	delete $PIDS{$pid};

	&log("Child process [$pid] ended with exit code $?");
};

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


my $ns = {
    ns1	=> [ ns1 => "http://niem.gov/niem/structures/2.0" ],
    ns2 => [ ns2 => "http://niem.gov/niem/domains/emergencyManagement/2.0" ],
    ns3 => [ ns3 => "http://niem.gov/niem/niem-core/2.0" ],
	ns4 => [ ns4 => "http://fhwm.net/xsd/ICadDispatch" ],
	ns6 => [ ns6 => "http://niem.gov/niem/domains/jxdm/4.0" ],
	ns7 => [ ns7 => "http://niem.gov/niem/ansi-nist/2.0" ]
};

unless ( defined $Config->{'icad'}->{'dispatcher'}->{'SQS_Uri'} )
{
	&main::log("Error initiating SQS queue - Invalid URI endpoint for dispatcher queue", E_CRIT);
	die "Error initiating SQS queue - Invalid URI endpoint for dispatcher queue";
}

&main::log("Initiating SQS dispatcher queue => [$Config->{icad}->{'dispatcher'}->{SQS_Uri}]");

unless ( $SQS = new Amazon::SQS::Simple($Config->{'icad'}->{'dispatcher'}->{'SQS_AccessKey'}, $Config->{'icad'}->{'dispatcher'}->{'SQS_SecretKey'})->GetQueue( $Config->{'icad'}->{'dispatcher'}->{'SQS_Uri'} ) )
{
	&main::log("SQS Connection Error - Can't initiate SQS dispatcher queue $@ $!", E_CRIT);
	die "SQS Connection Error - Can't initiate SQS dispatcher queue";
}

my ($sth, $pid, @__PIDS);

my $lookup_sth = {};

&log("Beginning icad-dispatcher main system block");

MAIN:
while ( $CONTINUE )
{
	if ( my $msg = $SQS->ReceiveMessage )
	{
		my $SQS_Message = {
			MessageId		=> $msg->MessageId(),
			ReceiptHandle	=> $msg->ReceiptHandle(),
			MessageBody		=> $msg->MessageBody()
		};

		unless ( md5_hex( $msg->MessageBody() ) eq $msg->MD5OfBody() )
		{
			&main::log("Failed to validate MD5 message payload - SQS_MD5 => [" . $SQS_Message->{'MD5OfBody'} . "] LOCAL_MD5 => [" . md5_hex( $SQS_Message->{'MessageBody'} ) . "]", E_CRIT);
		}

		eval
		{
			$SQS_Message->{'Payload'} = JSON->new->utf8(1)->decode( $msg->MessageBody() );
		};

		if ( $@ )
		{
			&main::log("MsgId: [$SQS_Message->{MessageId}] Error decoding SQS JSON payload - $@", E_CRIT);

			$SQS->DeleteMessage( $SQS_Message->{'ReceiptHandle'} );
			next;
		}

		if ( ! ( fork ) )
		{
			&main::log("Preparing SQS message for dispatch processing [$SQS_Message->{MessageId}]");

			my $_dbh = &ini_dbConnection( $SQS_Message->{'Payload'}->{'EventDB'} );

			my $_sth = &prepare_sth(
				$_dbh,
				qq{
					SELECT t1.Station
					FROM StationUnit t1
					RIGHT JOIN Station t2 ON t1.Station = t2.Station AND t2.Inactive = 0
					WHERE t1.UnitId = ? AND t1.Inactive = 0
				}
			);

			unless ( $_sth )
			{
				&main::log("Error preparing unit lookup statement - Can't continue with iCAD dispatcher processing", E_CRIT);
				next;
			}

			my $DispList = {};

			foreach my $_u ( @{ $SQS_Message->{'Payload'}->{'EventRef'} } )
			{
				try {
					$_sth->execute($_u->{'UnitId'});
				} catch {
					&main::log("Error inserting dispatch unit: EventNo => [$SQS_Message->{Payload}->{EventNo}] UnitId => [$_u->{UnitId}] DispTime => [$_u->{EventTime}] " . &ex($_), E_CRIT);
				};

				if ( my $_unit = $_sth->fetchrow_hashref )
				{
					$DispList->{ $_unit->{'Station'} } = $_u->{'EventTime'};
				}
			}

			foreach my $_i ( keys %{ $DispList } )
			{
				&log("Pending iCAD dispatch Src => [$SQS_Message->{Payload}->{EventSrc} ] EventNo => [$SQS_Message->{Payload}->{EventNo}] Station => [$_i] Dispatch => [$DispList->{ $_i }]");

				eval {

					if ( $SQS_Message->{'Payload'}->{'EventSrc'} eq 'controller' )
					{
						$dbh->run( sub {
							$_->do(
								qq{
									UPDATE IncidentUnit t1
									RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
									SET t1.AlertTrans = -2
									WHERE t1.EventNo = ? AND t1.Dispatch = ? AND t2.Station = ?
								},
								undef,
								$SQS_Message->{'Payload'}->{'EventNo'},
								$DispList->{ $_i },
								$_i
							);
						} )
					}
					elsif ( $SQS_Message->{'Payload'}->{'EventSrc'} eq 'listener' )
					{
						$dbh->run( sub {
							$_->do(
								qq{
									UPDATE CALLUNITEVENT t1
									RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.UnitId
									SET t1.AlertTrans = -2
									WHERE t1.EventNo = ? AND t1.DispatchTime = FROM_UNIXTIME(?) AND t2.Station = ?
								},
								undef,
								$SQS_Message->{'Payload'}->{'EventNo'},
								$DispList->{ $_i },
								$_i
							);
						} )
					}
				};

				if ( my $ex = $@ )
				{
					&log("[iCAD] Database exception received during incident alert transaction update Type => [$_i->{Type}] IncNo => [$_i->{IncidentNo}] Station => [$_i->{Station}] units - Can't initiate iCAD dispatch for station [$_i->{Station}] units " . &ex( $ex ), E_ERROR);
					next;
				}

				&dispatch(
					$_dbh,
					{
						Type		=> $_i->{'Type'},
						EventNo		=> $_i->{'EventNo'},
						IncNo		=> $_i->{'IncidentNo'},
						Station		=> $_i->{'Station'},
						EventTime	=> $_i->{'DispatchTime'}
					}
				);
					exit 0;
				}
			}


			&dispatch(
				$_dbh,
				{
					Type		=> $_i->{'Type'},
					EventNo		=> $SQS_Message->{'Payload'}->{'EventNo'},
					IncNo		=> $_i->{'IncidentNo'},
					Station		=> $_i->{'Station'},
					EventTime	=> $_i->{'DispatchTime'}
				}
			);

			exit 0;
		}
	}



	foreach my $_i ( @{ $IncRef } )
	{

	}

	sleep 1;
}

sub init_dbConnection
{
	my $label = shift;

	my $dsn = "dbi:$Config->{db_link}->{$label}->{driver}:$Config->{db_link}->{$label}->{db_name};$Config->{db_link}->{$label}->{host};$Config->{db_link}->{$label}->{port}";

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

sub dispatch
{
	my ($_dbh, $Params) = @_;

	my $Type = $Params->{'Type'};
	my $EventNo = $Params->{'EventNo'};
	my $Station = $Params->{'Station'};
	my $DispatchTime = $Params->{'EventTime'};
	my $IncidentNo = $Params->{'IncNo'};

	my ($prim_ip, $prim_port, $sec_ip, $sec_port, $dispatch_time);
	my $Timestamp = POSIX::strftime("%Y-%m-%dT%H:%M:%S", localtime);

	my $xml = XML::Generator->new;

	&log("[$EventNo] Initiating iCAD Dispatch for Type => [$Type] IncNo => [$IncidentNo] Station => [$Station] EventTime => [$DispatchTime] ");

	my $AlertId;
	eval {
		$AlertId = $_dbh->run( sub {
			$_->do(
				qq{
					INSERT INTO AlertTrans
					( EventNo, Station, AlertTime, Status )
					VALUES ( ?, ?, ?, '-2' )
				},
				undef,
				$EventNo,
				$IncidentNo,
				$Station,
				$Timestamp
			);
			return $_->{mysql_insertid};
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . &ex( $ex ), E_ERROR);
		return undef;
	}

	&main::log("[$EventNo] Setting alert transaction [$AlertId] for station [$Station] dispatch units");

	eval {

		if ( $Type == 1 )
		{
			$dbh->run( sub {
				$_->do(
					qq{
						UPDATE IncidentUnit t1
						RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
						SET t1.AlertTrans = ?
						WHERE t1.EventNo = ? AND t1.AlertTrans = -2 AND t2.Station = ?
					},
					undef,
					$AlertId,
					$EventNo,
					$Station
				);
			} )
		}
		elsif ( $Type == 2 )
		{
			$dbh->run( sub {
				$_->do(
					qq{
						UPDATE CALLUNITEVENT t1
						RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.UnitId
						SET t1.AlertTrans = ?
						WHERE t1.CallNo = ? AND t1.DispatchTime = FROM_UNIXTIME(?) AND t1.AlertTrans = -2 AND t2.Station = ?
					},
					undef,
					$AlertId,
					$IncidentNo,
					$DispatchTime,
					$Station
				);
			} )
		}
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . &ex( $ex ), E_ERROR);
		return undef;
	}

	&log("[$EventNo] Fetching incident data") if $DEBUG;

	my $incref;
	eval {
		if ( $Type == 1 )
		{
			$incref = $_dbh->run( sub {
				return $_->selectrow_hashref(
					qq{
						SELECT
							t1.IncidentNo,
							t1.ReportNo,
							DATE_FORMAT( FROM_UNIXTIME( t1.EntryTime ), '%Y-%m-%dT%T') AS EntryTime,
							DATE_FORMAT( FROM_UNIXTIME( t1.CreatedTime ), '%Y-%m-%dT%T') AS CreatedTime,
							IF(t1.DispatchTime IS NOT NULL AND t1.DispatchTime > 0, DATE_FORMAT( FROM_UNIXTIME( t1.DispatchTime ), '%Y-%m-%dT%T'), NULL) AS DispatchTime,
							IF(t1.EnrouteTime IS NOT NULL AND t1.EnrouteTime > 0, DATE_FORMAT( FROM_UNIXTIME( t1.EnrouteTime ), '%Y-%m-%dT%T'), NULL) AS EnrouteTime,
							IF(t1.OnsceneTime IS NOT NULL AND t1.OnsceneTime > 0, DATE_FORMAT( FROM_UNIXTIME( t1.OnsceneTime ), '%Y-%m-%dT%T'), NULL) AS OnsceneTime,
							IF(t1.CloseTime IS NOT NULL AND t1.CloseTime > 0, DATE_FORMAT( FROM_UNIXTIME( t1.CloseTime ), '%Y-%m-%dT%T'), NULL) AS CloseTime,
							t1.IncStatus AS Status,
							t1.CallType AS CallType,
							t5.CallGroup  AS CallGroup,
							IFNULL( t5.Label, t1.Nature) AS Nature,
							t5.TTS_Announcement AS TTS_Nature,
							t5.Ignore AS IgnoreType,
							t1.BoxArea,
							REPLACE(t1.BoxArea, CONCAT( IFNULL(t1.Agency, t1.CityCode), '-'), '') AS FormattedBox,
							t1.StationGrid,
							REPLACE(t1.LocationDescr, CONCAT(', ', IFNULL( t1.CityCode, t1.Agency ) ), '') AS LocationDescr,
							REPLACE(t1.LocationAddress, CONCAT(', ', IFNULL( t1.CityCode, t1.Agency ) ), '') AS LocationAddress,
							t1.LocationNote,
							t1.LocationApartment,
							t3.Status AS Geo_Status,
							t3.CrossStreet1 AS CrossSt1,
							t3.CrossStreet2 AS CrossSt2,
							t6.EntryCrossStreets AS CrossStreets,
							t4.Status AS TTS_Status,
							t4.VoiceAlertKeyUri AS TTS_Key,
							t1.GPSLatitude,
							t1.GPSLongitude,
							t1.Priority,
							'' AS RadioTac,
							t1.MapGrid,
							'' AS EntryComment
						FROM $DB_ICAD.Incident t1
						LEFT JOIN IncidentGeoInfo t3 ON t1.IncidentNo = t3.IncidentNo
						LEFT JOIN IncidentTTS t4 ON t1.EventNo = t4.EventNo AND t4.DispatchTime = $DispatchTime
						LEFT JOIN CallType t5 ON t1.CallType = t5.TypeCode
						LEFT JOIN IncidentNotes t6 ON t1.EventNo = t6.EventNo AND t6.EntryCrossStreets IS NOT NULL
						WHERE t1.EventNo = ?
						GROUP BY t1.EventNo
					},
					undef,
					$EventNo
				);
			} )
		}
		elsif ( $Type == 2 )
		{
			$incref = $_dbh->run( sub {
				return $_->selectrow_hashref(
					qq{
						SELECT
							CONCAT(t1.CallNo, '-', UNIX_TIMESTAMP(t1.EventTime)) AS EventNo,
							t1.CallNo AS IncidentNo,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%dT%T') AS CreatedTime,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%dT%T') AS EntryTime,
							DATE_FORMAT( t1.EventTime, '%Y-%m-%dT%T') AS DispatchTime,
							NULL AS EnrouteTime,
							NULL AS OnsceneTime,
							NULL AS CloseTime,
							1 AS Status,
							t1.Type AS CallType,
							t5.CallGroup AS CallGroup,
							IFNULL( t5.Label, t1.Nature) AS Nature,
							t5.TTS_Announcement AS TTS_Nature,
							t5.Ignore AS IgnoreType,
							t1.Box AS BoxArea,
							IF(t1.Agency IS NOT NULL, REPLACE(t1.Box, CONCAT(t1.Agency, '-'), ''), t1.Box) AS FormattedBox,
							t1.Location AS LocationDescr,
							t1.LocationAddress,
							'' AS LocationNote,
							'' AS LocationApartment,
							t1.CrossStreets AS CrossStreets,
							t4.Status AS TTS_Status,
							t4.VoiceAlertKeyUri AS TTS_Key,
							t1.GPSLatitude,
							t1.GPSLongitude,
							t1.Priority,
							RadioId AS RadioTac,
							t1.Comment AS EntryComment
						FROM $DB_ICAD.CALLEVENT t1
						LEFT JOIN IncidentTTS t4 ON CONCAT(t1.CallNo, '-', '$DispatchTime' ) = t4.EventNo AND t4.DispatchTime = $DispatchTime
						LEFT JOIN CallType t5 ON t1.Type = t5.TypeCode
						WHERE t1.CallNo = ? AND t1.EventTime = FROM_UNIXTIME(?)
						GROUP BY t1.CallNo, t1.EventTime
					},
					undef,
					$IncidentNo,
					$DispatchTime
				);
			} )
		}
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received during incident detail lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_CRIT);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	if ( $incref->{'IgnoreType'} )
	{
		&log("[$EventNo] Call type [$incref->{CallType}] flagged for ignore, aborting icad dispatch");
		return 1;
	}

	my $incref2;

	if ( $Type == 1 )
	{
		if ( ! $incref->{'CrossStreets'} )
		{
			&main::log("Looking up location cross streets from incident narrative");

			eval {
				$incref2 = $_dbh->run( sub {
					return $_->selectrow_hashref(
						qq{
							SELECT EntryCrossStreets AS XStreets
							FROM IncidentNotes
							WHERE EventNo = ? AND EntryCrossStreets IS NOT NULL AND EntryTime <= ?
							GROUP BY EventNo
							ORDER BY EntrySequence DESC
						},
						undef,
						$EventNo,
						$DispatchTime
					)
				} )
			};

			if ( my $ex = $@ )
			{
				&log("[iCAD] Database exception received during incident mapgrid lookup " . &ex( $ex ), E_ERROR);
			}

			$incref->{'CrossStreets'} = $incref2->{'XStreets'};
		}

		if ( ! $incref->{'MapGrid'} )
		{
			&main::log("Looking up location map grid from incident narrative");

			eval {
				$incref2 = $_dbh->run( sub {
					return $_->selectrow_hashref(
						qq{
							SELECT EntryMapGrid AS MapGrid
							FROM IncidentNotes
							WHERE EventNo = ? AND EntryMapGrid IS NOT NULL AND EntryTime <= ?
							GROUP BY EventNo
							ORDER BY EntrySequence DESC
						},
						undef,
						$EventNo,
						$DispatchTime
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

	&log("[$EventNo] Fetching dispatch units") if $DEBUG;

	my ($unitref, $UnitList, $UnitListFormatted);

	eval {
		if ( $Type == 1 )
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
						WHERE t1.EventNo = ? AND t1.Dispatch = ?
						ORDER BY t3.EntrySequence ASC
					},
					{ Slice => {} },
					$EventNo,
					$DispatchTime
				);
			} )
		}
		elsif ( $Type == 2 )
		{
			$unitref = $_dbh->run( sub {
				return $_->selectall_arrayref(
					qq{
						SELECT
							t1.UnitId,
							IF(t2.Agency IS NOT NULL, REPLACE( t1.UnitId, IFNULL(t2.Agency, ''), '' ), t1.UnitId) AS UnitFormatted
						FROM CALLUNITEVENT t1
						LEFT JOIN CALLEVENT t2 ON t1.CallNo = t2.CallNo AND t2.EventTime = t1.DispatchTime
						WHERE t1.CallNo = ? AND t1.DispatchTime = FROM_UNIXTIME(?)
					},
					{ Slice => {} },
					$IncidentNo,
					$DispatchTime
				);
			} )
		}
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received during incident unit lookup - Unable to continue with iCAD notification " . &ex( $ex ), E_CRIT);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	unless ( @{ $unitref } )
	{
		&log("Failed to locate dispatch units for event [$EventNo] - Unable to continue with iCAD notification ", E_CRIT);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	push @{ $UnitList }, $_->{'Unit'} and push @{ $UnitListFormatted }, $_->{'UnitFormatted'} foreach ( @{ $unitref } );

	my $noteref = [];

	if ( $Type == 1 )
	{
		&log("[$EventNo] Fetching dispatch narrative ") if $DEBUG;

		eval {
			$noteref = $_dbh->run( sub {
				return $_->selectall_arrayref(
					qq{
						SELECT
							DATE_FORMAT( FROM_UNIXTIME( t1.EntryTime ), '%Y-%m-%dT%T') AS EntryTime,
							t1.EntrySequence,
							t1.EntryType,
							t1.EntryFDID,
							t1.EntryOperator,
							t1.EntryText
						FROM $DB_ICAD.IncidentNotes t1
						WHERE t1.EventNo = ?
						ORDER BY t1.EntrySequence ASC
					},
					{ Slice => {} },
					$EventNo
				);
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[iCAD] Database exception received during incident narrative lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_CRIT);
		}
	}
	elsif ( $Type == 2 )
	{
		push @{ $noteref }, {
			'EntryTime'		=> $incref->{'DispatchTime'},
			'EntrySequence'	=> 1,
			'EntryFDID'		=> $incref->{''},
			'EntryOperator'	=> $incref->{''},
			'EntryText'		=> $incref->{'EntryComment'},
		};
	}

	my $inc_notes;
	foreach my $_note ( @{ $noteref } )
	{
		$inc_notes .= $xml->Comment(
			$ns->{ns4},
			$xml->CommentText(
				$ns->{ns3},
				encode_entities( $_note->{EntryText} ),
			),
			$xml->CommentDateTime(
				$ns->{ns4},
				$xml->DateTime(
					$ns->{ns3},
					$_note->{EntryTime}
				)
			),
			$xml->ServiceCallOperator(
				$ns->{ns6},
				$xml->PersonName(
					$ns->{ns3},
					$xml->PersonNamePrefixText(
						$ns->{ns3},
						$_note->{EntryFDID}
					),
					$xml->PersonFullName(
						$ns->{ns3},
						encode_entities( $_note->{EntryOperator} )
					)
				)
			),
			$xml->OrganizationIdentification(
				$ns->{ns3},
				$xml->IdentificationID(
					$ns->{ns3},
					$_note->{EntrySequence}
				)
			),
			$xml->SourceIDText(
				$ns->{ns3},
				$_note->{EntryType}
			)
		);
	}

	&log("[$EventNo] Fetching iCAD transaction information for unit dispatch assignments => [$Station] and transaction => [$AlertId]") if $DEBUG;

	$unitref = [];

	eval {
		$unitref = $_dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT
						TRIM( t1.UnitId ) AS Unit,
						DATE_FORMAT( FROM_UNIXTIME( t1.DispatchTime ), '%Y-%m-%dT%T') AS Dispatch,
						t3.PrimaryIp,
						t3.PrimaryPort,
						t3.SecondaryIp,
						t3.SecondaryPort
					FROM $DB_ICAD.CALLUNITEVENT t1
					LEFT JOIN StationUnit t2 ON t2.UnitId = t1.UnitId
					LEFT JOIN Station t3 ON t3.Station = t2.Station
					WHERE t1.CallNo = ? AND t1.DispatchTime = ? AND t1.AlertTrans = ?
				},
				{ Slice => {} },
				$IncidentNo,
				$DispatchTime,
				$AlertId
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received during unit assignment lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_CRIT);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	my $unitxml;
	my $AlertTime = POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime);

	foreach my $_unit ( @{ $unitref } )
	{
		$unitxml .= $xml->ServiceCallAssignedUnit(
			$ns->{ns4},
			$xml->OrganizationIdentification(
				$ns->{ns3},
				$xml->IdentificationID(
					$ns->{ns3},
					encode_entities( $_unit->{Unit} )
				)
			)
		);

		$prim_ip = $_unit->{PrimaryIp} unless ( $prim_ip );
		$prim_port = $_unit->{PrimaryPort} unless ( $prim_port );
		$sec_ip = $_unit->{SecondaryIp} unless ( $sec_ip );
		$sec_port = $_unit->{SecondaryPort} unless ( $sec_port );
		$dispatch_time = $_unit->{Dispatch} unless ( $dispatch_time );
	}

	my $StatusXML = $xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'INITIATE'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'CreatedTime'}
			)
		),
	) .
	$xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'ENTRY'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'EntryTime'}
			)
		),
	);

	$StatusXML .= $xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'DISPATCH'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'DispatchTime'}
			)
		),
	) if $incref->{'DispatchTime'};

	$StatusXML .= $xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'ENROUTE'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'EnrouteTime'}
			)
		),
	) if $incref->{'EnrouteTime'};

	$StatusXML .= $xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'ONSCENE'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'OnsceneTime'}
			)
		),
	) if $incref->{'OnsceneTime'};

	$StatusXML .= $xml->ActivityStatus(
		$ns->{ns3},
		$xml->StatusText(
			$ns->{ns3},
			'CLOSE'
		),
		$xml->StatusDate(
			$ns->{ns3},
			$xml->DateTime(
				$ns->{ns3},
				$incref->{'CloseTime'}
			)
		),
	) if $incref->{'CloseTime'};

	&log("[$EventNo] Checking geolocation data");

	my $init_geo;

	if ( $Config->{'geolocation'}->{'enabled'} && ! $incref->{'CrossStreets'} && ! $incref->{'CrossSt1'} && ! $incref->{'CrossSt2'} )
	{
		$init_geo = 1 unless $incref->{'Geo_Status'};

		if ( $init_geo && $incref->{'GPSLatitude'} && $incref->{'GPSLongitude'} )
		{
			&log("[$EventNo] Geolocation preprocessing required for incident [$incref->{IncidentNo}]");

			my $geo_update;

			eval {
				$sth = $dbh->run( sub
				{
					return $_->do(
						qq{
							INSERT INTO IncidentGeoInfo
							VALUES (?, NOW(), -1, NULL, NULL)
						},
						undef,
						$incref->{'IncidentNo'}
					)
				} )
			};

			if ( my $ex = $@ )
			{
				&log("[iCAD] Database exception received when writing to IncidentTTS table " . &ex( $ex ), E_ERROR);
				$geo_update = -1;
			}

			if ( $geo_update != -1 )
			{
				&log("[$EventNo] Incident geoinfo lacks cross street(s). Initiating location request to Geonames service");

				my $geo;

				if ( $geo = new Geo::GeoNames( 'username'	=> $Config->{'geolocation'}->{'auth_user'} ) )
				{
					my $result = $geo->find_nearest_intersection( lat => $incref->{'GPSLongitude'}, lng => $incref->{'GPSLatitude'} );

					if ( $result && $result->[0] )
					{
						&log("[$EventNo] GeoNames service request appears successful");

						if ( $result->[0]->{'street1'} || $result->[0]->{'street2'} )
						{
							$geo_update = 1;

							$incref->{'CrossSt1'} = $result->[0]->{'street1'} unless $incref->{'CrossSt1'};
							$incref->{'CrossSt2'} = $result->[0]->{'street2'} unless $incref->{'CrossSt2'};
						}
						else
						{
							&log("Geo request did not contain valid response - Cannot continue with geolocation service $@ $!", E_ERROR);
						}
					}
					else
					{
						&log("Geonames service request returned empty response", E_ERROR);
					}
				}
				else
				{
					&log("Could not initialize geolocation service $geo", E_ERROR);
				}
			}

			if ( $geo_update == 1 )
			{
				&log("[$EventNo] Updating geolocation data " . ( $incref->{'CrossSt1'} ? "X1: [$incref->{CrossSt1}] " : undef ) . ( $incref->{'CrossSt2'} ? "X2: [$incref->{CrossSt2}]" : undef ) );

				eval {
					$dbh->run( sub {
						$_->do(
							qq{
								UPDATE IncidentGeoInfo
								SET Status = ?, CrossStreet1 = ?, CrossStreet2 = ?
								WHERE IncidentNo = ?
							},
							undef,
							( $geo_update == 1 ? '1' : '0' ),
							( defined $incref->{'CrossSt1'} ? $incref->{'CrossSt1'} : undef ),
							( defined $incref->{'CrossSt2'} ? $incref->{'CrossSt2'} : undef ),
							$incref->{'IncidentNo'}
						);
					} )
				};

				if ( $@ )
				{
					&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . $@, E_ERROR);
					$dbh->disconnect;
				}
			}
		}
		else
		{
			&log("[$EventNo] GeoLocation data already exists for incident [$incref->{IncidentNo}] -- XStreet1: [$incref->{CrossSt2}] XStreet2: [$incref->{CrossSt1}]") if $incref->{'Geo_Status'};

			&log("Unable to proceed with GeoLocation processing for incident [$incref->{IncidentNo}] due to missing latitude and/or longitude value(s)", E_ERROR) if ( ! $incref->{'GPSLatitude'} || ! $incref->{'GPSLongitude'} );
		}
	}
	else
	{
		&log("[$EventNo] Geolocation data exists, skipping GeoNames cross street lookup ") if ( $incref->{'CrossStreets'} || ( $incref->{'CrossSt1'} && $incref->{'CrossSt2'} ) );
		&log("[$EventNo] Geolocation service not enabled") unless $Config->{'geolocation'}->{'enabled'};
	}

	my $voicealert_base64;

	if ( $Config->{'voicealert'}->{'enabled'} && ! $incref->{'TTS_Key'} )
	{
		&log("[$EventNo] VoiceAlert TTS service enabled, initiating VoiceAlert service");

		my $tts_data = &init_voicealert( $_dbh, {
			'EventNo'			=> $EventNo,
			'DispatchTime'		=> $DispatchTime,
			'IncidentNo'		=> $incref->{'IncidentNo'},
			'Nature'			=> $incref->{'Nature'},
			'TTS_Nature'		=> $incref->{'TTS_Nature'},
			'FormattedBox'		=> $incref->{'FormattedBox'},
			'LocationDescr'		=> $incref->{'LocationDescr'},
			'LocationAddress'	=> $incref->{'LocationAddress'},
			'LocationNote'		=> $incref->{'LocationNote'},
			'LocationApartment'	=> $incref->{'LocationApartment'},
			'TTS_Status'		=> $incref->{'TTS_Status'},
			'Geo_Status'		=> $incref->{'Geo_Status'},
			'CrossSt1'			=> $incref->{'CrossSt1'},
			'CrossSt2'			=> $incref->{'CrossSt2'},
			'CrossStreets'		=> $incref->{'CrossStreets'},
			'UnitList'			=> $UnitList,
			'UnitListFormatted'	=> $UnitListFormatted
		} );

		$incref->{'TTS_Key'} = $tts_data->{'TTS_Key'};

		if ( $incref->{'CrossStreets'} )
		{
			$incref->{'CrossSt1'} = $tts_data->{'CrossSt1'} if $tts_data->{'CrossSt1'};
			$incref->{'CrossSt2'} = $tts_data->{'CrossSt2'} if $tts_data->{'CrossSt2'};
		}
		elsif ( $incref->{'Geo_Status'} && ! $incref->{'CrossSt1'} && ! $incref->{'CrossSt1'} )
		{
			$incref->{'CrossSt1'} = $tts_data->{'CrossSt1'} if $tts_data->{'CrossSt1'};
			$incref->{'CrossSt2'} = $tts_data->{'CrossSt2'} if $tts_data->{'CrossSt2'};
		}
	}

	if ( ! $prim_ip )
	{
		&log("[$EventNo] Station configuration error - Missing primary IP address for station [$Station] - Unable to continue with iCAD dispatch", E_ERROR) unless ( $prim_ip );
		&log("[$EventNo] Station configuration error - Missing secondary IP address for station [$Station]", E_ERROR) unless ( $sec_ip );

		&AlertFail($_dbh, $AlertId);
		return undef if ( ! $prim_ip && ! $sec_ip );
	}

	my $xmlout = $xml->ICadDispatch(
		[
			fhwm	=> "http://fhwm.net/xsd/1.2/ICadDispatch",
			@{ $ns->{ns1} },
			@{ $ns->{ns2} },
			@{ $ns->{ns3} },
			@{ $ns->{ns4} },
			@{ $ns->{ns6} },
			@{ $ns->{ns7} }
		],
		$xml->Payload(
			$ns->{ns4},
			$xml->ServiceCall(
				$ns->{ns4},
				$xml->ActivityIdentification(
					$ns->{ns3},
					$xml->IdentificationID(
						$ns->{ns3},
						$EventNo
					)
				),
				$xml->ActivityDescriptionText(
					$ns->{ns3},
					encode_entities( $incref->{Nature} )
				),
				$StatusXML,
				$xml->ActivityReasonText(
					$ns->{ns3},
					encode_entities( ( @{ $UnitList } ? join(' ', @{ $UnitList } ) : '' ) )
				),
				$xml->ServiceCallDispatchedDate(
					$ns->{ns6},
					$xml->DateTime(
						$ns->{ns3},
						$dispatch_time
					)
				),
				$xml->ServiceCallAugmentation(
					$ns->{ns4},
					$xml->CurrentStatus(
						$ns->{ns4},
						$xml->StatusText(
							$ns->{ns3},
							$incref->{Status}
						)
					),
					$xml->CallTypeText(
						$ns->{ns4},
						encode_entities( $incref->{CallType} )
					),
					$xml->CallSubTypeText(
						$ns->{ns4},
						$incref->{CallGroup}
					),
					$xml->CallPriorityText(
						$ns->{ns4},
						$incref->{Priority}
					),
					$inc_notes,
					$xml->Staging(
						$ns->{ns4},
						$xml->ContactRadioChannelText(
							$ns->{ns3},
							$incref->{RadioTac}
						)
					),
					$xml->IncidentId(
						$ns->{ns4},
						$xml->IdentificationID(
							$ns->{ns3},
							$incref->{IncidentNo}
						)
					),
					$xml->LocalIncidentId(
						$ns->{ns4},
						$xml->IdentificationID(
							$ns->{ns3},
							$incref->{ReportNo}
						)
					)
				),
				$xml->ServiceCallResponseLocation(
					$ns->{ns4},
					$xml->LocationAddress(
						$ns->{ns3},
						$xml->StructuredAddress(
							$ns->{ns3},
							$xml->LocationStreet(
								$ns->{ns3},
								$xml->StreetName(
									$ns->{ns3},
									encode_entities( $incref->{LocationAddress} )
								),
								$xml->StreetName(
									$ns->{ns3},
									encode_entities( $incref->{LocationDescr} )
								),
								( $incref->{LocationNote} ?
									$xml->StreetName(
										$ns->{ns3},
										encode_entities( $incref->{LocationNote} )
									) : undef
								),
							)
						)
					),
					$xml->ServiceCallResponseLocationAugmentation(
						$ns->{ns4},
						$xml->Firebox(
							$ns->{ns4},
							$incref->{BoxArea}
						),
						$xml->MapGrid(
							$ns->{ns4},
							$incref->{MapGrid}
						),
						$xml->StationGrid(
							$ns->{ns4},
							$incref->{StationGrid}
						),
						$xml->GPSLatitudeDecimal(
							$ns->{ns4},
							( $incref->{GPSLatitude} ? $incref->{GPSLatitude} : 0 )
						),
						$xml->GPSLongitudeDecimal(
							$ns->{ns4},
							( $incref->{GPSLongitude} ? $incref->{GPSLongitude} : 0 )
						),
					),
					$xml->ServiceCallResponseLocationAugmentation(
						$ns->{ns4},
						$xml->LocationCrossStreet(
							$ns->{ns4},
							$xml->StreetName(
								$ns->{ns3},
								encode_entities( $incref->{CrossSt1} )
							),
							$xml->StreetName(
								$ns->{ns3},
								encode_entities( $incref->{CrossSt2} )
							)
						)
					)
				)
			),
			$unitxml
		),
		$xml->VoiceAlertData(
			$ns->{ns4},
			$voicealert_base64,
			$xml->VoiceAlertS3Uri(
				$ns->{ns4},
				$incref->{TTS_Key},
			),
		),
		$xml->ExchangeMetadata(
			$ns->{ns4},
			$xml->DataSubmitterMetadata(
				$ns->{ns4},
				$xml->OrganizationIdentification(
					$ns->{ns3},
					$xml->IdentificationID(
						$ns->{ns3},
						'ICAD-DISPATCH'
					)
				),
				$xml->OrganizationName(
					$ns->{ns3},
					$Config->{OrgName}
				)
			)
		),
		$xml->ExchangeMetadata(
			$ns->{ns4},
			$xml->TransactionMetadata(
				$ns->{ns4},
				$xml->MetadataAugmentation(
					$ns->{ns4},
					$xml->SubmissionDateTime(
						$ns->{ns4},
						$xml->DateTime(
							$ns->{ns3},
							$Timestamp
						)
					),
					$xml->MessageSequenceNumber(
						$ns->{ns4},
						$xml->IdentificationID(
							$ns->{ns3},
							$AlertId
						)
					)
				)
			)
		)
	);

	if ( $DEBUG )
	{
		my ($fh, $filename) = tempfile(
			'iCadDispatch_XXXXXX',
			SUFFIX		=> '.xml',
			DIR			=> DEBUG_DIR
		);
		&log("Dumping NIEM iCAD dispatch stream to temporary file => $filename") if $DEBUG;

		if ( $fh )
		{
			print $fh $xmlout;
			close $fh;
		}
	}

	&log("Opening remote INET socket to host $prim_ip:$prim_port");

	my ($sock, $confirm);
	unless (
		$sock = new IO::Socket::INET(
			PeerHost	=> $prim_ip,
			PeerPort	=> $prim_port,
			Proto		=> $Config->{net}->{protocol} || 'tcp',
			Type		=> SOCK_STREAM,
			Timeout		=> 30
		)
	)
	{
		&log("Failed to open INET socket to remote host $prim_ip:$prim_port $@ ", E_CRIT);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	$sock->autoflush(1);

	&log("Connected to remote host " . $sock->peerhost . ":" . $sock->peerport . " - Preparing NIEM/iCAD data stream");

	print $sock $xmlout,CRLF,CRLF;

	&log("Waiting for confirmation message...");

	{
		local $/ = CRLF;
		chomp( $confirm = <$sock> );
	}

	close($sock);

	&log("iCAD data transfer complete with confirmation => [$confirm] - Updating iCAD alert transaction status");

	eval {
		$_dbh->run( sub {
			$_->do(
				qq{
					UPDATE AlertTrans t1
					SET
						t1.Status = ?,
						t1.ConfirmTime = NOW(),
						t1.Result = ?
					WHERE t1.TransId = ?
				},
				undef,
				1,
				$confirm,
				$AlertId
			);
		} )
	};

	if ( $@ )
	{
		&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . $@, E_ERROR);
		$_dbh->disconnect;
	}

	&log("iCAD incident [$EventNo] has been successfully dispatched to station [$Station]");

	return 1;
}

sub AlertFail
{
	my $_dbh = shift;
	my $AlertId = shift;

	eval {
		$_dbh->run( sub {
			$_->do(
				qq{
					UPDATE AlertTrans t1
					SET t1.Status = ?
					WHERE t1.TransId = ?
				},
				undef,
				0,
				$AlertId
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . &ex( $ex ), E_ERROR);
	}

	return;
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

    $msg = "[icad-dispatcher:$line] $msg ($$)";

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

sub ex
{
    my $ex = shift;
    my $err = $ex->error;
    my $state = $ex->state;

    $err =~ s/\n//g;
    $err =~ s/\s{3,}/ /g;

    return ( $ex->can('error') ? "($state) $err" : $ex );
}

sub init_voicealert
{
	my $dbh = shift;
	my $params = shift;

	my $EventNo = $params->{'EventNo'};
	my $DispatchTime = $params->{'DispatchTime'};
	my $IncidentNo = $params->{'IncidentNo'};
	my $init_tts = 0;
	my $tts_update;

	&log("[$EventNo] Initiating VoiceAlert Preprocessing w/Dispatch Timestamp [$DispatchTime]");

	if ( $EventNo && $IncidentNo )
	{
		$init_tts = 1 unless $params->{'TTS_Status'};

		if ( $Config->{'voicealert'}->{'enabled'} && $init_tts && $params->{'LocationAddress'} )
		{
			&log("[$EventNo] No previous VoiceAlert preprocessing exists - Preparing incident for new VoiceAlert processing (locking IncidentTTS tables)");

			eval {
				$dbh->run( sub
				{
					$_->do(
						qq{
							INSERT INTO IncidentTTS
							( EventNo, DispatchTime )
							VALUES ( ?, ? )
						},
						undef,
						$EventNo,
						$DispatchTime
					);
				} )
			};

			if ( my $ex = $@ )
			{
				&log("[$EventNo] VoiceAlert conflict - TTS preprocessing in progress - Looking up existing TTS Key - " . &ex( $ex ), E_WARN);

				my $keyref;
				my $lookup_count = 0;

				TTS_CONFLICT:
				eval {
					$keyref = $dbh->run( sub {
						return $_->selectrow_hashref(
							qq{
								SELECT t1.VoiceAlertKeyUri AS TTSKey
								FROM IncidentTTS t1
								WHERE t1.EventNo = ? AND t1.DispatchTime = ?
							},
							undef,
							$EventNo,
							$DispatchTime
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("[$EventNo] Database exception received while fetching existing TTS key " . &ex( $ex ), E_ERROR);
				}

				unless ( $keyref->{'TTSKey'} )
				{
					$lookup_count++;

					if ( $lookup_count < 3 )
					{
						&log("Parallel lookup of TTS key returned empty result, retrying after $lookup_count attempt(s)");
						sleep 1;

						goto TTS_CONFLICT;
					}
				}

				&log("[$EventNo] VoiceAlert conflict - Returning existing TTS key: [$keyref->{TTSKey}]");

				if ( $params->{'CrossStreets'} )
				{
					if ( $params->{'CrossStreets'} =~ /^btwn\s(.*?)\sand\s(.*)$/ )
					{
						$keyref->{'CrossSt1'} = $1;
						$keyref->{'CrossSt2'} = $2;
					}
					else
					{
						$keyref->{'CrossSt1'} = $params->{'CrossStreets'};
					}
				}

				return {
					'TTS_Key'	=> $keyref->{'TTSKey'},
					'CrossSt1'	=> $keyref->{'CrossSt1'},
					'CrossSt2'	=> $keyref->{'CrossSt2'}
				};
			}

			&log("[$EventNo] Initiating VoiceAlert TTS pre-processing request ");

			my $tts_speak;

			$tts_speak .= "<prosody " .
			( $Config->{'voicealert'}->{'pitch'} ? "pitch=\"" . $Config->{'voicealert'}->{'pitch'} . "\" " : undef ) .
			( $Config->{'voicealert'}->{'rate'} ? "rate=\"" . $Config->{'voicealert'}->{'rate'} . "\" " : undef ) .
			( $Config->{'voicealert'}->{'volume'} ? "volume=\"" . $Config->{'voicealert'}->{'volume'} . "\" " : undef ) .
			">" if ( $Config->{'voicealert'}->{'pitch'}|| $Config->{'voicealert'}->{'rate'} || $Config->{'voicealert'}->{'volume'} );

			if ( $params->{'TTS_Nature'} )
			{
				$tts_speak .= "<s>" . lc( $params->{'TTS_Nature'} ) . "</s>";
			}
			elsif ( $params->{'Nature'} )
			{
				$tts_speak .= "<s>" . lc( &formatTextString( $params->{'Nature'}, 'nature' ) ) . "</s>";
			}

			$tts_speak .= "<s>" . lc( &formatTextString( $params->{'LocationDescr'}, 'location' ) ) . "</s>" if ( $params->{'LocationDescr'} && $params->{'LocationDescr'} ne $params->{'LocationAddress'} );

			my ($Intersection, $AddrNumbers, $AddressStreet, $Street1, $Street2, $HalfNumbers);

			if ( $params->{'LocationAddress'} =~ /^(?:([0-9]*[A-Z]{0,1}[\-0-9]*[A-Z]{0,1})?\s(1\/2)?)?\s?(.*)$/i )
			{
			    $AddrNumbers = $1;
			    $HalfNumbers = $2;
			    $AddressStreet = $3;
			}

			$AddressStreet = $params->{'LocationAddress'} unless $AddressStreet;

			if ( $AddressStreet =~ /^(.*?)(#$params->{LocationApartment})?$/ )
			{
			    $AddressStreet = $1;
			}

			$AddressStreet = &formatTextString($AddressStreet, 'location');

			if ( $AddressStreet =~ /^(.*)\/(.*)$/ )
			{
			    $Intersection = 1;
			    $Street1 = $1;
			    $Street2 = $2;
			}

			$tts_speak .= "<s>";

			if ( $Intersection )
			{
				$tts_speak .= lc($Street1) . " and " . lc($Street2);
			}
			else
			{
				if ( $AddrNumbers )
				{
					if ( $AddrNumbers =~ /^([0-9]*[A-Z]{0,1})\-([0-9]*[A-Z]{0,1})$/i )
					{
						my $num1 = $1;
						my ($unit1, $unit2);
						my $num2 = $2;

						if ( $num1 =~ /^([0-9]*)([A-Z]{0,1})?$/ )
						{
							$num1 = $1;
							$unit1 = $2;
						}

						if ( $num2 =~ /^([0-9]*)([A-Z]{0,1})?$/ )
						{
							$num2 = $1;
							$unit2 = $2;
						}

						$tts_speak .= "<say-as interpret-as=\"characters\" format=\"vxml:digits\">$num1</say-as> ";
						$tts_speak .= "$unit1<break/>" if $unit1;
						$tts_speak .= "through <say-as interpret-as=\"characters\" format=\"vxml:digits\">$num2</say-as> ";
						$tts_speak .= "$unit2<break/>" if $unit2;
					}
					else
					{
						$tts_speak .= "<say-as interpret-as=\"characters\" format=\"vxml:digits\">$AddrNumbers</say-as>";
						$tts_speak .= " and a half " if $HalfNumbers;
					}
				}

				if ( $AddressStreet =~ /^[0-9]/ )
				{
					$tts_speak .= "<say-as interpret-as=\"ordinal\">" . lc($AddressStreet) . "</say-as> ";
				}
				else
				{
					$tts_speak .= lc($AddressStreet);
				}
			}

			$tts_speak .= "</s>";

			if ( $params->{'LocationApartment'} )
			{
				my $apt = lc( $params->{'LocationApartment'} );
				my $detail;

				if ( $apt =~ /^([A-Z]{0,1})?([0-9]*)(?:(?:-|\s)([A-Z]*[0-9]*)?)?$/i )
				{
				    my $_apt;
				    my @format;

				    if ( $1 )
				    {
				        $_apt = $1;
				        push ( @format, length( $1 ));
				    }

				    if ( $2 )
				    {
				        $_apt .= $2;
				        push ( @format, length($2) );
				    }
				    if ( $3 )
				    {
				        $_apt .= $3;
				        push ( @format, length( $3 ) );
				    }

				    $apt = $_apt;
				    $detail = join ' ', @format;
				    $detail = "detail=\"$detail\"";
				}

				$tts_speak .= "<s>unit <say-as interpret-as=\"characters\" format=\"characters\" $detail>$apt</say-as></s>";
			}

			if ( $params->{'CrossStreets'} )
			{
				if ( $params->{'CrossStreets'} =~ /^btwn\s(.*?)\sand\s(.*)$/ )
				{
					$params->{'CrossSt1'} = $1;
					$params->{'CrossSt2'} = $2;
				}
				else
				{
					$params->{'CrossSt1'} = $params->{'CrossStreets'};
				}
			}
			elsif ( $params->{'Geo_Status'} && ! $params->{'CrossSt1'} && ! $params->{'CrossSt2'} )
			{

				&main::log("[$EventNo] Geo status flag suggests cross street(s) exists but none found, checking latest incident GeoLocation info", E_ERROR);

				my $georef;
				eval {
					$georef = $dbh->run( sub {
						return $_->selectrow_hashref(
							qq{
								SELECT CrossStreet1 AS CrossSt1, CrossStreet2 AS CrossSt2
								FROM IncidentGeoInfo
								WHERE t1.IncidentNo = ?
							},
							undef,
							$IncidentNo
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("Database exception received while querying IncidentGeoInfo table " . &ex( $ex ), E_ERROR);
				}

				$params->{'CrossSt1'} = $georef->{'CrossSt1'} if $georef->{'CrossSt1'};
				$params->{'CrossSt2'} = $georef->{'CrossSt2'} if $georef->{'CrossSt2'};
			}

			my $xstreet1 = &formatTextString( uc( $params->{'CrossSt1'} ), 'location' ) if $params->{'CrossSt1'};
			my $xstreet2 = &formatTextString( uc( $params->{'CrossSt2'} ), 'location' ) if $params->{'CrossSt2'};

			$tts_speak .= "<s>";

			if ( $xstreet1 && $xstreet2 )
			{
				$tts_speak .= "between ";

				$tts_speak .= "<say-as interpret-as=\"ordinal\">" . lc($xstreet1) . "</say-as> " if $xstreet1 =~ /^[0-9]/;
				$tts_speak .= lc($xstreet1) unless $xstreet1 =~ /^[0-9]/;

				$tts_speak .= " and ";

				$tts_speak .= "<say-as interpret-as=\"ordinal\">" . lc($xstreet2) . "</say-as> " if $xstreet2 =~ /^[0-9]/;
				$tts_speak .= lc($xstreet2) unless $xstreet2 =~ /^[0-9]/;
			}
			elsif ( ( $xstreet1 && ! $xstreet2 ) || ( ! $xstreet1 && $xstreet2 ) )
			{
				$tts_speak .= "<break />near ";

				if ( $xstreet1 && ! $xstreet2 )
				{
					$tts_speak .= "<say-as interpret-as=\"ordinal\">" . lc($xstreet1) . "</say-as> " if $xstreet1 =~ /^[0-9]/;
					$tts_speak .= lc($xstreet1) unless $xstreet1 =~ /^[0-9]/;
				}
				elsif ( $xstreet2 && ! $xstreet1 )
				{
					$tts_speak .= "<say-as interpret-as=\"ordinal\">" . lc($xstreet2) . "</say-as> " if $xstreet2 =~ /^[0-9]/;
					$tts_speak .= lc($xstreet2) unless $xstreet2 =~ /^[0-9]/;
				}
			}

			$tts_speak .= "</s>";

			$tts_speak .= "<s>" . &formatTextString( $params->{'FormattedBox'}, 'box' ) . "</s>" if $params->{'FormattedBox'};

			if ( @{ $params->{'UnitListFormatted'} } )
			{
				&log("Preparing dispatch units for VoiceAlert TTS conversion");

				my $numunits = 0;

				foreach ( @{ $params->{'UnitListFormatted'} } )
				{
					$numunits++;
					$_ = &formatTextString( $_, 'unit' );
				}

				if ( $numunits > 0 )
				{
					$tts_speak .= "<s>";
					$tts_speak .= join '<break/>', @{ $params->{'UnitListFormatted'} };
					$tts_speak .= " respond</s>";
				}
			}

			$tts_speak .= "</prosody>" if ( $Config->{'voicealert'}->{'pitch'}|| $Config->{'voicealert'}->{'rate'} || $Config->{'voicealert'}->{'volume'} );

			&log("[$EventNo] Preparing SSML TTS conversion request [ $tts_speak ]");

			my $ssml_post = "<?xml version=\"1.0\"?><ConvertSsml><email>$Config->{voicealert}->{auth_email}</email><accountId>$Config->{voicealert}->{account_id}</accountId><loginKey>$Config->{voicealert}->{login_key}</loginKey><loginPassword>$Config->{voicealert}->{login_password}</loginPassword><voice>$Config->{voicealert}->{tts_voice}</voice><outputFormat>" . ( $Config->{'voicealert'}->{'output_format'} ? "$Config->{voicealert}->{output_format}" : 'FORMAT_WAV' ) . "</outputFormat><sampleRate>" . ( $Config->{'voicealert'}->{'sample_rate'} ? "$Config->{voicealert}->{sample_rate}" : '8' ) . "</sampleRate><ssml><speak version=\"1.0\">$tts_speak</speak></ssml><useUserDictionary>" . ( $Config->{'voicealert'}->{'custom_dict'} eq 'true' ? 'true' : 'false' ) . "</useUserDictionary></ConvertSsml>";

			if ( $DEBUG )
			{
				my ($tmp_fh, $tmp_fname) = tempfile(
					'TTS_XXXXXX',
					SUFFIX		=> '.xml',
					DIR			=> DEBUG_DIR
				);

				&log("[$EventNo] Writing VoiceAlert SSML payload to debug file => $tmp_fname") if $DEBUG;

				if ( $tmp_fh )
				{
					print $tmp_fh $ssml_post;
					close $tmp_fh;
				}
			}

			my $ws_client = REST::Client->new( {
				timeout	=> $Config->{'voicealert'}->{'timeout'} || 5
			} );

			&log("[$EventNo] Initiating REST request to host [" . $Config->{'voicealert'}->{'req_uri'} . ( defined $Config->{'voicealert'}->{'req_uri_params'} ? '?' . $Config->{'voicealert'}->{'req_uri_params'} : undef ) . "]");

			$ws_client->POST(
				$Config->{'voicealert'}->{'req_uri'} . ( defined $Config->{'voicealert'}->{'req_uri_params'} ? '?' . $Config->{'voicealert'}->{'req_uri_params'} : undef ),
				$ssml_post
			);

			&log("[$EventNo] REST request completed with response code [" . $ws_client->responseCode() . "]");

			if ( $ws_client->responseCode() eq '200' )
			{
				my $tts_rescode = $ws_client->responseXpath()->findvalue('//response/@resultCode');
				my $tts_resmsg = $ws_client->responseXpath()->findvalue('//response/@resultString');
				my $tts_resdescr = $ws_client->responseXpath()->findvalue('//response/@resultDescription');
				my $tts_id = $ws_client->responseXpath()->findvalue('//response/@conversionNumber');

				&log("[$EventNo] TTS service returned result ($tts_rescode) $tts_resmsg $tts_resdescr with conversion ID: [$tts_id]");

				if ( $tts_rescode eq '0' && $tts_id )
				{
					$tts_update = 1;

					eval {
						$dbh->run( sub {
							$_->do(
								qq{
									UPDATE IncidentTTS
									SET Status = ?, VoiceAlertKeyUri = ?
									WHERE EventNo = ? AND DispatchTime = ?
								},
								undef,
								$tts_rescode,
								$tts_id,
								$EventNo,
								$DispatchTime
							);
						} )
					};

					if ( $@ )
					{
						&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . $@, E_ERROR);
						$dbh->disconnect;
					}

					return {
						'TTS_Key'	=> $tts_id,
						'CrossSt1'	=> $params->{'CrossSt1'},
						'CrossSt2'	=> $params->{'CrossSt2'}
					};
				}
				else
				{
					&log("[$EventNo] TTS conversion error Result Code: [$tts_rescode] ResultMsg: [$tts_resmsg] ResultDescr: [$tts_resdescr]", E_ERROR);
				}
			}
			else
			{
				&log("[$EventNo] TTS service request error received (" . $ws_client->responseCode() . ") " . $ws_client->responseContent(), E_ERROR);
			}
		}
		else
		{
			&log("[$EventNo] VoiceAlert data already exists for incident [$IncidentNo]") if $params->{'TTS_Status'};
			&log("[$EventNo] VoiceAlert TTS pre-processing is not enabled") unless $Config->{'voicealert'}->{'enabled'};
			&log("[$EventNo] Failed to lookup incident location address during dispatch preprocessing for new dispatch event [$EventNo] - VoiceAlert pre-processing failed", E_ERROR) unless ( $params->{'LocationAddress'} );
		}
	}
	else
	{
		&log("[$EventNo] iCAD dispatch attempted without valid IncidentNo - Unable to proceed with VoiceAlert preprocess for EventNo [$EventNo]", E_ERROR);
	}

	unless ( $tts_update )
	{
		&log("[$EventNo] Purging Incident [$IncidentNo] from IncidentTTS table due to failed VoiceAlert processing");

		eval {
			$dbh->run( sub {
				$_->do(
					qq{
						DELETE FROM IncidentTTS
						WHERE EventNo = ? AND DispatchTime = ?
					},
					undef,
					$EventNo,
					$DispatchTime
				);
			} )
		};

		if ( $@ )
		{
			&log("[iCAD] Database exception received during IncidentTTS delete " . $@, E_ERROR);
			$dbh->disconnect;
		}
	}

	return {
		'TTS_Key'	=> undef,
		'CrossSt1'	=> $params->{'CrossSt1'},
		'CrossSt2'	=> $params->{'CrossSt2'}
	};
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

sub prepare_sth
{
	my ($__dbh, $sql) = @_;

	&main::log("Preparing SQL statement [$sql]", E_DEBUG) if $DEBUG;

	try {
		return $__dbh->run( sub{
			return $_->prepare( $sql );
		} );
	}
	catch {
		&main::log("Error preparing SQL statement $_", E_ERROR);
		return undef;
	}
}