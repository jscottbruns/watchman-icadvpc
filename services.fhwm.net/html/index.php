<?php
define('APPLICATION_PATH', realpath('/var/www/fhwm.net') );
define('ERROR_FILE', realpath(APPLICATION_PATH . '/log') . '/fhwm.net.err' );

ini_set('display_errors', 0);

$uri = $_SERVER['REQUEST_URI'];
$ua = $_SERVER['HTTP_USER_AGENT'];

if ( ! ( preg_match('@^/(g|c)/([0-9]{1,})$@', $uri, $matches) ) )
{	
	header('HTTP/1.1 403 Forbidden');
	exit;
}

$uri_type = $matches[1];
$uri_key = $matches[2];

if ( $uri_type != 'g' && $uri_type != 'c' )
{
	header('HTTP/1.1 500 Internal Server Error');
	exit;	
}

if ( ! ( mysql_connect('localhost', 'icad_services', 'yT0WFr5DwDn') ) ) 
{
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}

if ( ! ( mysql_select_db( 'ICAD_SERVICES' ) ) ) 
{
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}

$r = mysql_query("SELECT ForwardUrl FROM iCadUrlMap WHERE UrlKey = '$uri_key' AND Url = 'http://fhwm.net/$uri_type/$uri_key'");
$row = mysql_fetch_assoc($r);

if ( ! $row['ForwardUrl'] )
{
	header('HTTP/1.1 500 Internal Server Error');
	exit;	
}

$dest_url = $row['ForwardUrl'];

if ( $uri_type == 'g' && preg_match('/Android/i', $ua) )
{	
	if ( preg_match('@^https://maps.google.com/maps\?z=([0-9]{1,})&t=([a-zA-Z]{1,})&q=(-?[\d\.]*)\+(-?[\d\.]*)$@', $dest_url, $m) )
	{
		$zoom = $m[1];
		$type = $m[2];
		$lat = $m[3];
		$lng = $m[4];
	
		$dest_url = "geo:$lat,$lng?z=$zoom&q=$lat,$lng";
	}
}

header("Location: $dest_url");

exit;