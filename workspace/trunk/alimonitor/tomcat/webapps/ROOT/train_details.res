<script type="text/javascript">
function openFiles(id){
    sHTML = '<iframe src="/productions/train/index.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    showCenteredWindow(sHTML, 'Train '+id);
    return false;
}
function openDownload(id){
    sHTML = '<iframe src="/productions/train/download.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    showCenteredWindowSize(sHTML, 'Output of train '+id, 600, 400);
    return false;
}
</script>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>PRODUCTION CYCLES</b></td>
    </tr>
    <tr height="25">
	<td>
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=left><a href="/train_details.jsp" class="link">Train Details</a> &raquo; <<:filter:>></td>
		    <td align=right><a class=link target=_blank href="/admin/job_types.jsp">Manage &raquo;</a></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td valign="top">
	    <table cellspacing=1 cellpadding=2 width="100%">
		<tr class="table_header">
		    <td class="table_header" colspan=6>Production info</td>
		    <td class="table_header" colspan=4>Jobs status</td>
		    <td class="table_header" colspan=1></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header">Production</td>
		    <td class="table_header">Description</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Completion<br>rate</td>
		    <td class="table_header">Config</td>
		    <td class="table_header">Results</td>
		    <td class="table_header">Total</td>
		    <td class="table_header">Done</td>
		    <td class="table_header">Running</td>
		    <td class="table_header">Waiting</td>
		    <td class="table_header">Comment</td>
		</tr>
		<<:continut:>>
	    </table>
	</td>
    </tr>
</table>
