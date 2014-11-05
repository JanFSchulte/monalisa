<table border=0 cellspacing=1 cellpadding=2 style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px" bgcolor="#777777">
    <tr height=25 bgcolor="#F8FFB8">
	<th colspan=7>Running jobs trend</th>
    </tr>
    <tr height=22 bgcolor="#CCCCCC">
	<th>Site name</th>
	<th>Current<br>running jobs</th>
	<th width=70>Last<br>24 hours</th>
	<th width=70>Last<br>12 hours</th>
	<th width=70>Last<br>6 hours</th>
	<th width=70>Last<br>hour</th>
	<th width=70><a href="/stats?page=services_status" style="color:blue;text-decoration:none" onMouseOver="this.style.textDecoration='underline';" onMouseOut="this.style.textDecoration='none';">Services<br>status</a></th>
    </tr>
    <<:continut:>>
    <tr height=20 bgcolor="#CCCCCC">
	<td align=center><b>TOTAL</b></td>
	<td align=right><b><<:running:>>&nbsp;</b></td>

	<td align=center 
	    onMouseOver="overlib('24 hours ago: <<:count_3:>> running jobs<<:extra_3:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=4 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_new/arrow_<<:angle_3:>>.png">
	</td>

	<td align=center 
	    onMouseOver="overlib('12 hours ago: <<:count_2:>> running jobs<<:extra_2:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=3 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_new/arrow_<<:angle_2:>>.png">
	</td>

	<td align=center 
	    onMouseOver="overlib('6 hours ago: <<:count_1:>> running jobs<<:extra_1:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=2 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_new/arrow_<<:angle_1:>>.png">
	</td>

	<td align=center 
	    onMouseOver="overlib('1 hour ago: <<:count_0:>> running jobs<<:extra_0:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=1 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_new/arrow_<<:angle_0:>>.png">
	</td>
	
	<td align=center
	    onMouseOver="overlib('<div align=left><b><<:services_stats:>></div>', CAPTION, 'Services status');"
	    onMouseOut="return nd();"
	><img src="/img/qm_2.png"></td>
    </tr>
</table>
<br clear=all>
