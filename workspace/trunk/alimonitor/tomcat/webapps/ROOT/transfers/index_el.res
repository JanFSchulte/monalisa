    <tr bgcolor="<<:color:>>" class="table_row_right">
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:id db esc:>>"><a name="<<:id db esc:>>"></a><a target=_blank href="details.jsp?id=<<:id db enc:>>" class=link><<:id db esc:>>.</a>&nbsp;</td>
	<td nowrap align=left  class="table_row" sorttable_customkey="<<:path db esc:>>"><a target=_blank href="/catalogue/?path=<<:path db enc:>>" class=link><<:path db esc:>></a></td>
	<td nowrap align=left  class="table_row" sorttable_customkey="<<:targetse db esc:>>"><<:targetse db esc:>></td>
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:status db esc:>>"><<:statustext:>></td>
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:size_done esc:>>">
		<table cellspacing=0 cellpadding=0 style="width:100px" onMouseOver="overlib('<<:transfer_tooltip js:>>');" onMouseOut="nd()">
		    <tr style="height:20px">
			<td style="width:<<:size_done:>>px" bgcolor=#00FF00 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=2'"></td>
			<td style="width:<<:size_running:>>px" bgcolor=#FFFF00 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=1'"></td>
			<td style="width:<<:size_error:>>px" bgcolor=#FF0000 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=3'"></td>
			<td style="width:<<:size_pending:>>px" bgcolor=#DDDDDD onClick="document.location='details.jsp?id=<<:id db enc:>>&status=0'"></td>
		    </tr>
		</table>
	</td>
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:cnt db esc:>>">
	    <<:cnt db:>>
	    <table border=0 cellspacing=0 cellpadding=0 style="width:<<:cntpercentage:>>px">
		<tr style="height:2px">
		    <td bgcolor=blue></td>
		</tr>
	    </table>
	</td>
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:total_size db esc:>>">
	    <<:total_size db size:>>
	    <table border=0 cellspacing=0 cellpadding=0 style="width:<<:total_sizepercentage:>>px">
		<tr style="height:2px">
		    <td bgcolor=blue></td>
		</tr>
	    </table>
	</td>
	<td nowrap align=right  class="table_row" sorttable_customkey="<<:start_time db esc:>>">
	    <<:start_time db nicedate:>> <<:start_time db time:>>
	</td>
	<td nowrap align=right class="table_row" sorttable_customkey="<<:end_time db esc:>>">
	    <<:end_time db nicedate:>> <<:end_time db time:>>
	</td>
    </tr>
