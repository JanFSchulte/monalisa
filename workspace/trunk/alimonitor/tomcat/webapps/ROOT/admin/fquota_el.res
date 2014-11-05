<tr class="table_row">
    <td nowrap class="table_row" align=left><<:account esc:>></td>
    
    	<td sorttable_customkey="<<:complement_files_count_ratio_int:>>" class=table_row onMouseOver="overlib('Current: <<:files_count dot:>><br>Quota: <<:files_count_quota dot:>>', CAPTION, 'Number of files of <<:account esc js:>>');" onMouseOut="nd()">
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=5>
		    <td width="<<:files_count_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_files_count_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
	<td class=table_row align=right sorttable_customkey="<<:files_count:>>">
	    <<:files_count dot:>> of
	</td>
	<td class=table_row align=right sorttable_customkey="<<:files_count_quota:>>">
	    <<:files_count_quota dot:>>
	</td>

	<td sorttable_customkey="<<:complement_total_size_ratio_int:>>"class="table_row" onMouseOver="overlib('Current: <<:total_size size:>><br>Quota: <<:total_size_quota size:>>', CAPTION, 'Total size of <<:account esc js:>>');" onMouseOut="nd()">
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=5>
		    <td width="<<:total_size_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_total_size_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
	<td class=table_row align=right sorttable_customkey="<<:total_size:>>">
	    <<:total_size size:>> of
	</td>
	<td class=table_row align=right sorttable_customkey="<<:total_size_quota:>>">
	    <<:total_size_quota size:>>
	</td>
</tr>
