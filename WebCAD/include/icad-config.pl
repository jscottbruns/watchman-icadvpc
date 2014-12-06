#!/usr/bin/perl
use strict;
use Config::General;

my ($ini, $phpini, $Config);
unless (
    $ini = new Config::General(
        -ConfigFile           => '/etc/icad.ini',
        -InterPolateVars      => 1,
    )
)
{
    die "Unable to load system configuration file $@ $!";
}

unless ( $Config = { $ini->getall } )
{
    die "Error parsing CAD Connector settings file icad.ini. Unable to continue.";
}

for my $_i ( keys %{ $Config->{'icad'}->{'webviewer'} } )
{
    $phpini .= "[$_i]\r\n";
    $phpini .= "OrgName = \"$Config->{OrgName}\"\r\n" if $_i eq 'system';

    for my $_j ( keys %{ $Config->{'icad'}->{'webviewer'}->{ $_i } } )
    {
        $phpini .= "$_j = \"$Config->{icad}->{webviewer}->{ $_i }->{ $_j }\"\r\n";
    }

    $phpini .= "\r\n";
}


print $phpini;