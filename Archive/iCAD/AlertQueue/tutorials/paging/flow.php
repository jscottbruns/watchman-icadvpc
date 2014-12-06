<?php

require_once('classes/database.php');

if(isset($_GET['action'])) {
	switch($_GET['action']) {
		case "count":
			getRecordCount();
			break;
		case "page":
			getTableData();
			break;
	}
}

function getRecordCount() {
	$db 	= new database();
	$sql 	= "SELECT COUNT(*) AS recordCount FROM Accounts";
	$rs 	= $db->query($sql);
	$row	= mysql_fetch_array($rs, MYSQL_ASSOC);
	echo	$row['recordCount'];
}

function getTableData() {
	$ret = '{"players" :[';
	$db 	= new database();
	$sql 	= "SELECT * FROM Accounts LIMIT ".$_GET['current'].", ".$_GET['size'];
	$rs 	= $db->query($sql);
	
	while($row	= mysql_fetch_array($rs, MYSQL_ASSOC)) {
		$ret .= '{ "firstName" : "'.$row['FirstName'].'", "lastName" : "'.$row['LastName'].'", "position" : "'.$row['Position'].'" }, ';
				
	}
	$ret = rtrim($ret, ', ').']}';
	
	echo $ret;
}

?>