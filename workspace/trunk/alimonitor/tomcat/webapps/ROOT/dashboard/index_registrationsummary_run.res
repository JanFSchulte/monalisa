<tr class="table_row">
    <td align=center nowrap class="table_row">
	<a target=_blank class="link" href="https://alice-logbook.cern.ch/logbook/date_online.php?p_cont=rund&p_run=<<:run db enc:>>"
	    onMouseOver="runDetails(<<:run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"><<:run db esc:>></a>
    </td>
    <td align=right nowrap class="table_row">
	<<:partition db esc:>>
    </td>
    <td align=right nowrap class="table_row">
	<a href="/DAQ/details.jsp?time=0&runfilter=<<:run db enc:>>" class="link"><<:chunks db esc:>></a>
    </td>
    <td align=center nowrap class="table_row" onMouseOver="overlib('First file registered: <<:mintime db nicedate:>> <<:mintime db time:>><BR>Last file registered: <<:maxtime db nicedate:>> <<:maxtime db time:>>', CAPTION, 'Run <<:run db js:>>');" onMouseOut="nd();">
	<<:maxtime db nicedate:>> <<:maxtime db time:>>
    </td>
    <td align=right nowrap class="table_row">
	<<:size db size:>>
    </td>
</tr>
