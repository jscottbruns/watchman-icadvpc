
<?php

class database {

	private $host;			
	private $user;		
	private $password;	
	private $database;	
	private $conn;
	
	function __construct($hostName = "", $userName = "", $passwordName = "", $databaseName = "") {
		$this->host = $hostName;
		$this->user = $userName;
		$this->password = $passwordName;
		
		$this->conn = mysql_connect($this->host, $this->user, $this->password)
			or die(mysql_error());
		
		$this->changeDatabase($databaseName);
	}
	
	function changeDatabase($databaseName) {
		mysql_select_db ($databaseName);
		$this->database = $databaseName;
	}
	
	function query($sql) {
		return mysql_query($sql,$this->conn);
	}
	
	function nonquery($sql) {
		$rs = mysql_query($sql,$this->conn);
		$newID = mysql_insert_id();
		settype($rs, "null");
		return $newID;
	}
	
	function insert($data, $tableName) {
		$names = '';
		$values = '';
	
		foreach($data as $key => $value){
			$names .= $key.',';
			$values .= (is_numeric($value))
				? $value.','
				: "'".mysql_real_escape_string($value)."',"
			;
		}
		
		$values = preg_replace("/,$/","",$values);
		$names = preg_replace("/,$/","",$names);
		
		$sql = 'INSERT INTO '.$tableName.' ('.$names.') VALUES ('.$values.')';
		
		return $this->nonquery($sql);
	}
	
	function update($data, $tableName, $condition) {
		$sql = "UPDATE " . $tableName . " SET ";
	
		foreach($data as $key => $value){
			$sql .= $key.' = ';
			$sql .= (is_numeric($value))
				? $value.','
				: "'".mysql_real_escape_string($value)."', "
			;
		}
		
		$sql = rtrim($sql, ", ").$condition;
		
		return $this->nonquery($sql);
	}
	
	function clean($value) {
	   if (get_magic_quotes_gpc()) {
	       $value = stripslashes($value);
	   }
	
	   if (!is_numeric($value)) {
	       $value = mysql_real_escape_string($value);
	   }
	   return $value;
	}
	
	function createDatabase($databaseName) {
		$sql = 'CREATE DATABASE '.$databaseName;
		$this->nonquery($sql);
	}
	
	function dropDatabase($databaseName) {
		$sql = 'DROP DATABASE '.$databaseName;
		$this->nonquery($sql);
	}
	
	function dropTable($tableName) {
		$sql = 'DROP TABLE '.$tableName;
		$this->nonquery($sql);
	}
	
	function truncateTable($tableName) {
		$sql = 'TRUNCATE TABLE '.$tableName;
		$this->nonquery($sql);
	}
	
	function __destruct()  {
		mysql_close($this->conn);
	}
	
}

?>