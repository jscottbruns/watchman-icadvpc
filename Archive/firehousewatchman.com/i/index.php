<?php
define('APPLICATION_PATH', realpath('/var/www/firehousewatchman.com-cgi/i') );

set_include_path(
	realpath(APPLICATION_PATH . '/..') .
	PATH_SEPARATOR .
	get_include_path()
) or die("Internal server error when setting inclusion path.");


define('ERROR_FILE', realpath(APPLICATION_PATH . '/../log') . '/firehousewatchman.com.err' );

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

if ( ! ( preg_match('/^\/i\/([A-Z]{2}[0-9]{6,})\/?(.*)?$/', $_SERVER['REDIRECT_URL'], $matches) ) ) {

	trigger_error("Invalid server redirect URL {$_SERVER['REDIRECT_URL']}", E_USER_ERROR);
    header('HTTP/1.1 403 Forbidden');
    exit;
}

$lic_no = $matches[1];
$inc_req = $matches[2];

$ini_file = realpath(APPLICATION_PATH . '/../config.ini');
$ini_array = parse_ini_file($ini_file, 1);

if ( ! ( mysql_connect($ini_array['database']['db_host'], $ini_array['database']['db_user'], $ini_array['database']['db_pass']) ) ) {

	trigger_error("Cannot connect to MySQL database: " . mysql_error(), E_USER_ERROR);
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}

if ( ! ( mysql_select_db( $ini_array['database']['db_name'] ) ) ) {

	trigger_error("Cannot select MySQL database for use: " . mysql_error(), E_USER_ERROR);
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}

$r = mysql_query("SELECT
					  sms_viewer,
					  sms_viewer_start,
					  sms_viewer_end
                  FROM license
                  WHERE license_no = '$lic_no'");
if ( $row = mysql_fetch_assoc($r) ) {

    if ( ! $row['sms_viewer'] ) {
        print "Watchman Error: License does not permit incident detail viewer. Upgrade required.";
        exit;
    }

    $sms_viewer_start = $row['sms_viewer_start'];
    $sms_viewer_end = $row['sms_viewer_end'];
}

$path = realpath(APPLICATION_PATH . "/$lic_no" . ( $inc_req ? "/$inc_req" : NULL ) );

if ( file_exists( $path ) ) {

	if ( $inc_req ) {

		$data = file_get_contents( $path );
		if ( preg_match("/$sms_viewer_start(.*)$sms_viewer_end/ms", $data, $matches ) )
	        $data = $matches[1];

	    print "
	    <div style=\"font-family:Arial;font-size:90%;margin-bottom:20px;\">
            <a href=\"/i/$lic_no\" style=\"color:#000000;\"><-- Back to Incident Listing</a>
	    </div>";
	    print preg_replace('/<!--CONTENT-->/', $sms_viewer_start . $data, file_get_contents( "/var/www/firehousewatchman.com-cgi/i/placeholder.htm" ));

	    exit;

	} else {

		print "
		<html>
		<head>
		<title>Recent Incident Listing</title>
		</head>
		<body>";

		if ( $dir_handle = opendir( $path ) ) {

		    $cont = array();
		    while ( $file = readdir( $dir_handle ) ) {
		        if ( strlen( $file ) > 3 )
		        	$cont[ $file ] = filemtime( $path . '/' . $file );
		    }

		    asort($cont);

			print "
			<div style=\"font-family:Arial;\">";
			if ( $cont ) {

			    while ( list($file, $ftime) = each( $cont ) ) {

			    	if ( $fdate != date("Y-m-d", $ftime) ) {
				        print
				        ( $fdate ?
				            "</ul>" : NULL
				        ) . "
				        <div style=\"font-weight:bold;\">" . date("D, M jS Y", $ftime) . "</div>
				        <ul style=\"font-size:80%;\">";
			    	}
                    print "
                    <li>
                        <a href=\"http://www.firehousewatchman.com/i/$lic_no/$file\">$file</a>
                        <span style=\"font-size:90%;font-style:italic;\">" . date("Hi", $ftime) . "</span>
                    </li>";


			        $fdate = date("Y-m-d", $ftime);
			    }
			}

			print "
                </ul>
			</div>";
		}
	}

} else {

	print "
	<div style=\"font-family:Arial;\">
        " . ( $inc_req ? "Incident details for $inc_req could not be displayed" : "No incident data to display" ) . "
	</div>";
}

print "
</body>
</html>";
