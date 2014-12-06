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
body {
	font-family:arial;
}

.bg_default {
	background-color:#FFFFFF;
}

.bg_header {
	background-color:#EFEFEF;
}

.stat_pending {
	background-color:#FF0000;
}
.row_pending {
	font-weight:bold;
	color:#000;
	background-color:#FFFFFF;
}

.stat_dispatched {
	background-color:#FFCC33;
}
.row_dispatched {
	font-weight:normal;
	color:#000;
	background-color:#FFFFFF;
}

.stat_enroute {
	background-color:#00FF00;
}
.row_enroute {
	font-weight:normal;
	color:#000;
	background-color:#FFFFFF;
}

.stat_onscene {
	background-color:#0080FF;
}
.row_onscene {
	font-weight:normal;
	color:#000;
	background-color:#FFFFFF;
}

.stat_closed {
	background-color:#E0E0E0;	
}
.row_closed {
	font-style:italic;
	font-weight:normal;
	color:#8f8f8f;
	background-color:#FFFFFF;
}
/*---- CROSS BROWSER DROPDOWN MENU ----*/
ul#nav {margin: 0 0 0 200px;}
ul.drop a { display:block; color: #fff; font-family: Verdana; font-size: 14px; text-decoration: none;}
ul.drop, ul.drop li, ul.drop ul { list-style: none; margin: 0; padding: 0; border: 1px solid #fff; background: #555; color: #fff;}
ul.drop { position: relative; z-index: 597; float: left; }
ul.drop li { float: left; line-height: 1.3em; vertical-align: middle; zoom: 1; padding: 5px 10px; }
ul.drop li.hover, ul.drop li:hover { position: relative; z-index: 599; cursor: default; background: #1e7c9a; }
ul.drop ul { visibility: hidden; position: absolute; top: 100%; left: 0; z-index: 598; width: 195px; background: #555; border: 1px solid #fff; }
ul.drop ul li { float: none; }
ul.drop ul ul { top: -2px; left: 100%; }
ul.drop li:hover > ul { visibility: visible } 
</style>
<script type="text/javascript" src="/js/prototype.js"></script>
<script type="text/javascript" src="/js/scriptaculous.js"></script>
<script type="text/javascript" src="/js/ObjTree.js"></script>

<script type="text/javascript">
<?php
if ( defined('DEBUG') )
	echo "var debug = 1;";
else
	echo "var debug;";
?>
</script>

<?php
if ( $browser->Name == 'MSIE' && preg_match('/^[^1-7]\..*/', $browser->Version) ) # Trac #1651 - Automatic compatibility mode for MSIE compatibility mode for version >= 8.x
	print "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=7\" />";

if ( $force_redirect )
	print "<meta http-equiv=\"refresh\" content=\"{$force_redirect['redirect_delay']}; url={$force_redirect['destination']}\">";

if ( $_SERVER['PHP_SELF'] == '/index.php' || $_SERVER['PHP_SELF'] == '/detail/index.php' )
	print "<script type=\"text/javascript\" src=\"/js/init.js\"></script>";

?>

<script type="text/javascript">

new PeriodicalExecuter( function(pe) {
	var currentTime = new Date ( );

	var currentHours = currentTime.getHours ( );
	var currentMinutes = currentTime.getMinutes ( );
	var currentSeconds = currentTime.getSeconds ( );

	currentMinutes = ( currentMinutes < 10 ? "0" : "" ) + currentMinutes;
	currentSeconds = ( currentSeconds < 10 ? "0" : "" ) + currentSeconds;

	// Choose either "AM" or "PM" as appropriate
	// var timeOfDay = ( currentHours < 12 ) ? "AM" : "PM";

	// Convert the hours component to 12-hour format if needed
	// currentHours = ( currentHours > 12 ) ? currentHours - 12 : currentHours;

	// Convert an hours component of "0" to "12"
	currentHours = ( currentHours == 0 ) ? '00' : currentHours;

	// Compose the string for display
	var currentTimeString = currentHours + ":" + currentMinutes + ":" + currentSeconds;

	// Update the time display
	$('clock').update(currentTimeString);
}, 1);
	
new PeriodicalExecuter( function(pe) {
	if ( debug ) $('debug1').update('[' + Math.floor((Math.random()*100)+1) + '] Request Timestamp => ' + $F('polling_utctime'));
	new Ajax.Request(
		'/poll.php', 
		{
			method: 'post',
			parameters: Form.serialize("f"),
			onSuccess: function(resp) { cf_loadcontent(resp.responseJSON); }
		}
	);	
}, 5);

var WindowSize = Class.create({
    width: window.innerWidth || (window.document.documentElement.clientWidth || window.document.body.clientWidth),
    height: window.innerHeight || (window.document.documentElement.clientHeight || window.document.body.clientHeight)
});
w = new WindowSize();

function pos()
{
	$('pbar').setStyle( {
		width: ( w.width - 78 ) + 'px'
	} );
}

</script>
<title>WatchmanAlerting WebCAD :: Firehouse Automation, LLC</title>
</head>
<body onload="pos();">
<div id="pbar" style="position:relative; left: 45px; height: 19px; background-color:#efefef;border-bottom:1px solid #cccccc;border-top:1px solid #cccccc;">
	<div style="font-size:8pt; float:right; margin-right: 5px; margin-top:4px " id="clock"></div>
	<div style="position: relative; left: -45px;">
		<img src="/images/Header-Logo.png"/>
		<div style="position: relative; font-size: 9pt; font-family: arial; top: -45px; left: 205px; ">
			Current User: <?php echo $_SESSION['my_name']; ?>&nbsp;&nbsp;
			[<small><a href="/logout.php" style="text-decoration:none;">logout</a></small>]
		</div>		
	</div>
</div>
<div style="position:relative; top:55px;">

		<!-- 
<ul id="nav" class="drop">
  <li><a href="#">Home</a></li>
  <li>About Us
    <ul>
      <li><a href="#">History</a></li>
      <li><a href="#">Clients</a></li>
      <li><a href="#">Testimonials</a></li>
      <li><a href="#">Staff</a>
        <ul>
          <li><a href="#">George Orsmond</a>
            <ul>
              <li>Web Design</li>
              <li>Graphic Design</li>
              <li>HTML</li>
              <li>CSS</li>
            </ul>
          </li>
          <li><a href="#">Dave Macleod</a></li>
        </ul>
      </li>
      <li><a href="#">FAQs</a></li>
    </ul>
  </li>
  <li>Services
    <ul>
      <li><a href="#">Web Design</a></li>
      <li><a href="#">Graphic Design</a></li>
      <li><a href="#">Logo Design</a></li>
    </ul>
  </li>
  <li>Products
    <ul>
      <li class="dir"><a href="#">Templates</a></li>
      <li class="dir"><a href="#">Stock Images</a>
        <ul>
          <li><a href="#">Category 1</a></li>
          <li><a href="#">Category 2</a></li>
          <li><a href="#">Category 3</a></li>
          <li><a href="#">Category 4</a></li>
          <li><a href="#">Category 5</a></li>
        </ul>
      </li>
      <li><a href="#">Featured</a></li>
      <li><a href="#">Top Rated</a></li>
      <li><a href="#">Resources</a></li>
    </ul>
  </li>
  <li><a href="#">Gallery</a></li>
  <li>Contact Us
    <ul>
      <li><a href="#">Contact Form</a></li>
      <li><a href="#">How to get here</a></li>
      <li><a href="#">View the map</a></li>
    </ul>
  </li>
</ul>
-->