<?php
$license_no = $_GET['l'];

$date = date("M jS Y");
$datestd = date("Y-m-d");
$date_year = date("Y");

$rand = rand(100,5000);

print <<<OUT
<link rel="stylesheet" type="text/css" href="http://www.firehousewatchman.com/rssbox/rssdisplaybox.css" />
<script type="text/javascript" src="http://www.firehousewatchman.com/rssbox/virtualpaginate.js"></script>
<script type="text/javascript" src="http://www.firehousewatchman.com/rssbox/rssdisplaybox.js"></script>
<script src="http://www.firehousewatchman.com/js/date-functions.js" type="text/javascript"></script>
<script src="http://www.firehousewatchman.com/js/datechooser.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="http://www.firehousewatchman.com/js/datechooser.css"/>
OUT;

print <<<OUT
<script>
reloadRSS = function() {
    var rssParentDiv = arguments[0];
    var rssDate = arguments[1];

    document.getElementById('rsspaginatediv').style.display = 'block';

    if ( rssDate ) {
        loadRSS(rssParentDiv, rssDate);
    }
}
document.write('<table class="contenttbl" style="width:100%;border:2px solid #242527;" cellspacing="0" cellpadding="0">\
    <tr>\
        <td style="width:100%;background-color:#0C0C0E;border-bottom:1px solid #242527;padding:2px 5px 5px 5px;">\
            <form>\
            <h2 style="margin-top:0;color:#a6a7a9;margin-bottom:4px;"><span style="font-size:small;color:#E6E6E6">West Lanham Hills RSS Incident Feed -</span></h2>\
            <div style="font-size:11px;font-weight:normal;margin-left:15px;margin-top:0px;margin-bottom:8px;color:#a6a7a9">\
                Incident Listing for <span id="rss_display_date">$date</span>\
                <span style="position:relative;top:2px;left:5px;">\
                    <input id="rssDateHidden" name="rssDateHidden" type="hidden" value="$datestd" />\
                    <a href="javascript:void(0);"><img src="img/calendar.gif" onclick="showChooser(this, \'rssDateHidden\', \'chooserSpan\', 2010, $date_year, \'Y-m-d\', false);" border="0" /></a>\
                    <div id="chooserSpan" class="dateChooser select-free" style="display: none; visibility: hidden; width: 160px;"></div>\
                </span>\
            </div>\
            </form>\
        </td>\
    </tr>\
    <tr>\
        <td style="padding-top:10px;background-color:#020303;">\
            <div id="rsspaginatediv" class="rsspaginate">\
                <a href="#" rel="previous"><<</a>\
                &nbsp;\
                <span class="paginateinfo" style="margin: 0 20px; font-weight: bold"></span>\
                &nbsp;\
                <a href="#" rel="next">>></a>\
            </div>\
        </td>\
    </tr>\
    <tr>\
        <td style="width:100%;background-color:#020303;color:#a6a7a9;padding:5px;">\
            <div id="rsscontent_div_{$rand}"><img src="img/ajax-loader.gif" /> Loading RSS Incident Feed...</div>\
        </td>\
    </tr>\
    <tr>\
        <td style="text-align:right;padding-right:5px;background-color:#020303;font-size:84%;font-color:grey">\
            Powered by FirehouseWatchman - Custom Firehouse Alerting\
        </td>\
    </tr>\
</table>');
</script>
OUT;

print <<<OUT
<script>
loadRSS('rsscontent_div_{$rand}');
</script>
OUT;
?>
