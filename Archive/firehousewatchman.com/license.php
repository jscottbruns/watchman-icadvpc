<?php
if ( $argv[0] && $argv[1] ) {
	$cli = true;
	$action = 'vldtlic';
	$licno = $argv[1];
} else {
    $action = $_POST['action'];
    $licno = $_POST['licno'];
    $ip_addr = $_SERVER['REMOTE_ADDR'];
    $node = $_POST['node'];	
}

if ( ! $cli )
    session_start();

$db_host = 'db2.dealer-choice.com';
$db_name = 'watchman';
$db_user = 'watchman';
$db_pass = 'yT0WFr5DwDn';

mysql_connect($db_host, $db_name, $db_pass) or die("-2");
mysql_select_db( $db_name ) or die("-2");

# 1: License valid
# -1: Missing required post field
# -2: Server error
# -3: License not found
# -4: Suspended
# -5: License not valid

if ( $action && $licno ) {
	
    # Check the action being requested
    if ( $action == 'vldtlic' ) {
    	
        $r = mysql_query("SELECT active, suspended
                          FROM license
                          WHERE license_no = '$licno'");
        if ( $row = mysql_fetch_assoc( $r ) ) {
            if ( ! $row['suspended'] && $row['active'] ) {
                print "1\n";
                exit;
            }
            if ( $row['suspended'] ) {
                print "-4\nAccount has been suspended.";
                exit;
            }
        }

        if ( ! $row ) {
            print "-3\nLicense not found.";
            exit;
        }

        print "-5\nLicense not valid";
        exit;
    }
}

print "-1\nMissing required information: " .
( ! $action ?
    "Missing action. " : NULL
) .
( ! $licno ?
    "Missing license number. " : NULL
) .
( ( ! $cli && ! $node ) ?
    "Missing computer/node name. " : NULL
) .
( ( ! $cli && ! $ip ) ?
    "Missing ip address. " : NULL
);

exit;

?>
