<tr class="table_row" bgcolor="<<:tr_bgcolor:>>">
    <td nowrap class="table_row" align=right><a target=_blank href="/runview/?run=<<:run db enc:>>" onMouseOver="jobDetails(<<:pid db:>>)" onMouseOut="nd()" onClick="nd(); return true;"><<:run db esc:>></a></td>
    <td nowrap class="table_row" align=right><<:errorv:>></td>
    <td nowrap class="table_row" align=right><<:chunks db dot esc:>></td>
    <td nowrap class="table_row" align=right><<:processed_chunks dot db esc:>></td>
    <td nowrap class="table_row" align=right bgcolor="<<:processed_color:>>"><<:processed_chunks_percentage ddot1:>>%</td>
    <td nowrap class="table_row" align=right><a class="link_header" style="text-decoration:none" href="raw_errors.jsp?runfilter=<<:run db enc:>>&onlyerr=0&return=<<:returnurl enc:>>"><<:events_nice dot esc:>></td>
    <<:com_admin_start:>>
    <td nowrap class="table_row" align=center>
	<input type=checkbox class=input_checkbox name=r value="<<:run db esc:>>" onMouseOver="overlib('Resubmit run <<:run db js:>>');" onMouseOut="nd()">
    </td>
    <td nowrap class="table_row" align=center>
	<<:prev_hide:>>
	<input type=checkbox class=input_checkbox name=h <<:hide db check:>> value="<<:run db esc:>>" onMouseOver="overlib('Ignore run <<:run db js:>>');" onMouseOut="nd()">
    </td>
    <<:com_admin_end:>>
    <td nowrap class="table_row" align=right><a class="link_header" style="text-decoration:none" href="#" onClick="return openJDL(<<:pid db:>>)" onMouseOver="overlib('Show JDL of job# <<:pid db:>>');" onMouseOut="nd();"><<:firstseen2:>></a></td>
    <td nowrap class="table_row" align=right><<:partition db esc:>></td>
    <td nowrap class="table_row" align=right><<:app_root db esc:>></td>
    <td nowrap class="table_row" align=right><<:app_aliroot db esc:>></td>
    <td nowrap class="table_row" align=left>
	<a target=_blank href="/DAQ/details.jsp?runfilter=<<:run db enc:>>&time=0" class="link_header" style="text-decoration:none"><<:outputdir:>></a>
    </td>
    <td nowrap class="table_row" align=left><<:jobtype:>></td>
    <td nowrap class="table_row"></td>
</tr>
