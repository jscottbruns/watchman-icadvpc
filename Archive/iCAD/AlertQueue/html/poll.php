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

if ( $_POST['ajaxstatic'] )
{
	$ajaxstatic = 1;
	$order_dir = 'DESC';
}
elseif ( $_POST['ajaxpoll'] )
{
	$ajaxpoll = 1;
}

if ( $_POST['Date'] )
	$PostDate = $_POST['Date'];
if ( $_POST['Hour'] )
	$PostHour = $_POST['Hour'];
if ( $_POST['Min'] )
	$PostMin = $_POST['Min'];
if ( $_POST['Timestamp'] )
	$Timestamp = $_POST['Timestamp'];
if ( $_POST['OpenTime'] )
	$OpenTime = $_POST['OpenTime'];

$cad = new cad($db, $county);
$total = $cad->fetch_incidents( array(
	'PostDate'		=> $_POST['Date'],
	'PostHour'		=> $_POST['Hour'],
	'PostMin'		=> $_POST['Min'],
	'Timestamp'		=> $_POST['Timestamp'],
	'OpenTime'		=> $_POST['OpenTime'],
	'AjaxPoll'		=> $_POST['ajaxpoll'],
	'AjaxStatic'	=> $_POST['ajaxstatic'],
	'OrderBy'		=> $_POST['OrderBy'],
	'OrderDir'		=> $_POST['OrderDir']
) );

$xml = new XML_Builder('text/xml', 'UTF-8');
$xml->add_group('poll');

$xml->add_tag('IncidentDate', $date);
$xml->add_tag('CountyCode', $county);
$xml->add_tag('PollingTimestamp', $cad->timestamp);
$xml->add_tag('Total', $total);

if ( $total > 0 ) {

	$xml->add_group('IncidentListing');

	for ( $i = 0; $i < $total; $i++ )
	{
		if ( $cad->incident[$i]['Location'] && $cad->incident[$i]['CrossSt1'] && $cad->incident[$i]['CrossSt2'] )
			$cad->incident[$i]['Location'] .= " (" . $cad->incident[$i]['CrossSt1'] . " & " . $cad->incident[$i]['CrossSt2'] . ")";

		$xml->add_tag('Incident', '', array(
			'timestamp'		=>	$cad->incident[$i]['Timestamp'],
			'call_no'		=>	trim($cad->incident[$i]['EventNo']),
			'opentime'		=>	trim($cad->incident[$i]['OpenTime']),
			'closetime'		=>	trim($cad->incident[$i]['CloseTime']),
			'pri'			=>	trim($cad->incident[$i]['Priority']),
			'calltype'		=>	trim($cad->incident[$i]['CallType']),
			'nature'		=>	trim($cad->incident[$i]['Nature']),
			'box'			=>	trim($cad->incident[$i]['BoxArea']),
			'incident_no'	=>	trim($cad->incident[$i]['IncidentNo']),
			'location'		=>	htmlspecialchars_uni( trim($cad->incident[$i]['Location']) )
		) );
	}

	$xml->close_group();
}

$xml->close_group();
$xml->print_xml();
exit;