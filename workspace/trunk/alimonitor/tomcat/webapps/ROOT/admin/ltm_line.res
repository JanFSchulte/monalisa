<tr bgcolor="<<:bgcolor:>>" class="table_row">
    <td align=left class="table_row"><<:strike_start:>><<:sename db esc:>><<:strike_end:>></td>
    <td align=right class="table_row"><<:strike_start:>><<:runcount db dot:>><<:strike_end:>></td>
    <td align=right class="table_row"><<:strike_start:>><<:files db dot:>><<:strike_end:>></td>
    <td align=right class="table_row"><<:strike_start:>><<:totalsize db size:>><<:strike_end:>></td>
    <td align=right class="table_row"><<:strike_start:>><<:ratio db dot:>><<:strike_end:>></td>
    <td align=left class="table_row">
	<a class=link href="ltm.jsp?edit=<<:sename db esc:>>">Edit</a>
	|
	<<:com_active_start:>>
	    <a class=link href="ltm.jsp?disable=<<:sename db enc:>>">Disable</a>
	<<:com_active_end:>>
	<<:com_notactive_start:>>
	    <a class=link href="ltm.jsp?enable=<<:sename db esc:>>">Enable</a>
	<<:com_notactive_end:>>
    </td>
</tr>
