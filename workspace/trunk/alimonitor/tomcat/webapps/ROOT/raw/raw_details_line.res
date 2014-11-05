<tr class="table_row" bgcolor="<<:tr_bgcolor:>>">
    <td nowrap class="table_row" align=right><a target=_blank class="link_header" style="text-decoration:none"  href="/runview/?run=<<:run db enc:>>"
	onMouseOver="runDetails(<<:run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"
    ><<:run db esc:>></a></td>
    <td nowrap class="table_row" align=right onClick="window.open('/DAQ/details.jsp?runfilter=<<:run db enc:>>&time=0');">
	<<:processed_chunks dot db esc:>> / <<:chunks db dot esc:>>
    </td>
    <td nowrap class="table_row" align=right bgcolor="<<:processed_color:>>" onClick="window.open('/DAQ/details.jsp?runfilter=<<:run db enc:>>&time=0');">
	<<:processed_chunks_percentage ddot1:>>%
    </td>
    <td nowrap class="table_row" align=right valign=bottom onMouseOver="overlib('<font color=blue>Raw data size: <<:size db size:>></font><br><font color=red>Pass 1 ESDs size: <<:size_pass1 db size:>></font><br><font color=green>Pass 2 ESDs size: <<:size_pass2 db size:>></font><br><font color=yellow>Pass 3 ESDs size: <<:size_pass3 db size:>></font>')" onMouseOut="nd()">
	<<:events dot:>><br>
	<table border=0 cellspacing=1 cellpadding=0 style="width:100px">
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
    <td nowrap class="table_row" align=right><a class="link_header" style="text-decoration:none" href="#" onClick="return openLive(<<:pid db:>>)" onMouseOver="jobDetails(<<:pid db:>>);" onMouseOut="nd();"><<:pid db:>></a></td>
    <td nowrap class="table_row" align=right><<:errorv:>></td>
    <<:com_admin_start:>>
    <td nowrap class="table_row" align=center>
	<input type=checkbox class=input_checkbox name=r value="<<:run db esc:>>_<<:pass db esc:>>" onMouseOver="overlib('Resubmit run <<:run db js:>>, pass <<:pass db js:>>');" onMouseOut="nd()">
    </td>
    <td nowrap class="table_row" align=center>
	<<:prev_hide:>>
	<input type=checkbox class=input_checkbox name=h <<:hide db check:>> value="<<:run db esc:>>" onMouseOver="overlib('Ignore run <<:run db js:>>');" onMouseOut="nd()">
    </td>
    <td nowrap class="table_row" align=center>
	<<:prev_hide_pid:>>
	<input type=checkbox class=input_checkbox name=hp <<:hidden db check:>> value="<<:pid db esc:>>" onMouseOver="overlib('Ignore pid <<:pid db js:>>');" onMouseOut="nd()">
    </td>
    <<:com_admin_end:>>
    <td nowrap class="table_row" align=right></td>
    <td nowrap class="table_row" align=right><<:app_root db esc:>></td>
    <td nowrap class="table_row" align=right><<:app_aliroot db esc:>></td>
    <td nowrap class="table_row" align=right><<:partition db esc:>></td>
    <td nowrap class="table_row" align=right><<:pass db esc:>></td>
    <td nowrap class="table_row" align=left>
	<a target=_blank href="/catalogue/index.jsp?path=<<:outputdir enc:>>" class="link_header" style="text-decoration:none" ><<:outputdir:>></a>
    </td>
    <<:comment_place:>>
    <td class="table_row" align=right nowrap><<:wall_time db intervalh:>></td>
    <td class="table_row" align=right nowrap><<:saving_time db intervalh:>></td>
    <td class="table_row" align=right nowrap><<:outputsize db size:>></td>
</tr>
