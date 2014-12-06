<?php
/***********************************************************************

  Copyright (C) 2002-2005  Rickard Andersson (rickard@punbb.org)

  This file is part of PunBB.

  PunBB is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 2 of the License,
  or (at your option) any later version.

  PunBB is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA  02111-1307  USA

************************************************************************/


// Make sure we have built in support for MySQL
if ( ! function_exists('mysqli_connect') )
	exit('This PHP environment doesn\'t have MySQLi support built in. Dealer-Choice needs MySQL database support in order to function properly.');

// Make sure no one attempts to run this script "directly"
//if ( ! defined('APPLICATION_PATH') )
	//exit;

//
// Return current timestamp (with microseconds) as a float (used in dblayer)
//

function get_microtime() {

	list($usec, $sec) = explode(' ', microtime());
	return ((float)$usec + (float)$sec);
}

class DBLayer extends mysqli 
{

	var $prefix;
	var $link_id;
	var $query_result;
	public $db_error;
	public $db_errno;
	var $connection_id;
	var $version;
	var $current_user;

	// Character set stuff
	public $character_set_client;
	public $character_set_connection;
	public $character_set_database;
	public $character_set_results;
	public $character_set_server;
	public $character_set_system;

	var $saved_queries = array();
	var $num_queries = 0;

	var $transaction;
	var $transaction_queries;
	var $deadlock;

	public $session_vars = array();
	
	public function __construct($db_host, $db_username, $db_password, $db_name, $charset='', $collation='') 
	{
		parent::init();
		$this->prefix = NULL;

		if ( ! parent::options(MYSQLI_INIT_COMMAND, 'SET AUTOCOMMIT = 0') ) 
		{
			$this->db_error = 'Setting MYSQLI_INIT_COMMAND failed';
			return false;
		}
		
		if ( ! parent::options(MYSQLI_OPT_CONNECT_TIMEOUT, 5) ) 
		{
			$this->db_error = 'Setting MYSQLI_OPT_CONNECT_TIMEOUT failed';
			return false;
		}
		
		if ( ! parent::real_connect($db_host, $db_username, $db_password, $db_name) ) 
		{
			$this->db_error = mysqli_connect_error();
			$this->db_errno = mysqli_connect_error();
			
			return false;
		}		
		
		$res = $this->query("SELECT CONNECTION_ID() AS CID , VERSION() AS VID");
		if ( $obj = $res->fetch_object() )
		{			
			$this->connection_id = $obj->CID;
			$this->version = $obj->VID;
		}
	}	

    function set_timezone($zone) 
    {
        $this->query("SET time_zone = '{$zone}'");
        return true;
    }
	
	function result($res, $r = 0, $c = NULL) 
	{
		if ( $r > 0 )
		{
			$res->data_seek($r);
		}
		
		if ( $row = $res->fetch_assoc() )
		{
			if ( $c )
			{
				return $row[$c];				
			}
			
			return $row;
		}
		
		return;
	}

