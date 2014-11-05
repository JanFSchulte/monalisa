<tr class=table_row_right>
    <td nowrap class="table_row" sorttable_customkey="<<:raw_run db esc:>>" align=right>
    <a target=_blank class="link_header" style="text-decoration:none"  href="/runview/?run=<<:raw_run db enc:>>" onMouseOver="runDetails(<<:raw_run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"><<:raw_run db esc:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:mintime db:>>" align=right><<:mintime db date:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:total_events db:>>" align=right><<:total_events db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:event_count_physics db:>>" align=right><<:event_count_physics db ddot:>></td>

    <td nowrap class="table_row" sorttable_customkey="<<:pass1_events:>>" align=right><a onClick="return openLive(<<:pass1_pid:>>)" onMouseOver="jobDetails(<<:pass1_pid:>>);" onMouseOut="nd();" class=link href="#"><<:pass1_events ddot:>></a></td>
    <td nowrap class="table_row" sorttable_customkey="<<:pass1_fraction:>>" align=right><a onClick="return openLive(<<:pass1_pid:>>)" onMouseOver="jobDetails(<<:pass1_pid:>>);" onMouseOut="nd();" class=link href="#"><<:pass1_fraction:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:cpass0_success:>>" align=right bgcolor="<<:cpass0_success_color:>>"><a onClick="return openLive(<<:cpass0_merging_pid:>>)" onMouseOver="jobDetails(<<:cpass0_merging_pid:>>);" onMouseOut="nd();" class=link href="#"><<:cpass0_success:>></a></td>
    <td nowrap class="table_row" sorttable_customkey="" align=center bgcolor="<<:cpass0_merging_color:>>"><a onClick="return openLive(<<:cpass0_merging_pid:>>)" onMouseOver="jobDetails(<<:cpass0_merging_pid:>>);" onMouseOut="nd();" class=link href="#"><<:cpass0_merging_success:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:pass1_success:>>" align=right bgcolor="<<:pass1_success_color:>>"><a onClick="return openLive(<<:pass1_pid:>>)" onMouseOver="jobDetails(<<:pass1_pid:>>);" onMouseOut="nd();" class=link href="#"><<:pass1_success:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:qa_events:>>" align=right><a onClick="return openLive(<<:qa_pid:>>)" onMouseOver="jobDetails(<<:qa_pid:>>);" onMouseOut="nd();" class=link href="#"><<:qa_events ddot:>></a></td>
    <td nowrap class="table_row" sorttable_customkey="<<:qa_fraction:>>" align=right><a onClick="return openLive(<<:qa_pid:>>)" onMouseOver="jobDetails(<<:qa_pid:>>);" onMouseOut="nd();" class=link href="#"><<:qa_fraction:>></a></td>
    <td nowrap class="table_row" sorttable_customkey="<<:qa_stage:>>" align=right bgcolor="<<:qa_color:>>"><a onClick="return openLive(<<:qa_pid:>>)" onMouseOver="jobDetails(<<:qa_pid:>>);" onMouseOut="nd();" class=link href="#"><<:qa_stage:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:app_aliroot esc:>>" align=right><<:app_aliroot esc:>></td>
    
    <td nowrap class="table_row" sorttable_customkey="" align=right></td>
</tr>
