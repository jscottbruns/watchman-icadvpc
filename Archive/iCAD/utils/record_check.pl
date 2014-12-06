#!/usr/bin/perl
use POSIX;

use Config::General;
use DBIx::Connector;
use Exception::Class::DBI;
use Data::Dumper;

$| = 1;

my $ini;

unless (
    $ini = new Config::General(
        -ConfigFile           => '/etc/icad.ini',
        -InterPolateVars      => 1,
    )
)
{
    die "Unable to load system configuration file $@ $!";
}

my %Config;
unless ( %Config = $ini->getall )
{
    die "Error parsing CAD Connector settings file icad-controller.ini. Unable to continue.";
}

$ENV{TDSVER} = $Config{'db_link'}->{'db_eoc'}->{'tds_version'} if $Config{'db_link'}->{'db_eoc'}->{'tds_version'};

my $dbh = {
    eoc		=> &main::init_dbConnection('db_eoc'),
    icad    => &main::init_dbConnection('db_icad')
};

my $IncidentNo = $ARGV[0] || die "No incident number specified\n";

my $ref;
eval {
	$ref = $dbh->{'eoc'}->run( sub {
		return $_->selectall_arrayref(
			qq{
				SELECT
					t1.IncidentNo,
					COUNT( t2.NoteId ) AS TotalNotes,
					COUNT( t3.TruckId ) AS TotalUnits
				FROM tblActiveFireCalls t1
				LEFT JOIN tblActiveCallNotes t2 ON t2.Incident = t1.IncidentNo
				LEFT JOIN tblActiveTrucks t3 ON t3.Incident = t1.IncidentNo
				WHERE t1.IncidentNo = ?
				GROUP BY t1.IncidentNo, t2.Incident, t3.Incident
			},
			{ Slice => {} },
			$IncidentNo
		);
	} )
};

my $i = 0;
foreach my $_row ( @{ $ref } )
{
	print "---------- Row " . ( $i++ ) . " ----------\n\n";
	for my $_i ( keys %{ $_row } )
	{
		print "$_i => $_row->{ $_i } \n";
	}

	print "\n";
}

if ( my $ex = $@ )
{
	print "Database exception received on line " . __LINE__ . ": " . $ex->error . "\n";
}

sub ex
{
    my $ex = shift;
    return ( $ex->can('error') ? $ex->error : $ex );
}

sub init_dbConnection
{
    my $db_label = shift;

    my $dsn = "dbi:$Config{db_link}->{$db_label}->{driver}:$Config{db_link}->{$db_label}->{dsn}";

    my $conn;
    unless (
        $conn = DBIx::Connector->new(
            "dbi:$Config{db_link}->{$db_label}->{driver}:$Config{db_link}->{$db_label}->{dsn}",
            $Config{'db_link'}->{$db_label}->{'user'},
            $Config{'db_link'}->{$db_label}->{'pass'},
            {
                PrintError  => 0,
                RaiseError  => 0,
                HandleError => Exception::Class::DBI->handler,
                AutoCommit  => 1,#( $Config{'db_link'}->{$db_label}->{'autocommit'} ? 1 : 0 ),
            }
        )
    ) {

        die "Database connection error: " . $DBI::errstr;
    }

    unless ( $conn->mode('fixup') )
    {
        die "Unable to set default SQL mode on line " . __LINE__ . ". Fatal.";
    }

    return $conn;
}
