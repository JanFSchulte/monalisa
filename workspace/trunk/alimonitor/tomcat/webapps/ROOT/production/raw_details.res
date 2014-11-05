<script type="text/javascript">
    function openJDL(pid){
	nd();
    
	window.open('/jdl/'+pid+'.html', 'JDL of '+pid, 'toolbar=0,width=800,height=600,scrollbars=1,resizable=1,titlebar=1'); 
	
	return false;
    }
    
    function jobDetails(pid){
	overlib('<iframe src="job_details.jsp?pid='+pid+'" border=0 width=100% height=230 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Click to go to the logbook');
    }
    
    function doFilter(){
	document.raw_form.submit();
    }

    function checkHide(){
	var fields = document.raw_form.h;
    
	var ref = document.raw_form.hide_all.checked;
    
	if (fields){
    	    if (fields.length && fields.length>0){
    		for (i=0; i<fields.length; i++)
            	    fields[i].checked=ref;
	    }
	    else{
        	try{
            	    fields.checked=ref;
        	}
        	catch (Ex){
        	}
    	    }
	}
    }

    function checkResubmit(){
	var fields = document.raw_form.r;
    
	var ref = document.raw_form.resubmit_all.checked;
    
	if (fields){
    	    if (fields.length && fields.length>0){
    		for (i=0; i<fields.length; i++)
            	    fields[i].checked=ref;
	    }
	    else{
        	try{
            	    fields.checked=ref;
        	}
        	catch (Ex){
        	}
    	    }
	}
    }
    
</script>

<form name="raw_form" action="raw_details.jsp" method=GET>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>RAW Production Cycles</b></td>
	<td align=right valign=bottom>
	    <<:com_authenticated_start:>>
		<a onMouseOver="overlib('Access to administrator functions');" onMouseOut="return nd();" href="/job_remarks.jsp?returnpath=<<:return_path enc:>>"><b>Login</b>
	    <<:com_authenticated_end:>>
	</td>
    </tr>
    <tr>
	<td valign="top" colspan=2>
	    <table cellspacing=1 cellpadding=2 width="100%">
		<tr class="table_header">
		    <td class="table_header" colspan=6>LPM&nbsp;&nbsp;&nbsp;&nbsp;
		    	<select name="filter_lpm" class="input_select" onChange="doFilter()">
			    <option value="0" <<:option_lpm_false:>>>- All -</option>
			    <option value="1" <<:option_lpm_true:>>>Only LPM jobs</option>
			</select>
		    </td>
		    <<:com_admin_start:>>
		    <td class="table_header" colspan=2>Admin</td>
		    <<:com_admin_end:>>
		    <td class="table_header">AliEn</td>
		    <td class="table_header">Detector</td>
		    <td class="table_header" colspan=2>Software versions</td>
		    <td class="table_header" colspan=2>Job details</td>
		    <td class="table_header">Options</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header" colspan=2>Run#</td>
		    <td class="table_header">Chunks</td>
		    <td class="table_header" colspan=2>Processed</td>
		    <td class="table_header">Events</td>
		    <<:com_admin_start:>>
		        <td class="table_header">Resubmit</td>
			<td class="table_header">Hide</td>
		    <<:com_admin_end:>>
		    <td class="table_header">Date/PID</td>
		    <td class="table_header">Partition</td>
		    <td class="table_header">ROOT</td>
		    <td class="table_header">ALIROOT</td>
		    <td class="table_header">Output dir</td>
		    <td class="table_header">Job type <input type=checkbox name="relaxed" <<:relaxed checked:>> onMouseOver="overlib('Checked = relaxed check / substring search<br>Clear = exact match of the string')" onMouseOut="nd()"></td>
		    <td class="table_header"></td>
		</tr>
		<tr class="table_row">
		    <td class="table_row" colspan=6 align=center>
			<input type=text class="input_text" name="filter_runno" value="<<:filter_runno esc:>>" style="width:100%" onMouseOver="overlib('Run range, eg. 12345,13000-13005')" onMouseOut="nd()" onClick="nd()">
		    </td>
		    <<:com_admin_start:>>
		    <td class="table_row" align=center>
		    	<input type=checkbox name=resubmit_all onChange="checkResubmit()">
		    </td>
		    <td class="table_row" align=center>
			<input type=checkbox name=hide_all onChange="checkHide()">
		    </td>
		    <<:com_admin_end:>>
		    <td class="table_row"></td>
		    <td class="table_row" align=center>
			<select name="filter_partition" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_partition:>>
			</select>
		    </td>
		    <td class="table_row" align=center>
			<select name="filter_root" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_root:>>
			</select>
		    </td>
		    <td class="table_row" align=center>
			<select name="filter_aliroot" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_aliroot:>>
			</select>
		    </td>
		    <td class="table_row" align=center>
			<input type=text class="input_text" name="filter_outputdir" value="<<:filter_outputdir esc:>>" style="width:100%" onMouseOver="overlib('Output directory filter');" onMouseOut="nd()" onClick="nd()">
		    </td>
		    <td class="table_row" align=center nowrap>
			<input type=text class="input_text" name="filter_jobtype" value="<<:filter_jobtype esc:>>" style="width:100%" onMouseOver="overlib('Job type filter');" onMouseOut="nd()" onClick="nd()">
			
		    </td>
		    <td class="table_row" align=center>
			<input type=submit name=s class=input_submit value="Filter">
		    </td>
		</tr>
		<<:content:>>
		<tr class="table_header">
		    <td class="table_header" style="text-align:left" colspan=2>TOTAL</td>
		    <td class="table_header" style="text-align:right"><<:total_chunks dot:>></td>
		    <td class="table_header" style="text-align:right"><<:total_processed dot:>></td>
		    <td class="table_header" style="text-align:right;background:<<:total_percent_color:>>"><<:total_percent ddot1:>>%</td>
		    <td class="table_header" style="text-align:right"><<:total_events dot:>></td>
		    <<:com_admin_start:>>
		    <td class="table_header" colspan=2 align=center><input type=submit name=execute value="Execute" onMouseOver="overlib('Apply resubmit and hide selections');" onMouseOut="nd()"></td>
		    <<:com_admin_end:>>
		    <td class="table_header" style="text-align:right"><<:total_count dot:>> jobs</td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
