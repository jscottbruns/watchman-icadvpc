#!/usr/bin/perl
use strict;
use DBI;
use POSIX qw/strftime/;
use Config::General;

$| = 1;

print "Connecting...\n";

my $dbh;
unless (
  $dbh = DBI->connect(
    "DBI:SQLRelay:host=localhost;port=9000;socket=",
    'icadproxy',
    's8fd674',
    {
      PrintError	=> 1,
      RaiseError	=> 0,
      AutoCommit	=> 1
    }
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

my $bind_c = 0;
$bind_c++ while ( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} =~ m/($Config{db_link}->{db_eoc}->{bind_var})/g );
unless ( $bind_c ) {
    print "No bound params found\n";
    exit;
}


my $__TIMESTAMP = $Config{'timestamp'}; #'2011-10-12T18:00:00';# strftime("%Y-%m-%dT%H:%M:%S", localtime());

my $sth_1 = $dbh->prepare( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} );

print "[EOC911] Executing Recent Incident Lookup Statement Using Timestamp < $__TIMESTAMP >\n";

unless ( $sth_1->execute( ( ($__TIMESTAMP) x $bind_c ) ) )
{
	print "SQL error during [eoc911] incident listing lookup on line " . __LINE__ . ": " . $sth_1->errstr . "\n";
	exit;
}

print "Fetching database result\n";
my @inc;

while ( my ($IncidentNo) = $sth_1->fetchrow_array() )
{
  print "Recent Incident: $IncidentNo \n";
  push @inc, $IncidentNo;
}

print "Inc List: " . join(', ', @inc);
print "\n";

foreach ( @inc ) {

	print "Fetching Inc Detail: $_\n";
	$sth_1 = $dbh->prepare("SELECT IncidentNo, IncDate, Nature, Code, Location, Grid FROM dbo.tblActiveFireCalls WHERE IncidentNo = ?");
	if ( $sth_1->execute($_) ) {

		my $ref = $sth_1->fetchrow_hashref();
		print "Displaying Incident Detail for $_ \n";
		for my $_i ( keys %{ $ref } ) {
			print "  $_i => $ref->{ $_i } \n";
		}
	}
}

$dbh->disconnect;
print "Done";

