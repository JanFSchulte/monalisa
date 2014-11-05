<style type="text/css">

a.trend_title:link,
a.trend_title:visited,
a.trend_title:active{
    font-family: Verdana,Arial,Helvetica,sans-serif;
    font-size: 11px;
    font-weight: bold;
    color: #0000C0;
    text-decoration: none;
}

a.trend_title:hover{
    font-family: Verdana,Arial,Helvetica,sans-serif;
    font-size: 11px;
    font-weight: bold;
    color: #FF5314;
    text-decoration: none;
}

.select_trend{
    font-size: 10px;
    font-family: Verdana, Arial;
    border: solid 1px #CCCC99;
    background-color: #FFFFFF;
}

.clsCMOn{
    font-size: 11px;
    font-weight: bold;
    padding: 2px 2px;
    color: black;
}

.clsCMOver {
    font-size: 11px;
    font-weight: bold;
    padding: 2px 2px;
    color: black;
}

.clsTitleCMOn{
    font-size: 11px;
    font-weight: bold;
    padding: 2px 2px;
    color: black;
    text-align:center;
}

.clsTitleCMOver {
    font-size: 11px;
    font-weight: bold;
    padding: 2px 2px;
    color: black;
    text-align:center;
}
                        
</style>
<script language="JavaScript" type="text/javascript">
    var title_sort=<<:title_sort:>>;
    var sort_link ="<<:sort_link:>>"; 
</script>
<script language="JavaScript" type="text/javascript" src="/js/coolmenu/coolmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/coolmenu/trend_items.js"></script>

<br />
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Running jobs trend</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25 class="table_header">
		    <td align="center" valign="middle" class="table_header"><a href="/trend.jsp?sort=1&type=<<:type_1:>>&filter=<<:filter:>>" class="trend_title">Site name</a>&nbsp;<<:com_1_start:>><img src="/img/<<:type_1_img:>>_trend.png" align="absmiddle" width="12" height="12"><<:com_1_end:>></td>
		    <td valign="middle" class="table_header">
			<table cellspacing="0" cellpadding="0" border="0">
			    <tr>
				<td align="center"><a href="/trend.jsp?sort=2&type=<<:type_2:>>&filter=<<:filter:>>" class="trend_title">Running jobs</a></td>
			    <td><<:com_2_start:>><img src="/img/<<:type_2_img:>>_trend.png" align="absmiddle" width="12" height="12"><<:com_2_end:>></td>
			    </tr>
			</table>    
		    </td>
		    <td valign="middle" class="table_header">
			<table cellspacing="0" cellpadding="0" border="0">
			    <tr>
				<td align="center"><a href="/trend.jsp?sort=3&type=<<:type_3:>>&filter=<<:filter:>>" class="trend_title">KSI2K units<br>(used/pledged)</a></td>
				<td><<:com_3_start:>><img src="/img/<<:type_3_img:>>_trend.png" align="absmiddle" width="12" height="12"><<:com_3_end:>></td>
			    </tr>
			</table>    
		    </td>
		    <td align="center" width="70" class="table_header">Last<br>24 hours</td>
		    <td align="center" width="70" class="table_header">Last<br>12 hours</td>
		    <td align="center" width="70" class="table_header">Last<br>6 hours</td>
		    <td align="center" width="70" class="table_header">Last<br>hour</td>
		    <td width="80" align="left" style="padding: 5px;" valign="top" class="table_header">
			<div style="position: relative: float: left"><script type="text/javascript">var m1 = new COOLjsMenu("menu_trend", MENU_ITEMS);</script>&nbsp;</div>
		    </td>
		</tr>
		<<:continut:>>
		<tr height=20 class="table_header">
		    <td align=center class="table_header"><b>ALIEN Status</b></td>
		    <td align=right class="table_header"><<:running:>>&nbsp;</td>
		    <td align=right class="table_header" onMouseOver="overlib('<div align=left>Last 24 hours average: <<:ksi2k:>><br>Pledged: <<:pledged_ksi2k:>><br><hr size=1>Provided resources: <<:ratio_ksi2k:>></div>', CAPTION, 'KSI2K Units', OFFSETY, -70);" onMouseOut="return nd();"><<:ksi2k:>> / <<:pledged_ksi2k:>>&nbsp;</td>
		    <td align=center class="table_header"
			onMouseOver="overlib('24 hours ago: <<:count_3:>> running jobs<<:extra_3:>>', CAPTION, 'Click for details');"
			onMouseOut="return nd();"
			onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=4 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
			    <img src="/img/arrows_simple/arrow_<<:angle_3:>>.png">
		    </td>
		    <td align=center class="table_header"
			onMouseOver="overlib('12 hours ago: <<:count_2:>> running jobs<<:extra_2:>>', CAPTION, 'Click for details');"
			onMouseOut="return nd();"
			onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=3 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
			<img src="/img/arrows_simple/arrow_<<:angle_2:>>.png">
		    </td>
		    <td align=center class="table_header"
			onMouseOver="overlib('6 hours ago: <<:count_1:>> running jobs<<:extra_1:>>', CAPTION, 'Click for details');"
			onMouseOut="return nd();"
	    		onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=2 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
			    <img src="/img/arrows_simple/arrow_<<:angle_1:>>.png">
		    </td>
		    <td align=center class="table_header"
			onMouseOver="overlib('1 hour ago: <<:count_0:>> running jobs<<:extra_0:>>', CAPTION, 'Click for details');"
	    		onMouseOut="return nd();"
			onClick="nd(); overlib('<iframe src=/trend_tooltip.jsp?site=_TOTALS_&tab=1 border=0 width=300 height=220 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Running jobs history', STICKY, CENTER, OFFSETY, -20);">
			<img src="/img/arrows_simple/arrow_<<:angle_0:>>.png">
		    </td>
		    <td align=center class="table_header"
			onMouseOver="overlib('<div align=left><b><<:services_stats:>></div>', CAPTION, 'Services status');"
			onMouseOut="return nd();"
			><img src="/img/qm_2.png"></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
<br clear=all>
