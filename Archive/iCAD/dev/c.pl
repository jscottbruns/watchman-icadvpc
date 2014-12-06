#!/usr/bin/perl
use Log::Log4perl;

Log::Log4perl::init('log.conf');
my $log = Log::Log4perl->get_logger;

$log->error("Error message");
