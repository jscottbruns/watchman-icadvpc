#!/usr/bin/perl
#use warnings;
use strict;
use DBIx::Connector;
use Data::Dumper;
use Exception::Class::DBI;

my $conn = DBIx::Connector->new(
	'dbi:mysql:Watchman_iCAD',
	'root',
	'ava457',
	{
		PrintError	=> 0,
		RaiseError	=> 0,
		HandleError	=> Exception::Class::DBI->handler,
		AutoCommit	=> 1,
	}
) or die("Connection Error\n");

my $TS = '2011-10-14T06:00:00';
$conn->mode('fixup');
my $sth;

while ( 1 )
{

	if ( ! $sth ) 
	{
		print "No active statement handle found, preparing statement\n";
		$sth = $conn->run( sub {
			my $sth = $_->prepare('SELECT IncidentNo, Nature FROM Incident WHERE Timestamp > :TS');
			#	$sth->execute($TS);
		    $sth;
	 	} );
	}

	eval {
	if ( $sth->execute($TS) )
	{
		my $dataref = $sth->fetchall_hashref;
		for my $_i ( keys %{ $dataref } ) 
		{
			print "Recent Incident: $_i => $dataref->{ $_i }->{IncidentNo} $dataref->{ $_i }->{Nature} \n";

			eval {
				$conn->run( sub {
					$_->do('INSERT INTO test2 VALUES(?, ?, ?)', undef, $dataref->[0], $dataref->[1], $TS);
				} )
			};
			if ( my $ex = $@ ) {
				print "Insert error: $ex->error\n";
			}
		} 
	}
	};
	if ( my $ex = $@ )
	{
		print "DBI Exception caught:\n";
		print "  Type: ", ref $ex, "\n";
		print "  Error: ", $ex->error, "\n";
		print "  Err: ", $ex->err, "\n";
		print "  Errstr: ", $ex->errstr, "\n";
		print "  State: ", $ex->state, "\n";
		print "  Return: ", $ex->retval, "\n";
		undef $sth;
		#	$conn->disconnect;
	}
	print "Sleeping\n";
	sleep 5;
}

print "Done";

$conn->disconnect;
exit;
