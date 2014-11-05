<tr bgcolor="<<:bgcolor:>>">
    <form name="lpm_edit" action="/lpm/lpm_manager.jsp" method=POST>
    <input type="hidden" name="account" value="<<:account esc:>>">
    <input type="hidden" name="id" value="<<:id esc:>>">
    <input type="hidden" name="parentid" value="<<:parentid esc:>>">
    <td nowrap class=text align=right><a name="<<:id esc:>>"></a><<:id esc:>>.</td>
    <td nowrap style="padding-left:<<:padding:>>px"><a name="edit"></a><input class="input_text" type="text" name="jdl" value="<<:jdl esc:>>" size="30"></td>
    <td nowrap align=right><input class="input_text" type="text" name="parameters" value="<<:parameters esc:>>" size="30"></td>
    <td nowrap align=right>
	<<:com_sublevel_start:>>
	<input class="input_text" type="text" name="parent_completion_min" value="<<:parent_completion_min esc:>>" size="3">
	<<:com_sublevel_end:>>
    </td>
    <td nowrap align=right>
	<input class="input_text" type="text" name="constraints" value="<<:constraints esc:>>" size="20">
    </td>
    <td nowrap align=right><input class="input_text" type="text" name="completion" value="<<:completion esc:>>" size="3"></td>
    <td nowrap align=right><input class="input_text" type="text" name="alienuser" value="<<:alienuser esc:>>" size="8"></td>
    <td nowrap align=right>
	<<:com_level0_start:>><input class="input_text" type="text" name="weight" value="<<:weight esc:>>" size="3"><<:com_level0_end:>>
	<<:com_sublevel_start:>><input type=hidden name=weight value="<<:weight esc:>>"><<:com_sublevel_end:>>
    </td>
    <td nowrap align=right>
	<<:com_level0_start:>><input class="input_text" type="text" name="lastrun" value="<<:lastrun esc:>>" size="6"><<:com_level0_end:>>
	<<:com_sublevel_start:>><input type=hidden name=lastrun value="<<:lastrun esc:>>"><<:com_sublevel_end:>>
    </td>
    <td nowrap align=right>
	<<:com_level0_start:>><input class="input_text" type="text" name="maxrun" value="<<:maxrun esc:>>" size="6"><<:com_level0_end:>>
	<<:com_sublevel_start:>><input type=hidden name=maxrun value="<<:maxrun esc:>>"><<:com_sublevel_end:>>
    </td>
    <td nowrap align=right>
	<input class="input_text" type="text" name="submitcount" value="<<:submitcount esc:>>" size="5">
    </td>
    <td nowrap align=right colspan=2><input class="input_submit" type="submit" name="submit" value="Save"> <input class="input_submit" type="button" value="Cancel" onClick="window.location='/lpm/lpm_manager.jsp?account=<<:account enc:>>';"></td>
    </form>
</tr>
