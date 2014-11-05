<script type=text/javascript>
    function showAddForm(){
	showCenteredWindowSize('<iframe src="/admin/transfers/add.jsp" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="yes" align="absmiddle" vspace="0" hspace="0"></iframe>', 'Add new transfer request', 800, 500);
    }
</script>

<form name=form1 action=index.jsp method=get>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<b>Transfer requests (<a class=link href="javascript:showAddForm()">add new request</a>)</b>
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
		    <th class="table_header_stats"><input class=input_text type=text name=id value="<<:id esc:>>" size=5></th>
		    <th class="table_header_stats"><input class=input_text type=text name=path value="<<:path esc:>>" style="width:100%"></th>
		    <th class="table_header_stats"><input class=input_text type=text name=target value="<<:target esc:>>" style="width:100%"></th>
		    <th class="table_header_stats">
			<select class=input_select name=status onChange="modify()">
			    <option value=-1>- any -</option>
			    <option value=0 <<:status_0_selected:>>>Queued</option>
			    <option value=1 <<:status_1_selected:>>>Running</option>
			    <option value=2 <<:status_2_selected:>>>Done</option>
			    <option value=3 <<:status_3_selected:>>>Error</option>
			</select>
		    </th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"><input type=submit class=input_submit value="Filter"></th>
		</tr>

		<tr height=25>
		    <th class="table_header_stats"><b>ID</b></th>
		    <th class="table_header_stats"><b>Path</b></th>
		    <th class="table_header_stats"><b>Target SE</b></th>
		    <th class="table_header_stats"><b>Status</b></th>
		    <th class="table_header_stats"><b>Progress</b></th>
		    <th class="table_header_stats"><b>Files</b></th>
		    <th class="table_header_stats"><b>Total size</b></th>
		    <th class="table_header_stats"><b>Started</b></th>
		    <th class="table_header_stats"><b>Ended</b></th>
		</tr>
		
		</thead>

		<tbody>
		<<:content:>>
		</tbody>

		<tfoot>
		<tr height=25>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats" onMouseOver="overlib('<<:transfer_ids esc js:>>');" onMouseOut="nd();" onClick="showCenteredWindow('<<:transfer_ids esc js:>>', 'Transfer IDs');"><<:transfers_count db:>> requests</th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats">
			<table cellspacing=0 cellpadding=0 style="width:100px" onMouseOver="overlib('<<:transfer_tooltip js:>>');" onMouseOut="nd()">
			<tr style="height:20px">
			    <td style="width:<<:size_done:>>px" bgcolor=#00FF00 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=2'"></td>
			    <td style="width:<<:size_running:>>px" bgcolor=#FFFF00 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=1'"></td>
			    <td style="width:<<:size_error:>>px" bgcolor=#FF0000 onClick="document.location='details.jsp?id=<<:id db enc:>>&status=3'"></td>
			    <td style="width:<<:size_pending:>>px" bgcolor=#DDDDDD onClick="document.location='details.jsp?id=<<:id db enc:>>&status=0'"></td>
			</tr>
			</table>
		    </th>
		    <th class="table_header_stats"><<:total_count db:>></th>
		    <th class="table_header_stats"><span onMouseOver="overlib('Total : <<:total_size size db:>>&lt;br&gt;Done : <<:done_size size db:>>');" onMouseOut="nd()"><<:total_size size db:>></span></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		</tr>
		</tfoot>
	    </table>
	</td>
    </tr>
    <input type=hidden name=p value="0">
    <tr>
        <td>
    	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
    		<tr>
    		    <td width=33% align=left>
    			<<:com_prev_start:>><a href="javascript:void(0)" onClick="document.form1.p.value=<<:prev_page:>>; document.form1.submit(); return false;" class=link>&laquo; Previous page &laquo;</a><<:com_prev_end:>>
    		    </td>
    		    <td width=33% align=center>Requests per page: <select name=l class=input_select onChange="modify();">
    			<option <<:limit_100:>> value=100>100</option>
    			<option <<:limit_500:>> value=500>500</option>
    			<option <<:limit_1000:>> value=1000>1000</option>
    			<option <<:limit_-1:>> value=-1>- All -</option>
    			</select>
    		    </td>
    		    <td width=33% align=right>
    			<<:com_next_start:>><a href="javascript:void(0)" onClick="document.form1.p.value=<<:next_page:>>; document.form1.submit(); return false;" class=link>&raquo; Next page &raquo;</a><<:com_next_end:>>
    		    </td>
    		</tr>
    	    </table>
        </td>
    </tr>
</table>

</form>
