<?php
require '../include/common.php';

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) {

	header("Location: login.php");
	exit;
}

require_once 'header.php';

# Prevent forced page reloads
if ( $_SESSION['req_count'] % 5 == 0 )
{
	if ( time() - $_SESSION['req_time'] <= 30 )
	{
		if ( $_SESSION['req_count'] >= 15 )
		{
			header("Location: logout.php");
			exit;
		}

		echo "<script>alert('Page content is dynamically loaded as it becomes available. This means that all new/pending incidents as well as updates to existing incidents will appear automatically without requiring manual page reloading. Please disable any automatic page reloaders that may be in use.');</script>";
	}
}

$_SESSION['req_count']++;
$_SESSION['req_time'] = time();

$county = $_SESSION['county'];
$date = ( $_POST['date'] ? $_POST['date'] : date('Y-m-d') );

$cad = new cad($db, $county);
$total = $cad->fetch_incidents( array(
	'date'		=>	$date,
	'order_by'	=>	'OpenTime',
	'order_dir'	=>	'DESC'
) );

print "
<input type=\"hidden\" name=\"timestamp\" id=\"timestamp\" value=\"{$cad->timestamp}\" />
<table style=\"background-color:#cccccc;font-family:arial,sans-serif;font-size:10pt;width:100%;\" cellspacing=\"1\" cellpadding=\"3\" id=\"content_table\">
<tr id=\"content_header\">
	<td class=\"bggry\" style=\"width:10%\">EVENT NO</td>
	<td class=\"bggry\" style=\"width:10%\">INCIDENT NO</td>
	<td class=\"bggry\" style=\"width:5%\">OPEN</td>
	<td class=\"bggry\" style=\"width:5%\">CLOSE</td>
	<td class=\"bggry\" style=\"width:8%\">TYPE</td>
	<td class=\"bggry\" style=\"width:15%\">NATURE</td>
	<td class=\"bggry\" style=\"width:5%\">BOX</td>
	<td class=\"bggry\" >LOCATION</td>
</tr>";

for ( $i = 0; $i < $total; $i++ )
{
	if ( $cad->incident[$i]['Location'] && $cad->incident[$i]['CrossSt1'] && $cad->incident[$i]['CrossSt2'] )
	{
		$cad->incident[$i]['Location'] .= " (" . $cad->incident[$i]['CrossSt1'] . " & " . $cad->incident[$i]['CrossSt2'] . ")";
	}

	print "
	<tr id=\"{$cad->incident[$i]['EventNo']}\">
		<td class=\"bgwht\">
			{$cad->incident[$i]['EventNo']}
			<input type=\"hidden\" id=\"timestamp_{$cad->incident[$i]['EventNo']}\" name=\"timestamp_{$cad->incident[$i]['EventNo']}\" value=\"{$cad->incident[$i]['Timestamp']}\" />
		</td>
		<td class=\"bgwht\">{$cad->incident[$i]['IncidentNo']}</td>
		<td class=\"bgwht\">" . date("G:i:s", strtotime($cad->incident[$i]['OpenTime']) ) ."</td>
		<td class=\"bgwht\">{$cad->incident[$i]['CloseTime']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['CallType']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['Nature']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['BoxArea']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['Location']}</td>
	</tr>";
}

print "
</table>
<div style=\"margin-top:25px;font-family:arial,sans-serif;font-size:8pt;\">NUMBER OF RECORDS DISPLAYED: $total</div>";

require_once 'footer.php';
?>