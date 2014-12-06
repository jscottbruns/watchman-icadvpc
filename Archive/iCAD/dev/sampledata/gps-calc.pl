#!/usr/bin/perl

my $lat = '40.1611';
my $long = '-78.785127';

my ($gpslat_deg, $gpslat_min, $gpslat_sec) = &gpsDecToDeg($long);

print "$gpslat_deg, $gpslat_min, $gpslat_sec\n";
exit;

sub gpsDecToDeg
{
	my $dec = shift;

	return (0, 0, 0) unless ( $dec );

	my ($degree, $fraction, $minute, $second);

	if ( $dec =~ /^(\d{0,})\.(\d*)$/ )
	{
		$degree = $1;
		$fraction = $2;
	}

	$dec = ( ( $dec - $degree ) * 60 );
	$minute = $1 if ( $dec =~ /^(\d{0,})\.(\d*)$/ );
	$second = ( ( $dec - $minute ) * 60 );

	return ($degree, $minute, sprintf('%.6f', $second));
}
