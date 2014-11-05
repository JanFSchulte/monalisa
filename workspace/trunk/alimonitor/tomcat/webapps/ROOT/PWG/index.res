<script type="text/javascript">
    function editPrio(id, prio){
	if ( (newprio=prompt('New priority for this request', prio)) ){
	    window.location = 'admin/change_prio.jsp?id='+id+'&prio='+newprio;
	}
	
	return false;
    }
    
    function delID(id){
	if (confirm('Are you sure you want to delete request '+id+' ?')){
	    window.location = 'admin/delete_request.jsp?id='+id;
	}
    
	return false;
    }
    
    function showUsers(id){
        sHTML = '<iframe src="users.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    
	showCenteredWindow(sHTML, 'Responsibles for task '+id);
	
	return false;
    }
    
    function showFile(file){
        sHTML = '<iframe src="view.jsp?file='+file+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    
	showCenteredWindowSize(sHTML, '<b>Click to download the file: <a class=link href="files/'+file+'"><b>'+file+'</a>', 800, 500);
	
	return false;
    }
    
    function showComments(id){
        sHTML = '<iframe src="comments.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    
	showCenteredWindowSize(sHTML, 'Comments on '+id, 800, 500);
	
	return false;
    }
    
    function publishInAliEn(id){
	if (confirm('Are you sure you want to publish the files in AliEn?')){
	    showCenteredWindowSize('<iframe src="admin/publish.jsp?id='+id+'" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="yes" align="absmiddle" vspace="0" hspace="0"></iframe>', 'Please wait ...', 800, 500);
	}

	return false;
    }
</script>

<div align=left>
<table border=0 cellspacing=0 cellpadding=0><tr><td>

<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b>Production Requests</b></td>
    </tr>
    <tr>
	<td align=right>
	    <a href="javascript:void(0);" onClick="JavaScript:window.open('/doc/index.jsp?page=PWG_index', 'docwindow', 'toolbar=0,width=600,height=400,scrollbars=1,resizable=1,titlebar=1'); return false;" class="link" style="cursor:help">What is this about?</a>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_0:>>"><b>ID</b><<:arrow_0:>></a></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_9:>>"><b>Tag</b><<:arrow_9:>></a></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_10:>>"><b>Status</b><<:arrow_10:>></a></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_1:>>"><b>PWG</b><<:arrow_1:>></a></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_2:>>"><b>Type</b><<:arrow_2:>></a></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_3:>>"><b>Energy</b><<:arrow_3:>></a></td>
		    <td class="table_header" rowspan=2>Savannah</td>
		    <td class="table_header" colspan=2><b>Events</b></td>
		    <td class="table_header" colspan=2><b>Dates</b></td>
		    <td class="table_header" colspan=7><b>Files</b></td>
		    <td class="table_header" rowspan=2><a class="link" href="index.jsp?sort=<<:sort_6:>>"><b>Priority</b><<:arrow_6:>></a><br><b>set by PB</b></td>
		    <td class="table_header" rowspan=2><b>Comments</b></td>
		    <td class="table_header" rowspan=2><b>Options</b></td>
		</tr>
		<tr height=25>	
		    <td class="table_header"><a class="link" href="index.jsp?sort=<<:sort_4:>>">Requested</a><<:arrow_4:>></td>
		    <td class="table_header"><a class="link" href="index.jsp?sort=<<:sort_5:>>">Produced</a><<:arrow_5:>></td>
		    <td class="table_header"><a class="link" href="index.jsp?sort=<<:sort_7:>>">Requested</a><<:arrow_7:>></td>
		    <td class="table_header"><a class="link" href="index.jsp?sort=<<:sort_8:>>">Expected</a><<:arrow_8:>></td>
		    <td class="table_header">CheckESD.C</td>
		    <td class="table_header">Config.C</td>
		    <td class="table_header">rec.C</td>
		    <td class="table_header">sim.C</td>
		    <td class="table_header">simrun.C</td>
		    <td class="table_header">tag.C</td>
		    <td class="table_header">JDL</td>
		</tr>
		<<:continut:>>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=right>
	    <a href="work/edit.jsp" class="link">Add production request</a>
	</td>
    </tr>
</table>
</td></tr>
<tr><td>
<<:checklist_disabled:>>
</td></tr></table>
</div>
