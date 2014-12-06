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

	function fetch_incidents() {

		if ( $params = func_get_arg(0) ) {

			$date = $params['date'];
			$sql = $params['sql'];
			$order_by = $params['order_by'];
			$order_dir = $params['order_dir'];
			$method = $params['method'];
		}

		$total = 0;
		$this->incident = array();
		$this->timestamp = time();

		$r = $this->db->query("SELECT t1.*
							   FROM incidentpoll t1
							   WHERE t1.incident_date = '$date' AND t1.county_code = '{$this->county}' " .
							   ( $sql ?
								   "AND $sql " : NULL
							   ) .
							   ( $order_by ?
								   "ORDER BY $order_by " .
								   ( $order_dir ?
								   "$order_dir" : NULL
								   ) : NULL
							   ) );
		while ( $row = $this->db->fetch_assoc($r) ) {

			$total++;
			array_push($this->incident, $row);
		}

		return $total;
	}
}

?>