#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use SOAP::Transport::HTTP;

$SIG{PIPE} = 'IGNORE';

$ENV{HTTPS_CERT_FILE} = '/etc/httpd/ssl/crt/vhost.crt';
$ENV{HTTPS_KEY_FILE}  = '/etc/httpd/ssl/crt/vhost.crt';
    
BEGIN
{	
	push @INC, './lib';
	
	use constant DOCROOT => '/var/www/services.fhwm.net';
	use vars qw ( $DOCROOT );	
}

#use iCAD_Services;
#use mt_callback;

my $daemon = SOAP::Transport::HTTP::Daemon->new(
	'LocalAddr'	=> '0.0.0.0',
	'LocalPort'	=> '8090'
)->dispatch_to( 'iCAD_Services', 'mt_callback' );

&write_log("iCAD Services Proxy Server Started [" . $daemon->url );

$daemon->handle;

sub write_log
{
    my $msg = shift;
    my ($package, $file, $line) = caller;

    my $logfile = DOCROOT . "/log/soap_request.log";
    my $ts = POSIX::strftime("%a %b %e %H:%M:%S %Y", localtime);

    $msg =~ s/\n$//;
    $msg = "[$ts] [" . $package . ":" . $line . "] $msg\n";

    open LOG_FILE, ">> $logfile";
    print LOG_FILE $msg;
    close LOG_FILE;
}