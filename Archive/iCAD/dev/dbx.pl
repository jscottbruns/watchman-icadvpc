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

my $__TIMESTAMP = $Config{'timestamp'}; #'2011-10-12T18:00:00';# strftime("%Y-%m-%dT%H:%M:%S", localtime());

print "Connected, preparing eoc911 query...\n";
print "Recent Incidents SQL: \n";
print $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'};
print "\n\n";

my $bind_c = 0;
$bind_c++ while ( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} =~ m/($Config{db_link}->{db_eoc}->{bind_var})/g );
unless ( $bind_c ) {
  print "No bound params found\n";
  exit;
}

my $sth_1;
$sth_1 = $dbh->prepare( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} )  if ( ! $sth_1 );

print "[EOC911] Executing Recent Incident Lookup Statement Using Timestamp < $__TIMESTAMP >\n";

unless ( $sth_1->execute( ( ($__TIMESTAMP) x $bind_c ) ) )
{
	print "SQL error during [eoc911] incident listing lookup on line " . __LINE__ . ": " . $sth_1->errstr . "\n";
	exit;
}

print "Fetching database result\n";

while ( my ($IncidentNo) = $sth_1->fetchrow_array() )
{
  print "Recent Incident: $IncidentNo \n";
}

$sth_1->finish;
$dbh->disconnect;
print "Done";

