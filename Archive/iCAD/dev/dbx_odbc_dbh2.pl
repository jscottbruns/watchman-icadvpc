#!/usr/bin/perl
use warnings;
use strict;
use DBIx::Connector;
use Config::General;
use POSIX qw/strftime/;

$ENV{TDSVER} = '8.0';
my $attr = {
	'RaiseError'	=> 1,
	'AutoCommit'	=> 1,
	#'odbc_cursortype'	=> 2
};

my $dbh = {
	'conn1'	=> DBIx::Connector->new(
		'dbi:ODBC:CambriaDSN',
		undef, #	'fa',
		undef,#'firehouseautomation',
		$attr
	),
	'conn2' => DBIx::Connector->new(
	   'dbi:ODBC:CambriaDSN',
      undef, #'fa',
     undef, #'firehouseautomation',
     $attr
 )};

my $ini = new Config::General(
	-ConfigFile           => 'etc/icad-controller.ini',
	-InterPolateVars      => 1,
);

my %Config;

unless ( %Config = $ini->getall )
{
	print "Config error";
	exit;
}


my $bind_c = 0;
$bind_c++ while ( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} =~ m/$Config{db_link}->{db_eoc}->{bind_var}/g );
unless ( $bind_c ) {

	die "Invalid syntax for recent incident select statement on line " . __LINE__ . ". No input placeholders found.";
}

print "Running select query\n";
my $__TIMESTAMP = '2011-10-14T20:08:00';

my $sth;
$sth = $dbh->{'conn1'}->run( 
	fixup => sub {
		$sth = $_->prepare( $Config{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'} );
		$sth->execute(  ( ($__TIMESTAMP) x $bind_c ) ) or die ("Execute error: $@ $!\n");
		$sth;
	}
); 

my $sth2 = $dbh->{'conn2'}->run(
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

$dbh->{'conn1'}->disconnect;
$dbh->{'conn2'}->disconnect;

END 
{ 
	$a = time - $^T, warn sprintf "Runtime %d min %d sec\n", $a/60, $a%60 
}

