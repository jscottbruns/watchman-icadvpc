<?php
if ( preg_match('/([a-zA-Z0-9_]{1,})\.php/', $_SERVER['PHP_SELF'], $matches) )
	$r = $matches[1];

if ( ( $login_class && ! $login_class->user_isloggedin() ) || ! $_SESSION['my_name'] ) {

	$login_class->user_logout();
	header("Location: login.php?r=$r");
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<style type="text/css">
.bgwht{
	background: #ffffff;
}
.bggry {
	background: #efefef;
}

.bgred {
	background: #ff0000;
}
</style>
<script type="text/javascript" src="js/prototype.js"></script>
<script type="text/javascript" src="js/scriptaculous.js"></script>
<script type="text/javascript" src="js/ObjTree.js"></script>
<?php
if ( $browser->Name == 'MSIE' && preg_match('/^[^1-7]\..*/', $browser->Version) ) # Trac #1651 - Automatic compatibility mode for MSIE compatibility mode for version >= 8.x
	print "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=7\" />";

if ( $force_redirect )
	print "<meta http-equiv=\"refresh\" content=\"{$force_redirect['redirect_delay']}; url={$force_redirect['destination']}\">";

if ( $_SERVER['PHP_SELF'] == '/index.php' )
	print "<script type=\"text/javascript\" src=\"js/init.js\"></script>";

?>
<script type="text/javascript">
new Ajax.PeriodicalUpdater(
	'clock',
	'clock.php',
	{
		method:		'get',
		frequency:	1
	}
);
</script>
<title>WatchmanCAD :: Firehouse Watchman CAD Viewer</title>
</head>
<body >
<table style="width:100%;">
<tr>
	<td style="background-color:#efefef;border-bottom:1px solid #cccccc;border-top:1px solid #cccccc;">
		<table style="width:100%;font-family:arial,sans-serif;font-size:10pt;">
			<tr>
				<td style="width:30%;text-align:left;font-size:8pt;"><div id="clock"></div></td>
				<td style="width:40%;text-align:center;font-weight:bold;"><?php echo ( $_SERVER['PHP_SELF'] != '/logout.php' ? "WatchmanCAD :: CAD Incident Viewer" : NULL ); ?></td>
				<td style="width:30%;text-align:right;font-size:8pt;">
					Current User: <?php echo $_SESSION['my_name']; ?>
					&nbsp;&nbsp;
					[<small><a href="logout.php" style="text-decoration:none;">logout</a></small>]
				</td>
			</tr>
		</table>
	</td>
</tr>
</table>