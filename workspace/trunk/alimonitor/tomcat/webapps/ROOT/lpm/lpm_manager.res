<script type="text/javascript">
    function showEditDialog(){
	var editDialog = '<form name=lpm_settings action=/lpm/lpm_manager.jsp method=POST><table border=0 cellspacing=5 cellpadding=0 class=text style="padding-left:15px;padding-top:15px">'+
		'<tr><td align=left>LPM active: </td><td align=left><input type=checkbox class=input_checkbox name=lpm_active value=1 <<:lpm_status:>>></td></tr>'+
		'<tr><td align=left>(Re)submission trigger: </td><td align=left><input class="input_text" type=text name=submit_trigger value="<<:submit_trigger:>>"></td></tr>'+
		'<tr><td align=left>(Re)submission target: </td><td align=left><input  class="input_text" type=text name=submit_target value="<<:submit_target:>>"></td></tr>'+
		'<tr><td align=left>Stop after resubmitting: </td><td align=left><input class="input_text" type=text name=resubmit_max value="<<:resubmit_max:>>"></td></tr>'+
		'<tr><td align=left>Max number of resubmissions/job: </td><td align=left><input class="input_text" type=text name=resubmit_count value="<<:resubmit_count:>>"></td></tr>'+
		'<tr><td align=left>Max resubmissions for alidaq: </td><td align=left><input class="input_text" type=text name=resubmit_count_alidaq value="<<:resubmit_count_alidaq:>>"></td></tr>'+
		'<tr><td>&nbsp;</td><td align=left style="padding-top:5px"><input type=submit name=submit value="Save settings" class="input_submit"></td></tr>'+
	    '</table></form>';
	    
	showCenteredWindow(editDialog, 'LPM Settings');
	
	return false;
    }

    function showLTMEditDialog(){
	var editDialog = '<form name=lpm_settings action=/lpm/lpm_manager.jsp method=POST><table border=0 cellspacing=5 cellpadding=0 class=text style="padding-left:15px;padding-top:15px">'+
		'<tr><td align=left>LPM active: </td><td align=left><input type=checkbox class=input_checkbox name=ltm_active value=1 <<:ltm_status:>>></td></tr>'+
		'<tr><td align=left>(Re)submission trigger: </td><td align=left><input class="input_text" type=text name=ltm_submit_trigger value="<<:ltm_submit_trigger:>>"></td></tr>'+
		'<tr><td align=left>Stop after submitting: </td><td align=left><input class="input_text" type=text name=ltm_resubmit_max value="<<:ltm_resubmit_max:>>"></td></tr>'+
		'<tr><td>&nbsp;</td><td align=left style="padding-top:5px"><input type=submit name=submit value="Save settings" class="input_submit"></td></tr>'+
	    '</table></form>';
	    
	showCenteredWindow(editDialog, 'LTM Settings');
	
	return false;
    }
    
    function showIgnoreDialog(){
    	showCenteredWindowSize('<iframe src="/lpm/lpm_ignore.jsp" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="yes" align="absmiddle" vspace="0" hspace="0"></iframe>', 'Please wait ...', 800, 500);

	return false;
    }

    function manualSubmit(id){
	if (confirm('Are you sure you want to manually submit another job?')){
	    showCenteredWindowSize('<iframe src="/admin/lpm_submit.jsp?id='+id+'" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="yes" align="absmiddle" vspace="0" hspace="0"></iframe>', 'Please wait ...', 800, 500);	}
	
	return false;
    }
    
    function highlightRow(id){
	objById("id_"+id).style.fontWeight='bold';
	objById("id_"+id).style.color='red';
	
	window.setTimeout('unhighlightRow('+id+')', 5000);
	
	return true;
    }
    
    function unhighlightRow(id){
	objById("id_"+id).style.fontWeight='normal';
	objById("id_"+id).style.color='black';	
    }
