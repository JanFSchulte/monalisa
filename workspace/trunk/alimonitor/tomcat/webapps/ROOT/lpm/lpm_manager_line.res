<tr bgcolor="<<:bgcolor:>>" class="table_row">
    <td align=right class=table_row nowrap><a name="<<:id esc:>>" id="id_<<:id esc:>>"><<:id esc:>>.</a></a>
    <td style="padding-left:<<:padding:>>px" colspan=2 align=left class="table_row" nowrap>
	<<:extra_start:>>
	    <<:com_edit_start:>><a class=link href="/users/download.jsp?path=<<:jdl_long enc:>>&view=1" target=_blank><<:com_edit_end:>><<:jdl:>><<:com_edit_start:>></a><<:com_edit_end:>> <<:com_edit_start:>> (<a target=_blank class=link href="/users/edit.jsp?path=<<:jdl_long enc:>>">edit</a>)<<:com_edit_end:>>&nbsp;&nbsp;&nbsp;&nbsp;<span onMouseOver="overlib('<<:parameters esc js:>>');" onClick="overlib('<<:parameters esc js:>>', STICKY);" onMouseOut="nd()"><<:parameters_cut:>></span><<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:parent_completion_min:>><<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:constraints:>><<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:completion:>> %<<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:alienuser:>><<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:weight:>><<:extra_end:>></td>
    <td align=left class="table_row" nowrap>&nbsp;<<:extra_start:>><<:lastrun:>><<:submitdate:>><<:extra_end:>></td>
    <td align=left class="table_row" nowrap>&nbsp;<<:extra_start:>><<:maxrun:>><<:extra_end:>></td>
    <td align=right class="table_row" nowrap>&nbsp;<<:extra_start:>><<:submitcount:>><<:extra_end:>></td>
    <td align=left class="table_row" nowrap><a class="link" href="/lpm/lpm_manager.jsp?add=<<:id:>>&account=<<:account enc:>>#edit">Add dependency</a> | <a class="link" href="/lpm/lpm_manager.jsp?edit=<<:id:>>&account=<<:account enc:>>#edit">Edit</a> | <a class="link" href="/lpm/lpm_manager.jsp?delete=<<:id:>>&account=<<:account enc:>>" onClick="return confirm('Are you sure you want to delete this entry?');">Delete</a> | <a class="link" href="/lpm/lpm_manager.jsp?enable=<<:id:>>&account=<<:account enc:>>"><<:enabletext:>></a></td>
    <td align=left class="table_row" nowrap><a class="link" href="javascript:void(0)" onClick="return manualSubmit(<<:id:>>);">Execute</a></td>
</tr>
