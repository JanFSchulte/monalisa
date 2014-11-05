    <tr bgcolor="<<:color:>>" class="table_row_right">
	<td nowrap align=left  class="table_row" sorttable_customkey="<<:path db esc:>>"><a target=_blank class=link href="/catalogue/?path=<<:path db enc:>>"><<:path db esc:>></td>
	<td nowrap align=right class="table_row" sorttable_customkey="<<:filesize db:>>"><<:filesize db size:>></td>
	<td nowrap align=right  class="table_row"><<:link_start:>><<:alienid db esc:>><<:link_end:>></td>
	<td nowrap align=right  class="table_row" bgcolor="<<:statuscolor:>>"><<:statustext:>></td>
	<td nowrap align=right  class="table_row"><<:triesleft db esc:>></td>
	<td nowrap align=right  class="table_row"><span onMouseOver="overlib('<<:failreason db esc js:>>');" onClick="showCenteredWindow('<<:link_start esc js:>><<:failreason db esc js:>><<:link_end esc js:>>', '<<:alienid db esc js:>>')" onMouseOut='nd()'><<:failreason db esc cut30:>></span><<:link_end:>></td>
    </tr>
