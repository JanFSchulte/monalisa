<form name=form1 action=index.jsp method=get>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<b>Jobs by efficiency</b>
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
		    <th class="table_header_stats" width=80><b>#</b></th>
		    <th class="table_header_stats" width=80><b>Job ID</b></th>
		    <th class="table_header_stats" width=80><b>Site</b></th>
		    <th class="table_header_stats" width=80><b>Host</b></th>
		    <th class="table_header_stats" width=80><b>Host pid</b></th>
		    <th class="table_header_stats" width=80><b>Wall time</b></th>
		    <th class="table_header_stats" width=80><b>CPU time</b></th>
		    <th class="table_header_stats" width=80><b>Efficiency</b></th>
		    <th class="table_header_stats" width=80><b>User</b></th>
		    <th class="table_header_stats" width=80><b>RSS</b></th>
		    <th class="table_header_stats" width=80><b>VirtualMem</b></th>
		</tr>
		</thead>

		<tbody>
		<<:content:>>
		</tbody>
	    </table>
	</td>
    </tr>
</table>

</form>
