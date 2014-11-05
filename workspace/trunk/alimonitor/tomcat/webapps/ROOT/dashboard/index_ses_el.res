<tr class="table_row">
    <td align=left nowrap class="table_row">
	<<:se_name esc:>>
    </td>
    <td align=center nowrap class="table_row">
	<span onMouseOver="overlib('<<:testtime nicedate:>> <<:testtime time:>>')" onMouseOut="nd()">
	<<:com_ok_start:>>
	<font color=green><b>OK</b></font>
	<<:com_ok_end:>>
	<<:!com_ok_start:>>
	<span onClick="showCenteredWindow('<<:message js esc:>>', '<<:se_name js esc:>>')"><font color=red><b>FAIL</b></font></span>
	<<:!com_ok_end:>>
	</span>
    </td>
</tr>
