<?php
$db_host = 'db2.dealer-choice.com';
$db_name = 'watchman';
$db_user = 'watchman';
$db_pass = 'yT0WFr5DwDn';

if ( ! ( mysql_connect($db_host, $db_user, $db_pass) ) ) {
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}

if ( ! ( mysql_select_db( $db_name ) ) ) {
    header('HTTP/1.1 500 Internal Server Error');
    exit;
}
?>