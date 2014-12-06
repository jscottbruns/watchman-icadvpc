Event.observe(window, 'load', init, false);

function init() {

	var myAjax = new Ajax.PeriodicalUpdater(
		'',
		'poll.php',
		{
			method: 'post',
			parameters: 'ajaxstatic=1&ts=' + $F('timestamp'),
			frequency: 5,
			onSuccess: function(resp) { cf_loadcontent(resp.responseXML); }
		}
	);
}

function cf_loadcontent(xml) {

	if ( xml.hasChildNodes() ) {

		var XMLObj = new XML.ObjTree();
		XMLObj.force_array = [ "member" ];

		var XMLTree = XMLObj.parseDOM( xml.documentElement );

		var total = XMLTree.poll.Total;
		var inc_date = XMLTree.poll.IncidentDate;
		var county_code = XMLTree.poll.CountyCode;
		var pollingtime = XMLTree.poll.PollingTimestamp;

		var callno, timestamp, opentime, closetime, type, area, incno, loc;

		if ( total > 0 ) {

			XMLTree.poll.IncidentListing.Incident.each( function(inc) {

				opentime = closetime = type = area = incno = loc = '';

				callno = inc["-call_no"];
				timestamp = inc["-timestamp"];
				if ( inc["-opentime"] )
					opentime = inc["-opentime"];

				if ( inc["-closetime"] )
					closetime = inc["-closetime"];

				if ( inc["-calltype"] )
					type = inc["-calltype"];

				if ( inc["-box"] )
					area = inc["-box"];

				if ( inc["-incident_no"] )
					incno = inc["-incident_no"];

				if ( inc["-location"] )
					loc = inc["-location"];

				if ( ! $(callno) || ( $(callno) && $('timestamp_' + callno) && timestamp > $F('timestamp_' + callno) ) ) {

					tr_str = "\
					<td class='bgwht'>" + callno + "<input type='hidden' id='timestamp_" + callno + "' name='timestamp_" + callno + "' value='" + timestamp + "'/></td>\
					<td class='bgwht'>" + opentime + "</td>\
					<td class='bgwht'>" + closetime + "</td>\
					<td class='bgwht'>" + type + "</td>\
					<td class='bgwht'>" + area + "</td>\
					<td class='bgwht'>" + incno + "</td>\
					<td class='bgwht'>" + loc + "</td>\
					";

					if ( $(callno) ) {
						$(callno).update(tr_str);
					} else {

						tr_str = "<tr id='" + callno + "'>" + tr_str + "</tr>";

						$('content_header').insert( {
							after: tr_str
						} );
					}
				}
			} );
		}
	}
}