<?php
include("feedcreator.class.php");

$dbHost = 'db2.dealer-choice.com';
$dbUser = 'watchman';
$dbPass = 'yT0WFr5DwDn';
$dbName = 'watchman';

if ( mysql_connect($dbHost, $dbUser, $dbPass) ) {
	mysql_select_db( $dbName ) or die("Database error: " . mysql_error());
} else
    die("Unable to connect to database: " . mysql_error());

$invalid = 1;

reset( $_GET );
$license = base64_decode( key( $_GET ) );
$date = $_GET['rssDate'];
$remote_addr = $_SERVER['REMOTE_ADDR'];

if ( $license && $remote_addr ) {
    $r = mysql_query("SELECT *
                      FROM license
                      WHERE license_no = '$license' AND rss = 1 ");
    if ( $row = mysql_fetch_assoc( $r ) ) {
    	$licensee = $row['license_name'];
    	$node_name = $row['node_name'];
    	$active = $row['active'];
    	$suspended = $row['suspended'];
	$invalid = 0;
    } else
    	$invalid = 1;

}

if ( $invalid ) {
    print "License not valid\n";
    exit;
}

$rss = new UniversalFeedCreator();
$rss->title = "FireHouse Watchman Incident Feed - $licensee";
$rss->description = "Real time incident ticker";
$rss->link = "http://www.firehousewatchman.com/rss.php";
$rss->syndicationURL = "http://www.firehousewatchman.com/rss.php";

$image = new FeedImage();
$image->url = "http://www.firehousewatchman.com/img/watchman.gif";
$image->link = "http://www.firehousewatchman.com/img/watchman.gif";
$rss->image = $image;

// get your news items from somewhere, e.g. your database:
$res = mysql_query("SELECT *, UNIX_TIMESTAMP(rss.datetime) AS unix_time
                    FROM rss
		    WHERE license_no = '$license' AND " . 
		    ( $date ? "rss.datetime BETWEEN '$date 00:00:00' AND '$date 23:59:59'" :  "DATE( rss.datetime ) = CURDATE()" ) . "
                    ORDER BY rss.datetime DESC");
while ($row = mysql_fetch_assoc($res)) {
    $item = new FeedItem();
    $item->title = "[" . $row['area'] . "] " . $row['callType'] . ( $row['callTypeName'] && $row['callTypeName'] != $row['callType'] ? " - " . $row['callTypeName'] : NULL );
    $item->link = "http://www.firehousewatchman.com/" . $row['rss_id'];
    $item->description = $row['location'] . " " . $row['units'] . "\n" . ( $row['callGroup'] != 'typeEms' ? $row['text'] : NULL);
    $item->date = (int)($row['unix_time'] - 18000);
    $item->author = $licensee;
    $item->category = $row['callGroup'];

    $rss->addItem($item);
}
echo $rss->createFeed();
#echo $rss->saveFeed("RSS1.0", "tmp/feed_{$license}.xml");
?>
