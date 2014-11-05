<tr class="table_row" bgcolor="<<:tr_bgcolor:>>">
    <td class="table_row"><<:jt_field1 db:>></td>    
    <td class="table_row" align="left"><a href="raw_details.jsp?timesel=0&filter_jobtype=<<:jt_type db enc:>>" class="link" target="_blank"><<:jt_description db esc:>></a></td>
    <td class="table_row" bgcolor="<<:bgcolor:>>" align="center"><<:jt_field2 db esc:>></td>
    <td class="table_row" align="center" nowrap><<:run_min db:>> - <<:run_max db:>></td>    
    <td class="table_row" align="right"><<:jobs_count db ddot:>></td>
    <td class="table_row" align="right"><<:chunks_sum db ddot:>></td>
    <td class="table_row" align="right"><<:raw_size db size:>></td>
    <td class="table_row" align="right"><<:processed_chunks_sum db ddot:>></td>
    <td class="table_row" align="right" bgcolor="<<:chunks_percentage_color:>>"><<:chunks_percentage:>></td>
    <td class="table_row" align="right"><<:esds_size db size:>></td>
    <td class="table_row" align="right" bgcolor="<<:size_percentage_color:>>"><<:size_percentage:>></td>
    <td class="table_row" align="right"><<:events_sum db ddot:>></td>
    <td class="table_row" nowrap align=right><<:wall_time db intervalh:>></td>
    <td class="table_row" nowrap align=right><<:saving_time db intervalh:>></td>
</tr>
