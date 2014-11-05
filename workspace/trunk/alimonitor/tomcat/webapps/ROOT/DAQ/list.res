<script type="text/javascript">
    /*
     * Order the staging of an entire run (all the .root files registered for this run by DAQ)
     */
    function order(run, counter){
	objById('button_'+counter).disabled=true;
	
	if (<<:not_secure:>>){
	    document.form1.action='https://alimonitor.cern.ch/DAQ/';
	    document.form1.run.value=run;
	    document.form1.submit();
	    return;
	}

        var url = "/admin/stage_run.jsp?run="+run;

        new Ajax.Request(url, {
            asynchronous : false,
            method: 'post',
            onComplete: function(transport) {

		var color = '#FFFF00';

                if(transport.status == "200"){
                    if(transport.responseText.indexOf('Error') >= 0){
                        alert("Some error occured:\n"+transport.responseText);
			color='#FF0000';
                    }
                    else{
                        bResponse = true;
                    }
                }
                else{
                    alert("HTTP error (?!?)");
		    color='#FF0000';
                }

	    	objById('td_'+counter).style.backgroundColor=color;
		objById('button_'+counter).style.display='none';
            }
        }
        );
    }
    
    function deleteRun(run, counter){
	objById('remove_'+counter).disabled=true;	
	
	if (<<:not_secure:>>){
	    document.form1.action='https://alimonitor.cern.ch/DAQ/';
	    document.form1.delete.value=run;
	    document.form1.submit();
	    return;
	}
	
        var url = "/admin/stage_run.jsp?delete="+run;

        new Ajax.Request(url, {
            asynchronous : false,
            method: 'post',
            onComplete: function(transport) {
		var color = '#FF9900';

                if(transport.status == "200"){
                    if(transport.responseText.indexOf('Error') >= 0){
                        alert("Some error occured:\n"+transport.responseText);
			color='#FF0000';
                    }
                    else{
                        bResponse = true;
                    }
                }
                else{
                    alert("HTTP error (?!?)");
		    color='#FF0000';
                }

	    	objById('td_'+counter).style.backgroundColor=color;
		objById('remove_'+counter).style.display='none';
            }
        }
        );	
    }
    
    function loginAction(){
	document.form1.action='https://alimonitor.cern.ch/DAQ/';
	document.form1.submit();
    }
    
    function writeLogin(){
	if (<<:not_secure:>>){
	    document.write('<a href=# onClick="return loginAction();" class=link>Login</a>');
	}
    }
</script>

