#!/usr/bin/perl --
use strict;

$| = 1;

BEGIN {

	use constant DAEMON		=> 'icad-dispatcher';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-dispatcher.log';
	use constant PID_FILE	=> '/var/run/icad-dispatcher.pid';
	use constant CONF_FILE	=> '/etc/icad.ini';

	use vars qw( %PIDS $log $CONTINUE $DEBUG $LICENSE $dbh );

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
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

make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=>	'/',
	child_STDOUT	=>	File::Spec->catfile( LOG_DIR, 'icad-dispatcher.stdout'),
	child_STDERR	=>	File::Spec->catfile( LOG_DIR, 'icad-dispatcher.stderr'),
	pid_file		=>	PID_FILE
} ) unless $0 eq 'icad-dispatcher.pl';

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

my %Config;
unless ( %Config = $ini->getall )
{
	&log("Error parsing CAD Connector settings file icad-controller.ini. Unable to continue. $@ ", E_ERROR);
	die "Error parsing CAD Connector settings file icad-controller.ini. Unable to continue.";
}

$CONTINUE = 1;

$DEBUG = $Config{'debug'};
&log("Setting DEBUG flag => [$DEBUG]");

$LICENSE = $Config{'license'};
&log("Setting license => [$LICENSE]");

$dbh = &main::init_dbConnection('db_icad');

my $ns = {
    ns1	=> [ ns1 => "http://niem.gov/niem/structures/2.0" ],
    ns2 => [ ns2 => "http://niem.gov/niem/domains/emergencyManagement/2.0" ],
    ns3 => [ ns3 => "http://niem.gov/niem/niem-core/2.0" ],
	ns4 => [ ns4 => "http://fhwm.net/xsd/ICadDispatch" ],
	ns6 => [ ns6 => "http://niem.gov/niem/domains/jxdm/4.0" ],
	ns7 => [ ns7 => "http://niem.gov/niem/ansi-nist/2.0" ]
};

my ($sth, $pid, @__PIDS);

&log("Beginning icad-dispatcher main system block");

