<form name=form1 action=details.jsp method=get>
    <input type=hidden name=id value="<<:id db esc:>>">
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<a href="index.jsp#<<:id db:>>" class=link>Details for transfer #<<:id db :>> (<b><<:path db esc:>></b> to <b><<:targetse db esc:>></b>)</a>
		    </td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 class=sortable>
		<thead>
		
		<tr height=25>
		    <th class="table_header_stats"><input type=text name=pathfilter value="<<:pathfilter esc:>>" class=input_text style="width:100%"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"><input type=text name=alienid value="<<:alienid esc:>>" class=input_text style="width:70px"></th>
		    <th class="table_header_stats">
			<select name=status class=input_select onChange="modify()">
			    <option value=-1>- All -</option>
			    <option value=0 <<:status_0:>>>Pending</option>
			    <option value=1 <<:status_1:>>>Running</option>
			    <option value=2 <<:status_2:>>>Done</option>
			    <option value=3 <<:status_3:>>>Error</option>
			</select>
		    </th>
		    <th class="table_header_stats"><input type=text name=retries value="<<:retries esc:>>" class=input_text style="width:70px"></th>
		    <th class="table_header_stats" nowrap><input type=text name=reason value="<<:reason esc:>>" class=input_text style="width:100px">
			<input type=submit name=submit value="&raquo;" class=input_submit>
		    </th>
		</tr>
		
		<tr height=25>
		    <th class="table_header_stats"><b>Path</b></th>
		    <th class="table_header_stats"><b>File size</b></th>
		    <th class="table_header_stats"><b>AliEn ID</b></th>
		    <th class="table_header_stats"><b>Status</b></th>
		    <th class="table_header_stats"><b>Retries left</b></th>
		    <th class="table_header_stats"><b>Failure reason</b></th>
		</tr>

		</thead>
		<<:content:>>
		
		<tfoot>
		    <th class="table_header_stats"><<:count:>> files</th>
		    <th class="table_header_stats"><<:filesize size:>></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		</tfoot>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=right>
	    <<:com_prev_start:>><a class=link href="details.jsp?id=<<:id db enc:>>&status=<<:status:>>&page=<<:page_prev:>>">&laquo; Prev</a>&nbsp;&nbsp;<<:com_prev_end:>>
	    <<:com_all_start:>>&nbsp;&nbsp;<a class=link href="details.jsp?id=<<:id db enc:>>&status=<<:status:>>&all=true">All</a>&nbsp;&nbsp;<<:com_all_end:>>
	    <<:com_next_start:>>&nbsp;&nbsp;<a class=link href="details.jsp?id=<<:id db enc:>>&status=<<:status:>>&page=<<:page_next:>>">Next &raquo;</a>&nbsp;&nbsp;<<:com_next_end:>>
	</td>
    </tr>
</table>

</form>