<form name=form1 action="/DAQ/list.jsp" method=POST>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>RAW Data Runs from period
			<select name="partition" class="input_select" onChange="modify();">
			    <<:opt_partition:>>
			</select>

	</b>
	    <div align=right><script type="text/javascript">writeLogin();</script></div>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 class=sortable>
		<thead>
		<tr height=25>
		    <td class="table_header">
			<input type=text name=runfilter value="<<:runfilter esc:>>" class="input_text" style="width:50px" onMouseOver="overlib('list,list,interval-interval,interval-interval');" onMouseOut="nd();">
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<select name="transfer" onChange="modify();" class="input_select">
			    <option value=0 <<:transfer_0:>>>- All -</option>
			    <option value=2 <<:transfer_2:>>>Started</option>
			    <option value=3 <<:transfer_3:>>>Completed</option>
			    <option value=1 <<:transfer_1:>>>Not transferred</option>
			</select>
		    </td>
		    <td class="table_header">
			<select name="processing" onChange="modify();" class="input_select">
			    <option value=0 <<:processing_0:>>>- All -</option>
			    <option value=1 <<:processing_1:>>>Started</option>
			    <option value=2 <<:processing_2:>>>Completed</option>
			</select>
		    </td>
		    <!--
		    <td class="table_header">
			<select name=staging onChange="modify();" class="input_select">
			    <option value=0 <<:staging_0:>>>- All -</option>
			    <option value=1 <<:staging_1:>>>Staged</option>
			    <option value=2 <<:staging_2:>>>Scheduled</option>
			    <option value=3 <<:staging_3:>>>Unstaged</option>
			</select>
		    </td>
		    -->
		    <td class=table_header>
			<input type=submit name=submitter class=input_submit value="&raquo;">
		    </td>
		</tr>
		<tr height=25>
		    <td class="table_header"><b>Run#</b></td>
		    <td class="table_header"><b>Partition</b></td>
		    <td class="table_header"><b>Chunks</b></td>
		    <td class="table_header"><b>Total size</b></td>
		    <td class="table_header"><b>First seen</b></td>
		    <td class="table_header"><b>Last seen</b></td>
		    <td class="table_header"><b>Transfer status</b></td>
		    <td class="table_header"><b>Processing status</b></td>
		    <!--
		    <td class="table_header"><b>Staging status</b></td>
		    -->
		    <td class="table_header">&nbsp;</td>
		</tr>
		</thead>
		<tbody>
		<<:content:>>
		</tbody>
		<tfoot>
		<tr height=25>
		    <td align=right class="table_header"><a class=link href="javascript:void(0)" onClick="showCenteredWindow('<<:runlist esc js:>>', 'Runs in this period');"><<:runs:>> runs</a></td>
		    <td class="table_header">&nbsp;</td>
		    <td align=right class="table_header"><<:files:>> files</td>
		    <td align=right class="table_header"><<:totalsize size:>></td>
		    <td class="table_header">&nbsp;</td>
		    <td class="table_header">&nbsp;</td>
		    <td class="table_header">
			<table border=0 cellspacing=0 cellpadding=0 width=100%>
			    <tr>
				<td bgcolor=#FFFFFF width=33% onMouseOver="overlib('Waiting transfers: <<:transfers_unknown:>>');" onMouseOut="nd();"><<:transfers_unknown:>></td>
				<td bgcolor=#FFFF00 width=33% onMouseOver="overlib('Scheduled transfers: <<:transfers_scheduled:>>');" onMouseOut="nd();"><<:transfers_scheduled:>></td>
				<td bgcolor=#00FF00 width=33% onMouseOver="overlib('Completed transfers: <<:transfers_completed:>>');" onMouseOut="nd();"><<:transfers_completed:>></td>
			    </tr>
			</table>
		    </td>
		    <td class="table_header">
		    	<table border=0 cellspacing=0 cellpadding=0 width=100%>
			    <tr>
				<td bgcolor=#FFFFFF width=33% onMouseOver="overlib('Waiting jobs: <<:jobs_unknown:>>');" onMouseOut="nd();"><<:jobs_unknown:>></td>
				<td bgcolor=#FFFF00 width=33% onMouseOver="overlib('Started jobs: <<:jobs_started:>>');" onMouseOut="nd();"><<:jobs_started:>></td>
				<td bgcolor=#00FF00 width=33% onMouseOver="overlib('Completed jobs: <<:jobs_completed:>>');" onMouseOut="nd();"><<:jobs_completed:>></td>
			    </tr>
			</table>
		    </td>
		    <!--
		    <td class="table_header">
		    	<table border=0 cellspacing=0 cellpadding=0 width=100%>
			    <tr>
				<td bgcolor=#FFFFFF width=33% onMouseOver="overlib('Unstaged runs: <<:staged_unknown:>>');" onMouseOut="nd();"><<:staged_unknown:>></td>
				<td bgcolor=#FFFF00 width=33% onMouseOver="overlib('Staging scheduled: <<:staged_started:>>');" onMouseOut="nd();"><<:staged_started:>></td>
				<td bgcolor=#00FF00 width=33% onMouseOver="overlib('Staging ordered: <<:staged_completed:>>');" onMouseOut="nd();"><<:staged_completed:>></td>
			    </tr>
			</table>
		    </td>
		    -->
		    <td class="table_header">&nbsp;</td>
		</tr>
		</tfoot>
	    </table>
	</td>
    </tr>
</table>

</form>
