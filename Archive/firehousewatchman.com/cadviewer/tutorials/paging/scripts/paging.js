/*-------------------------GLOBALS-------------------------*/

var currentRecord = 0;
var pagingSize 	= 10;
var recordCount;
var previousPage;
var currentPage;
var nextPage;
var active = false;

/*---------------------------------------------------------------*/

Event.observe(window, 'load', init, false);

function init() {
	showNavigation();
	getRecordCount();
	getTableData();
	setTimeout(
		function() {
			getNextData();
		}, 500
	);
}

function getRecordCount() {
	var myAjax = new Ajax.Request(
			'flow.php?action=count', 
			{
				method: 'get', 
				parameters: '', 
				onComplete: function(response) {
					recordCount = response.responseText;
				}
			});
}

function getTableData() {
	var myAjax = new Ajax.Request(
			'flow.php?action=page&current='+currentRecord+'&size='+pagingSize, 
			{
				method: 'get', 
				parameters: '', 
				onComplete: function(response) {
					currentPage = eval('(' + response.responseText + ')');
					drawTable(currentPage, $('view'));
				}
			});
}

function getNextData() {
	$('next').innerHTML = '';
	active = true;
	var myAjax = new Ajax.Request(
			'flow.php?action=page&current='+(currentRecord+pagingSize)+'&size='+pagingSize, 
			{
				method: 'get', 
				parameters: '', 
				onComplete: function(response) {
					nextPage = eval('(' + response.responseText + ')');
					active = false;
					drawTable(nextPage, $('next'));
				}
			});
}

function getPreviousData() {
	if((currentRecord - pagingSize) >= 0) {
		$('previous').innerHTML = '';
		active = true;
		var myAjax = new Ajax.Request(
				'flow.php?action=page&current='+(currentRecord-pagingSize)+'&size='+pagingSize, 
				{
					method: 'get', 
					parameters: '', 
					onComplete: function(response) {
						previousPage = eval('(' + response.responseText + ')');
						active = false;
						drawTable(previousPage,$('previous'));
					}
				});
	}
	else {
		$('previous').innerHTML = '';
	}
}

/*---------------------------------------------------------------*/

function drawTable(page, contain) {
	table = 	'<table>';
	alt = '';
	for(i = 0; i < page['players'].length; i++) {
		table +=		'<tr class="'+alt+'">' +
						'<td>' + page['players'][i].lastName 	+ ',</td>' +
						'<td>' + page['players'][i].firstName 	+ '</td>' +
						'<td>' + page['players'][i].position	+ '</td>' +
						'</tr>';
		(alt == '')
			?	alt = 'alt'
			:	alt = '';
	}
	
	table += '</table>';
	contain.innerHTML = table;
}

function getNextPage() {
	if(!active) {
		currentRecord += pagingSize;
		showNavigation();
		previousPage = currentPage;
		currentPage = nextPage;
		drawTable(currentPage, $('view'));
		drawTable(previousPage, $('previous'));
		getNextData();
	}
}

function getPreviousPage() {
	if(!active) {
		currentRecord -= pagingSize;
		showNavigation();
		nextPage = currentPage;
		currentPage = previousPage;
		drawTable(currentPage, $('view'));
		drawTable(nextPage, $('next'));
		getPreviousData();
	}
}

function showNavigation() {
	$('currentRec').innerHTML = "Record " + currentRecord; 
	(currentRecord == 0)
		?	$('previousLink').style.visibility = 'hidden'
		:	$('previousLink').style.visibility = 'visible';
	((currentRecord + pagingSize) >= recordCount)
		?	$('nextLink').style.visibility = 'hidden'
		:	$('nextLink').style.visibility = 'visible';
		
}
