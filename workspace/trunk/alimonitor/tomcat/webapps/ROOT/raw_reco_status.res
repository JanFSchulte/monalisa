<script type="text/javascript">
    function setFilter(value){
	field = objById('filter');
	
	field.value = field.value==value ? '' : value;
	
	document.form1.submit();
	return false;
    }
    
    function stopReloading(){
	cancelAutoReload();
	document.form1.stopreloading.disabled=true;
	document.form1.stopreloading.style.visibility="hidden";
	
	document.form1.resumereloading.style.visibility="visible";
    }
    
    var askPass = <<:ask_pass:>>;
    
    function edit(run, old_comment, caf_reco, grid_reco){
	var htmlCode = 
	    '<div class=text>'+
	    '<form name=formx method=post action='+(askPass ? 'https://alimonitor.cern.ch/raw_reco_status.jsp' : 'raw_reco_status.jsp')+'>'+
	    '<input type=hidden name=runrange value="'+document.form1.runrange.value+'">'+
	    '<input type=hidden name=time value="'+document.form1.time.options[document.form1.time.selectedIndex].value+'">'+
	    '<input type=hidden name=runno value='+run+'>'+
	    '<input type=hidden name=runtype value="'+document.form1.runtype.options[document.form1.runtype.selectedIndex].value+'">'+
	    '<table border=0 cellspacing=5 cellpadding=5 width=100%>'+
	    '<tr><td align=left><textarea name=comment class=input_text style="width:450px;height:200px"></textarea></td></tr>'+
	    '<tr><td align=left>CAF reconstruction status: <select name=caf_reco class=input_select>'+
	    '<option value=0 '+(caf_reco==0 ? 'selected' : '')+'>unknown</option>'+
	    '<option value=1 '+(caf_reco==1 ? 'selected' : '')+'>works</option>'+
	    '<option value=2 '+(caf_reco==2 ? 'selected' : '')+'>fails</option>'+
	    '</select></td></tr>'+
	    '<tr><td align=left>Grid reconstruction status: <select name=grid_reco class=input_select>'+
	    '<option value=0 '+(grid_reco==0 ? 'selected' : '')+'>unknown</option>'+
	    '<option value=1 '+(grid_reco==1 ? 'selected' : '')+'>works</option>'+
	    '<option value=2 '+(grid_reco==2 ? 'selected' : '')+'>fails</option>'+
	    '</select></td></tr>'+
	    '<tr><td align=center><input type=submit name=submit class=input_submit value="Update"></td></tr></table></form>'+
	    '</div>'
	;
	
	stopReloading();
	
	showCenteredWindowSize(htmlCode, 'Comments on run '+run, 470, 290);
	
	document.formx.comment.value = old_comment;
    }
    
    function convertComment(sometext){
	return '<div align=left>'+sometext.replace(/\n/g, "&nbsp;<BR clear=all>")+'</div>';
    }
    
    <<:comments:>>
</script>

<form name=form1 action=raw_reco_status.jsp method=get>
    <input type=hidden name=instance value="<<:instance esc:>>">
    <input type=hidden name=wchunks value=1>
    
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<b>Raw data reconstruction status</b>
		    </td>
		    <td align=right>
			<input type=button class=input_submit name=stopreloading value="Stop reloading" onClick="stopReloading()">
			<input type=submit class=input_submit name=resumereloading value="Refresh" style="visibility:hidden">
		    </td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25>
		    <td class="table_header"><b>Run#</b></td>
		    <td class="table_header"><b>Run type</b></td>
		    <td class="table_header"><b>First seen</b></td>
		    <td class="table_header"><b>Last change</b></td>
		    <td class="table_header"><b>Shuttle PPs</b></td>
		    <td class="table_header"><b>Chunks</b></td>
		    <td class="table_header"><b>Events</b></td>
		    <td class="table_header" colspan=2><b>Reconstruction status</b></td>
		    <td class="table_header" colspan=3><b>Shifter's comments</b></td>
		</tr>

		<tr height=25>
		    <td class="table_header"><input type=text name=runrange value="<<:runrange esc:>>" class=input_text onMouseOver="overlib('Example: 12345,13000-13010,13050', 'Run range')" onMouseOut="nd()" onClick="nd()" style="width:50px"></td>
		    <td class="table_header">
			<select name=runtype class="input_select" onChange="modify();">
			    <option value=''> -- ALL --</option>
			    <<:options_runtype:>>
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<select name=time class="input_select" onChange="modify();">
			    <!--<option value="0" <<:time_0:>>>- All -</option>-->
			    <option value="24" <<:time_24:>>>Last day</option>
			    <option value="168" <<:time_168:>>>Last week</option>
			    <!--
			    <option value="720" <<:time_720:>>>Last month</option>
			    <option value="1464" <<:time_1464:>>>Last 2 months</option>
			    <option value="2190" <<:time_2190:>>>Last 3 months</option>
			    <option value="2920" <<:time_2920:>>>Last 4 months</option>
			    <option value="4320" <<:time_4320:>>>Last 6 months</option>
			    <option value="8760" <<:time_8760:>>>Last year</option>
			    -->
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<input type=checkbox <<:wchunks check:>> name=wchunks_checkbox onChange="document.form1.wchunks.value=document.form1.wchunks_checkbox.checked ? 1 : 0; modify()" class=input_checkbox
			    onMouseOver="overlib('Show only runs with registered chunks')" onMouseOut="nd()"
			>
		    </td>
		    <td class="table_header">(grid reco)</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Event count</td>
		    <td class="table_header">CAF reco</td>
		    <td class="table_header">Grid reco</td>
		    <td class="table_header">Comment</td>
		</tr>
		
		<<:continut:>>
		
		<tr height=25>
		    <td class="table_header"><<:total_runs:>> runs</td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:PP:>></td>
		    <td class="table_header"><<:total_chunks dot:>></td>
		    <td class="table_header"><<:total_grid_events dot:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:total_caf_events dot:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
	    </table>
	</td>
    </tr>
</table>

</form>
