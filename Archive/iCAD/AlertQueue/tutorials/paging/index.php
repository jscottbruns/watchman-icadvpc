<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>

<title>Particletree &middot; Preloading Data with Ajax and JSON</title>

<!-- Meta Tags -->
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta name="robots" content="index, follow" />

<!-- CSS -->
<link rel="stylesheet" type="text/css" href="style.css" title="default"/>

<!-- JavaScript -->
<script src="scripts/prototype.js" type="text/javascript"></script>
<script src="scripts/paging.js" type="text/javascript"></script>

</head>

<body>
	
	<h2>Preloading Data with Ajax and JSON</h2>
	
	<div id="container">
		<span class="titles">Preloaded Previous</span>
		<a href="#" onclick="getPreviousPage(); return false;" id="previousLink">Previous</a>
		<a href="#" onclick="getNextPage(); return false;" id="nextLink">Next</a>
		<span class="titles">Preloaded Next</span>
				
		<div id="previous"></div>
		<div id="view"></div>
		<div id="next"></div>
	</div><!--container-->
	
	<div id="currentRec"></div>
	
	<div id="info">
		<p>This is a paging demo that shows how to preload the next and previous page of data using JSON. When the user pages through, they can do so quickly and see results without having to wait for an Ajax call to finish.</p>

		<p>
			<a href="http://particletree.com/files/paging/paging.zip" 
			title="Paging Files">Download Source</a> &middot; 
			<a href="http://particletree.com/features/preloading-data-with-ajax-and-json/" 
			title="Prelaoding Demo">Return to Tutorial</a>
		</p>
	</div>

</body>

</html>