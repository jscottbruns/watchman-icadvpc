#!/usr/bin/perl
use DBI;

my $dbh = DBI->connect(
	'dbi:SQLRelay:host=localhost;port=9000;socket=',
	'icadproxy',
	's8fd674',
) or die "Can't connect: $DBI::errstr\n";

$dbh->{RaiseError} = 1;
$dbh->{odbc_cursortype} = DBI::SQL_CURSOR_DYNAMIC;

my $sth1 = $dbh->prepare(q/SELECT IncidentNo, Nature FROM dbo.tblActiveFireCalls/);
$sth1->execute or die "SQL error during execution: $DBI::errstr\n";

my $sth2 = $dbh->prepare(q/SELECT Truck, Dispatched FROM dbo.tblActiveTrucks WHERE Incident = ?/);
while ( my ($IncNo, $IncDate) = $sth1->fetchrow_array() ) 
{
	print "Recent Incident: $IncNo $IncDate \n";

	$sth2->execute($IncNo) or die "Error when executing nested query: $DBI::errst || $sth2->errstr \n";
	while ( my ($Truck, $DispTime) = $sth2->fetchrow_array() ) 
	{
		print "  Unit: $Truck Dispatched: $DispTime \n";
	}
	print "\n";
}

