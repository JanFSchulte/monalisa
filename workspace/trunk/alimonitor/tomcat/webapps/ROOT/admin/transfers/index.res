<script type=text/javascript>
    function next(){
	alert('next');
	document.form1.offset.value = document.form1.offset.value + document.form1.show.value;
	modify();
    }
    
    function next(){
	document.form1.offset.value = document.form1.offset.value + document.form1.show.value;
	modify();
    }

    function all(){
	document.form1.show.value = -1;
	modify();
    }

    function countChecks(fields){
	var cnt = 0;
	
	if (fields){
    	    if (fields.length && fields.length>0){
        	for (i=0; i<fields.length; i++)
            	    if (fields[i].checked) cnt++;
	    }
    	    else{
        	try{
            	    if (fields.checked) cnt++;
        	}
        	catch (Ex){
    		}
    	    }
	}
	
	return cnt;
    }
    
    function checkForm(){
	var deleteCount = countChecks(document.form1.d);

	if (deleteCount>0){
	    if (!confirm("Are you sure you want to delete "+deleteCount+" runs?"))
		return false;

	    if (confirm("Are you really really sure? This operation CANNOT BE UNDONE! Click Cancel to confirm"))
		return false;
	}
	
	var archiveCount = countChecks(document.form1.a);
	
	if (archiveCount>0){
	    if (!confirm("Are you sure you want to archive "+archiveCount+" runs?"))
		return false;
	}

	return true;
    }
</script>

<form name=form1 action=index.jsp method=get onSubmit="return checkForm()">
<input type=hidden name=show value="<<:limit:>>">
<input type=hidden name=offset value="<<:offset:>>">
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center>
			<b>Raw data runs transfer</b>
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
		    <td class="table_header"><b>Partition</b></td>
		    <td class="table_header"><b>Chunks</b></td>
		    <td class="table_header"><b>Size</b></td>
		    <td class="table_header">DAQ "Good run"</td>
		    <td class="table_header">SHUTTLE</td>
		    <td class="table_header"><b>Archive</b><input type=checkbox name=aall onChange="changeCheckState(document.form1.a, document.form1.aall.checked)"></td>
		    <td class="table_header"><b>To T1</b><input type=checkbox name=tall onChange="changeCheckState(document.form1.t, document.form1.tall.checked)"></td>
		    <td class="table_header"><b>Delete</b><input type=checkbox name=dall onChange="changeCheckState(document.form1.d, document.form1.dall.checked)"></td>
		</tr>

		<tr height=25>
		    <td class="table_header"><input type=text name=runrange value="<<:runrange esc:>>" class=input_text onMouseOver="overlib('Example: 12345,13000-13010,13050', 'Run range')" onMouseOut="nd()" onClick="nd()" style="width:100px"></td>
		    <td class="table_header">
			<select name=partition class="input_select" onChange="modify();">
			    <option value=''> -- ALL --</option>
			    <<:options_partitions:>>
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<select name=daqstatus class=input_select onChange="modify()">
			    <option value='-1'>-- ALL --</option>
			    <option value=1 <<:daqstatus_1:>>>Good runs</option>
			</select>
		    </td>
		    <td class="table_header">
			<select name=shuttlestatus class=input_select onChange="modify()">
			    <option value=''>-- ALL --</option>
			    <option value='Done' <<:shuttlestatus_Done:>>>Success</option>
			</select>
		    </td>
		    <td class="table_header">
			<select name=transferstatus class=input_select onChange="modify()">
			    <option value=''>-- ALL --</option>
			    <option value=0 <<:transferstatus_0:>>>Not requested</option>
			    <option value=1 <<:transferstatus_1:>>>Active</option>
			    <option value=2 <<:transferstatus_2:>>>Completed</option>
			    <option value=3 <<:transferstatus_3:>>>Failed</option>
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		</tr>
		
		<<:content:>>
		
		<tr height=25>
		    <td class="table_header"><<:total_runs:>> runs</td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:total_chunks:>></td>
		    <td class="table_header"><<:total_size size:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" colspan=3 align=center><input type=submit name=submit class=input_submit value="Execute"></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td>
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=left width=100>
			<<:com_prev_start:>>
			    <a class=link href="javascript:prev()">&laquo; Previous &laquo;</a>
			<<:com_prev_end:>>
		    </td>
		    <td align=center>
			<<:com_all_start:>>
			    <a class=link href="javascript:all()">&laquo; Show all &raquo;</a>
			<<:com_all_end:>>
		    </td>
		    <td align=right width=100>
			<<:com_next_start:>>
			    <a class=link href="javascript:next()">&raquo; Next &raquo;</a>
			<<:com_next_end:>>
		    </td>
		</tr>
	    </table>
	</td>
    </tr>
</table>

</form>
