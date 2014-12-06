<?php
defined('APPLICATION_PATH') || define('APPLICATION_PATH', realpath( dirname(__FILE__) . '/../html' ) );

set_include_path(
	realpath(APPLICATION_PATH . '/../include') .
	PATH_SEPARATOR .
	get_include_path()
) or die("Internal server error when setting inclusion path.");

require_once 'common_helper.php';

$config_result = ini_decrypt('./watchman.ini');

//session_set_cookie_params(0,'/',$config_result['cookie']['cookie_domain']);
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT"); // Date in the past
session_start();

if ( ! defineConfigVars($config_result) ) {

	print "System error encountered during startup process. Please try again\n<br />";
    exit;
}

if ( defined('DEBUG') )
{
	list($usec, $sec) = explode(' ', microtime());
	$pun_start = ( (float)$usec + (float)$sec );
}

errorlog_setup();

ini_set('display_errors', 0);
error_reporting(0);

require_once 'error_handler.class.php';
set_error_handler(
    array(
        'errorHandler',
        'do_error'
    ),
    E_ERROR | E_USER_ERROR | E_USER_NOTICE | E_USER_WARNING
);

set_magic_quotes_runtime(0);
mt_srand((double)microtime()*1000000);

$timezone_map = array(
    '-3:30'  =>  'Canada/Newfoundland',
    '-4:00'  =>  'Canada/Atlantic',
    '-5:00'  =>  'US/Eastern',
    '-6:00'  =>  'US/Central',
    '-7:00'  =>  'US/Mountain',
    '-8:00'  =>  'US/Pacific',
    '-9:00'  =>  'US/Alaska',
    '-10:00' =>  'US/Hawaii'
);

require_once 'db_layer.php';

$db = new DBLayer(
	DB_HOST,
	DB_USERNAME,
	DB_PASSWORD,
	DB_NAME,
	( defined('CONNECTION_CHARSET') ? CONNECTION_CHARSET : '' ),
	( defined('CONNECTION_COLLATION') ? '' : '' )
);

if ( ! $db || ( $db && $db->db_errno && $db->db_error ) ) {

	print "Can't connect to database. " . ( $db && $db->db_errno ? "Database reported: ({$db->db_errno}) {$db->db_error}. " : NULL ) . "Please try again.";
	exit;
}

if ( ! defined('DEFAULT_CHARSET') )
    define('DEFAULT_CHARSET', 'iso-8859-1');

if ( defined('DEFAULT_TIMEZONE') )
	date_default_timezone_set(DEFAULT_TIMEZONE);
else {

	define('DEFAULT_TIMEZONE', "US/Eastern");
	date_default_timezone_set("US/Eastern");
}

$db->set_timezone(DEFAULT_TIMEZONE);

require_once 'ajax_layer.class.php';
require_once 'login_class.class.php';
require_once 'form_funcs.class.php';
require_once 'cad.class.php';

# $_SERVER['HTTP_ACCEPT_ENCODING'] = ''; # Disable content encoding for debug purposes.

$_SERVER['HTTP_ACCEPT_ENCODING'] = ( isset($_SERVER['HTTP_ACCEPT_ENCODING']) ? $_SERVER['HTTP_ACCEPT_ENCODING'] : '' );

if ( extension_loaded('zlib') && ( strpos($_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip') !== false || strpos($_SERVER['HTTP_ACCEPT_ENCODING'], 'deflate') !== false) ) {

	$_SESSION['O_GZIP'] = true;
	ob_start('ob_gzhandler');
} else
	ob_start();

?>