	function fetch_obj()
	{
		if ( method_exists($this, 'fetch_object') )
			return $this->fetch_object();
		
		return false;
	}
	
/*
	function fetch_assoc($query_id = 0) {
		return ($query_id) ? @mysql_fetch_assoc($query_id) : false;
	}

	function fetch_array($query_id = 0) {
		return ($query_id) ? @mysql_fetch_array($query_id) : false;
	}

	function fetch_row($query_id = 0) {
		return ($query_id) ? @mysql_fetch_row($query_id) : false;
	}


	function num_rows($query_id = 0) {
		return ($query_id) ? @mysql_num_rows($query_id) : false;
	}


	function affected_rows() {
		return ($this->link_id) ? @mysql_affected_rows($this->link_id) : false;
	}


	function insert_id() {
		return ($this->link_id) ? @mysql_insert_id($this->link_id) : false;
	}


	function get_num_queries() {
		return $this->num_queries;
	}


	function get_saved_queries() {
		return $this->saved_queries;
	}


	function free_result($query_id = false) {
		return ($query_id) ? @mysql_free_result($query_id) : false;
	}

*/
	function escape($str) 
	{
		return $this->real_escape_string($str);
	}

/*
	function error() {
		$result['error_sql'] = @current(@end($this->saved_queries));
		$result['error_no'] = @mysql_errno($this->link_id);
		$result['error_msg'] = @mysql_error($this->link_id);

		return $result;
	}


	function close() {
		if ($this->transaction === true)
			$this->end_transaction(1);

		if ($this->link_id) {
			if (is_resource($this->query_result))
				@mysql_free_result($this->query_result);

			return @mysql_close($this->link_id);
		}
		else
			return false;
	}


	function prepare_query($value_array,$table,$q_type,$drop_array=NULL,$add_array=NULL) {
		$keys = array_keys($value_array);
		$values = array_values($value_array);

		$result = $this->query("SHOW COLUMNS FROM `".$table."`");
		while ($row = $this->fetch_assoc($result))
			$field[] = $row['Field'];

		$drop_fields = array_diff($keys,$field);

		if (is_array($drop_fields)) {
			while (list($key) = each($drop_fields))
				unset($keys[$key],$values[$key]);

			$keys = array_values($keys);
			$values = array_values($values);
		}

		//Remove empty items
		if ($q_type == 'INSERT') {
			while (list($key,$val) = each($values)) {
				if (!$val)
					unset($keys[$key],$values[$key]);
			}
			$keys = @array_values($keys);
			$values = @array_values($values);
		}

		@array_walk($keys,'wrap_array',"`");
		@array_walk($values,'wrap_array',"'");

		if (strtoupper($q_type) == 'INSERT')
			return @array_combine($keys,$values);
		else {
			for ($i = 0; $i < count($keys); $i++)
				$sql[] = $keys[$i]." = ".$values[$i];

			return $sql;
		}
	}

	function server_info() {
		return mysql_get_server_info($this->link_id);
	}

	function resolve_deadlock($timeout_query=NULL) {
		$max_attempts = 50;
		$current = 0;

		while ($current++ < $max_attempts) {
			$res = $this->deadlock_query_loop($timeout_query);

			if (!$res && ($this->db_errno == 1213 || $this->db_errno == 1205))
				continue;
			else {
				if ($res)
					return $res;
				else
					return false;
			}
		}

		return false;
	}

	function deadlock_query_loop($timeout_query=NULL) {
		if ($timeout_query)
			$q = array($timeout_query);
		else
			$q =& $this->transaction_queries;

		for ($i = 0; $i < count($q); $i++) {
			$res = $this->query($q[$i]);

			return $res;
		}

		return true;
	}

    function set_charset($charset,$collation='') {

    	if ($charset)
        	$this->query("SET NAMES {$charset}");
        if ($collation)
            $this->query("SET CHARACTER SET {$collation}");

        $r = $this->query("SHOW VARIABLES LIKE 'character_set_%'");
        while ($row = $this->fetch_assoc($r)) {
            if (property_exists(get_class($this),$row['Variable_name']))
                $this->{$row['Variable_name']} = $row['Value'];
        }
        $r = $this->query("SHOW VARIABLES LIKE 'collation%'");
        while ($row = $this->fetch_assoc($r)) {
            if (property_exists(get_class($this),$row['Variable_name']))
                $this->{$row['Variable_name']} = $row['Value'];
        }
    }

    function set_timezone($zone) {
        $this->query("SET time_zone = '{$zone}'");
        return true;
    }

    function define($var,$val) {
        if ($this->query("SET @{$var} = '{$val}'"))
            return true;

        return false;
    }

    function seek($result, $row) {

    	if ( ! mysql_data_seek($result, $row) ) {

            $this->db_error = "MySQL data seek error to row $row " . mysql_error();
            $this->db_errno = mysql_errno();

    		return false;
    	}

    	return true;
    }
    */
}