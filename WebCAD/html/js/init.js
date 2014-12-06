function format_time(ts)
{
	if ( ts > 0 )
	{
		ts = ts * 1000;

		var date = new Date( ts );
		var hour = date.getHours();
		var min = date.getMinutes();
		var sec = date.getSeconds();
		
		if ( hour < 10 ) hour = '0' + hour;
		if ( min < 10 ) min = '0' + min;
		if ( sec < 10 ) sec = '0' + sec;
		
		return hour + ':' + min + ':' + sec;
	}

	return '';
}


function cf_loadcontent(json) {
	
	if ( json )
	{		
		var req_type = json.PollRequest;
		var total = json.Total;
		var inc_date = json.IncidentDate;
		var county_code = json.AgencyCode;
		
		if ( json.UTC_Timestamp )
		{
			if ( debug ) $('debug2').update('[' + Math.floor((Math.random()*100)+1) + '] Response Timestamp => ' + json.UTC_Timestamp + '<br /><br />\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TOTAL => ' + total);
			$('polling_utctime').value = json.UTC_Timestamp;
		}
		
		if ( json.Unix_Timestamp )
		{
			$('polling_unixtime').value = json.Unix_Timestamp;
		}
		
		if ( req_type == 'incdetail' )
		{
			return;
			if ( total > 0 )
			{				
				json.IncidentListing.each( function(inc) 
				{				
					var EntryId = inc.EntryId;
					var EntrySequence = inc.EntrySequence;	
					var EntryTime = inc.EntryTime;
					var EntryUTCTime = inc.EntryUTCTime;
					var EntryType = inc.EntryType;
					var EntryFDID = inc.EntryFDID;
					var EntryText = inc.EntryText;		
					
					var tr_str = '';
					
//					tr_str += '<td style="border-left:1px solid #cccccc;border-top:1px solid #cccccc;background-color:#efefef;width:55px;border-bottom:1px solid #ccc;">' + format_time(EntryTime) + '</td>';
//					tr_str += '<td style="border-top:1px solid #cccccc;background-color:#efefef;width:50px;border-bottom:1px solid #ccc;">' + EntryType + '</td>';
//					tr_str += '<td style="border-right:1px solid #cccccc;border-top:1px solid #cccccc;background-color:#efefef;width:65px;text-align:center;border-bottom:1px solid #ccc;">' + EntryFDID + '</td>';
//					tr_str += '<td style="border-right:1px solid #cccccc;border-top:1px solid #cccccc;background-color:#fff;border-bottom:1px solid #ccc;">' + EntryText + '</td>';					
					
					tr_str += '<td >' + format_time(EntryTime) + '</td>';
					tr_str += '<td >' + EntryType + '</td>';
					tr_str += '<td >' + EntryFDID + '</td>';
					tr_str += '<td >' + EntryText + '</td>';					
						
					tr_str = '<tr id="' + EntryId + '">' + tr_str + '</tr>';
					
					$('narrative_detail').insert( {
						after: tr_str
					} );						
				} );
			}
		}
		else
		{
			if ( total > 0 )
			{				
				json.IncidentListing.each( function(inc) 
				{				
					var CallNo = inc.CallNo
					var Timestamp = inc.Timestamp;				
					
					var statcss = 'bg_default';
					var rowcss = '';
					var statcom = '';				
					
					if ( inc.Status == -1 )
					{
						statcss = "stat_pending";
						rowcss = "row_pending";
						statcom = "Pending";		
					}
					else if ( inc.Status == 1 )
					{
						statcss = "stat_dispatched";
						rowcss = "row_dispatched";
						statcom = "Dispatched";
					}	
					else if ( inc.Status == 2 )
					{
						statcss = "stat_enroute";
						rowcss = "row_enroute";
						statcom = "Enroute";
					}
					else if ( inc.Status == 3 )
					{
						statcss = "stat_onscene";
						rowcss = "row_onscene";
						statcom = "Onscene";
					}
					else if ( inc.Status == 0 )
					{
						statcss = "stat_closed";
						rowcss = "row_closed";
						statcom = "Closed";
					}
					
					var tr_str = '';
					var url = '/detail/' + inc.CallNo;
					
					tr_str += '<td class="' + statcss + '" title="' + statcom + '"><a href="' + url + '" title="Incident Detail">' + inc.IncidentNo + '</a><input type="hidden" id="timestamp_' + CallNo + '" name="timestamp_' + CallNo + '" value="' + Timestamp + '"/>' + ( inc.Status == 0 ? '<input type="hidden" id="status_' + CallNo + '" name="' + CallNo + '" value="' + inc.Unix_CloseTime + '" closed="1"/>' : '' )+ '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.City + ' (' + inc.Agency + ')</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.Box + '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.Station + '</td>';				
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.Nature + '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.CreatedTimeStr + '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.EntryTimeStr + '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.DispatchTimeStr + '</td>';
					//tr_str += '<td class="bg_default" title="' + statcom + '">' + inc.EnrouteTimeStr + '</td>';
					//tr_str += '<td class="bg_default" title="' + statcom + '">' + inc.OnsceneTimeStr + '</td>';
					//tr_str += '<td class="bg_default" title="' + statcom + '">' + inc.CloseTimeStr + '</td>';
					tr_str += '<td class="' + rowcss + '" title="' + statcom + '">' + inc.Location + '</td>';
					
					if ( $(CallNo) ) 
					{
						if ( debug ) $('debug2').innerHTML += '<br />\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;INCIDENT UPDATE => ' + inc.IncidentNo;
						
						$(CallNo).update(tr_str);
						
					} 
					else 
					{
						if ( debug ) $('debug2').innerHTML += '<br />\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NEW INCIDENT => ' + inc.IncidentNo;
						
						tr_str = '<tr id="' + CallNo + '">' + tr_str + '</tr>';
	
						$('content_header').insert( {
							after: tr_str
						} );
					}			
				} );
			}
			
			var d = new Date();
			var utc = Math.round( Date.UTC( d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds() ) / 1000 );
			$$('input[closed="1"]').each( function(n) {
				var closetime = $(n).value;
				var elapsed = utc - closetime;
				if ( elapsed > 900 && $( $(n).name ) ) 
				{
					$( $(n).name ).remove();
				}
			} );
		}
	}
	else
	{
		//alert('JSON Error');
	}
}