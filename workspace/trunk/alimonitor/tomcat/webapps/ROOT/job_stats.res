<script type=text/javascript>
    function openJDL(pid){
	nd();
    
	window.open('/jdl/'+pid+'.html', 'JDL of '+pid, 'toolbar=0,width=800,height=600,scrollbars=1,resizable=1,titlebar=1'); 
	
	return false;
    }

    function openLive(pid){
	nd();

	var htmlcode = '<iframe src="/jobs/details.jsp?pid='+pid+'" border=0 width=100% height=99% frameborder=0 marginwidth=0 marginheight=0 scrolling=auto align=absmiddle vspace=0 hspace=0></iframe>';

	showCenteredWindowSize(htmlcode, "Status of masterjob "+pid, 650, 400);

	return false;    
    }
    
    function jobDetails(pid){
	overlib('<iframe src="/jobs/job_details.jsp?pid='+pid+'" border=0 width=100% height=230 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Click for live details');
    }

    function runDetails(run){
	overlib('<iframe src="rawrun_details.jsp?run='+run+'" border=0 width=100% height=230 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>');
    }
</script>

<form name=form1 action=job_stats.jsp method=post>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Jobs in TaskQueue</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25 class="table_header_right_bold">
		    <td class="table_header">pid</td>
		    <td class="table_header">owner</td>
		    <td class="table_header">first seen</td>
		    <td class="table_header">last seen</td>
		    <td class="table_header">subjobs</td>
		    <td class="table_header" colspan=13>Job states</td>
		    <td class="table_header" colspan=16>Error types</td>
		</tr>
		<tr bgcolor="#FFFFFF">
		    <td class="table_row_right">
			<input type=text class=input_text name=pid value="<<:pid:>>" onFocus="focusText(this, 100);" onBlur="blurText(this);" style="width:100%">
		    </td>
		    <td class="table_row_right">
			<select name=owner class="input_select" onChange="document.form1.submit();">
			    <option value=""> - All - </option>
			    <<:opt_owner:>>
			</select>
		    </td>
		    <td class="table_row_right">
			<select name=timesel class="input_select" onChange="document.form1.submit();">
			    <option <<:opt_time_0:>> value=""> - All - </option>
			    <option <<:opt_time_1:>> value="1">last day</option>
			    <option <<:opt_time_7:>> value="7">last week</option>
			    <option <<:opt_time_14:>> value="14">last 2 weeks</option>
			    <option <<:opt_time_31:>> value="31">last month</option>
			    <option <<:opt_time_61:>> value="61">last 2 months</option>
			    <option <<:opt_time_92:>> value="92">last 3 months</option>
			    <option <<:opt_time_365:>> value="365">last year</option>
			</select>
		    </td>
		    <td class="table_row_right">
			<select name=lastseen class="input_select" onChange="document.form1.submit();">
			    <option value="0" <<:opt_last_0:>>> - All - </option>
			    <option value="1" <<:opt_last_1:>>> Active </option>
			    <option value="2" <<:opt_last_2:>>> Finished </option>
			    <option value="3" <<:opt_last_3:>>> Completed </option>
			</select>
		    </td>
		    <td class="table_row" style="border-right: 1px solid #9F9F9F"></td>
		    <td class="table_row_right">SPLIT</td>
		    <td class="table_row_right" colspan=2><font color=#999900>WAITING</td>
		    <td class="table_row_right" colspan=2>STARTED</td>
		    <td class="table_row_right" colspan=2><font color=green>RUNNING</td>
		    <td class="table_row_right" colspan=2><font color=#990099>SAVING</td>
		    <td class="table_row_right" colspan=2><font color=blue>DONE</td>
		    <td class="table_row_right" colspan=2 style="border-right: 1px solid #9F9F9F"><font color=red>ERRORS</td>
		    <td class="table_row_right" colspan=2>ERROR_V</td>
		    <td class="table_row_right" colspan=2><font color=red>ERROR_SV</td>
		    <td class="table_row_right" colspan=2>ERROR_E</td>
		    <td class="table_row_right" colspan=2><font color=red>ERROR_IB</td>
		    <td class="table_row_right" colspan=2>ERROR_VN</td>
		    <td class="table_row_right" colspan=2><font color=red>ERROR_VT</td>
		    <td class="table_row_right" colspan=2>EXPIRED</td>
		    <td class="table_row" colspan=2><font color=red>ZOMBIE</td>
    		</tr>
		<<:continut:>>
		<tr class="table_header_right">
		    <td class="table_header" colspan=4>TOTAL : <<:TOTAL_JOBS:>> jobs</td>
		    <td class="table_header" align=right style="border-right: 1px solid #9F9F9F">&nbsp;<<:TOTAL:>></td>
		    <td class="table_header" align=right>&nbsp;<<:SPLIT:>></td>
		    <td class="table_header" align=right><font color=#999900>&nbsp;<<:P_WAITING:>></td>
		    <td class="table_header" align=right><font color=#999900>&nbsp;<<:WAITING:>></td>
		    <td class="table_header" align=right><font color=#999900>&nbsp;<<:P_STARTED:>></td>
		    <td class="table_header" align=right><font color=#999900>&nbsp;<<:STARTED:>></td>
		    <td class="table_header" align=right><font color=green>&nbsp;<<:P_RUNNING:>></td>
		    <td class="table_header" align=right><font color=green>&nbsp;<<:RUNNING:>></td>
		    <td class="table_header" align=right><font color=#990099>&nbsp;<<:P_SAVING:>></td>
		    <td class="table_header" align=right><font color=#990099>&nbsp;<<:SAVING:>></td>
		    <td class="table_header" align=right><font color=blue>&nbsp;<<:P_DONE:>></td>
		    <td class="table_header" align=right><font color=blue>&nbsp;<<:DONE:>></td>	
		    <td class="table_header" align=right><font color=red>&nbsp;<<:P_ERROR_ALL:>></td>
		    <td class="table_header" align=right  style="border-right: 1px solid #9F9F9F"><font color=red>&nbsp;<<:ERROR_ALL:>></td>
		    <td class="table_header" align=right>&nbsp;<<:P_ERROR_V:>></td>
		    <td class="table_header" align=right>&nbsp;<<:ERROR_V:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:P_ERROR_SV:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:ERROR_SV:>></td>
		    <td class="table_header" align=right>&nbsp;<<:P_ERROR_E:>></td>
		    <td class="table_header" align=right>&nbsp;<<:ERROR_E:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:P_ERROR_IB:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:ERROR_IB:>></td>
		    <td class="table_header" align=right>&nbsp;<<:P_ERROR_VN:>></td>
		    <td class="table_header" align=right>&nbsp;<<:ERROR_VN:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:P_ERROR_VT:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:ERROR_VT:>></td>
		    <td class="table_header" align=right>&nbsp;<<:P_EXPIRED:>></td>
		    <td class="table_header" align=right>&nbsp;<<:EXPIRED:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:P_ZOMBIE:>></td>
		    <td class="table_header" align=right><font color=red>&nbsp;<<:ZOMBIE:>></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
