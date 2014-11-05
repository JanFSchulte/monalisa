<tr bgcolor="<<:bgcolor:>>" class="table_row">
    <td align=right class="table_row" nowrap><<:p_id db:>></td>
    <td align=right class="table_row" nowrap><<:p_tag db esc:>></td>
    <td align=center class="table_row" nowrap bgcolor="<<:statusbgcolor:>>"><<:jt_field2 db esc:>></td>
    <td align=left class="table_row" nowrap><a href="javascript:void(0);" onClick="return showUsers('<<:p_id db js:>>');" class="link"><<:pg_name db esc:>></a></td>
    <td align=right class="table_row" nowrap><<:type db esc:>></td>
    <td align=right class="table_row" nowrap><<:energy esc:>>eV</td>
    <td align=center class="table_row" nowrap><<:com_savannah_start:>><a class=link href="javascript:void(0);" onClick="return showCenteredWindow('<<:p_savannah js esc:>>', 'Savannah links');">View</a><<:com_savannah_end:>></td>
    <td align=right class="table_row" nowrap><<:p_reqev db dot:>></td>
    <td align=right class="table_row" nowrap><<:p_prodev db dot:>></td>
    <td align=right class="table_row" nowrap><<:p_reqdate db date:>></td>
    <td align=right class="table_row" nowrap><<:p_expdate db date:>></td>
    <td align=center class="table_row" nowrap><<:com_checkesd_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/CheckESD.C');" class="link">View</a><<:com_checkesd_end:>></td>
    <td align=center class="table_row" nowrap><<:com_config_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/Config.C');" class="link">View</a><<:com_config_end:>></td>
    <td align=center class="table_row" nowrap><<:com_rec_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/rec.C');" class="link">View</a><<:com_rec_end:>></td>
    <td align=center class="table_row" nowrap><<:com_sim_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/sim.C');" class="link">View</a><<:com_sim_end:>></td>
    <td align=center class="table_row" nowrap><<:com_simrun_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/simrun.C');" class="link">View</a><<:com_simrun_end:>></td>
    <td align=center class="table_row" nowrap><<:com_tag_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/tag.C');" class="link">View</a><<:com_tag_end:>></td>
    <td align=center class="table_row" nowrap><<:com_jdl_start:>><a href="javascript:void(0);" onClick="return showFile('<<:p_id db:>>/JDL');" class="link">View</a><<:com_jdl_end:>></td>
    <td align=center class="table_row" nowrap><a href="javascript:void(0);" onClick="return editPrio(<<:p_id db:>>, <<:p_prio db:>>);" class="link"><<:p_prio:>></a></td>
    <td align=center class="table_row" nowrap><a href="javascript:void(0);" onClick="return showComments(<<:p_id db:>>);" class="link">View (<<:comments db esc:>>)</a></td>
    <td align=left class="table_row" nowrap>
	<a href="work/edit.jsp?id=<<:p_id db enc:>>" class="link">Edit</a> 
	| 
	<a href="javascript:void(0);" onClick="return delID(<<:p_id db:>>);" class="link">Del</a>
	<<:com_publish_start:>>| <a href="javascript:void(0);" onClick="return publishInAliEn(<<:p_id db:>>);" class="link">Publish</a><<:com_publish_end:>>
    </td>
</tr>
