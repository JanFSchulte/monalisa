<script type="text/javascript">
    function executeAjax(op, run, pass){
	new Ajax.Request('/PWG/admin/rawrequest.jsp?op='+op+'&run='+run+'&pass='+pass, {
	    method: 'get',
	    onComplete: function(transport) {
		if(transport.status == "200"){
		    if(transport.responseText.indexOf('ERR') >= 0){
		        alert("Error: "+transport.responseText.substring(4));
		    }
		}
		else{
		    alert("Error requesting : "+transport.status);
		}
		
		document.raw_form.submit();
		return false;
	    }
	  }
	);

	return false;
    }
    
    function executeAdd(){
	executeAjax(1, document.addform.run.value, document.addform.pass.value);
	
	closeWindow();
	
	return false;
    }
    
    function switchToSecure(){
	document.raw_form.action='https://alimonitor.cern.ch/production/requests.jsp';
	document.raw_form.submit();
    }

    function checkSecure(){
	if (!<<:secure:>>){
	    alert('To execute this operation you have to be authenticated. You will now be switched to a secure connection.');

	    switchToSecure();
	    
	    return false;
	}
	
	return true;
    }

    function add(){
	if (!checkSecure())
	    return;
    
	sHTML = 
	    '<div style="padding-left:20px;padding-top:20px" align=left>'+
	    '<form name=addform method=post action=/PWG/admin/rawrequest.jsp onSubmit="return executeAdd()">'+
	    '<table border=0 cellspacing=5 cellpadding=0 class=text>'+
		'<tr><td colspan=2 align=center><b>Add new request to the list</b></td></tr>'+
		'<tr><td align=left>Run number(s) (comma separated list):</td><td><input type=text class=input_text name=run></td></tr>'+
		'<tr><td align=left>Pass:</td><td><input type=text class=input_text name=pass value=1></td></tr>'+
		'<tr><td colspan=2 align=center><input type=submit class=input_submit name=submit value=Add></td></tr>'+
	    '</table></div>'
	;
	
	showCenteredWindow(sHTML, 'New request');
	
	return false;
    }

    function delete_run(run, pass){
	if (!checkSecure())
	    return;
    
	if (!confirm('Are you sure you want to delete request for run '+run+', pass '+pass+' ?')){
	    return;
	}
	
	executeAjax(2, run, pass);
    }
    
    function reprocess(run, pass){
	if (!checkSecure())
	    return;
    
	if (!confirm('Are you sure you want to re-execute analysis of run '+run+', pass '+pass+' ?')){
	    return;
	}
	
	executeAjax(3, run, pass);
    }
</script>
<form name="raw_form" action="requests.jsp" method=POST>
<table cellspacing=0 cellpadding=2 class="table_content" align="left">
    <tr height="25">
	<td class="table_title">
	    <b>RAW Data Processing Requests</b>
	    <div align=right class=text>
	    <<:com_insecure_start:>>
		<a href="javascript:void(0)" onClick="switchToSecure()" class=link>Log in to access administrative options &raquo;</a>
	    <<:com_insecure_end:>>
	    <<:com_secure_start:>>
	        Welcome <B><<:username:>></B>!
		<<:com_auth_start:>>
		    <a href="javascript:void(0)" onClick="add()" class=link>Add new request &raquo;</a>
	        <<:com_auth_end:>>
	        <<:com_noauth_start:>>
	    	    <br>Sorry, you don't have administrator role on this page.
	        <<:com_noauth_end:>>
	    <<:com_secure_end:>>
	    </div>
	</td>
    </tr>
    <tr>
	<td valign="top">
	    <table cellspacing=1 cellpadding=2 width="100%" class=text>
		<tr class="table_header">
		    <td class="table_header">Run # (chunks)</td>
		    <td class="table_header">Partition</td>
		    <td class="table_header">Pass</td>
		    <td class="table_header">Requested</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Options</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header" align=center>
			<input type=text class="input_text" name="filter_runno" value="<<:filter_runno esc:>>" onMouseOver="overlib('Run range, eg. 12345,13000-13005')" onMouseOut="nd()" onClick="nd()">
		    </td>
		    <td class="table_header" align=center>
			<select name=filter_partition class=input_select onChange="document.raw_form.submit()">
			    <option value="">- Any -</option>
			    <<:opt_partition:>>
			</select>
		    </td>
		    <td class="table_header" align=center>
			<select name=filter_pass class=input_select onChange="document.raw_form.submit()">
			    <option value="-1">- Any -</option>
			    <<:pass_options:>>
			</select>
		    </td>
		    <td class="table_header" align=center>
		    </td>
		    <td class="table_header" align=center>
			<select name=filter_status class=input_select onChange="document.raw_form.submit()">
			    <option value="">- Any -</option>
			    <option value=0 <<:status_0:>>>Requested</option>
			    <option value=1 <<:status_1:>>>Processing</option>
			    <option value=2 <<:status_2:>>>Completed</option>
			</select>
		    </td>
		    <td class="table_header" align=center>
			<input type=submit name=s value="Filter" class=input_submit>
		    </td>
		</tr>
		<<:content:>>
		<tr class="table_header">
		    <td class="table_header" style="text-align:left">TOTAL</td>
		    <td class="table_header" style="text-align:right"><<:totalcnt:>> jobs</td>
		    <td class="table_header" style="text-align:left"></td>
		    <td class="table_header" style="text-align:left"></td>
		    <td class="table_header" style="text-align:left">
			<table border=0 cellspacing=2 cellpadding=0 width=100% style="font-family:Helvetica,Arial;font-size:9px">
			    <tr>
				<td bgcolor=#FFFFFF width=33.3% align=center><<:requested:>></td>
				<td bgcolor=#FFFF00 width=33.3% align=center><<:started:>></td>
				<td bgcolor=#00FF00 width=33.3% align=center><<:completed:>></td>
			    </tr>
			</table>
		    </td>
		    <td class="table_header" style="text-align:left"></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
