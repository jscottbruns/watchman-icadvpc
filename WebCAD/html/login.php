<?php
require '/var/www/icad-poll/include/common.php';

if ( preg_match('/^iCAD Client/', $_SERVER['HTTP_USER_AGENT']) )
{
	$login_class = new login_class($db);
	$feedback = $login_class->user_login($_COOKIE['autologin'], 1);
	
	if ( $feedback )
		print $feedback;
		
	exit;
}

if ( isset($_COOKIE['autologin']) || isset($_POST['login_button_x']) )
{
	$login_class = new login_class($db);
	$feedback = $login_class->user_login($_COOKIE['autologin']);
}

$tabindex = 1;

?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="SHORTCUT ICON" href="core/images/favicon.ico"/>
<title>iCAD Login :: Watchman CAD Viewer</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<script type="text/javascript" src="js/prototype.js"></script>
<script type="text/javascript" src="js/scriptaculous.js?load=effects"></script>
<?php
if ( isset($feedback) )
{
	echo "
	<script type=\"text/javascript\">
	document.observe(\"dom:loaded\", function() {
		$('feedback_holder').appear({ duration: 1.0 });
	});
	</script>";
}
?>
<style>
html {font-size: 125%}
/* body styles contain settings for color, background and font across the page */
body,td {font-family:arial, verdana, helvetica, tahoma;font-size: 78%; }
#holding_table{height:100%;width:801px;text-align:center}
.nav_out{background-color:#666666;cursor:hand;color:#ffffff;border-bottom:1px solid #262626;}
.nav_out a:link,a:active,a:visited{color:#ffffff;text-decoration:none}

.nav_in{background-color:#cccccc;cursor:hand;color:#333333;border-bottom:0;text-decoration:underline;}
.nav_in a:visited{color:#333333;}
.nav_in a:active{color:#333333}
.nav_in a:link{color:#333333}
.nav_in a:hover{color:#333333}
.link_standard , .link_standard a , .link_standard a:link , .link_standard a:active , .link_standard a:visited{color:#000000}
.textbox{background-color:#cccccc;}
.button {
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	font-weight:800;
	color:#4D4D4D;
	background-color:#ffffff;
}

.error_msg{color:#e60000;font-size:10pt;font-weight:bold;}
</style>
<script type="text/javascript">
function login() {
    if (document.getElementById('login_holder')) {
		var login_hldr = document.getElementById('login_holder');

		login_hldr.innerHTML = "\
            <table style='text-align:center;'>\
                <tr>\
                    <td style='text-align:right;font-family:Arial,Helvetica,sans-serif;font-size:70%;'>Username: </td>\
                    <td style='text-align:left'><input type='text' name='user_name' id='user_name' tabindex='<?php echo$tabindex++?>' value='<?php echo ($_POST['user_name'] ? $_POST['user_name'] : $_COOKIE['user_name']); ?>' style='width:175px' /></td>\
                </tr>\
                <tr>\
                    <td style='text-align:right;font-family:Arial,Helvetica,sans-serif;font-size:70%;'>Password: </td>\
                    <td style='text-align:left;'><input type='password' name='password' tabindex='<?php echo$tabindex++?>' id='password' tabindex='2' style='width:175px' /></td>\
                </tr>\
                <tr>\
                    <td style='text-align:right;padding-top:5px;'><input type='checkbox' tabindex='<?php echo$tabindex++?>' name='rememberme' id='rememberme' tabindex='3' value='1' <?php echo ( $_COOKIE['autologin'] == 1 ? 'checked' : NULL ); ?>/></td>\
                    <td style='text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:70%;padding-top:5px;'><a href='javascript:void(0);' style='text-decoration:none;color:#000000;' onClick='checkit();'>Remember me on this computer.</a></td>\
                </tr>\
                <tr>\
                    <td ></td>\
                    <td style='text-align:left;padding-top:20px;'><input type='image' name='login_button' tabindex='<?php echo$tabindex++?>' src='images/login.gif' /></td>\
                </tr>\
            </table>\
        ";
		document.getElementById('<?php echo ($_POST['user_name'] || $_COOKIE['user_name'] ? "password" : "user_name"); ?>').focus();
	}
}

</script>
</head>
<body bgcolor="#efefef" topmargin="0" onLoad="login()">
<table style="width:700px;height:100%;background-color:#ffffff;" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td style="text-align:center;vertical-align:top;border-right:1px solid #8f8f8f;border-left:1px solid #8f8f8f">
       	<div style="margin-bottom:95px;margin-top:100px;"></div>
        <table align="center">
        <tr>
            <td style="text-align:center;">
			<form action="<?php echo $PHP_SELF; ?>" method="post" name="f"><input type="hidden" name="r" value="<?php echo $_GET['r']; ?>" />

<?php

echo "
<center>
<div style=\"margin-bottom:5px;height:45px;\">
	<div style=\"text-align:center;font-size:8pt;color:#ff0000;display:none;\" id=\"feedback_holder\">" . ( isset($feedback) ? $feedback : NULL ) . "</div>
</div>
<div style=\"width:350px;padding:35px 25px 20px 25px;border:1px solid #8f8f8f;background-color:#efefef;\">
	<div style=\"text-align:left;margin-top:-30px;margin-left:-20px;font-size:7pt;color:#000000;font-weight:bold;\">
	<img src=\"images/ssl.gif\" />&nbsp;Secure Login</div>
	<div style=\"text-align:left;margin-top:15px;margin-bottom:0px;margin-left:115px;font-weight:bold;\">
		Watchman iCAD Login";

		if ( $_GET['r'] )
			echo "<div style=\"font-size: -20%; font-weight: normal; font-style: italic; margin-top: 5px\">please login to continue...</div>";

echo "
	</div>
	<div id=\"login_holder\" style=\"margin-top:15px;\"></div>
</div>
</center>";

echo "
<div style=\"color:#000000;font-size:9pt;padding-top:5px;\">iCAD :: Watchman CAD Viewer</div>
<div style=\"color:#000000;font-size:8pt;margin-top:5px;\">" . ( defined('ORGNAME') ? ORGNAME : '' ) . "</div>";

echo "
<noscript>
<b>Your browser does not have javascript enabled. Please check your browser settings and enable javascript to continue.</b>
</noscript>";
?>
            </form>
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>
</body>
</html>