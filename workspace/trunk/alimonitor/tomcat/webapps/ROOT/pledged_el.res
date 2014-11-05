<tr bgcolor="<<:color esc:>>" class="table_row">
    <td align=right class="table_row"><<:i esc:>>.</td>
    <td align=left class="table_row"><b><<:name esc:>></b></td>
    <!--
    <td align=right class="table_row"><<:version esc:>></td>
    <td align=center class="table_row"><%= Cache.getLastValue(pred)!=null ? "<font color=green><b>ON</b></font>" : "<font color=red><b>OFF</b></font>"%></td>
    <td align=center class="table_row"><input type=text size=4 maxlength=6 name="cpus_<%= db.gets("name")%>" value="<%= db.geti("cpus")%>" class="input_text"></td>
    <td align=center  class="table_row"><input type=text size=4 maxlength=6 name="ksi2k_<<:name esc:>>" value="<<:ksi2k esc:>>" class="input_text"></td>
    -->
    <td align=center  class="table_row">
	<<:com_input_start:>>
	<input type=checkbox name=group_members value="<<:name esc:>>" class="input_submit" <<:group_checked esc:>>>
	<<:com_input_end:>>
	<<:com_link_start:>>
	    <a href="<<:jsp enc:>>?edit_group=<<:group enc:>>" title="Edit group"><<:group esc:>></a>
	<<:com_link_end:>>
    </td>
    <!--
    <td align=center class="table_row"><input type=submit name=submit value=Update class="input_submit"></td>
    -->
</tr>
