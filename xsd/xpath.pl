#!/usr/bin/perl
use XML::XPath;
use XML::XPath::XMLParser;
use Data::Dumper;

if ( open(FH, "<./Watchman_Incident.xml") )
{
	while ( <FH> )
	{
		$xsltout .= $_;
	}
	close FH;
}

my $xp = XML::XPath->new( xml => $xsltout );
my $xnotes = $xp->find('.', '//WatchmanAlerting/IncidentLocation/Location/StreetName');
print $xnotes;


