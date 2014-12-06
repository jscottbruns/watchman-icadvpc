<?php
require '../include/common.php';

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) {

	header("Location: login.php");
	exit;
}

require_once 'header.php';

# Prevent forced page reloads
if ( $_SESSION['req_count'] % 5 == 0 ) {
	if ( time() - $_SESSION['req_time'] <= 30 ) {

		if ( $_SESSION['req_count'] >= 15 ) {

			header("Location: logout.php");
			exit;
		}

		echo "<script>alert('Page content is dynamically loaded as it becomes available. This means that all new/pending incidents as well as updates to existing incidents will appear automatically without any page reloading. Please disable any automatic page reloaders that may be in use.');</script>";
	}
}

$_SESSION['req_count']++;
$_SESSION['req_time'] = time();



$county = $_SESSION['county'];
$date = ( $_POST['date'] ? $_POST['date'] : date('Y-m-d') );

$cad = new cad($db, $county);
$total = $cad->fetch_incidents( array(
	'date'		=>	$date,
	'order_by'	=>	't1.opentime',
	'order_dir'	=>	'DESC'
) );

print "
<input type=\"hidden\" name=\"timestamp\" id=\"timestamp\" value=\"{$cad->timestamp}\" />
<table style=\"background-color:#cccccc;font-family:arial,sans-serif;font-size:10pt;width:100%;\" cellspacing=\"1\" cellpadding=\"3\" id=\"content_table\">
<tr id=\"content_header\">
	<td class=\"bggry\">CALL NO</td>
	<td class=\"bggry\">OPEN</td>
	<td class=\"bggry\">CLOSE</td>
	<td class=\"bggry\">TYPE</td>
	<td class=\"bggry\">BOX</td>
	<td class=\"bggry\">CASE NO</td>
	<td class=\"bggry\">LOCATION</td>
</tr>";

for ( $i = 0; $i < $total; $i++ ) {

	print "
	<tr id=\"{$cad->incident[$i]['call_no']}\">
		<td class=\"bgwht\">
			{$cad->incident[$i]['call_no']}
			<input type=\"hidden\" id=\"timestamp_{$cad->incident[$i]['call_no']}\" name=\"timestamp_{$cad->incident[$i]['call_no']}\" value=\"{$cad->incident[$i]['timestamp']}\" />
		</td>
		<td class=\"bgwht\">{$cad->incident[$i]['opentime']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['closetime']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['calltype']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['box']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['incident_no']}</td>
		<td class=\"bgwht\">{$cad->incident[$i]['location']}</td>
	</tr>";
}

print "
</table>
<div style=\"margin-top:25px;font-family:arial,sans-serif;font-size:8pt;\">NUMBER OF RECORDS DISPLAYED: $total</div>";

require_once 'footer.php';
?>