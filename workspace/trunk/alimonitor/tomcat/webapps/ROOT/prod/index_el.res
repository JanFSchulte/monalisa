<tr class="table_row text" bgcolor="<<:tr_bgcolor:>>">
    <td nowrap class="table_row" align=right><<:jt_id db esc:>>&nbsp;</td>
    <td nowrap class="table_row"><<:indent:>><a href="jobs.jsp?t=<<:jt_id db enc:>>" class="link" target="_blank"><<:jt_field1 db esc:>></a></td>
    <td class="table_row" sorttable_customkey="<<:status_code:>>" bgcolor="<<:bgcolor:>>" align="center" nowrap><<:jt_field2_new esc:>></td>
    <td class="table_row" bgcolor="<<:rate_bgcolor:>>" align="center" nowrap <<:extra_rate:>>><<:success_rate esc:>></td>
    <td class="table_row" align="center" nowrap>
	<<:com_files_start:>><a href="javascript:void(0);" onClick="openFiles('<<:field1 js:>>')" class=link><img border=0 src="/img/folderopen.gif"></a><<:com_files_end:>>
	<<:com_catalogue_start:>><a target=_blank href="http://alimonitor.cern.ch/catalogue/?path=<<:catalogue_path enc:>>"><img border=0 src="/img/folderopen.gif"></a><<:com_catalogue_end:>>
    </td>
    <td class="table_row" align="center" nowrap><<:com_download_start:>><a href="javascript:void(0);" onClick="openDownload('<<:field1 js:>>')" class=link><img border=0 src="/img/folderopen.gif"></a><<:com_download_end:>></td>
    <td class="table_row" align="center" nowrap><<:com_links_start:>><a href="javascript:void(0);" onClick="showIframeWindow('links.jsp?id=<<:jt_id db esc:>>', 'Documentation for <<:jt_field1 db esc js:>>')" class=link><img border=0 src="/img/folderopen.gif"></a><<:com_links_end:>></td>
    <td class="table_row" align="right" nowrap><<:total_jobs db esc:>></td>
    <td class="table_row" align="right" nowrap><<:done_jobs db esc:>></td>
    <td class="table_row" align="right" nowrap><<:running_jobs db esc:>></td>
    <td class="table_row" align="right" nowrap><<:waiting_jobs db esc:>></td>
    <td class="table_row" sorttable_customkey="<<:nr_runs db esc:>>" align="right" nowrap><<:com_run_start:>><<:nr_runs db esc:>> (<<:minrun db esc:>> - <<:maxrun db esc:>>)<<:com_run_end:>></td>
    <td class="table_row" align="right" nowrap><<:train_passed db ddot:>></td>
    <td class="table_row" align="right" nowrap><<:train_output db ddot:>></td>
    <td class="table_row"><<:jt_type_x esc:>></td>
    <td class="table_row"><<:com_comment_start:>><span onMouseOver="overlib('<<:comment db js esc:>>');" onMouseOut="nd();" onClick="showCenteredWindow('<<:comment db js esc:>>', 'Comment');"><<:comment db cut20 esc:>></span><<:com_comment_end:>></td>
    <td class="table_row" nowrap align=right><<:wall_time db intervalh:>></td>
    <td class="table_row" nowrap align=right><<:saving_time db intervalh:>></td>
    <td class="table_row" nowrap align=right><<:outputsize db size:>></td>
</tr>
