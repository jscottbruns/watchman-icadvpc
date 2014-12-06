<?php

class cad {

	public $county;
	public $db;
	public $timestamp = 0;

	public $incident = array();

	function __construct(&$db, $county) {

		$this->db =& $db;
		$this->county = $county;
	}

	function fetch_incidents()
	{
		if ( $params = func_get_arg(0) )
		{
			if ( $params['date'] )
			{


			}

	'sql'		=>	( $ajaxstatic ? "OpenTime > DATE_FORMAT( DATE_SUB(NOW(), INTERVAL 60 MINUTE), '%T')" : $sql ),
	'order_by'	=>	'OpenTime',
	'order_dir'	=>	$order_dir,
	'method'	=>	( $ajaxstatic ? 'ajaxstatic' : 'ajaxpoll' )
			$sql = $params['sql'];
			$order_by = $params['order_by'];
			$order_dir = $params['order_dir'];
			$method = $params['method'];
		}

		$total = 0;
		$this->incident = array();
		$this->timestamp = time();

		$r = $this->db->query(
			"SELECT
				IncidentNo,
				EventNo,
				Timestamp,
				OpenTime,
				CloseTime,
				CallType,
				Nature,
				BoxArea,
				Location,
				CrossSt1,
				CrossSt2,
				Priority
			FROM Incident
			WHERE DATE( EntryTime ) = '$date' " .
			( $sql ?
				"AND $sql " : NULL
			) .
			( $order_by ?
				"ORDER BY $order_by " .
				( $order_dir ?
					"$order_dir" : NULL
				) : NULL
			)
		);
		while ( $row = $this->db->fetch_assoc($r) )
		{
			$total++;
			array_push($this->incident, $row);
		}

		return $total;
	}
}

?>