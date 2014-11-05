    <<:com_color_0_start:>>
    <tr class="table_row_right" bgcolor="#FFFFFF">
    <<:com_color_0_end:>>
    <<:com_color_1_start:>>
    <tr class="table_row_right" bgcolor="#F0F0F0">
    <<:com_color_1_end:>>
	<td nowrap align=right  class="table_row_right"><<:com_jdl_html_start:>><a class="link_header" style="text-decoration:none" href="#" onClick="window.open('/jdl/<<:pid db:>>.html', 'jdl', 'toolbar=0,width=800,height=600,scrollbars=1,resizable=1,titlebar=1'); return false;"><<:com_jdl_html_end:>><<:runno db:>><<:com_jdl_html_start:>></a><<:com_jdl_html_end:>></td>
	<td nowrap align=right class="table_row_right">
	    <a class="link_header" style="text-decoration:none" href="#" onClick="return openLive(<<:pid db:>>)" onMouseOver="jobDetails(<<:pid db:>>);" onMouseOut="nd();"><<:pid db:>></a>
	    <!--<a class="link_header" style="text-decoration:none" target=_blank href="job_stats.jsp?pid=<<:pid db enc:>>"><<:pid:>></a>-->
	</td>
	<td nowrap align=right class="table_row_right"><<:owner db:>></td>
	<td nowrap align=right class="table_row_right"><<:events db:>></td>
	<td nowrap align=right class="table_row_right"><<:tag_app_root db:>></td>
	<td nowrap align=right class="table_row_right"><<:tag_app_aliroot db:>></td>
	<td nowrap align=right class="table_row_right"><<:tag_app_geant db:>></td>
	<td nowrap align=right class="table_row_right"><<:firstseen:>></td>
	<td nowrap align=left class="table_row_right" bgcolor="<<:stagingstatus_bgcolor:>>">&nbsp;<<:staged:>></td>
	<td nowrap align=left class="table_row_right">&nbsp;<a target="_blank" href="/catalogue/index.jsp?path=<<:tag_outputdir db enc:>>" class="link_header" style="text-decoration:none"><<:tag_outputdir db:>></a></td>
	<td nowrap align=left class="table_row_right">&nbsp;<a onClick="nd(); showCenteredWindow('<<:jobtype js:>>', 'Comments for <<:pid js:>>'); return false;" onmouseover="overlib('<<:tag_jobtype js:>>', CAPTION, 'Click for a persistent text');" onmouseout='return nd();'><<:tag_jobtype cut30:>></a></td>
	<td nowrap align=left class="table_row_right">&nbsp;<a onClick="nd(); showCenteredWindow('<<:remark js:>>', 'Remarks for <<:pid js:>>'); return false;" onmouseover="overlib('<<:remark js:>>', CAPTION, 'Click for a persistent text');" onmouseout='return nd();'><<:remark esc cut20:>></td>
	<td nowrap align=center class="table_row" bgcolor="<<:stagingstatus_bgcolor_auth:>>" id="td_<<:runno db:>>">
	    <script language=javascript>
		var pid_<<:pid:>> = getEditForm('<<:runno js:>>', '<<:pid js:>>', '<<:owner js:>>', '<<:events js:>>', '<<:app_root js:>>', '<<:app_aliroot js:>>', '<<:app_geant js:>>', '<<:firstseen js:>>', '<<:outputdir js:>>', '<<:jobtype js:>>');
	    </script>
	    <<:com_authenticated_start:>>
		<a onClick="showCenteredWindow(pid_<<:pid:>>, 'Edit job <<:pid:>>');"><img src="/img/edit.gif" border=0 onMouseOver="overlib('Edit this entry');" onMouseOut="return nd();"></a>
		<a href="job_remarks.jsp?deljob=<<:pid:>>&returnpath=<<:return_path enc:>>" onClick="return confirm('Are you sure you want to delete pid <<:pid:>> ?');"><img src="/img/editdelete.gif" border=0 onMouseOver="overlib('Delete this entry');" onMouseOut="return nd();"></a>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="bulk_del" value="<<:pid:>>" onMouseOver="overlib('Mark pid <<:pid:>> for deletion')" onMouseOut="nd();">
		<input type="checkbox" class="input_submit" name="bulk_stage" value="<<:pid:>>" onMouseOver="overlib('Mark pid <<:pid:>> for staging/unstaging');" onMouseOut="nd();">
	    <<:com_authenticated_end:>>
	</td>
	
	<td class="table_row" nowrap align=right><<:wall_time db intervalh:>></td>
	<td class="table_row" nowrap align=right><<:saving_time db intervalh:>></td>
	<td class="table_row" nowrap align=right><<:outputsize db size:>></td>
    </tr>
