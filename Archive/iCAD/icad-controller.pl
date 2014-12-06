#!/usr/bin/perl
use strict;
use POSIX;

$| = 1;

BEGIN {

	use constant DAEMON		=> 'icad-controller';
	use constant ROOT_DIR	=> '/usr/local/bin';
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'icad-controller.log';
	use constant PID_FILE	=> '/var/run/icad-controller.pid';
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
use POSIX qw/strftime/;
use File::Spec;
use File::Touch;
use File::Path;
use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;

make_path( LOG_DIR, { mode => 0777 } ) if ( ! -d LOG_DIR ); # Create log directory if not exists
touch( File::Spec->catfile( LOG_DIR, LOG_FILE ) ) if ( ! -f File::Spec->catfile( LOG_DIR, LOG_FILE ) ); # Touch log file if not exists

Proc::Daemon::Init( {
	work_dir		=>	'/',
	child_STDOUT	=>	File::Spec->catfile( LOG_DIR, 'icad-controller.stdout'),
	child_STDERR	=>	File::Spec->catfile( LOG_DIR, 'icad-controller.stderr'),
	pid_file		=>	PID_FILE
} ) unless $0 eq 'icad-controller.pl';

if ( Proc::PID::File->running() )
{
	print STDERR "WatchmanAlerting iCAD Controller Server is already running\n";
	die "WatchmanAlerting iCAD Controller Server is already running";
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

$DEBUG = $Config{'debug'};
&log("Setting DEBUG flag => [$DEBUG]");

$LICENSE = $Config{'license'};
&log("Setting license => [$LICENSE]");

my $INTERVAL = $Config{'interval'} || 10;
my $COUNT = 1;
$CONTINUE = 1;

sub trim($);
sub rtrim($);
sub ltrim($);

if ( $Config{'db_link'}->{'db_eoc'}->{'tds_version'} )
{
	&log("Setting environment TDS version => [$Config{db_link}->{db_eoc}->{tds_version}]");
	$ENV{TDSVER} = $Config{'db_link'}->{'db_eoc'}->{'tds_version'}
}

my $dbh = {
	eoc1	=> &main::init_dbConnection('db_eoc'),
	eoc2	=> &main::init_dbConnection('db_eoc'),
	icad	=> &main::init_dbConnection('db_icad')
};

#TODO: SQL statement checks
&log("Using recent incident search offset => [$Config{db_link}->{db_eoc}->{table}->{incident}->{offset_time}]") if $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'offset_time'};

my ($_sql, $__TIMESTAMP);
my $TIMESTAMP = &cache_timestamp( $dbh->{'eoc1'} );

MAIN:
while ( $CONTINUE )
{
	sleep ( $INTERVAL );

	$__TIMESTAMP = $TIMESTAMP;
	$TIMESTAMP = &cache_timestamp( $dbh->{'eoc1'} );

	&log("[EOC911] Executing Recent Incident Lookup Statement [$COUNT] --> $__TIMESTAMP ") if $DEBUG;

	$_sql = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'};

	my $recents;
	eval {
		$recents = $dbh->{'eoc1'}->run( sub {
			return $_->selectall_arrayref(
				qq{
					BEGIN
						DECLARE \@p_date DATETIME = CONVERT( DATETIME, ?, 121 )
						$_sql
					END;
				},
				undef,
				$__TIMESTAMP
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[EOC911] *ERROR* Database exception received during recent incident lookup " . &ex( $ex ), E_ERROR);
		$dbh->{'eoc1'}->disconnect;

		next MAIN;
	}

	my $new_incidents = 0;

	foreach my $_i ( @{ $recents } )
	{
		$new_incidents++;
		my $IncidentNo = $_i->[0];

		&log("[EOC911] Found recent incident $IncidentNo - Starting iCAD synchronization process") if $DEBUG;

		&log("[EOC911] Incident Detail Lookup [$IncidentNo]") if $DEBUG;

		$_sql = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'IncidentDetail'};
		$_sql =~ s/%incidentno%/$IncidentNo/g;

		my $ref; # Unit Dispatch Lookup
		eval {
			$ref = $dbh->{'eoc1'}->run( sub {
				return $_->selectrow_hashref( $_sql );
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[EOC911] Database exception received during incident detail lookup " . &ex( $ex ), E_ERROR);
			goto UNIT_FETCH;
		}

		if ( $ref )
		{
			&log("[iCAD] Incident Insert/Update [$IncidentNo] TYPE:$ref->{CallType} NATURE:$ref->{Nature} ") if $DEBUG;

			eval {
				$dbh->{'icad'}->run( sub {
					$_->do( qq{
						INSERT INTO Watchman_iCAD.Incident
						VALUES
						(
							?, # EventNo
							?, # IncidentNo
							CURRENT_TIMESTAMP(),
							?, # EntryTime
							?, # OpenTime
							?, # DispatchTime
							?, # EnrouteTime
							?, # OnsceneTime
							?, # CloseTime
							?, # Status
							?, # CallType
							?, # Nature
							?, # BoxArea
							?, # StationGrid
							?, # Location
							?, # LocationNote
							?, # CrossSt1
							?, # CrossSt2
							?, # GPSLatitude
							?, # GPSLongitude
							?, # Priority
							?, # RadioTac
							?  # MapGrid
						)
						ON DUPLICATE KEY UPDATE
							IncidentNo = ?,
							DispatchTime = ?,
							EnrouteTime = ?,
							OnsceneTime = ?,
							CloseTime = ?,
							Status = ?,
							CallType = ?,
							Nature = ?,
							BoxArea = ?,
							StationGrid = ?,
							Location = ?,
							LocationNote = ?,
							CrossSt1 = ?,
							CrossSt2 = ?,
							GPSLatitude = ?,
							GPSLongitude = ?,
							Priority = ?,
							RadioTac = ?,
							MapGrid = ?
						},
						undef,
						( defined $ref->{'EventNo'} ? $ref->{'EventNo'} : $IncidentNo ),
						$IncidentNo,
						$ref->{'EntryTime'},
						( defined $ref->{'OpenTime'} ? $ref->{'OpenTime'} : undef ),
						( defined $ref->{'InitialDispatch'} ? $ref->{'InitialDispatch'} : undef ),
						( defined $ref->{'InitialEnroute'} ? $ref->{'InitialEnroute'} : undef ),
						( defined $ref->{'InitialArrival'} ? $ref->{'InitialArrival'} : undef ),
						( defined $ref->{'CloseTime'} ? $ref->{'CloseTime'} : undef ),
						( defined $ref->{'Status'} ? $ref->{'Status'} : undef ),
						$ref->{'CallType'},
						$ref->{'Nature'},
						$ref->{'BoxArea'},
						$ref->{'StationGrid'},
						$ref->{'Location'},
						$ref->{'LocationNote'},
						$ref->{'CrossSt1'},
						$ref->{'CrossSt2'},
						( defined $ref->{'GPSLatitude'} ? $ref->{'GPSLatitude'} : 0 ),
						( defined $ref->{'GPSLongitude'} ? $ref->{'GPSLongitude'} : 0 ),
						$ref->{'Priority'},
						$ref->{'RadioTac'},
						$ref->{'MapGrid'},
						$IncidentNo,
						( defined $ref->{'InitialDispatch'} ? $ref->{'InitialDispatch'} : undef ),
						( defined $ref->{'InitialEnroute'} ? $ref->{'InitialEnroute'} : undef ),
						( defined $ref->{'InitialArrival'} ? $ref->{'InitialArrival'} : undef ),
						( defined $ref->{'CloseTime'} ? $ref->{'CloseTime'} : undef ),
						( defined $ref->{'Status'} ? $ref->{'Status'} : undef ),
						$ref->{'CallType'},
						$ref->{'Nature'},
						$ref->{'BoxArea'},
						$ref->{'StationGrid'},
						$ref->{'Location'},
						$ref->{'LocationNote'},
						$ref->{'CrossSt1'},
						$ref->{'CrossSt2'},
						( defined $ref->{'GPSLatitude'} ? $ref->{'GPSLatitude'} : 0 ),
						( defined $ref->{'GPSLongitude'} ? $ref->{'GPSLongitude'} : 0 ),
						$ref->{'Priority'},
						$ref->{'RadioTac'},
						$ref->{'MapGrid'}
					);
				} )
			};

			if ( my $ex = $@ )
			{
				&log("[iCAD] Database exception received during incident insert/update " . &ex( $ex ), E_ERROR);
				&log("Prio: [$ref->{Priority}] TAC: [$ref->{RadioTac}] Map: [$ref->{MapGrid}]", E_ERROR);
			}
		}

		UNIT_FETCH: # Unit Dispatch Lookup
		&log("[EOC911] Unit Dispatch Lookup [$IncidentNo]") if $DEBUG;

		$_sql = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'units'}->{'sql'}->{'select'}->{'UnitDetail'};
		$_sql =~ s/%incidentno%/$IncidentNo/g;

		my $ref;
		eval {
			$ref = $dbh->{'eoc2'}->run( sub {
				return $_->selectall_arrayref(
					qq{
						BEGIN
							DECLARE \@p_date DATETIME = CONVERT( DATETIME, ?, 121 )
							$_sql
						END;
					},
					{ Slice => {} },
					$__TIMESTAMP
				);
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[EOC911] Database exception received during unit dispatch lookup " . &ex( $ex ), E_ERROR);
		}

		if ( $ref )
		{
			foreach my $row ( @{ $ref } )
			{
				&log("[iCAD] Incident [$IncidentNo] Unit Insert/Update [$row->{Unit}] ") if $DEBUG;

				eval {
					$dbh->{'icad'}->run( sub {
						$_->do( qq{
							INSERT INTO Watchman_iCAD.IncidentUnit
							(
								UnitId,
								Unit,
								IncidentNo,
								Dispatch,
								Enroute,
								OnScene,
								InService,
								Status
							)
							VALUES
							(
								?, # UnitId
								?, # Unit
								?, # IncidentNo
								?, # Dispatch
								?, # Enroute
								?, # Onscene
								?, # InService
								?  # Status
							)
							ON DUPLICATE KEY UPDATE
								Dispatch = ?,
								Enroute = ?,
								Onscene = ?,
								InService = ?,
								Status = ?
							},
							undef,
							$row->{'UnitId'},
							$row->{'Unit'},
							$IncidentNo,
							( $row->{'Dispatch'} ? $row->{'Dispatch'} : undef ),
							( $row->{'Enroute'} ? $row->{'Enroute'} : undef ),
							( $row->{'Onscene'} ? $row->{'Onscene'} : undef ),
							( $row->{'InService'} ? $row->{'InService'} : undef ),
							$row->{'Status'},
							( $row->{'Dispatch'} ? $row->{'Dispatch'} : undef ),
							( $row->{'Enroute'} ? $row->{'Enroute'} : undef ),
							( $row->{'Onscene'} ? $row->{'Onscene'} : undef ),
							( $row->{'InService'} ? $row->{'InService'} : undef ),
							$row->{'Status'}
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("[iCAD] Database exception received during incident [$IncidentNo] unit insert/update on unit [$row->{UnitId}] " . &ex( $ex ), E_ERROR);
				}
			}
		}

		# Call Notes Lookup
		NOTES_FETCH:
		&log("[EOC911] Incident Notes Lookup [$IncidentNo]") if $DEBUG;

		$_sql = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'callnotes'}->{'sql'}->{'select'}->{'CallNoteDetail'};
		$_sql =~ s/%incidentno%/$IncidentNo/g;

		my $ref;
		eval {
			$ref = $dbh->{'eoc2'}->run( sub {
				return $_->selectall_arrayref(
					qq{
						BEGIN
							DECLARE \@p_date DATETIME = CONVERT( DATETIME, ?, 121 )
							$_sql
						END;
					},
					{ Slice => {} },
					$__TIMESTAMP
				);
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[EOC911] Database exception received during call notes lookup " . &ex( $ex ), E_ERROR);
		}

		if ( $ref )
		{
			foreach my $row ( @{ $ref } )
			{
				&log("[iCAD] Incident [$IncidentNo] Call Notes Insert/Update [$row->{NoteId}] ") if $DEBUG;

				eval {
					$dbh->{'icad'}->run( sub {
						$_->do( qq{
							INSERT INTO Watchman_iCAD.IncidentNotes
							VALUES
							(
								?, # NoteId
								CURRENT_TIMESTAMP(),
								?, # IncidentNo,
								?, # NoteTime
								?, # EntryType
								?, # EntryFDID,
								?, # Operator
								?  # Note
							)
							ON DUPLICATE KEY UPDATE
								NoteTime = ?,
								EntryType = ?,
								EntryFDID = ?,
								Operator = ?,
								Note = ?
							},
							undef,
							$row->{'NoteId'},
							$row->{'IncidentNo'},
							$row->{'NoteTime'},
							$row->{'EntryType'},
							$row->{'EntryFDID'},
							$row->{'Operator'},
							$row->{'Note'},
							$row->{'NoteTime'},
							$row->{'EntryType'},
							$row->{'EntryFDID'},
							$row->{'Operator'},
							$row->{'Note'}
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("[iCAD] Database exception received during incident [$IncidentNo] call note insert/update on entry [$row->{NoteId}] " . &ex( $ex ), E_ERROR);
				}
			}
		}
	}

	&log( ( $new_incidents ? "Finished iCAD synchronization for $new_incidents recent incidents" : "No recent incidents found" ) ) if ( $DEBUG || $new_incidents );

	# Update past/current iCAD incidents that have since been closed/cancelled
	&log("Comparing current iCAD incidents to closed/cancelled EOC911 incidents") if $DEBUG;

	my $closedList;
	eval {
		$closedList = $dbh->{'icad'}->run( sub {
			return $_->selectall_arrayref(
				qq{
					SELECT
						EventNo,
						IncidentNo,
						EntryTime AS EntryTime,
						DATE_FORMAT(EntryTime, '%Y-%m-%dT00:00:00') AS IncidentDate,
						Location AS Location
					FROM Watchman_iCAD.Incident
					WHERE Timestamp <= ? AND Status != 'CLOSED' AND Status != 'CANCELLED'
				},
				{ Slice => {} },
				$__TIMESTAMP
			);
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[iCAD] Database exception received during active incident lookup older than [$__TIMESTAMP] " . &ex( $ex ), E_ERROR);
		$dbh->{'icad'}->disconnect;

		next MAIN;
	}

	next MAIN unless ( $closedList );

	my $Location;
	foreach my $row ( @{ $closedList } )
	{
		&log("Searching [$row->{IncidentNo}] $row->{EntryTime} ($row->{IncidentDate}) $row->{Location} against EOC911 closed/cancelled incidents") if $DEBUG;

		$Location = $dbh->{'eoc2'}->dbh->quote( $row->{Location} );

		$_sql = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'IncStatusSearch'};
		$_sql =~ s/%incidentno%/$row->{IncidentNo}/g;
		$_sql =~ s/%entrytime%/$row->{EntryTime}/g;
		$_sql =~ s/%incidentdate%/$row->{IncidentDate}/g;
		$_sql =~ s/%location%/$Location/g;

		my $dataref;
		eval {
			$dataref = $dbh->{'eoc2'}->run( sub {
				return $_->selectall_arrayref(
					$_sql,
					{ Slice => {} }
				);
			} )
		};

		if ( my $ex = $@ )
		{
			&log("[EOC911] Database exception received during incident status criteria search [$row->{IncidentNo}] " . &ex( $ex ), E_ERROR);

			next MAIN;
		}

		if ( @{ $dataref } )
		{
			&log("Lookup returned " . ( $#{ $dataref } + 1 ) . " matching incident(s) - EOC911 incident status ($dataref->[0]->{IncidentNo}) => $dataref->[0]->{Status} ") if $DEBUG;

			if ( $dataref->[0]->{'Status'} ne 'ACTIVE' )
			{
				&log("Closing iCAD incident [$row->{IncidentNo}] --$dataref->[0]->{Status}--");

				eval {
					$dbh->{'icad'}->run( sub {
						$_->do(
							qq{
								UPDATE Watchman_iCAD.Incident t1
								LEFT JOIN Watchman_iCAD.IncidentUnit t2 ON t2.IncidentNo = t1.IncidentNo
								SET
									t1.IncidentNo = ?,
									t1.CloseTime = ?,
									t1.Status = ?,
									t2.Closed = 1
								WHERE t1.EventNo = ?
							},
							undef,
							$dataref->[0]->{'IncidentNo'},
							( defined $dataref->[0]->{'CloseTime'} ? $dataref->[0]->{'CloseTime'} : $__TIMESTAMP ),
							$dataref->[0]->{'Status'},
							$row->{'EventNo'}
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("[iCAD] Database exception received during closed/cancelled incident update [$dataref->[0]->{IncidentNo}] " . &ex( $ex ), E_ERROR);
				}
			}
		}
		else
		{
			&log("Incident $row->{IncidentNo} can't be matched against [EOC911] active/cancelled/closed incidents. ");

			if ( $row->{'IncidentNo'} =~ /$Config{db_link}->{db_eoc}->{table}->{incident}->{active_inc_format}/ && $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'purge_waiting_inc'} )
			{
				&log("Incident [$row->{IncidentNo}] matches active incident format, removing non-existent pending incident ") if $DEBUG;

				eval {
					$dbh->{'icad'}->run( sub {
						$_->do(
							qq{
								DELETE
									t1.*,
									t2.*
								FROM Watchman_iCAD.Incident t1
								LEFT JOIN Watchman_iCAD.IncidentNotes t2 ON t2.IncidentNo = t1.IncidentNo
								WHERE t1.EventNo = ?
							},
							undef,
							$row->{'EventNo'}
						);
					} )
				};

				if ( my $ex = $@ )
				{
					&log("[iCAD] Database exception received during pending incident delete [$row->{IncidentNo}] " . &ex( $ex ), E_ERROR);
				}
			}
		}
	}

	$COUNT++;
}

sub init_dbConnection
{
	my $db_label = shift;

	my $dsn = "dbi:$Config{db_link}->{$db_label}->{driver}:$Config{db_link}->{$db_label}->{dsn}";

	&log("Opening database connection to [ $dsn ]");

	my $conn;
	unless (
		$conn = DBIx::Connector->new(
			"dbi:$Config{db_link}->{$db_label}->{driver}:$Config{db_link}->{$db_label}->{dsn}",
	        $Config{'db_link'}->{$db_label}->{'user'},
	        $Config{'db_link'}->{$db_label}->{'pass'},
	        {
	        	PrintError	=> 0,
	        	RaiseError	=> 0,
	        	HandleError	=> Exception::Class::DBI->handler,
	    	    AutoCommit	=> 1,#( $Config{'db_link'}->{$db_label}->{'autocommit'} ? 1 : 0 ),
	        }
		)
	) {

		&log("Database connection error: " . $DBI::errstr, E_ERROR);
		die "Database connection error: " . $DBI::errstr;
	}

	&log("Setting default DBIx mode => 'fixup' ");
	unless ( $conn->mode('fixup') )
	{
		&log("Error received when attempting to set default mode  " . $DBI::errstr, E_ERROR);
		die "Unable to set default SQL mode on line " . __LINE__ . ". Fatal.";
	}

	if ( $Config{'db_link'}->{$db_label}->{'debug'} )
	{
		&log("Registering database handler callback debugging functions");
		$conn->{Callbacks} =
		{
	    	'connected'	=> sub
	    	{
	    		my ($_dbh, $_sql, $_attr) = @_;
	    	    &log("DBI connection established", E_DEBUG);
	    	    return;
			},
	    	'prepare'	=> sub
	    	{
				my ($_dbh, $_sql, $_attr) = @_;
				&log("q{$_sql}", E_DEBUG);
				return;
			}
		}
	}

	return $conn;
}

sub cache_timestamp
{
	my $_dbh = shift;

	my $OffsetTime = $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'offset_time'} || 0;
	my $Timestamp;

	eval {
		($Timestamp) = $_dbh->run( sub {
			return $_->selectrow_array("SELECT CONVERT(VARCHAR, DATEADD( second, $OffsetTime, CURRENT_TIMESTAMP ), 121)");
		} )
	};

	if ( my $ex = $@ )
	{
		&log("[EOC911] Database exception received while fetching database timestamp - Defaulting to iCAD system timestamp " . &ex( $ex ), E_ERROR);
	}

	$Timestamp = strftime("%Y-%m-%d %H:%M:%S", localtime( time - $OffsetTime )) unless ( $Timestamp );

	return $Timestamp;
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

    $msg = "[icad-controller:$line] $msg ($$)";

	$log->$level($msg) if defined $log;
	print STDERR "$msg \n" unless defined $log;
}

sub init_log
{
	if ( $log = Log::Dispatch->new )
	{
		if ( $0 eq 'icad-controller.pl' )
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
