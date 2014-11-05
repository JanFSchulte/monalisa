<script type="text/javascript">
    function resubmit(list){
	showIframeWindow('/admin/resubmitList.jsp?ids='+escape(list), 'Resubmitting error jobs');
    }
    
    function psqa(){
	window.open('psqa.jsp?pid=<<:psqa_pids enc:>>', '_blank');
    }
    
    function iostat(){
	window.open('/jobs/iostat.jsp?pid=<<:iostat_pids enc:>>', '_blank');
    }
</script>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title">Production details: <b><<:jt_type db esc:>></b></td>
    </tr>
    <tr>
	<td valign="top">
	    <form name=form1 method=post action="/prod/jobs.jsp?t=<<:jt_id db esc:>>">
	    <table cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<tr class="table_header">
		    <td class="table_header" colspan=2>Job info</td>
		    <<:com_qafinalmerging_start:>>
		    <td class=table_header>Beam status</td>
		    <<:com_qafinalmerging_end:>>
		    <<:com_cpass0merging_start:>>
		    <td class="table_header" colspan=20>Detector status</td>
		    <<:com_cpass0merging_end:>>
		    <<:!com_cpass0merging_start:>>
		    <td class="table_header" colspan=4>Events</td>
		    <<:!com_cpass0merging_end:>>
		    <td class="table_header" colspan=2>Software versions</td>
		    <td class="table_header" colspan=1></td>
		    <td class="table_header" colspan=7>Job states</td>
		    <td class="table_header" colspan=2>Timing</td>
		    <td class="table_header" colspan=1>Output</td>
		    <<:com_psqa_start:>>
			<td class="table_header" colspan=1>PS QA</td>
		    <<:com_psqa_end:>>
		    <<:com_iostat_start:>>
			<td class="table_header" colspan=1>IO</td>
		    <<:com_iostat_end:>>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=pid style="width:100%" value="<<:pid esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=runno style="width:100%" value="<<:runno esc:>>"></td>
		    
		    <<:com_qafinalmerging_start:>>
		    <td class=table_header></td>
		    <<:com_qafinalmerging_end:>>
		    
		    <<:com_cpass0merging_start:>>
		    <td class="table_header" colspan=4>GRP</td>
		    <td class="table_header" colspan=4>T0</td>
		    <td class="table_header" colspan=4>TOF</td>
		    <td class="table_header" colspan=4>TPC</td>
		    <td class="table_header" colspan=4>TRD</td>
		    <<:com_cpass0merging_end:>>
		    <<:!com_cpass0merging_start:>>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=input_events style="width:100%" value="<<:input_events esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=train_passed style="width:100%" value="<<:train_passed esc:>>"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=train_output style="width:100%" value="<<:train_output esc:>>"></td>
		    <<:!com_cpass0merging_end:>>
		    
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=app_root style="width:100%" value="<<:app_root esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=app_aliroot style="width:100%" value="<<:app_aliroot esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=outputdir style="width:100%" value="<<:outputdir esc:>>"></td>
		    <td class="table_header" colspan=7 align=right><input type=submit class=input_submit name=s value="&raquo;"></td>
		    <td class="table_header" colspan=3 align=right>(done jobs only)</td>
		    <<:com_psqa_start:>>
			<td class="table_header" colspan=1 align=right></td>
		    <<:com_psqa_end:>>
		    <<:com_iostat_start:>>
			<td class="table_header" colspan=1 align=right></td>
		    <<:com_iostat_end:>>
		</tr>
		<tr class="table_header">
		    <td class="table_header">PID</td>
		    <td class="table_header">Run no.</td>
		    
		    <<:com_qafinalmerging_start:>>
		    <td class=table_header></td>
		    <<:com_qafinalmerging_end:>>
		    
		    <<:com_cpass0merging_start:>>
		    <td class="table_header" style="width:25px">Log</td>
		    <td nowrap class="table_header">Code</td>
		    <td nowrap class="table_header">Events</td>
		    <td nowrap class="table_header">Tracks</td>
		    <td nowrap class="table_header">Log</td>
		    <td nowrap class="table_header">Code</td>
		    <td nowrap class="table_header">Events</td>
		    <td nowrap class="table_header">Tracks</td>
		    <td nowrap class="table_header">Log</td>
		    <td nowrap class="table_header">Code</td>
		    <td nowrap class="table_header">Events</td>
		    <td nowrap class="table_header">Tracks</td>
		    <td nowrap class="table_header">Log</td>
		    <td nowrap class="table_header">Code</td>
		    <td nowrap class="table_header">Events</td>
		    <td nowrap class="table_header">Tracks</td>
		    <td nowrap class="table_header">Log</td>
		    <td nowrap class="table_header">Code</td>
		    <td nowrap class="table_header">Events</td>
		    <td nowrap class="table_header">Tracks</td>
		    <<:com_cpass0merging_end:>>
		    <<:!com_cpass0merging_start:>>
		    <td class="table_header">Input</td>
		    <td class="table_header">Processed</td>
		    <td class="table_header">%</td>
		    <td class="table_header">Filtered</td>
		    <<:!com_cpass0merging_end:>>
		    
		    <td class="table_header">ROOT</td>
		    <td class="table_header">AliROOT</td>
		    <td class="table_header">Output directory</td>
		    <td class="table_header">%</td>
		    <td class="table_header">Total</td>
		    <td class="table_header">Done</td>
		    <td class="table_header">Active</td>
		    <td class="table_header">Wait</td>
		    <td class="table_header">Err.</td>
		    <td class="table_header">Oth.</td>
		    <td class="table_header">Running</td>
		    <td class="table_header">Saving</td>
		    <td class="table_header">Size</td>
		    <<:com_psqa_start:>>
			<td class="table_header">Plot</td>
		    <<:com_psqa_end:>>
		    <<:com_iostat_start:>>
			<td class="table_header">Plot</td>
		    <<:com_iostat_end:>>
		</tr>
		</thead>
		<tbody>
		<<:content:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class="table_header" nowrap><span onMouseOver="overlib('Click to get the list of job IDs');" onMouseOut="nd();" onClick="showCenteredWindow('<<:pids_list js esc:>>', 'Process IDs');"><<:jobs_cnt esc:>> jobs</span></td>
		    <td class="table_header" nowrap>
			<span onMouseOver="overlib('Click to get the list of run numbers');" onMouseOut="nd();" onClick="showCenteredWindow('<<:runs_list_compiled js esc:>>', 'Run list');"><<:runs_cnt esc:>> runs
			<<:com_cpass0merging_start:>>
			    , <span style="color:green"><<:good_runs_cnt esc:>> OK</span>
			<<:com_cpass0merging_end:>>
			</span>
		    </td>

		    <<:com_qafinalmerging_start:>>
		    <td class=table_header></td>
		    <<:com_qafinalmerging_end:>>
		    
		    <<:com_cpass0merging_start:>>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:GRP_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:GRP_statuslong esc js:>>', 'GRP');"><<:GRP_counter:>></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:GRP_status_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:GRP_status_statuslong esc js:>>', 'GRP');"><<:GRP_status_counter:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:T0_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:T0_statuslong esc js:>>', 'T0');"><<:T0_counter:>></td>		    
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:T0_status_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:T0_status_statuslong esc js:>>', 'T0');"><<:T0_status_counter:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TOF_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TOF_statuslong esc js:>>', 'TOF');"><<:TOF_counter:>></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TOF_status_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TOF_status_statuslong esc js:>>', 'TOF');"><<:TOF_status_counter:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TPC_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TPC_statuslong esc js:>>', 'TPC');"><<:TPC_counter:>></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TPC_status_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TPC_status_statuslong esc js:>>', 'TPC');"><<:TPC_status_counter:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TRD_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TRD_statuslong esc js:>>', 'TRD');"><<:TRD_counter:>></td>
		    <td class="table_header" nowrap onMouseOver="overlibnz('<<:TRD_status_statusshort esc js:>>')" onMouseOut="nd()" onClick="showCenteredWindow('<<:TRD_status_statuslong esc js:>>', 'TRD');"><<:TRD_status_counter:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <<:com_cpass0merging_end:>>
		    <<:!com_cpass0merging_start:>>
		    <td class="table_header" nowrap><<:tinput_events ddot:>></td>
		    <td class="table_header" nowrap><<:ttrain_passed ddot:>></td>
		    <td class="table_header" nowrap><<:tpassed_percentage:>></td>
		    <td class="table_header" nowrap><<:ttrain_output ddot:>></td>
		    <<:!com_cpass0merging_end:>>
		    
		    <td class="table_header" nowrap></td>
		    <td class="table_header" nowrap></td>
		    <td class="table_header" nowrap></td>
		    <td class="table_header" nowrap bgcolor="completion_bgcolor"><<:jobs_completion:>></td>
		    <td class="table_header" nowrap><<:jobs_total:>></td>
		    <td class="table_header" nowrap><font color=green><<:jobs_done:>></font></td>
		    <td class="table_header" nowrap><font color=blue><<:jobs_running:>></font></td>
		    <td class="table_header" nowrap><font color=orange><<:jobs_waiting:>></font></td>
		    <td class="table_header" nowrap><span onClick="resubmit('<<:pids_list js esc:>>');"><font color=red><<:jobs_error:>></font></span></td>
		    <td class="table_header" nowrap><<:jobs_other:>></td>
		    <td class="table_header" nowrap><<:wall_time intervalh:>></td>
		    <td class="table_header" nowrap><<:saving_time intervalh:>></td>
		    <td class="table_header" nowrap><<:outputsize size:>></td>
		    <<:com_psqa_start:>>
			<td class="table_header" align=center nowrap><a href="javascript:void(0);" onClick="return psqa();"><img src="/img/line_chart.png" border=0></a></td>
		    <<:com_psqa_end:>>
		    <<:com_iostat_start:>>
			<td class="table_header" align=center nowrap><a href="javascript:void(0);" onClick="return iostat();"><img src="/img/line_chart.png" border=0></a></td>
		    <<:com_iostat_end:>>
		</tr>
		</tfoot>
	    </table>
	    </form>
	</td>
    </tr>
</table>
