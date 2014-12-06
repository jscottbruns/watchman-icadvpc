<?php
require '/var/www/icad-poll/include/common.php';

$login_class = new login_class($db);

$force_redirect['redirect_delay'] = 2;
$force_redirect['destination'] = 'index.php';

require_once 'header.php';

$login_class->user_logout();

echo "
<div style=\"text-align:center;font-family:arial,sans-serif;\">
	<div style=\"margin-bottom:15px;\"><img src=\"images/FirehouseAutomation_Logo.png\" alt=\"Firehouse Automation Logo\"/></div>
	<h4 style=\"font-weight:bold;color:#8c8c8c;\">WatchmanCAD :: Logging Out</h4>
	<img src=\"images/ajax-loader.gif\" />
</div>";

require_once 'footer.php';