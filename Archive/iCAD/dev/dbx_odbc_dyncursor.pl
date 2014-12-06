#!/usr/bin/perl
use warnings;
use strict;
use DBIx::Connector;

$ENV{TDSVER} = '8.0';
my $attr = {
	'RaiseError'	=> 1,
	'AutoCommit'	=> 1,
	'odbc_cursortype'	=> 2
};
my $conn = DBIx::Connector->new(
	'dbi:ODBC:CambriaDSN',
	'fa',
	'firehouseautomation',
	$attr
) or die("Connection Error\n");

my $dbh = $conn->dbh;

print "Running select query\n";
my $sth = $conn->run( 
	fixup => sub {
		my $sth = $_->prepare( q/SELECT IncidentNo, Nature FROM dbo.tblActiveFireCalls/ );
		$sth->execute;
		$sth;
	}
); 

my $sth2 = $conn->run(
	fixup => sub {
		my $sth2 = $_->prepare(q/SELECT Truck, Dispatched FROM dbo.tblActiveTrucks WHERE Incident = ?/);
		$sth2;
	}
);

while ( my ($IncNo, $IncDate) = $sth->fetchrow_array() ) 
{
	print "Recent Incident: $IncNo $IncDate \n";

	$sth2->execute($IncNo) or die "Error when executing nested query: " . $DBI::errstr . ' || ' . $sth2->errstr . "\n";
	while ( my ($Truck, $DispTime) = $sth2->fetchrow_array() ) 
	{
		print "  Unit: $Truck Dispatched: $DispTime \n";
	}
	print "\n";
}

$conn->disconnect;

END
{
    $a = time - $^T, warn sprintf "Runtime %d min %d sec\n", $a/60, $a%60
}

