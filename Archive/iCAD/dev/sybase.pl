#!/usr/bin/perl
use DBI;

my $dbh = DBI->connect('DBI:Sybase:server=CambriaEOC', 'fa', 'firehouseautomation') or die("Connect error: " . $DBI::errstr);
my $dbh2 = DBI->connect('DBI:Sybase:server=CambriaEOC', 'fa', 'firehouseautomation') or die("Connect error: " . $DBI::errstr);

$dbh->do("use Istatus");
$dbh2->do("use Istatus");

my $sth = $dbh->prepare("SELECT IncidentNo, IncDate FROM dbo.tblActiveFireCalls") or die("Prepare Error");
$sth->execute() or die "Execute error: $DBI::errstr\n";

while ( my $ref = $sth->fetchrow_hashref() ) 
{
	print "Incident $ref->{IncidentNo} $ref->{IncDate}\n";
	my $sth2 = $dbh2->prepare("SELECT Truck, Dispatched FROM dbo.tblActiveTrucks WHERE Incident = '$ref->{IncidentNo}'") or die("Prepare error\n");
	if ( $sth2->execute( ) ) {

		my $rows = $sth2->rows;
		print "  Showing $rows Units for Incident $ref->{IncidentNo}\n";
		while ( my ($Tr, $Di) = $sth2->fetchrow_array ) 
		{
			print "  Truck $Tr Dispatched $Di \n"
		}
		print "\n";

	} else {
		print "Error during ActiveTrucks execute: $DBI::errstr\n";
	}
}
