<?php

class cad extends AJAX_layer {

	public $agency;
	public $db;
	public $Unix_Timestamp;
	public $UTC_Timestamp;

	public $incident = array();
	public $offset;

	function __construct(&$db, $agency=NULL) 
	{

		$this->db =& $db;
		if ( $_SESSION['agency'] )
			$this->agency = $_SESSION['agency'];
		
		$offset = ( date_offset_get(new DateTime) / 3600 );
		$this->offset = "$offset:00";
	}

	function fetch_incidents()
	{	
		if ( $params = func_get_arg(0) )
		{			
			$order_by = $params['order_by'];
			$order_dir = $params['order_dir'];			
			$ajaxstatic = $params['ajax_static'];
			$ajaxpoll = $params['ajax_poll'];
			$queryinterval = $params['query_interval'];
			$method = $params['method'];	
			$alertqueue = $params['alertqueue'];			
			$agency = $params['agency'];
			$q_timestamp = $params['q_timestamp'];
		}

		if ( ! $method )
		{
			$method = ( $ajaxstatic ? 'ajaxstatic' : 'ajaxpoll' );
		}
		if ( ! $order_by )
		{
			$order_by = "CreatedTime";
		}			
		
		if ( $ajaxstatic ) 
		{
			if ( $q_timestamp ) 
				$sql[] = "t1.Timestamp >= '$q_timestamp' "; //$sql[] = "UNIX_TIMESTAMP(t1.Timestamp) >= $q_timestamp ";
			
			$order_dir = 'DESC';
		}

		if ( $alertqueue )
		{			
			if ( ! $queryinterval )
				$queryinterval = '300';
						
			$sql[] = "t1.Timestamp >= DATE_SUB( NOW(), INTERVAL $queryinterval SECOND ) ";			
			$order_by = 't1.Timestamp';
		}
		else 
		{
			if ( ! $ajaxstatic )
			{
				if ( $params['date'] )
					$sql[] = "DATE( FROM_UNIXTIME( t1.CreatedTime ) ) = '$params[date]' ";
				if ( $params['today'] )
					$sql[] = "DATE( FROM_UNIXTIME( t1.CreatedTime ) ) = DATE( NOW() ) ";
				
				if ( ! $order_dir )
					$order_dir = "DESC";
			}
		}	
		
		if ( $this->agency )
			$sql[] = "t1.Agency = '$this->agency' ";
		
		$total = 0;
		$this->incident = array();												
		
		if (
			$this->res = $this->db->query(
				"SELECT
					NOW() AS UTC_PollTime,
					UNIX_TIMESTAMP() AS Unix_PollTime,
					t1.EventNo,
					CONVERT_TZ( t1.Timestamp, TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') AS Timestamp,
					UNIX_TIMESTAMP( CONVERT_TZ( t1.Timestamp, TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') ) AS Unix_Timestamp,
					t1.Agency,
					t1.CityName,
					t1.CityCode,
					t1.Service,
					t1.IncidentNo,
					FROM_UNIXTIME(t1.CreatedTime) AS CreatedTime,
					t1.CreatedTime AS Unix_CreatedTime,
					IF(t1.EntryTime > 0, FROM_UNIXTIME(t1.EntryTime), NULL) AS EntryTime,
					t1.EntryTime AS Unix_EntryTime,
					IF(t1.DispatchTime > 0, FROM_UNIXTIME(t1.DispatchTime), NULL) AS DispatchTime,
					t1.DispatchTime AS Unix_DispatchTime,
					IF(t1.EnrouteTime > 0, FROM_UNIXTIME(t1.EnrouteTime), NULL) AS EnrouteTime,
					t1.EnrouteTime AS Unix_EnrouteTime,
					IF(t1.OnsceneTime > 0, FROM_UNIXTIME(t1.OnsceneTime), NULL) AS OnsceneTime,
					t1.OnsceneTime AS Unix_OnsceneTime,
					IF(t1.CloseTime > 0, FROM_UNIXTIME(t1.CloseTime), NULL) AS CloseTime,
					t1.CloseTime AS Unix_CloseTime,
					IF(t1.CallType != '' AND t1.CallType IS NOT NULL, t1.CallType, t1.CallTypeOrig) AS CallType,
					IF(t1.Nature != '' AND t1.Nature IS NOT NULL, t1.Nature, t1.NatureOrig) AS Nature,
					t2.CallGroup,
					t1.StationGrid,
					t1.BoxArea,
					t1.LocationAddress,
					t1.PrimaryUnit,
					t1.IncStatus,
					TIMESTAMPDIFF( MINUTE, FROM_UNIXTIME(CreatedTime), CONVERT_TZ(NOW(), TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') ) AS Elapsed
				FROM Incident t1
				LEFT JOIN CallType t2 ON t1.CallType = t2.TypeCode
				WHERE " .
				( $sql ?
					"(" . implode(" AND ", $sql) . ")" : NULL
				) .
				( ! $ajaxstatic && ! $alertqueue ?
					( $sql ? " AND " : NULL ) .
					"(
						IncStatus != 0 
						OR 
						(
							IncStatus = 0 AND TIMESTAMPDIFF( MINUTE, FROM_UNIXTIME(CloseTime), CONVERT_TZ(NOW(), TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') ) < 15 
						)  
					)" : NULL 
				) .
				( $order_by ?
					" ORDER BY $order_by " .
					( $order_dir ?
						"$order_dir" : NULL
					) : NULL
				)			
			)
		) 
		{
			if ( $this->res->num_rows > 0 )
			{
				if ( $datarow = $this->res->fetch_array() )
				{
					$this->UTC_Timestamp = $datarow[0];
					$this->Unix_Timestamp = $datarow[1];
				}
				
				$this->res->data_seek(0);
				
				return $this->res->num_rows;
			}
			else
			{
				$res = $this->db->query("SELECT DATE_SUB(NOW(), INTERVAL 3 SECOND) AS UTC_PollTime, UNIX_TIMESTAMP()-3 AS Unix_PollTime");
				
				if ( $datarow = $res->fetch_array() )
				{
					$this->UTC_Timestamp = $datarow[0];
					$this->Unix_Timestamp = $datarow[1];
				}	

				return 0;
			}
		}
		else
		{						
			$this->__trigger_error("{$this->db->errno} - {$this->db->error}", E_DATABASE_ERROR, __FILE__, __LINE__); 
			return 0;
		}
	}
	
	function fetch_incident($eventno)
	{		
		$this->incidentunit = array();
		$this->narrative = array();
		$this->totalnarrative = 0;
		$this->incidentextra = array();
		$this->numunits = 0;
		$this->numnotes = 0;		

		$r = $this->db->query("
			SELECT t1.EventNo 
			FROM Incident t1
			WHERE t1.IncidentNo = '$eventno'"
		);		
		
		if ( $r->num_rows > 0 )
		{
			$e = $r->fetch_object();
			$eventno = $e->EventNo;
		}				
		
		$this->res = $this->db->query("
			SELECT 
				NOW() AS UTC_LookupTime,
				UNIX_TIMESTAMP() AS Unix_LookupTime,
				CONVERT_TZ( t1.Timestamp, TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') AS Timestamp,
				UNIX_TIMESTAMP( CONVERT_TZ( t1.Timestamp, TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') ) AS Unix_Timestamp,				
				t1.*, 
				FROM_UNIXTIME(t1.CreatedTime) AS CreatedTime,
				t1.CreatedTime AS Unix_CreatedTime,
				IF(t1.EntryTime > 0, FROM_UNIXTIME(t1.EntryTime), NULL) AS EntryTime,
				t1.EntryTime AS Unix_EntryTime,
				IF(t1.DispatchTime > 0, FROM_UNIXTIME(t1.DispatchTime), NULL) AS DispatchTime,
				t1.DispatchTime AS Unix_DispatchTime,
				IF(t1.EnrouteTime > 0, FROM_UNIXTIME(t1.EnrouteTime), NULL) AS EnrouteTime,
				t1.EnrouteTime AS Unix_EnrouteTime,
				IF(t1.OnsceneTime > 0, FROM_UNIXTIME(t1.OnsceneTime), NULL) AS OnsceneTime,
				t1.OnsceneTime AS Unix_OnsceneTime,
				IF(t1.CloseTime > 0, FROM_UNIXTIME(t1.CloseTime), NULL) AS CloseTime,
				t1.CloseTime AS Unix_CloseTime,
				t1.CallTypeOrig,
				t1.NatureOrig,
				t1.CallType,
				t1.Nature,
				REPLACE(t1.LocationAddress, CONCAT(', ', IFNULL( t1.CityCode, '' ) ), '') AS LocationAddress,
				t1.MapGrid,
				t2.CallGroup,
				t4.CrossStreet1,
				t4.CrossStreet2,
				TIMESTAMPDIFF( MINUTE, FROM_UNIXTIME(CreatedTime), CONVERT_TZ(NOW(), TIME_FORMAT( NOW() - UTC_TIMESTAMP(), '+%H:%i' ), '$this->offset') ) AS Elapsed 
			FROM Incident t1 
			LEFT JOIN CallType t2 ON t1.CallType = t2.TypeCode
			LEFT JOIN IncidentGeoInfo t4 ON t1.IncidentNo = t4.IncidentNo							
			WHERE t1.EventNo = '$eventno'"
		);					
	
		if ( $this->res->num_rows > 0 )
		{		
			if (
				$res2 = $this->db->query("
					SELECT EntryCrossStreets AS XStreets
					FROM IncidentNotes
					WHERE EventNo = '$eventno' AND EntryCrossStreets IS NOT NULL
					GROUP BY EventNo
					ORDER BY EntrySequence DESC
					LIMIT 1")
			)
			{
				if ( $obj = $res2->fetch_object() )
				{
					$this->incidentextra['XStreets'] = $obj->XStreets;
				}
			}
			
			if (
				$res2 = $this->db->query("
					SELECT EntryMapGrid AS MapGrid 
					FROM IncidentNotes
					WHERE EventNo = '$eventno' AND EntryMapGrid IS NOT NULL
					GROUP BY EventNo
					ORDER BY EntrySequence DESC
					LIMIT 1")
			)
			{
				if ( $obj = $res2->fetch_object() )
				{
					$this->incidentextra['MapGrid'] = $obj->MapGrid;
				}
			}			
			
			if ( 
				$res2 = $this->db->query("
					SELECT 
						t1.Unit,
						IF( t1.Dispatch > 0, FROM_UNIXTIME( t1.Dispatch ), NULL) AS DispatchTime,
						IF( t1.Enroute > 0, FROM_UNIXTIME( t1.Enroute ), NULL) AS EnrouteTime, 
						IF( t1.OnScene > 0, FROM_UNIXTIME( t1.OnScene ), NULL) AS OnSceneTime, 
						IF( t1.InService > 0, FROM_UNIXTIME( t1.InService ), NULL) AS InServiceTime,  
						t1.Closed
					FROM IncidentUnit t1
					LEFT JOIN IncidentNotes t2 ON t1.EventNo = t2.EventNo AND t1.Unit = t2.EntryUnit AND t2.EntryType IN ('DISP', 'DISPER', 'DISPOS', 'XDISP', 'BACKER', 'BACKUP', 'BACKOS') 
					WHERE t1.EventNo = '$eventno'
					ORDER BY t2.EntrySequence ASC")
			)
			{
				while ( $obj = $res2->fetch_object() )
				{
					$this->numunits++;
					array_push($this->incidentunit, $obj);				
				}
			}				
			
			if ( 
				$res2 = $this->db->query("
					SELECT
						EntryId,
						EntrySequence,
						EventNo,
						IncidentNo,
						FROM_UNIXTIME(EntryUTCTime) AS EntryTime,
						EntryUTCTime AS EntryUnixTime,
						EntryType,
						EntryText
					FROM IncidentNotes 
					WHERE EventNo = '$eventno'
					ORDER BY EntrySequence ASC")
			)
			{
			while ( $obj = $res2->fetch_object() )
				{
					$this->numnotes++;
					
					if ( $obj->EntryType == 'CHANGE' )
					{
						$res3 = $this->db->query("
							SELECT
								EntryId,
								EntrySequence,
								EventNo,
								IncidentNo,
								FROM_UNIXTIME(EntryUTCTime) AS EntryTime,
								EntryUTCTime AS EntryUnixTime,
								EntryType,
								EntryText
								FROM IncidentNotes
								WHERE EventNo = '$eventno'
								ORDER BY EntrySequence ASC")
					
					}
					
					array_push($this->narrative, $obj);				
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	function recent_narrative()
	{
		if ( $params = func_get_arg(0) )
		{
			$ajaxstatic = $params['ajax_static'];
			$EventNo = $params['EventNo'];
			$LastEntry = $params['LastEntry'];
		}
		
		$this->narrative = array();
		$this->totalnarrative = 0;
		
		if (
			$this->res = $this->db->query("
				SELECT 
					EntryId,
					EntrySequence,
					EntryTime,
					EntryUTCTime,
					EntryType,
					EntryFDID,
					EntryText 
				FROM IncidentNotes
				WHERE EventNo = '$EventNo' " . ( $LastEntry ? "AND EntrySequence > '$LastEntry'" : NULL ) . "
				ORDER BY EntrySequence ASC" 
			)
		)
		{					
			return $this->res->num_rows;
		}
		
		return 0;
	}
}





















?>