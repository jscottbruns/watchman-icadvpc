#!/usr/bin/perl
use strict;
use SQLRelay::Connection;
use SQLRelay::Cursor;
use POSIX qw/strftime/;
use Config::General;

$| = 1;

print "Connecting...\n";

my $dbh;
unless (
  $dbh = SQLRelay::Connection->new(
	  'localhost',
	  9000,
	  '',
	  'icadproxy',
      's8fd674',
	  0, 
	  1
  )
) {
  print "Database API Connection Error - Unable to connect to database layer $DBI::errstr ";
  exit;
}

my $ini = new Config::General(
	-ConfigFile           => '/home/jsbruns/workspace/WatchmanAlerting/iCAD/etc/icad-controller.ini',
	-InterPolateVars      => 1,
);

my %Config;
unless ( %Config = $ini->getall )
{
  print "Ini config error\n";
  exit;
}


my $__TIMESTAMP = $Config{'timestamp'}; #'2011-10-12T18:00:00';# strftime("%Y-%m-%dT%H:%M:%S", localtime());

my $cur1 = SQLRelay::Cursor->new($dbh);
$cur1->setResultSetBufferSize(0);
$cur1->prepareQuery( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} );

print "[EOC911] Executing Recent Incident Lookup Statement Using Timestamp < $__TIMESTAMP >\n";
#$cur1->inputBind('TS', $__TIMESTAMP);
for ( my $i = 1; $i <= 7; $i++ ) {
	$cur1->inputBind($i, $__TIMESTAMP);
}
unless ( $cur1->executeQuery( ) )
{
	print "SQL error during [eoc911] incident listing lookup on line " . __LINE__ . ": " . $cur1->errorMessage() . "\n";
	exit;
}
#$dbh->endSession();

print "Fetching database result\n";
my @inc;

for ( my $row = 0; $row < $cur1->rowCount(); $row++ )
{
	my ($IncidentNo) = $cur1->getRow($row);
	print "Recent Incident: $IncidentNo \n";
	push @inc, $IncidentNo;
}

print "Inc List: " . join(', ', @inc);
print "\n";

foreach ( @inc ) {

	print "Fetching Inc Detail: $_\n";
	$cur1->setResultSetBufferSize(0);
	$cur1->prepareQuery("SELECT IncidentNo, IncDate, Nature, Code, Location, Grid FROM dbo.tblActiveFireCalls WHERE IncidentNo = ?");
	$cur1->inputBind(1, $_);
	if ( $cur1->executeQuery() ) {
		
		my %ref = $cur1->getRowHash(0);
		print "Displaying Incident Detail for $_ (" . $cur1->rowCount() . ") \n";

		print "  IncidentNo => $ref{'IncidentNo'} \n";
		print "  IncDate => $ref{'IncDate'} \n";
		print "  Nature => $ref{'Nature'} \n";
		print "  Code => $ref{'Code'}\n";
		print "  Location => $ref{'Location'} \n";
		print "  Grid => $ref{'Grid'} \n";
	} else {
		print "Error: " . $cur1->errorMessage() . "\n";
	}
#	$dbh->endSession();
}

#$dbh->endSession();
print "Done";

