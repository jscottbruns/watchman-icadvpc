<?php
require '/var/www/icad-poll/include/common.php';
require '/var/www/icad-poll/include/xml.class.php';
require '/var/www/icad-poll/include/json/JSON.php';

$login_class = new login_class($db);

if ( ! $login_class->user_isloggedin() ) 
{
	header("Location: login.php?r=" . base64_encode('/poll.php'));
	exit;
}
#HTTP_REFERER http://icad.pittsburghpa.fhwm.net:8080/detail/B1F290A50B8C358

if ( $_POST['OrderDir'] )
	$order_dir = $_POST['OrderDir'];
if ( $_POST['OrderBy'] )
	$order_by = $_POST['OrderBy'];
if ( $_POST['QueryInterval'] )
	$query_interval = $_POST['QueryInterval'];

$format = 'json';
if ( $_POST['format'] && $_POST['format'] == 'xml' )
	$format = 'xml';

if ( $_POST['ajaxstatic'] )
{
	$ajaxstatic = 1;
	$order_dir = 'DESC';
	$poll_utctime = $_POST['polling_utctime'];
	$poll_unixtime = $_POST['polling_unixtime'];
	$query_timestamp = $poll_utctime;
	$PollRequest = $_POST['PollRequest'];	
}
elseif ( $_POST['ajaxpoll'] )
{
	$ajaxpoll = 1;
}

if ( $_POST['AlertQueue'] )
	$AlertQueue = 1;
if ( $_POST['Date'] )
	$PostDate = $_POST['Date'];

$cad = new cad($db);