</script>

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr><td align=left valign=top>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>LPM Management</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<thead>
		<tr height=25>
		    <td class="table_header">ID</td>
		    <td class="table_header" onMouseOver="overlib('Path to the JDL, absolute or relative to <b><i>aliprod</i></b>\'s home dir.');" onMouseOut="nd();"><b>JDL</b></td>
		    <td class="table_header" onMouseOver="overlib('Job parameter. <b>#RUN#</b> will be replaced automatically with the next run number or the run number of the parent that just finished.');" onMouseOut="nd();"><b>Parameters</b></td>
		    <td class="table_header" onMouseOver="overlib('Submit the child job only if the parent has reached at least this completion. The value can be in either absolute (number of successfull subjobs) or percentage (if you add % at the end)');" onMouseOut="nd();"><b>Parent min<br>completion</b></td>
		    <td class="table_header" onMouseOver="overlib('Logical constraints');" onMouseOut="nd();"><b>Constraints</b></td>
		    <td class="table_header" onMouseOver="overlib('The job is considered done when the percentage of successful subjobs is above this threshold and there are no more active subjobs');" onMouseOut="nd();"><b>Target %<br>completion</b></td>
		    <td class="table_header" onMouseOver="overlib('AliEn username under which to run this JDL');" onMouseOut="nd();"><b>AliEn user</b></td>
		    <td class="table_header" onMouseOver="overlib('Relative weight of this kind of jobs. LPM will try to balance the submission so that <b>Submit count / weight</b> is (almost) equal for all master jobs.');" onMouseOut="nd();"><b>Weight</b></td>
		    <td class="table_header" onMouseOver="overlib('Last run number for this kind of jobs. The next submitted job will have the next value of this sequence.');" onMouseOut="nd();"><b>Last run no</b></td>
		    <td class="table_header" onMouseOver="overlib('Increment up to this run number');"><b>Max run no</b></td>
		    <td class="table_header" onMouseOver="overlib('How many jobs of this kind were submitted by LPM');" onMouseOut="nd();"><b>Submitted</b></td>
		    <td class="table_header" onMouseOver="overlib('Administrative options for the entries');" onMouseOut="nd();"><b>Options</b></td>
		    <td class="table_header" onMouseOver="overlib('Manual submission');" onMouseOut="nd();"><b>Override</b></td>
		</tr>
		<form name=form1>
		<tr height=25>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<select name=account onChange="modify()" class=input_select>
			    <option value=''> - Any -</option>
			    <<:opt_account:>>
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<input type=submit name=input_submit value="&raquo;">
		    </td>
		</tr>
		</form>
		</thead>
		<tbody>
		<<:continut:>>
		</tbody>
	    </table>
	</td>
    </tr>
</table>
<a class="link" href="/lpm/lpm_manager.jsp?add=0&account=<<:account enc:>>#edit"><u>Start a new chain</u></a>
</td>
<td align=center valign=top>
<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b>LPM Settings</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr>
		    <td align=left class="table_row">LPM Status: </td>
		    <td align=right class="table_row"><<:lpm_status_text:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">(Re)submission trigger: </td>
		    <td align=right class="table_row"><<:submit_trigger:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">(Re)submission target: </td>
		    <td align=right class="table_row"><<:submit_target:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">Stop after resubmitting: </td>
		    <td align=right class="table_row"><<:resubmit_max:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">Max resubmissions: </td>
		    <td align=right class="table_row"><<:resubmit_count:>></td>
		</td>
		<tr>
		    <td align=left class="table_row"><i>alidaq</i> resubmissions: </td>
		    <td align=right class="table_row"><<:resubmit_count_alidaq:>></td>
		</td>
	    </table>
	</td>
    </tr>
</table>
<a class="link" href="javascript:void(0);" onClick="return showEditDialog();"><u>Edit LPM Settings</u></a>
<br>
<br>
<a class=link onClick="return showIgnoreDialog();" href="javascript:void(0);"><b><u>Ignore job IDs</u></b></a>
<!--
<br>
<br>
<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b>LTM Settings</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr>
		    <td align=left class="table_row">LTM Status: </td>
		    <td align=right class="table_row"><<:ltm_status_text:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">(Re)submission trigger: </td>
		    <td align=right class="table_row"><<:ltm_submit_trigger:>></td>
		</td>
		<tr>
		    <td align=left class="table_row">Stop after submitting: </td>
		    <td align=right class="table_row"><<:ltm_resubmit_max:>></td>
		</td>
	    </table>
	</td>
    </tr>
</table>
<a class="link" href="javascript:void(0);" onClick="return showLTMEditDialog();"><u>Edit LTM Settings</u></a>
-->
</td>
</table>
