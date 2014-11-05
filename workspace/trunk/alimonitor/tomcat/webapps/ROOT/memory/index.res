<form name=form1 action=index.jsp method=get>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<b>Top memory consumers (active jobs) : by <a style="text-decoration:none" href="index.jsp?field=virtualmem">virtual memory</a> or by <a style="text-decoration:none" href="index.jsp?field=rss">RSS</a></b>
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
		    <th class="table_header_stats" width=80><b>Job ID</b></th>
		    <th class="table_header_stats" width=80><b>Site</b></th>
		    <th class="table_header_stats" width=80><b>Host</b></th>
		    <th class="table_header_stats" width=80><b>Account</b></th>
		    <th class="table_header_stats" width=80><b>RSS</b></th>
		    <th class="table_header_stats" width=80><b>Virtualmem</b></th>
		    <th class="table_header_stats" width=80><b>Open files</b></th>
		    <th class="table_header_stats" width=80><b>Run time</b></th>
		    <th class="table_header_stats" width=80><b>CPU time</b></th>
		</tr>
		</thead>

		<tbody>
		<<:content:>>
		</tbody>

		<!--
		<thead>
		<tr height=25>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		    <th class="table_header_stats"></th>
		</tr>
		</thead>
		-->
	    </table>
	</td>
    </tr>
</table>

</form>
