<?php
require('../simplepie/simplepie.php');

$feed = new SimplePie();
$feed->cache_location('cache');
$feed->handle_content_type();

require('outputbody.php');

$rsslist = array(
    "watchman" => "http://www.firehousewatchman.com/rss.php?" . base64_encode('MD160025')
);

$rssid = $_GET['id'];
$rssurl = ( isset($rsslist[$rssid])? $rsslist[$rssid] : die("<b>Error:</b> Can't find requested RSS in list.") );
$cachetime = ( isset($_GET["cachetime"])? (int)$_GET["cachetime"] : 5 );
$feednumber = ( isset($_GET["limit"])? (int)$_GET["limit"] : "" );
if ( isset( $_GET['rssDate'] ) && strtotime($_GET['rssDate']) ) {
	$rssDate = date("Y-m-d", strtotime($_GET['rssDate'])); 
	$rssurl .= "&rssDate=$_GET[rssDate]";
}
$templatename = ( isset($_GET["template"])? $_GET["template"] : "" );
if ( $templatename != "" && ! preg_match("/^(\w|-)+$/i", $templatename) )
    die ("<b>Error:</b> Template name can only consist of alphanumeric characters, underscore or dash");

$cachetime = 3;

$feed->cache_max_minutes($cachetime);
$feed->feed_url($rssurl);
$feed->init();
$max = $feed->get_item_quantity($feednumber);

$omitCallType = array('RAPE', 'RA', 'RAP', 'SUI');

function outputitems(){
	global $feed, $feednumber, $templatename, $omitCallType;
	
	$max = $feed->get_item_quantity($feednumber);
	for ($x = 0; $x < $max; $x++) {		
    	$item = $feed->get_item($x);
    	$t = $item->get_title();
    	
    	if ( is_array( $omitCallType ) ) {
	    	$matches = array();
	    	if ( preg_match('/\[[0-9]{2}\]\s([a-z]*)\s?/i', $t, $matches) ) {
	            if ( in_array($matches[1], $omitCallType) )
	                continue;                                            	
	    	}    
    	}
    	
        outputbody($item, $templatename);    	
	}
}

if ($feed->data)
    outputitems();     
