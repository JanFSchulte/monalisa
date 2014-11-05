<script type="text/javascript">
    function addSE(){
	var se = prompt('New target SE');
	
	if (se.length>0){
	    document.addSEform.add.value=se;
	    document.addSEform.submit();
	}
	
	return false;
    }

    function showLTMEditDialog(){
	var editDialog = '<form name=lpm_settings action=ltm.jsp method=POST><input type=hidden name=settings value=1><table border=0 cellspacing=5 cellpadding=0 class=text style="padding-left:15px;padding-top:15px">'+
		'<tr><td align=left>LPM active: </td><td align=left><input type=checkbox class=input_checkbox name=ltm_active value=1 <<:ltm_status:>>></td></tr>'+
		'<tr><td align=left>(Re)submission trigger: </td><td align=left><input class="input_text" type=text name=ltm_submit_trigger value="<<:ltm_submit_trigger:>>"></td></tr>'+
		'<tr><td align=left>Stop after submitting: </td><td align=left><input class="input_text" type=text name=ltm_resubmit_max value="<<:ltm_resubmit_max:>>"></td></tr>'+
		'<tr><td>&nbsp;</td><td align=left style="padding-top:5px"><input type=submit name=submit value="Save settings" class="input_submit"></td></tr>'+
	    '</table></form>';
	    
	showCenteredWindow(editDialog, 'LTM Settings');
	
	return false;
    }

</script>

<form name=addSEform action=ltm.jsp>
    <input type=hidden name=add value="">
</form>

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr><td align=left valign=top>

<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>RAW data replication targets</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25>
		    <td class="table_header" onMouseOver="overlib('Storage element name');" onMouseOut="nd();"><b>SE name</b></td>
		    <td class="table_header" onMouseOver="overlib('Number of runs mirrored to each SE');" onMouseOut="nd();"><b>Runs</b></td>
		    <td class="table_header" onMouseOver="overlib('Number of raw files mirrored to each SE');" onMouseOut="nd();"><b>Files</b></td>
		    <td class="table_header" onMouseOver="overlib('Total size of the raw files mirrored to each SE');" onMouseOut="nd();"><b>Size</b></td>
		    <td class="table_header" onMouseOver="overlib('Distribution ratio, in percentage');" onMouseOut="nd();"><b>Distribution ratio</b></td>
		    <td class="table_header">Options</td>
		</tr>
		<<:content:>>
		<tr height=25>
		    <td class="table_header"><<:active:>> active, <<:disabled:>> disabled</td>
		    <td class="table_header"><<:runs dot:>></td>
		    <td class="table_header"><<:files dot:>></td>
		    <td class="table_header"><<:size size:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"><a class=link href=# onClick="return addSE();">Add SE</td>
		</tr>
	    </table>
	</td>
    </tr>
</table>

</td>
<td align=right valign=top>
  <table cellspacing=0 cellpadding=2 class="table_content" width=200>
    <tr height=25>
	<td class="table_title"><b>LTM Settings</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
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

</td>
</tr></table>