MAIN:
while ( $CONTINUE )
{

	my $IncRef;
	eval {
		$IncRef = $dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT
						t1.IncidentNo,
						t2.Station
					FROM Watchman_iCAD.IncidentUnit t1
					RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
					WHERE t1.AlertTrans = -1
					GROUP BY t1.IncidentNo, t2.Station
				},
				{ Slice => {} }
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received while preparing pending incident dispatch statement: " . &ex( $ex ), E_ERROR);
		sleep 3;

		next MAIN;
	}

	foreach my $_i ( @{ $IncRef } )
	{
		&log("Pending iCAD dispatch Incident => [$_i->{IncidentNo}] Station => [$_i->{Station}]");

		eval {
			$dbh->run( sub {
				$_->do(
					qq{
						UPDATE IncidentUnit t1
						RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
						SET t1.AlertTrans = -2
						WHERE t1.IncidentNo = ? AND t1.AlertTrans = -1 AND t2.Station = ?
					},
					undef,
					$_i->{'IncidentNo'},
					$_i->{'Station'},
				);
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[iCAD] Database exception received when setting Incident [$_i->{IncidentNo}] alert transaction flag for station [$_i->{Station}] units - Can't initiate iCAD dispatch for station [$_i->{Station}] units " . &ex( $ex ), E_ERROR);
			next;
		}

		if ( $pid = fork ) # Parent process
		{
			push @__PIDS, $pid;
		}
		elsif ( defined $pid ) # Child process
		{
			&dispatch($dbh, $_i->{'IncidentNo'}, $_i->{'Station'});
			exit 0;
		}
	}

	sleep 1;
}

sub init_dbConnection
{
	my $label = shift;

	my $dsn = "dbi:$Config{db_link}->{$label}->{driver}:$Config{db_link}->{$label}->{db_name};" .
	( $Config{db_link}->{$label}->{'socket'} ?
		"socket=$Config{db_link}->{$label}->{socket}" : "host=$Config{db_link}->{$label}->{host};port=$Config{db_link}->{$label}->{port}"
	);

	&log("Opening database connection to [ $dsn ]");

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			$dsn,
	        $Config{db_link}->{$label}->{'user'},
	        $Config{db_link}->{$label}->{'pass'},
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

	if ( $Config{db_link}->{$label}->{'debug'} )
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
	my ($_dbh, $IncidentNo, $Station) = @_;

	my ($prim_ip, $prim_port, $sec_ip, $sec_port, $dispatch_time);
	my $Timestamp = strftime("%Y-%m-%dT%H:%M:%S", localtime());

	my $xml = XML::Generator->new;

	&log("Initiating iCAD Alerting for Incident => [$IncidentNo] Station => [$Station] ");

	my $AlertId;
	eval {
		$AlertId = $_dbh->run( sub {
			$_->do(
				qq{
					INSERT INTO AlertTrans
					( IncidentNo, Station, AlertTime, Status )
					VALUES ( ?, ?, ?, '-2' )
				},
				undef,
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

	&main::log("Setting alert transaction [$AlertId] for station [$Station] dispatched units");

	eval {
		$dbh->run( sub {
			$_->do(
				qq{
					UPDATE IncidentUnit t1
					RIGHT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
					SET t1.AlertTrans = ?
					WHERE t1.IncidentNo = ? AND t1.AlertTrans = -2 AND t2.Station = ?
				},
				undef,
				$AlertId,
				$IncidentNo,
				$Station
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received while updating iCAD Alert Transation status " . &ex( $ex ), E_ERROR);
		return undef;
	}

	&log("Fetching incident detail for Incident => $IncidentNo") if $DEBUG;

	my $incref;
	eval {
		$incref = $_dbh->run( sub {
			return $_->selectrow_hashref(
				q{
					SELECT
						t1.EventNo,
						DATE_FORMAT(t1.EntryTime, '%Y-%m-%dT%T') AS EntryTime,
						IFNULL(DATE_FORMAT(t1.OpenTime, '%Y-%m-%dT%T'), NULL) AS OpenTime,
						IFNULL(DATE_FORMAT(t1.DispatchTime, '%Y-%m-%dT%T'), NULL) AS InitialDispatchTime,
						IFNULL(DATE_FORMAT(t1.EnrouteTime, '%Y-%m-%dT%T'), NULL) AS EnrouteTime,
						IFNULL(DATE_FORMAT(t1.OnsceneTime, '%Y-%m-%dT%T'), NULL) AS OnsceneTime,
						IFNULL(DATE_FORMAT(t1.CloseTime, '%Y-%m-%dT%T'), NULL) AS CloseTime,
						t1.Status,
						t1.CallType,
						t1.Nature,
						t1.BoxArea,
						t1.StationGrid,
						t1.Location,
						t1.LocationNote,
						t1.CrossSt1,
						t1.CrossSt2,
						t1.GPSLatitude,
						t1.GPSLongitude,
						t1.Priority,
						t1.RadioTac,
						t1.MapGrid,
						GROUP_CONCAT( t2.Unit SEPARATOR ' ' ) AS UnitList
					FROM Watchman_iCAD.Incident t1
					LEFT JOIN IncidentUnit t2 ON t2.IncidentNo = t1.IncidentNo
					WHERE t1.IncidentNo = ?
					GROUP BY t1.IncidentNo
				},
				undef,
				$IncidentNo
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received during incident detail lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_ERROR);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	&log("Fetching incident narrative for incident => $IncidentNo") if $DEBUG;

	my $noteref;
	eval {
		$noteref = $_dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT
						DATE_FORMAT(t1.NoteTime, '%Y-%m-%dT%T') AS NoteTime,
						t1.EntryType,
						t1.EntryFDID,
						t1.Operator,
						t1.Note
					FROM Watchman_iCAD.IncidentNotes t1
					WHERE t1.IncidentNo = ?
					ORDER BY t1.NoteTime ASC
				},
				{ Slice => {} },
				$IncidentNo
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received during incident narrative lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_ERROR);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	my $inc_notes;
	foreach my $_note ( @{ $noteref } )
	{
		$inc_notes .= $xml->Comment(
			$ns->{ns4},
			$xml->CommentText(
				$ns->{ns3},
				$_note->{Note}
			),
			$xml->CommentDateTime(
				$ns->{ns4},
				$xml->DateTime(
					$ns->{ns3},
					$_note->{NoteTime}
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
						$_note->{Operator}
					)
				)
			),
			$xml->SourceIDText(
				$ns->{ns3},
				$_note->{EntryType} # TODO: Replace w/ event label i.e. PROQA, ENTRY, REVIEW, etc
			)
		);
	}

	&log("Fetching assigned units for station => [$Station]") if $DEBUG;

	my $unitref;
	eval {
		$unitref = $_dbh->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT
						TRIM( t1.Unit ) AS Unit,
						DATE_FORMAT(t1.Dispatch, '%Y-%m-%dT%T') AS Dispatch,
						t3.PrimaryIp,
						t3.PrimaryPort,
						t3.SecondaryIp,
						t3.SecondaryPort
					FROM Watchman_iCAD.IncidentUnit t1
					LEFT JOIN StationUnit t2 ON t2.UnitId = t1.Unit
					LEFT JOIN Station t3 ON t3.Station = t2.Station
					WHERE t1.IncidentNo = ? AND t1.AlertTrans = ?
				},
				{ Slice => {} },
				$IncidentNo,
				$AlertId
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] *ERROR* Database exception received during unit assignment lookup - Unable to continue with iCAD dispatch " . &ex( $ex ), E_ERROR);

		&AlertFail($_dbh, $AlertId);
		return undef;
	}

	my $unitxml;
	my $AlertTime = POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime());

	foreach my $_unit ( @{ $unitref } )
	{
		$unitxml .= $xml->ServiceCallAssignedUnit(
			$ns->{ns4},
			$xml->OrganizationIdentification(
				$ns->{ns3},
				$xml->IdentificationID(
					$ns->{ns3},
					$_unit->{Unit}
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

	if ( $incref->{'OpenTime'} )
	{
		$StatusXML .= $xml->ActivityStatus(
			$ns->{ns3},
			$xml->StatusText(
				$ns->{ns3},
				'OPEN'
			),
			$xml->StatusDate(
				$ns->{ns3},
				$xml->DateTime(
					$ns->{ns3},
					$incref->{'OpenTime'}
				)
			),
		);
	}
	if ( $incref->{'InitialDispatchTime'} )
	{
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
					$incref->{'InitialDispatchTime'}
				)
			),
		);
	}
	if ( $incref->{'EnrouteTime'} )
	{
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
		);
	}
	if ( $incref->{'OnsceneTime'} )
	{
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
		);
	}
	if ( $incref->{'CloseTime'} )
	{
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
		);
	}

	if ( ! $prim_ip )
	{
		&log("Station configuration error - Missing primary IP address for station [$Station] - Unable to continue with iCAD dispatch", E_ERROR) unless ( $prim_ip );
		&log("Station configuration error - Missing secondary IP address for station [$Station]", E_ERROR) unless ( $sec_ip );

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
						$incref->{EventNo}
					)
				),
				$xml->ActivityDescriptionText(
					$ns->{ns3},
					$incref->{Nature}
				),
				$StatusXML,
				$xml->ActivityReasonText(
					$ns->{ns3},
					$incref->{UnitList}
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
						$incref->{CallType}
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
							$incref->{'RadioTac'}
						)
					),
					$xml->IncidentId(
						$ns->{ns4},
						$xml->IdentificationID(
							$ns->{ns3},
							$IncidentNo
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
									$incref->{Location}
								),
								$xml->StreetName(
									$ns->{ns3},
									$incref->{LocationNote}
								)
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
								$incref->{CrossSt1}
							),
							$xml->StreetName(
								$ns->{ns3},
								$incref->{CrossSt2}
							)
						)
					)
				)
			),
			$unitxml
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
					$Config{OrgName}
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
			DIR			=> LOG_DIR
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
			Proto		=> $Config{net}->{protocol} || 'tcp',
			Type		=> SOCK_STREAM,
			Timeout		=> 10
		)
	)
	{
		&log("*ERROR_CRIT* Unable to open INET socket to remote host $prim_ip on port $prim_port $@ ", E_CRIT);

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
			$_->do( qq{
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

	&log("iCAD incident [$IncidentNo] has been successfully dispatched to station [$Station]");

	return 1;
}

sub AlertFail
{
	my $_dbh = shift;
	my $AlertId = shift;

	eval {
		$_dbh->run( sub {
			$_->do( qq{
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
		if ( $0 eq 'icad-dispatcher.pl' )
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
    return ( $ex->can('error') ? $ex->error : $ex );
}