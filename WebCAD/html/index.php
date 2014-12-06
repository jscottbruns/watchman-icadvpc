<?php
require '/var/www/icad-poll/include/common.php';

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) {

	header("Location: login.php");
	exit;
}

require_once 'header.php';

# Prevent forced page reloads
if ( ! $_SERVER['HTTP_REFERER'] )
{
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
}

$_SESSION['req_count']++;
$_SESSION['req_time'] = time();

$agency = $_SESSION['agency'];
$date = ( $_POST['date'] ? $_POST['date'] : date('Y-m-d') );

$cad = new cad($db, $agency);
$total = $cad->fetch_incidents( array (
	'date'	=> date("Y-m-d")
) );
 
print "
<div style=\"margin-right:15px;margin-top:65px;margin-bottom: 25px;\">
	<h3 style=\"color: #565658;font-family:arial;\">WatchmanAlerting WebCAD :: Active Incident Feed</h3>
</div>
<div style=\"margin-right:15px;margin-top:25px;margin-bottom:15px;font-family:arial;font-size:10pt;\">
	<span style=\"width:45px;height:45px;background-color:#ff0000;border:1px solid black;\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<small><strong>PENDING</strong></small>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<span style=\"width:45px;height:45px;background-color:#FFCC33;border:1px solid black;\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<small>DISPATCHED</small>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<span style=\"width:45px;height:45px;background-color:#00FF00;border:1px solid black;\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<small>ENROUTE</small>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<span style=\"width:45px;height:45px;background-color:#0080FF;border:1px solid black;\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<small>ONSCENE</small>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<span style=\"width:45px;height:45px;background-color:#E0E0E0;border:1px solid black;\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;<small>CLOSED</small>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</div>
<div style=\"display:" . ( defined('DEBUG') ? 'block' : 'none' ) . ";margin-top: 20px;margin-left:20px;font:12px arial,sans-serif;\" id=\"debug1\"></div>
<div style=\"display:" . ( defined('DEBUG') ? 'block' : 'none' ) . ";margin-left: 20px;margin-bottom:20px;font:12px arial,sans-serif;\" id=\"debug2\"></div>
<form name=\"f\" id=\"f\">
<input type=\"hidden\" name=\"polling_utctime\" id=\"polling_utctime\" value=\"{$cad->UTC_Timestamp}\" />
<input type=\"hidden\" name=\"polling_unixtime\" id=\"polling_unixtime\" value=\"{$cad->Unix_Timestamp}\" />
<input type=\"hidden\" name=\"ajaxstatic\" value=\"1\"/>
</form>
<table style=\"background-color:#cccccc;font-family:arial,sans-serif;font-size:9pt;width:100%;\" cellspacing=\"1\" cellpadding=\"3\" id=\"content_table\">
<tr id=\"content_header\">
	<td class=\"bg_header\" style=\"width:75px\">INCIDENT</td>
	<td class=\"bg_header\" style=\"width:125px\">AGENCY</td>
	<td class=\"bg_header\" style=\"width:45px\">BOX</td>		
	<td class=\"bg_header\" style=\"width:45px\">STATION</td>		
	<td class=\"bg_header\" style=\"width:250px\">NATURE</td>	
	<td class=\"bg_header\" style=\"width:70px\">OPEN</td>
	<td class=\"bg_header\" style=\"width:70px\">ENTRY</td>
	<td class=\"bg_header\" style=\"width:70px\">DISPATCH</td>
	<!--<td class=\"bg_header\" style=\"width:70px\">ENROUTE</td>-->
	<!--<td class=\"bg_header\" style=\"width:70px\">ONSCENE</td>-->
	<!--<td class=\"bg_header\" style=\"width:70px\">CLOSE</td>	-->
	<td class=\"bg_header\" >LOCATION</td>
</tr>";

while ( $obj = $cad->res->fetch_object() )
{
	if ( $obj->Location && $obj->CrossSt1 && $obj->CrossSt2 )
	{
		$obj->Location .= " (" . $obj->CrossSt1 . " & " . $obj->CrossSt2 . ")";
	}

	$statcss = "bg_default";
	$statcom = "";
	
	if ( $obj->IncStatus == -1 )
	{
		$statcss = "stat_pending";
		$rowcss = "row_pending";
		$statcom = "Pending";		
	}
	elseif ( $obj->IncStatus == 1 )
	{
		$statcss = "stat_dispatched";
		$rowcss = "row_dispatched";
		$statcom = "Dispatched";
	}	
	elseif ( $obj->IncStatus == 2 )
	{
		$statcss = "stat_enroute";
		$rowcss = "row_enroute";
		$statcom = "Enroute";
	}
	elseif ( $obj->IncStatus == 3 )
	{
		$statcss = "stat_onscene";		
		$rowcss = "row_onscene";
		$statcom = "Onscene";
	}
	elseif ( $obj->IncStatus == 0 )
	{
		$statcss = "stat_closed";
		$rowcss = "row_closed";
		$statcom = "Closed";
	}	
	
	
	print "
	<tr id=\"{$obj->EventNo}\" class=\"$rowcss\">
		<td class=\"$statcss\" title=\"$statcom\">
			<a href=\"/detail/{$obj->EventNo}\" title=\"Incident Detail\">{$obj->IncidentNo}</a>
			<input type=\"hidden\" id=\"timestamp_{$obj->EventNo}\" name=\"timestamp_{$obj->EventNo}\" value=\"{$obj->Timestamp}\"/>" . 
			( $obj->IncStatus == 0 ?
				"<input type=\"hidden\" id=\"status_{$obj->EventNo}\" name=\"{$obj->EventNo}\" value=\"{$obj->Unix_CloseTime}\" closed=\"1\"/>" : NULL 
			) . "
		</td>
		<td class=\"bg_default\" title=\"$statcom\">{$obj->CityName}</td>
		<td class=\"bg_default\" title=\"$statcom\">{$obj->BoxArea}</td>
		<td class=\"bg_default\" title=\"$statcom\">{$obj->StationGrid}</td>				
		<td class=\"bg_default\" title=\"$statcom\">{$obj->Nature}</td>
		<td class=\"bg_default\" title=\"$statcom\">" . strftime("%H:%M:%S", strtotime($obj->CreatedTime) ) ."</td>
		<td class=\"bg_default\" title=\"$statcom\">" . ( $obj->EntryTime ? strftime("%H:%M:%S", strtotime($obj->EntryTime) ) : '' ) . "</td>
		<td class=\"bg_default\" title=\"$statcom\">" . ( $obj->DispatchTime ? strftime("%H:%M:%S", strtotime($obj->DispatchTime) )  : '' ) ."</td>
		<!--<td class=\"bg_default\" title=\"$statcom\">" . ( $obj->EnrouteTime ? strftime("%H:%M:%S", strtotime($obj->EnrouteTime) )  : '' ) ."</td>-->
		<!--<td class=\"bg_default\" title=\"$statcom\">" . ( $obj->OnsceneTime ? strftime("%H:%M:%S", strtotime($obj->OnsceneTime) )  : '' ) ."</td>-->
		<!--<td class=\"bg_default\" title=\"$statcom\">" . ( $obj->CloseTime ? strftime("%H:%M:%S", strtotime($obj->CloseTime) ) : '' ) ."</td>-->		
		<td class=\"bg_default\" title=\"$statcom\">{$obj->LocationAddress}</td>
	</tr>";
}

print "
</table>
<div style=\"margin-top:25px;font-family:arial,sans-serif;font-size:8pt;\">NUMBER OF RECORDS DISPLAYED: $total</div>";

require_once 'footer.php';
?>