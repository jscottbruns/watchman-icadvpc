package Watchman::Test;
use strict;

BEGIN
{
    use constant DOCROOT => "/var/www/html/firehousewatchman.com/log";
    use vars qw( $DOCROOT $LICENSE $DEBUG );
}

$DEBUG = 1;

sub init
{
    my $this = shift;
    my $params = shift;

    my $class = ref($this) || $this;
    my $self = {};

    my $o;
    for my $_key ( keys %{ $params } ) {
        $o .= "$_key => $params->{ $_key } \n";
    }

    return "-1\nOutput: $o\n";
}
1;