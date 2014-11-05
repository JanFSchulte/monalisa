    <tr bgcolor="<<:color:>>" class="table_row_right">
	<td nowrap align=right  class="table_row_right"><a class=link target=_blank href="https://alice-logbook.cern.ch/logbook/date_online.php?p_cont=rund&p_run=<<:run enc:>>"><<:run esc:>></a>&nbsp;</td>
	<td nowrap align=left  class="table_row_right"><<:runtype esc:>></td>
	<td nowrap align=right class="table_row_right"><<:first_seen esc:>></td>
	<td nowrap align=right class="table_row_right"><<:last_seen esc:>></td>
	<td nowrap align=right class="table_row_right" bgcolor="<<:PP_color:>>"><a target=_blank href="shuttle.jsp?instance=PROD&runrange=<<:run enc:>>" class=link><U><<:PP:>></U></a></td>
	<td nowrap align=right class="table_row_right" onMouseOver="overlib('Total size: <<:size size:>>')" onMouseOut="nd()"><<:chunks:>><br>
	<table border=0 cellspacing=0 cellpadding=0 style="width:<<:sizepercentage:>>px">
	    <tr style="height:2px">
		<td bgcolor=blue></td>
	    </tr>
	</table></td>
	<td nowrap align=right class="table_row_right"><<:events dot:>></td>
	<td nowrap align=right class="table_row_right" bgcolor="<<:rm_status_color:>>"><span onMouseOver="overlib('<<:rm_time nicedate:>> <<:rm_time time:>>')" onMouseOut="nd()"><<:rm_status:>></span></td>
	<td nowrap align=right class="table_row_right"><span onMouseOver="overlib('<<:rm_time nicedate:>> <<:rm_time time:>>')" onMouseOut="nd()"><<:rm_event_count dot:>></span></td>
	<td nowrap align=right class="table_row_right" bgcolor="<<:caf_reco_color:>>"><<:caf_reco:>></td>
	<td nowrap align=right class="table_row_right" bgcolor="<<:grid_reco_color:>>"><<:grid_reco:>></td>
	<td nowrap align=left  class="table_row_right" onClick="edit(<<:run:>>, old_comment_<<:run:>>, <<:caf_reco_code:>>, <<:grid_reco_code:>>)" onMouseOver='if (old_comment_<<:run:>>.length>0) overlib(convertComment(old_comment_<<:run:>>), CAPTION, "<<:author:>>, <<:addtime nicedate:>> <<:addtime time:>>");' onMouseOut='nd()'><<:comment cut40 esc:>></td>
    </tr>
