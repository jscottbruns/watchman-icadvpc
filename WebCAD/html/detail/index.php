<?php
require '/var/www/icad-poll/include/common.php';

$uri = $_SERVER['REDIRECT_URL'];
if ( ! ( preg_match('/^\/detail\/(.*)$/', $uri, $matches) ) )
{
	trigger_error("Invalid server redirect URL {$_SERVER['REDIRECT_URL']}", E_USER_ERROR);
	header('HTTP/1.1 403 Forbidden');
	exit;
}

$eventno = $matches[1];

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) {

	header("Location: /login.php?r=" . base64_encode("/detail/$eventno"));
	exit;
}

if ( $_POST['AlertQueueDetail'] )
{
	require '/var/www/icad-poll/include/xml.class.php';
	require '/var/www/icad-poll/include/json/JSON.php';
}

require_once 'header.php';

$cad = new cad($db, $agency);

if ( $cad->fetch_incident( $eventno ) )
{
	$obj = $cad->res->fetch_object();
	
	$obj->CrossStreets = $cad->incidentextra['XStreets'];
	
	if ( ! trim( $obj->MapGrid ) && $cad->incidentextra['MapGrid'] )
		$obj->MapGrid = $cad->incidentextra['MapGrid'];
	
	if ( $obj->IncStatus == -1 )
		$stat = 'PENDING';
	
	if ( $obj->IncStatus == 1 )
		$stat = 'DISPATCHED';
	
	if ( $obj->IncStatus == 2 )
		$stat = 'ENROUTE';
	
	if ( $obj->IncStatus == 3 )
		$stat = 'ONSCENE';
	
	if ( $obj->IncStatus == 0 )
		$stat = 'CLOSED';	
	
	if ( $obj->LocationAddress && $obj->GPSLatitude && $obj->GPSLongitude )
	{		
		$dest_url = "https://maps.google.com/maps?z=16&t=m&q=$obj->GPSLongitude" . '+' . "$obj->GPSLatitude";
		if ( preg_match('/Android/i', $_SERVER['HTTP_USER_AGENT']) )
		{
			if ( preg_match('@^https://maps.google.com/maps\?z=([0-9]{1,})&t=([a-zA-Z]{1,})&q=(-?[\d\.]*)\+(-?[\d\.]*)$@', $dest_url, $m) )
				$dest_url = "geo:{$obj->GPSLongitude},{$obj->GPSLatitude}?z=16&q={$obj->GPSLongitude},{$obj->GPSLatitude}";
		}
		$obj->LocationAddress = "<a href=\"$dest_url\" target=\"_blank\">$obj->LocationAddress</a>";
	}
	
	if ( $obj->CrossStreets )
	{
		$XStreets = preg_replace('/^btwn\s(.*?)\sand\s(.*)$/', "($1 & $2)", $obj->CrossStreets);
		if ( $XStreets )
			$obj->LocationAddress .= " $XStreets";
		elseif ( $obj->CrossStreets )
			$obj->LocationAddress .= " {$obj->CrossStreets}";
	}
	elseif ( $obj->CrossStreet1 && $obj->CrossStreet2 )
	{
		$obj->LocationAddress .= " (" . $obj->CrossStreet1 . " & " . $obj->CrossStreet2 . ")";
	}

	print "	
	<table style=\"width:100%;\" cellspacing=\"0\">
	<tr>
		<td>
			<div style=\"font-size: large; margin-top: 15px; \">Incident History Detail - " . ( $obj->Service == 'F' ? 'Fire' : 'EMS' ) . " Event #$obj->IncidentNo</div>
			<div style=\"font-size: 8pt; margin-left:10px;margin-bottom:15px;\">
				<a href=\"/index.php\" style=\"text-decoration:none; color: #000;\"><< back to active incidents</a>
			</div>
		</td>
	</tr>
	<tr>
		<td>
		<table style=\"background-color:#cccccc;font-size:10pt;width:800px;font-family:arial;\" cellspacing=\"1\" cellpadding=\"4\" id=\"header_detail\">
			<tr>
				<td style=\"width:125px;background-color:#efefef;\">INITIATE TIME:</td>
				<td style=\"width:195px;background-color:#fff\">{$obj->CreatedTime}</td>
				<td style=\"width:125px;background-color:#efefef;\">INCIDENT NO:</td>
				<td style=\"background-color:#fff\">{$obj->IncidentNo}</td>
			</tr>
			<tr>
				<td style=\"background-color:#efefef;\">ENTRY TIME:</td>
				<td style=\"background-color:#fff\">" . date("H:i:s", strtotime($obj->EntryTime)) . "</td>
				<td style=\"background-color:#efefef;\">CURR STATUS:</td>
				<td style=\"background-color:#fff\">$stat</td>
			</tr>
			<tr>
				<td style=\"background-color:#efefef;\">DISPATCH TIME:</td>
				<td style=\"background-color:#fff\">" . ( $obj->DispatchTime > 0 ? date("H:i:s", strtotime($obj->DispatchTime)) : NULL ) . "</td>
				<td style=\"background-color:#efefef;\">DISTRICT:</td>
				<td style=\"background-color:#fff\">{$obj->District}</td>
			</tr>
			<tr>
				<td style=\"background-color:#efefef;\">ENROUTE TIME:</td>
				<td style=\"background-color:#fff\">" . ( $obj->EnrouteTime > 0 ? date("H:i:s", strtotime($obj->EnrouteTime)) : NULL ). "</td>
				<td style=\"background-color:#efefef;\">REPORT NO:</td>
				<td style=\"background-color:#fff\">{$obj->ReportNo}</td>
			</tr>
			<tr>
				<td style=\"background-color:#efefef;\">ONSCENE TIME:</td>
				<td style=\"background-color:#fff\">" . ( $obj->OnsceneTime > 0 ? date("H:i:s", strtotime($obj->OnsceneTime)) : NULL ). "</td>
				<td style=\"background-color:#efefef;\">AGENCY NO:</td>
				<td style=\"background-color:#fff\">{$obj->Agency}</td>
			</tr>
			<tr>
				<td style=\"background-color:#efefef;\">CLOSE TIME:</td>
				<td style=\"background-color:#fff\">" . ( $obj->CloseTime > 0 ? date("H:i:s", strtotime($obj->CloseTime)) : NULL ). "</td>
				<td style=\"background-color:#efefef;\">AGENCY NAME:</td>
				<td style=\"background-color:#fff\">{$obj->CityName}</td>
			</tr>
		</table>	
		<div style=\"margin-top:15px;\">
		<table style=\"font-size:10pt;width:800px;font-family:arial;\" cellspacing=\"1\" id=\"primary_detail\">
			<tr>
				<td style=\"width:125px;vertical-align:top;padding: 1px 5px;\">LOCATION: </td>
				<td colspan=\"3\" style=\"padding: 1px 5px;\">{$obj->LocationAddress}</td>
			</tr>
			<tr>
				<td style=\"width:125px;vertical-align:top;padding: 1px 5px;\">LOCATION NOTE: </td>
				<td colspan=\"3\" style=\"padding: 1px 5px;\">{$obj->LocationNote}</td>
			</tr>" . 
			( $obj->CallerName || $obj->CallerPhone || $obj->CallerAddress ? 
				"<tr>
					<td style=\"width:125px;vertical-align:top;padding: 1px 5px;\">CALLING PARTY: </td>
					<td colspan=\"3\" style=\"padding: 1px 5px;\">{$obj->CallerName} {$obj->CallerPhone} {$obj->CallerAddress}</td>
				</tr>" : NULL 
			) . "			
		</table>
		</div>
		
		<div style=\"margin-top:15px;\">
		<table style=\"font-size:10pt;width:800px;font-family:arial;\" cellspacing=\"1\" id=\"secondary_detail\">		
			<tr>
				<td style=\"width:125px;vertical-align:top;padding: 1px 5px;\">TYPE / NATURE: </td>
				<td colspan=\"3\" style=\"padding: 1px 5px;\">[{$obj->CallTypeOrig}] {$obj->NatureOrig}</td>
			</tr>" .
			( $obj->CallTypeOrig != $obj->CallType || $obj->NatureOrig != $obj->Nature ?
			"<tr>
				<td style=\"width:125px;vertical-align:top;padding: 1px 5px;\">CALLTYPE FINAL: </td>
				<td colspan=\"3\" style=\"padding: 1px 5px;\">[{$obj->CallType}] {$obj->Nature}</td>
			</tr>" : NULL 
			) . "
			<tr>
				<td style=\"width:125px;padding: 1px 5px;\">BOX / ZONE: </td>
				<td style=\"width:195px;padding: 1px 5px;\">{$obj->BoxArea}</td>
				<td style=\"width:125px;padding: 1px 5px;\">STATION: </td>
				<td style=\"padding: 1px 5px;\">{$obj->StationGrid}</td>
			</tr>
			<tr>
				<td style=\"width:125px;padding: 1px 5px;\">MAP GRID: </td>
				<td style=\"width:195px;padding: 1px 5px;\">{$obj->MapGrid}</td>
				<td style=\"width:125px;padding: 1px 5px;\">PRIORITY: </td>
				<td style=\"padding: 1px 5px;\">{$obj->Priority}</td>
			</tr>				
		</table>
		</div>	
	
		<div style=\"margin-top:15px;font-size:10pt;width:800px;font-family:arial;\">
		<table cellspacing=\"1\">
		<tr>
			<td style=\"vertical-align:top; width: 125px;padding:1px 5px;\">ASSIGNED: </td>
			<td>";
		
			for ( $i = 0; $i < count($cad->incidentunit); $i++ )
			{
				print "{$cad->incidentunit[$i]->Unit}&nbsp;&nbsp;";
			}
		
		print "
			</td>
		</tr>
		</table>
		</div>
	
		<div style=\"margin-top:15px;\">
		<table style=\"font-size:9pt;width:800px;font-family:arial;\" cellspacing=\"1\" cellpadding=\"4\" id=\"narrative_detail\">";
		
		$totalnotes = $cad->numnotes - 1;
		for ( $i = 0; $i < count($cad->narrative); $i++ )
		{
			$narr = $cad->narrative[$i]->EntryText;
			$type = $cad->narrative[$i]->EntryType;
				
			if ( $type == 'DISP' )
				$type = 'DISPATCH';
			
			print "
			<tr>
				<td style=\"width:55px;vertical-align:top;border-left:1px solid #cccccc;border-top:1px solid #cccccc;background-color:#efefef;" . ( $i == $totalnotes ? "border-bottom:1px solid #ccc;" : NULL ) ."\">" . ( $i == $totalnotes ? "" : NULL ) . date("H:i:s", strtotime($cad->narrative[$i]->EntryTime)) . "</td>
				<td style=\"width:60px;vertical-align:top;border-top:1px solid #cccccc;background-color:#efefef;border-right:1px solid #cccccc;" . ( $i == $totalnotes ? "border-bottom:1px solid #ccc;" : NULL ) ."\">$type</td>
				<td style=\"border-right:1px solid #cccccc;border-top:1px solid #cccccc;background-color:#fff;" . ( $i == $totalnotes ? "border-bottom:1px solid #ccc;" : NULL ) ."\">" . preg_replace('/(\[)(.*?)(])/', "<span style=\"color:blue\">$2</span>" , $narr) . "</td>
			</tr>";
		}
			
		print "
		</table>
		</div>
		</td>
	</tr>
	</table>
	</div>";
}
else
{
	print "
	<div style=\"margin-left:15px;font-family:arial;\"><span style=\"color:#ff0000;\">Error </span>- Invalid Incident Event Number</div>";
}

print "
<form name=\"f\" id=\"f\">
	<input type=\"hidden\" name=\"polling_utctime\" id=\"polling_utctime\" value=\"{$cad->UTC_Timestamp}\" />
	<input type=\"hidden\" name=\"polling_unixtime\" id=\"polling_unixtime\" value=\"{$cad->Unix_Timestamp}\" />
	<input type=\"hidden\" name=\"ajaxstatic\" value=\"1\"/>
	<input type=\"hidden\" name=\"PollRequest\" value=\"incdetail\"/>
	<input type=\"hidden\" name=\"EventNo\" value=\"{$obj->EventNo}\"/>
	<input type=\"hidden\" name=\"LastEntrySeq\" value=\"{$cad->narrative[$totalnotes]->EntrySequence}\"/>
	<input type=\"hidden\" name=\"LastTimestamp\" value=\"{$cad->narrative[$totalnotes]->EntryTime}\"/>
</form>";

require_once 'footer.php';
?>