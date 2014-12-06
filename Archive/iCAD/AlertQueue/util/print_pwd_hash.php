<?php
require_once('../include/login_hash.class.php');

$pw = $argv[1];

if ( ! $pw ) {
	print "Missing password (pwd=1234)";
	exit;
}

$login = new login_hash;
$pwd_hash = $login->hash($pw);

print $pwd_hash;