<tr class="table_row" height=27 >
    <td align=right class="table_row">
	<<:com_job_start:>><a href="/raw/raw_details.jsp?filter_runno=<<:run db enc:>>&filter_lpm=0"><u><<:com_job_end:>><span onMouseOver="runDetails(<<:run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"><<:run db esc:>></span><<:com_job_start:>></u></a><<:com_job_end:>>
    </td>
    <td align=right class="table_row"><<:partition db esc:>></td>
    <td align=right class="table_row"><a href="details.jsp?runfilter=<<:run db enc:>>&time=0"><<:chunks db:>></a></td>
    <td align=right class="table_row"><<:size db size:>></td>
    <td align=right class="table_row"><<:mintime db nicedate:>> <<:mintime db time:>></td>
    <td align=right class="table_row"><<:maxtime db nicedate:>> <<:maxtime db time:>></td>
    <td align=right class="table_row" bgcolor="<<:transferstatus_bgcolor:>>"><a class=link href="/transfers/?id=<<:transfer_id db enc:>>"><<:targetse db esc:>></a></td>
    <td align=right class="table_row" bgcolor="<<:processingstatus_bgcolor:>>">
	<<:com_processing_flag_start:>>
	<<:com_errorv_start:>>
	    <a href="details.jsp?runfilter=<<:run db enc:>>&time=0"><img src="/img/trend_alert.png" border=0 onMouseOver="overlib('<<:errorv_count db:>> subjobs have failed with ERROR_V');" onMouseOut="nd();"></a>&nbsp;
	<<:com_errorv_end:>>
	<span onMouseOver="overlib('<<:esds_path js:>>');" onClick="showCenteredWindow('<<:esds_path js:>>', 'ESDs path');" onMouseOut='nd();'>
	    <<:processed_chunks db esc:>> / <<:chunks db esc:>> (<<:processing_percent db esc:>>%)
	</span>
	<<:com_processing_flag_end:>>
    </td>
    <!--
    <td align=center class="table_row" bgcolor="<<:stagingstatus_bgcolor:>>" id="td_<<:counter:>>">&nbsp;
	<<:com_order_start:>><input id="button_<<:counter:>>" type=button class="input_submit" onClick="order(<<:run db:>>, <<:counter:>>);" value="Stage"><<:com_order_end:>>
	<<:com_remove_start:>><input id="remove_<<:counter:>>" type=button class="input_submit" onClick="deleteRun(<<:run db:>>, <<:counter:>>);" value="Dismiss"><<:com_remove_end:>>
    </td>
    -->
    <td align=right class="table_row">
	<<:com_processing_flag_auth_start:>>
	    <input type=hidden name=pfo value=<<:run db esc:>>>
	<<:com_processing_flag_auth_end:>>
    </td>
</tr>
