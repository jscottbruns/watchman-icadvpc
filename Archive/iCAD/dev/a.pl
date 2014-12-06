#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBIx::Connector;
use Exception::Class::DBI;

$ENV{TDSVER} = '8.0';
my $attr = {
	'RaiseError'	=> 1,
	'AutoCommit'	=> 1,
};
my $conn = DBIx::Connector->new(
	'dbi:mysql:Watchman_iCAD',
	'root',
	'ava457',
	{
		RaiseError	=> 0,
		PrintError	=> 0,
		AutoCommit	=> 1,
		HandleError	=> Exception::Class::DBI->handler,
	}
) or die("Connection Error\n");

$conn->mode('fixup');

my $_sth;
eval {
	$_sth = $conn->run( sub {
		my $_sth = $_->prepare( qq{
			SELECT t1.IncidentNo, t2.Unit, t4.PrimaryIp, t4.SecondaryIp
			FROM Watchman_iCAD.AlertTrans t1
			LEFT JOIN IncidentUnit t2 ON t2.AlertTrans = t1.TransId
			LEFT JOIN StationUnit t3 ON t3.UnitId = t2.Unit
			LEFT JOIN Station t4 ON t4.Station = t3.Station
			WHERE t1.TransId = ? AND t4.Station = ?
		} );
		$_sth->execute('151', '36');
		$_sth;
	} );
};
if ( my $ex = $@ ) 
{
	print "Error: ", $ex->errstr, "\n";
	exit;
}

my $unitref = $_sth->fetchall_arrayref({});

foreach my $_unit ( @$unitref )
{
	print "Unit: $_unit->{Unit} $_unit->{PrimaryIp} \n";
}

$conn->disconnect;
exit;
