<tr class="table_row text" bgcolor="<<:tr_bgcolor:>>">
    <td nowrap class="table_row" align=right><a class="link_header" style="text-decoration:none" href="#" onClick="return openLive(<<:pid db:>>)" onMouseOver="jobDetails(<<:pid db:>>);" onMouseOut="nd();"><<:pid db esc:>></a></td>
    <td nowrap class="table_row" align=right>
	<<:com_rawdata_start:>>
	    <a target=_blank class="link_header" style="text-decoration:none"  
		href="/runview/?run=<<:runno db enc:>>"
		onMouseOver="runDetails(<<:runno db js:>>);" onMouseOut="nd()" onClick="nd(); return true"><<:runno db esc:>></a>
	<<:com_rawdata_end:>>
	<<:!com_rawdata_start:>>
	    <<:runno db esc:>>
	<<:!com_rawdata_end:>>
    </td>

    <<:com_qafinalmerging_start:>>
    <td nowrap class="table_row" align=right><<:lhcbeammode db esc:>></td>
    <<:com_qafinalmerging_end:>>

    <<:com_cpass0merging_start:>>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_GRP_color:>>"><<:cpass0_GRP:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_MeanVertex_status_color:>>"><<:cpass0_MeanVertex_status:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_MeanVertexevents_statistic:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_MeanVertextracks_statistic:>></td>
    
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_T0_color:>>"><<:cpass0_T0:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_T0_status_color:>>"><<:cpass0_T0_status:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_T0events_statistic:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_T0tracks_statistic:>></td>
    
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TOF_color:>>"><<:cpass0_TOF:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TOF_status_color:>>"><<:cpass0_TOF_status:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TOFevents_statistic:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TOFtracks_statistic:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TPC_color:>>"><<:cpass0_TPC:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TPC_status_color:>>"><<:cpass0_TPC_status:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TPCevents_statistic:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TPCtracks_statistic:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TRD_color:>>"><<:cpass0_TRD:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:cpass0_TRD_status_color:>>"><<:cpass0_TRD_status:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TRDevents_statistic:>></td>
    <td nowrap class="table_row" align=right><<:cpass0_TRDtracks_statistic:>></td>
    <<:com_cpass0merging_end:>>   
    <<:!com_cpass0merging_start:>>
    <td nowrap class="table_row" align=right><<:input_events db ddot:>></td>
    <td nowrap class="table_row" align=right><<:train_passed db ddot:>></td>
    <td nowrap class="table_row" align=right><<:passed_percentage:>></td>
    <td nowrap class="table_row" align=right><<:train_output db ddot:>></td>    
    <<:!com_cpass0merging_end:>>
    
    <td nowrap class="table_row" align=right><<:app_root db esc:>></td>
    <td nowrap class="table_row" align=right><<:app_aliroot db esc:>></td>
    <td nowrap class="table_row" align=left nowrap><a target=_blank href="/catalogue/index.jsp?path=<<:outputdir db enc:>>" class="link_header" style="text-decoration:none" ><<:outputdir db esc:>></a></td>
    <td nowrap class="table_row" bgcolor="<<:completion_bgcolor:>>" align=right><<:jobs_completion:>></td>
    <td nowrap class="table_row" align=right><<:jobs_total:>></td>
    <td nowrap class="table_row" align=right><font color=green><<:jobs_done:>></font></td>
    <td nowrap class="table_row" align=right><font color=blue><<:jobs_running:>></font></td>
    <td nowrap class="table_row" align=right><font color=orange><<:jobs_waiting:>></font></td>
    <td nowrap class="table_row" align=right><font color=red><<:jobs_error:>></font></td>
    <td nowrap class="table_row" align=right><<:jobs_other:>></td>
    <td nowrap class="table_row" align=right nowrap><<:wall_time db intervalh:>></td>
    <td nowrap class="table_row" align=right nowrap><<:saving_time db intervalh:>></td>
    <td nowrap class="table_row" align=right nowrap><<:outputsize db size:>></td>
    <<:com_psqa_start:>>
	<td nowrap class="table_row" align=center nowrap><a href="javascript:void(0);" onClick="return psqa();"><img src="/img/line_chart.png" border=0></a></td>
    <<:com_psqa_end:>>
    <<:com_iostat_start:>>
	<td nowrap class="table_row" align=center nowrap><a target=_blank href="/jobs/iostat.jsp?pid=<<:pid db enc:>>"><img src="/img/line_chart.png" border=0></a></td>
    <<:com_psqa_end:>>
</tr>
