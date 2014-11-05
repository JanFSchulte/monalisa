<script type="text/javascript">
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
    
    function editComment(run, comment){
	var htmlCode = 
	    '<div class=text>'+
	    '<form name=formx method=post action="<<:returnurl:>>">'+
	    '<input type=hidden name=comment_for_run value='+run+'>'+
	    '<table border=0 cellspacing=5 cellpadding=5 width=100%>'+
	    '<tr><td align=left><textarea name=comment class=input_text style="width:450px;height:230px"></textarea></td></tr>'+
	    '<tr><td align=center><input type=submit name=submit class=input_submit value="Update"></td></tr></table></form>'+
	    '</div>'
	;
	
	showCenteredWindowSize(htmlCode, 'Comments on run '+run, 470, 290);
	
	document.formx.comment.value = comment;
    }
    
    function convertComment(sometext){
	return '<div align=left>'+sometext.replace(/\n/g, "&nbsp;<BR clear=all>")+'</div>';
    }
    
</script>

<form name="raw_form" action="raw_details.jsp" method=GET>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>RAW Production Cycles</b></td>
	<td align=right valign=bottom>
	    <<:com_authenticated_start:>>
		<a class=link onMouseOver="overlib('Access to administrator functions');" onMouseOut="return nd();" href="/job_remarks.jsp?returnpath=<<:return_path enc:>>">Login</a>
	    <<:com_authenticated_end:>>
	</td>
    </tr>
    <tr>
	<td align=right colspan=2>
	    <a href="javascript:void(0);" onClick="JavaScript:window.open('/doc/index.jsp?page=raw_raw_details', 'docwindow', 'toolbar=0,width=600,height=400,scrollbars=1,resizable=1,titlebar=1'); return false;" class="link" style="cursor:help">What is this about?</a>
	</td>
    </tr>

    <tr>
	<td valign="top" colspan=2>
	    <table cellspacing=1 cellpadding=2 width="100%" class="sortable">
		<thead>
		<tr class="table_header">
		    <td class="table_header" onClick="switchDiv('td_rawoptions', false, 0.3);" style="cursor:hand; cursor:pointer" onMouseOver="overlib('Show options');" onMouseOut="nd();">
			Filters <img id="td_rawoptions_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0">
		    </td>
		    <td class="table_header" colspan=2>Chunks</td>
		    <td class="table_header"><a href="histograms.jsp?runs=<<:all_runs enc:>>" class="link_header" style="text-decoration:none">Events</a></td>
		    <td class="table_header" colspan=2>AliEn job</td>
		    <<:com_admin_start:>>
		    <td class="table_header" colspan=3>Admin</td>
		    <<:com_admin_end:>>
		    <td class="table_header">QA</td>
		    <td class="table_header" colspan=2>Software versions</td>
		    <td class="table_header">Partition</td>
		    <td class="table_header">Pass</td>
		    <td class="table_header">Output dir</td>
		    <td class="table_header">Comment</td>
		    <td class="table_header" align=center valign=top colspan=2>
			Timing
		    </td>
		    <td class="table_header" align=center valign=top colspan=1>
			Output
		    </td>
		</tr>
		
		<tr class="table_header" style="display:none;font-weight:normal;text-align:left" id="td_rawoptions">
		    <td class="table_header" colspan=3 align=left nowrap valign=top>
			<table border=0 cellspacing=0 cellpadding=0 style="width:100%;font-weight:normal;text-align:left">
			    <tr>
				<td align=left>Run range:</td>
				<td align=left width=100%>
				    <input type=text class="input_text" name="filter_runno" value="<<:filter_runno esc:>>" style="width:100%" onMouseOver="overlib('Run range, eg. 12345,13000-13005,14000-')" onMouseOut="nd()" onClick="nd()">
				</td>
			    </tr>
			    <tr>
				<td>Detectors:</td>
				<td align=left width=100%>
				    <input type=text class="input_text" name="filter_detectors" value="<<:filter_detectors esc:>>" style="width:100%" onMouseOver="overlib('Detectors list, eg. TRD,-TPC')" onMouseOut="nd()" onClick="nd()">
				</td>
			    </tr>
			</table>
		    </td>
		    <td class="table_header" colspan=3 align=left valign=top style="font-weight:normal;text-align:left">
			Job comment filter:<br>
			<input type=text class="input_text" name="filter_jobtype" value="<<:filter_jobtype esc:>>" style="width:100%">
		    </td>
		    <<:com_admin_start:>>
		    <td class="table_header" align=center valign=top>
		    	<input type=checkbox name=resubmit_all onChange="checkResubmit()">
		    </td>
		    <td class="table_header" align=center valign=top>
			<input type=checkbox name=hide_all onChange="checkHide()">
		    </td>
		    <td class="table_header" align=center valign=top>
			<input type=checkbox name=hide_pid_all onChange="checkHidePid()">
		    </td>
		    <<:com_admin_end:>>
		    <td class="table_header" valign=top></td>
		    <td class="table_header" align=center valign=top>
			<select name="filter_root" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_root:>>
			</select>
		    </td>
		    <td class="table_header" align=center valign=top>
			<select name="filter_aliroot" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_aliroot:>>
			</select>
		    </td>
		    <td class="table_header" align=center valign=top>
			<select name="filter_partition" class="input_select" onChange="doFilter()">
			    <option value="">- All -</option>
			    <<:opt_partition:>>
			</select>
		    </td>
		    <td class="table_header" align=center valign=top>
			<select name="filter_pass" class="input_select" onChange="doFilter()">
			    <option value="-1">- All -</option>
			    <<:pass_options:>>
			</select>
		    </td>
		    <td class="table_header" align=center valign=top>
			<input type=text class="input_text" name="filter_outputdir" value="<<:filter_outputdir esc:>>" style="width:100%" onMouseOver="overlib('Output directory filter');" onMouseOut="nd()" onClick="nd()">
		    </td>
		    <td class="table_header" align=center valign=top>
			<input type=text class="input_text" name="filter_comment" value="<<:filter_comment esc:>>" style="width:100%" onMouseOver="overlib('Comment filter');" onMouseOut="nd()" onClick="nd()">
		    </td>
		    <td class="table_header" align=center valign=top colspan=3>
		    </td>
		</tr>
		<tr class="table_header">
		    <td class="table_header">Run number</td>
		    <td class="table_header">OK/All</td>
		    <td class="table_header">%</td>
		    <td class="table_header">(reco)</td>
		    <td class="table_header">Job ID</td>
		    <td class="table_header">Err</td>
		    <<:com_admin_start:>>
		        <td class="table_header">Resubmit</td>
			<td class="table_header">Hide run</td>
			<td class="table_header">Hide PID</td>
		    <<:com_admin_end:>>
		    <td class="table_header"></td>
		    <td class="table_header">ROOT</td>
		    <td class="table_header">ALIROOT</td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
		    	<input type=submit name=s class=input_submit value="Filter">
		    </td>
		    <td class="table_header">Running</td>
		    <td class="table_header">Saving</td>
		    <td class="table_header">Size</td>
		</tr>
		</thead>
		<tbody>
		<<:content:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class="table_header" style="text-align:right"><A href="#" style="text-decoration:none" onClick="showCenteredWindow('<<:all_runs js:>>', 'Run list')"><<:runs_count:>> runs</A></td>
		    <td class="table_header" style="text-align:right"><<:total_processed dot:>>/<<:total_chunks dot:>></td>
		    <td class="table_header" style="text-align:right;background:<<:total_percent_color:>>"><<:total_percent ddot1:>>%</td>
		    <td class="table_header" style="text-align:right" onMouseOver="overlib('<font color=blue>Raw data size: <<:total_rawdata_size db size:>></font><br><font color=red>Pass 1 ESDs size: <<:total_pass1_size db size:>></font><br><font color=green>Pass 2 ESDs size: <<:total_pass2_size db size:>></font><br><font color=yellow>Pass 3 ESDs size: <<:total_pass3_size db size:>></font>')" onMouseOut="nd()">
			<<:total_events dot:>><br>
			<table border=0 cellspacing=1 cellpadding=0 style="width:100px" align=right>
			    <tr><td align=right>
				<table border=0 cellspacing=0 cellpadding=0  style="width:<<:sizepercentage:>>%">
				    <tr style="height:2px">
					<td bgcolor=blue></td>
				    </tr>
				</table>
			    </td></tr>
			    <tr><td align=right>
				<table border=0 cellspacing=0 cellpadding=0  style="width:<<:sizepercentagepass1:>>%">
				    <tr style="height:2px">
					<td bgcolor=red></td>
				    </tr>
				</table>
			    </td></tr>
			    <tr><td align=right>
				<table border=0 cellspacing=0 cellpadding=0  style="width:<<:sizepercentagepass2:>>%">
				    <tr style="height:2px">
					<td bgcolor=green></td>
				    </tr>
				</table>
			    </td></tr>
			</table>
		    </td>
		    <td class="table_header" style="text-align:right" nowrap><a href="javascript:void(0)" style="text-decoration:none" onClick="showCenteredWindow('<<:all_jobs js:>>', 'PIDs')"><<:total_count dot:>> jobs</A></td>
		    <td class="table_header" style="text-align:right" nowrap><<:total_errors dot:>> err</td>
		    <<:com_admin_start:>>
		    <td class="table_header" colspan=3 align=center><input type=submit name=execute value="Execute" onMouseOver="overlib('Apply resubmit and hide selections');" onMouseOut="nd()"></td>
		    <<:com_admin_end:>>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap><<:wall_time intervalh:>></td>
		    <td class="table_header" nowrap><<:saving_time intervalh:>></td>
		    <td class="table_header" nowrap><<:outputsize size:>></td>
		</tr>
		</tfoot>
	    </table>
	</td>
    </tr>
</table>
</form>
