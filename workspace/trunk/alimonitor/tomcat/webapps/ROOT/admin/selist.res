<form name=delete action=selist.jsp method=POST>
    <input type=hidden name=delete value="">
</form>

<script type="text/javascript">
    function deleteSE(se_name){
	document.delete.delete.value=se_name;
	document.delete.submit();
    }
    
    function editSE(se_name, se_description){
	document.editform.se_name.value=se_name;
	document.editform.se_description.value=se_description;
	document.editform.se_description.focus();
    }
</script>

<table border=0 cellspacing=0 cellpadding=0>
<tr><td>
<table cellspacing=0 cellpadding=5 class="table_content" width=100%>
    <tr height=25>
	<td nowrap><a href="/services.jsp" class="menu_link_active"><b>Services management</b></a></td>
	<td nowrap style="border-left: 1px solid #C0D5FF;"><a href="/admin/services.jsp" class="menu_link_active"><b>Autorestart &amp; notifications</b></a></td>	
	<td nowrap style="border-left: 1px solid #C0D5FF;"><a href="/admin/subscribers.jsp" class="menu_link_active"><b>Alert Subscribers</b></a></td>		
    </tr>
</table>
</td></tr>
<tr><td>
<table border=0 cellspacing=1 cellpadding=2 class="table_content" style="border: 0px; width:100%; padding-top:10px">
    <tr>
        <td nowrap class="table_header" align=center><b>Storage name</b></td>
        <td nowrap class="table_header" align=center width=100%><b>Description</b></td>
        <td nowrap class="table_header" align=center><b>Options</b></td>
    </tr>
    
    <<:content:>>
    
    <form action="selist.jsp" method=POST name=editform>
    <tr>
	<td nowrap class="table_header" align=left><input type=text class=input_text name="se_name" value="" style="width:100%"></td>
	<td nowrap class="table_header" align=left><input type=text class=input_text name="se_description" value="" style="width:100%"></td>
	<td nowrap class="table_header" align=center><input type=submit class=input_submit name=submit value="Add/Change"></td>
    </tr>
    </form>
</table>
</td></tr>
<tr><td align=right>
<a class=link href="http://alimonitor.cern.ch/stats?page=SE%2Fusertable&dont_cache=true" title="See the list on the live page">Preview &raquo;</a>
</td></tr></table>
