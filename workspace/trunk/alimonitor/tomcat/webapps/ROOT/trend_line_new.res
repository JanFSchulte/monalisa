    <tr bgcolor="#<<:color:>>" style="border-bottom: 1px solid #D9D9D9" class="table_row_right">
	<td align=left class="table_row">&nbsp;
	<<:count:>>. <a href="/display?page=jobs_per_site&SiteBase=<<:site:>>" style="text-decoration:none;color:#0000FF" onMouseOver="this.style.textDecoration='underline'" onMouseOut="this.style.textDecoration='none'"><b><<:site:>></a></td>
	<td align=right bgcolor="#<<:running_color:>>" style="border-bottom: 1px solid #D9D9D9"><<:running:>>&nbsp;</td>
	<td align=right bgcolor="#<<:ksi2k_color:>>" style="border-bottom: 1px solid #D9D9D9" onMouseOver="overlib('<div align=left>Last 24 hours average: <<:ksi2k:>><br>Pledged: <<:pledged_ksi2k:>><br><hr size=1>Provided resources: <<:ratio_ksi2k:>></div>', CAPTION, 'KSI2K Units');" onMouseOut="return nd();"><<:ksi2k:>> / <<:pledged_ksi2k:>>&nbsp;</td>

	<td align=center  class="table_row"
	    onMouseOver="overlib('24 hours ago: <<:count_3:>> running jobs<<:extra_3:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=<<:site:>>&tab=4 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'History for <<:site:>>', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_simple/arrow_<<:angle_3:>>.png">
	</td>

	<td align=center  class="table_row"
	    onMouseOver="overlib('12 hours ago: <<:count_2:>> running jobs<<:extra_2:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=<<:site:>>&tab=3 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'History for <<:site:>>', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_simple/arrow_<<:angle_2:>>.png">
	</td>

	<td align=center  class="table_row"
	    onMouseOver="overlib('6 hours ago: <<:count_1:>> running jobs<<:extra_1:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=<<:site:>>&tab=2 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'History for <<:site:>>', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_simple/arrow_<<:angle_1:>>.png">
	</td>
	
	<td align=center  class="table_row"
	    onMouseOver="overlib('1 hour ago: <<:count_0:>> running jobs<<:extra_0:>>', CAPTION, 'Click for details');"
	    onMouseOut="return nd();"
	    onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=<<:site:>>&tab=1 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'History for <<:site:>>', STICKY, CENTER, OFFSETY, -20);">
		<img src="/img/arrows_simple/arrow_<<:angle_0:>>.png">
	</td>

	<td align=center class="table_row"
	    onMouseOver="overlib('<div align=left><<:message js:>></div>', CAPTION, 'Click for persistent window');"
	    onMouseOut="return nd();"
	    onClick="nd(); showCenteredWindow('<div align=left><<:message js:>></div>', 'Page usage'); return false;"
	>
	    <img src="/img/<<:icon:>>.png">
	</td>
    </tr>
