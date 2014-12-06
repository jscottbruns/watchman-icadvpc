#!/usr/bin/perl
use POSIX qw(strftime);
use SOAP::Transport::HTTP;

$SIG{PIPE} = $SIG{INT} = 'IGNORE';

BEGIN
{
    push(@INC, "./lib");

    use constant DOCROOT => "/var/www/html/firehousewatchman.com/log";
    use vars qw( $DOCROOT );
}

use Watchman::SOAP;
use Watchman::Test;

my $handler = "Watchman::SOAP";

my $daemon = SOAP::Transport::HTTP::Daemon->new(
    LocalAddr => '67.217.167.22',
    LocalPort => 80,
    Reuse     => 1
)->dispatch_to( $handler );

&Watchman::SOAP::write_log("SOAP HTTP server listening on ", $daemon->sockhost, ":", $daemon->sockport, "\n");

$daemon->handle();

sub write_log
{
    my $msg = shift;
    my ($package, $file, $line) = caller;

    my $logfile = DOCROOT . "/httpd.log";
    my $ts = POSIX::strftime("%a %b %e %H:%M:%S %Y", localtime);

    $msg =~ s/\n$//;
    $msg = "[$ts] [" . $package . ":" . $line . "] $msg\n";

    open LOG_FILE, ">> $logfile";
    print LOG_FILE $msg;
    close LOG_FILE;
}