if ( $PollRequest == 'incdetail' )
{
	$LastEntrySeq = $_POST['LastEntrySeq'];
	$LastTimestamp = $_POST['LastTimestamp'];
	$EventNo = $_POST['EventNo'];
	
	$total = $cad->recent_narrative( array(		
		'ajax_static'		=> $ajaxstatic,
		'q_timestamp'		=> $query_timestamp,			
		'EventNo'			=> $EventNo,
		'LastEntry'			=> $LastEntrySeq,
		'LastTimestamp'		=> $LastTimestamp
	) );
	
	$json = new Services_JSON();
	$json_hash = array(
		'EventNo'			=> $EventNo,
		'PollRequest'		=> 'incdetail',
		'Total'				=> 0,
		'LastTimestamp'		=> $LastTimestamp,
		'LastEntrySeq'		=> $LastEntrySeq,
		'IncidentListing'	=> array()
	);
	
	$t = $seq = $ts = 0;
	
	if ( $total )
	{
		while ( $obj = $cad->res->fetch_object() )
		{
			$t++;
			$seq = $obj->EntrySequence;
			$ts = $obj->EntryTime;
			
			array_push(
				$json_hash['IncidentListing'],
				array(
					'EntryId'		=> $obj->EntryId,
					'EntrySequence'	=> $obj->EntrySequence,
					'EntryTime'		=> $obj->EntryTime,
					'EntryUTCTime'	=> $obj->EntryUTCTime,
					'EntryType'		=> $obj->EntryType,
					'EntryFDID'		=> $obj->EntryFDID,
					'EntryText'		=> htmlspecialchars_uni( trim( $obj->EntryText ) )
				)
			);
		}
		
		$json_hash['Total'] = $t;
		$json_hash['LastEntrySeq'] = $seq;
		$json_hash['LastTimestamp'] = $ts;
	}
}
else
{
	$total = $cad->fetch_incidents( array(
		'alertqueue'		=> $AlertQueue,
		'date'				=> $PostDate,
		'ajax_poll'			=> $ajaxpoll,
		'ajax_static'		=> $ajaxstatic,
		'q_timestamp'		=> $query_timestamp,
		'query_interval'	=> $query_interval,
		'order_by'			=> $order_by,
		'order_dir'			=> $order_dir
	) );

	if ( $format == 'xml' )
	{
		$xml = new XML_Builder('text/xml', 'UTF-8');
		$xml->add_group('poll');
		
		$xml->add_tag('IncidentDate', $date);
		$xml->add_tag('PollRequest', 'incpoll');
		$xml->add_tag('AgencyCode', $cad->agency);
		$xml->add_tag('UTC_Timestamp', $cad->UTC_Timestamp);
		$xml->add_tag('Unix_Timestamp', $cad->Unix_Timestamp);
		$xml->add_tag('Total', $total);
	}
	else
	{
		$json = new Services_JSON();
		$json_hash = array(
			'PollRequest'		=> 'incpoll',
			'IncidentDate'		=> $data,
			'AgencyCode'		=> $cad->agency,
			'UTC_Timestamp'		=> $cad->UTC_Timestamp,
			'Unix_Timestamp'	=> $cad->Unix_Timestamp,
			'Total'				=> $total
		);
	}	
	
	if ( $total > 0 ) 
	{
		if ( $format == 'xml' )
		{
			$xml->add_group('IncidentListing');
		}
		else
		{
			$json_hash['IncidentListing'] = array();		
		}
		
		while ( $obj = $cad->res->fetch_object() )
		{
			if ( $format == 'xml' )
			{
				$xml->add_tag(
					'Incident',
					'',
					array(
							'Timestamp'		=> $obj->Unix_Timestamp,
							'UTC_Timestamp'	=> $obj->Timestamp,
							'Agency'		=> htmlspecialchars_uni( trim($obj->Agency) ),
							'Service'		=> trim($obj->Service),
							'City'			=> htmlspecialchars_uni( trim($obj->CityName) ),
							'CityCode'		=> htmlspecialchars_uni( trim( $obj->CityCode ) ),
							'CallNo'		=> trim($obj->EventNo),
							'IncidentNo'	=> trim($obj->IncidentNo),
							'Status'		=> trim($obj->IncStatus),
							'CreatedTime'	=> $obj->Unix_CreatedTime,
							'EntryTime'		=> $obj->Unix_EntryTime,
							'DispatchTime'	=> $obj->Unix_DispatchTime,
							'EnrouteTime'	=> $obj->Unix_EnrouteTime,
							'OnsceneTime'	=> $obj->Unix_OnsceneTime,
							'CloseTime'		=> $obj->Unix_CloseTime,
							'Pri'			=> trim($obj->Priority),
							'CallType'		=> trim($obj->CallType),
							'CallGroup'		=> trim($obj->CallGroup),
							'Nature'		=> htmlspecialchars_uni( trim($obj->Nature) ),
							'Box'			=> trim($obj->BoxArea),
							'Station'		=> trim($obj->StationGrid),
							'Location'		=> htmlspecialchars_uni( trim($obj->LocationAddress) )
					)
				);			
			}
			else
			{
				array_push( 
					$json_hash['IncidentListing'], 
					array(
						'Timestamp'		=> $obj->Unix_Timestamp,
						'UTC_Timestamp'	=> $obj->Timestamp,
						'Agency'		=> htmlspecialchars_uni( trim( $obj->Agency ) ),
						'Service'		=> trim($obj->Service),
						'City'			=> htmlspecialchars_uni( trim( $obj->CityName ) ),
						'CityCode'		=> htmlspecialchars_uni( trim( $obj->CityCode ) ),
						'CallNo'		=> trim($obj->EventNo),
						'IncidentNo'	=> trim($obj->IncidentNo),
						'Status'		=> trim($obj->IncStatus),
						'CreatedTime'	=> $obj->Unix_CreatedTime,
						'CreatedTimeStr'=> ( $obj->Unix_CreatedTime > 0 ? date("H:i:s", strtotime($obj->CreatedTime)) : ''),
						'EntryTime'		=> $obj->Unix_EntryTime,
						'EntryTimeStr'	=> ( $obj->Unix_EntryTime > 0 ? date("H:i:s", strtotime($obj->EntryTime)) : ''),						
						'DispatchTime'	=> $obj->Unix_DispatchTime,
						'DispatchTimeStr'	=> ( $obj->Unix_DispatchTime > 0 ? date("H:i:s", strtotime($obj->DispatchTime)) : ''),
						'EnrouteTime'	=> $obj->Unix_EnrouteTime,
						'EnrouteTimeStr'=> ( $obj->Unix_EnrouteTime > 0 ? date("H:i:s", strtotime($obj->EnrouteTime)) : ''),
						'OnsceneTime'	=> $obj->Unix_OnsceneTime,
						'OnsceneTimeStr'=> ( $obj->Unix_OnsceneTime > 0 ? date("H:i:s", strtotime($obj->OnsceneTime)) : ''),
						'CloseTime'		=> $obj->Unix_CloseTime,
						'CloseTimeStr'	=> ( $obj->Unix_CloseTime > 0 ? date("H:i:s", strtotime($obj->CloseTime)) : ''),
						'Pri'			=> trim($obj->Priority),
						'CallType'		=> trim($obj->CallType),
						'CallGroup'		=> trim($obj->CallGroup),
						'Nature'		=> htmlspecialchars_uni( trim( $obj->Nature ) ),
						'Box'			=> trim($obj->BoxArea),
						'Station'		=> trim($obj->StationGrid),
						'Location'		=> htmlspecialchars_uni( trim( $obj->LocationAddress ) )
					)
				);
			}
		}
	
		if ( $format == 'xml' )
		{
			$xml->close_group();
		}
	}
}

if ( $format == 'xml' )
{
	$xml->close_group();
	$xml->print_xml();	
}
else
{
	@header('Content-Type: application/json');
	echo $json->encode( $json_hash );
	header('Content-Length: ' . ob_get_length());
	ob_end_flush();	
}

exit;