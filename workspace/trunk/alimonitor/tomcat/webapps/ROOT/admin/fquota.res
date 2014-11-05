<table border=0 cellspacing=0 cellpadding=0>
<tr><td>
<table cellspacing=0 cellpadding=5 class="table_content" width=100%>
    <tr height=25>
	<td nowrap><a href="jquota.jsp" class="menu_link"><b>Job Quotas</b></a></td>
	<td nowrap style="border-left: 1px solid #C0D5FF;"><a href="/admin/fquota.jsp" class=menu_link_active><b>File Quotas</b></a></td>	
    </tr>
</table>
</td></tr>
<tr><td>
<table border=0 cellspacing=1 cellpadding=2 class="table_content sortable" style="border: 0px; width:100%; padding-top:10px">
    <thead>
    <tr>
	<td class=table_header></td>
        <td nowrap class="table_header" align=center colspan=3><b>File count</b></td>
        <td nowrap class="table_header" align=center colspan=3><b>Total size</b></td>
    </tr>
    <tr>
        <td nowrap class="table_header" align=center><b>Account</b></td>
        <td nowrap class="table_header" align=center><b>Graphical</b></td>
        <td nowrap class="table_header" align=center><b>Defined</b></td>
        <td nowrap class="table_header" align=center><b>Quota</b></td>
        <td nowrap class="table_header" align=center><b>Graphical</b></td>
        <td nowrap class="table_header" align=center><b>Used</b></td>
        <td nowrap class="table_header" align=center><b>Quota</b></td>
    </tr>
    </thead>
    
    <tbody>
    <<:content:>>
    </tbody>
    <tfoot>
    <tr>
	<td class=table_header>TOTAL</td>
	<td class=table_header></td>
	<td class=table_header><<:total_count dot:>></td>
	<td class=table_header></td>
	<td class=table_header></td>
	<td class=table_header><<:total_size size:>></td>
	<td class=table_header></td>
    </tr>
    </tfoot>
</table>
</td></tr>
</table>
