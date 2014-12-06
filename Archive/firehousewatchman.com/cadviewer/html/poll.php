<?php
require '../include/common.php';
require '../include/xml.class.php';

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) {

	header("Location: login.php?r=poll");
	exit;
}

$county = $_SESSION['county'];
$order_dir = 'ASC';

if ( $_POST['ajaxstatic'] ) {

	$ajaxstatic = 1;
	$order_dir = 'DESC';

} elseif ( $_POST['ajaxpoll'] )
	$ajaxpoll = 1;

$date = ( $_POST['date'] ? $_POST['date'] : date('Y-m-d') );
$hour = $_POST['hour'];
$min = $_POST['min'];
$ts = $_POST['ts'];

if ( isset($hour) && isset($min) )
	$sql = "t1.opentime >= '{$hour}:{$min}:00'";
elseif ( $ts )
	$sql = "t1.timestamp >= $ts";
else
	$sql = "t1.opentime > DATE_FORMAT( DATE_SUB(NOW(), INTERVAL 10 MINUTE), '%T')";

$cad = new cad($db, $county);
$total = $cad->fetch_incidents( array(
	'date'		=>	$date,
	'sql'		=>	( $ajaxstatic ? "t1.opentime > DATE_FORMAT( DATE_SUB(NOW(), INTERVAL 60 MINUTE), '%T')" : $sql ),
	'order_by'	=>	't1.opentime',
	'order_dir'	=>	$order_dir,
	'method'	=>	( $ajaxstatic ? 'ajaxstatic' : 'ajaxpoll' )
) );

$xml = new XML_Builder('text/xml', 'UTF-8');
$xml->add_group('poll');

$xml->add_tag('IncidentDate', $date);
$xml->add_tag('CountyCode', $county);
$xml->add_tag('PollingTimestamp', $cad->timestamp);
$xml->add_tag('Total', $total);

if ( $total > 0 ) {

	$xml->add_group('IncidentListing');

	for ( $i = 0; $i < $total; $i++ ) {

		$xml->add_tag('Incident', '', array(
			'timestamp'		=>	$cad->incident[$i]['timestamp'],
			'call_no'		=>	trim($cad->incident[$i]['call_no']),
			'opentime'		=>	trim($cad->incident[$i]['opentime']),
			'closetime'		=>	trim($cad->incident[$i]['closetime']),
			'pri'			=>	trim($cad->incident[$i]['pri']),
			'calltype'		=>	trim($cad->incident[$i]['calltype']),
			'box'			=>	trim($cad->incident[$i]['box']),
			'incident_no'	=>	trim($cad->incident[$i]['incident_no']),
			'location'		=>	htmlspecialchars_uni( trim($cad->incident[$i]['location']) )
		) );
	}

	$xml->close_group();
}

$xml->close_group();
$xml->print_xml();
exit;