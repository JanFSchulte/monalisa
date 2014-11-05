<tr class="table_row" bgcolor="<<:tr_bgcolor:>>">
    <td nowrap class="table_row" align=left>
	&nbsp;&nbsp;
	
	<a class=link target=_blank href="/runview/?run=<<:run db enc:>>" onMouseOver="jobDetails(<<:pid db:>>)" onMouseOut="nd()" onClick="nd(); return true;"><<:run db esc:>></a>
	
	(<<:chunks db ddot:>>)
    </td>
    <td nowrap class="table_row" align=right><<:partition db esc:>></td>
    <td nowrap class="table_row" align=center><<:pass db esc:>></td>
    <td nowrap class="table_row" align=right onMouseOver="overlib('<<:requested_by db js:>>', CAPTION, 'Requested by')" onMouseOut="nd()"><<:requested_on db date:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:status_color:>>"><<:com_link_start:>><a class=link target=_blank href="raw_details.jsp?filter_lpm=1&filter_runno=<<:run db enc:>>&filter_outputdir=%2Fpass<<:pass db enc:>>%2F"><<:com_link_end:>><<:status_text:>><<:com_link_start:>></a><<:com_link_end:>></td>
    <td nowrap class="table_row" align=left>
	<<:com_auth_start:>>
        <input type=button class=input_submit onClick="delete_run(<<:run db js:>>, <<:pass db js:>>)" value="Delete">
        <<:com_link_start:>><input type=button class=input_submit onClick="reprocess(<<:run db js:>>, <<:pass db js:>>)" value="Reprocess"><<:com_link_end:>>
        <<:com_auth_end:>>
    </td>
</tr>
