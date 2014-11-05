<tr class="table_row">
    <td nowrap class="table_row" align=left><<:account esc:>></td>
    
    	<td sorttable_customkey="<<:complement_unfinished_jobs_ratio_int:>>" class=table_row onMouseOver="overlib('Current: <<:unfinished_jobs dot:>><br>Quota: <<:unfinished_jobs_quota dot:>>', CAPTION, 'Unfinished Jobs of <<:account esc js:>>');" onMouseOut="nd()">
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=5>
		    <td width="<<:unfinished_jobs_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_unfinished_jobs_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>

	<td sorttable_customkey="<<:complement_total_running_time_ratio_int:>>" class="table_row" onMouseOver="overlib('Current: <<:total_running_time intervals:>><br>Quota: <<:total_running_time_quota intervals:>>', CAPTION, 'Total Running Time of <<:account esc js:>>');" onMouseOut="nd()">
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=5>
		    <td width="<<:total_running_time_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_total_running_time_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
	
	<td sorttable_customkey="<<:complement_total_cpu_cost_ratio_int:>>" class="table_row" onMouseOver="overlib('Current: <<:total_cpu_cost intervals:>><br>Quota: <<:total_cpu_cost_quota intervals:>>', CAPTION, 'Total CPU Cost of <<:account esc js:>>');" onMouseOut="nd()">
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=5>
		    <td width="<<:total_cpu_cost_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_total_cpu_cost_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>

</tr>
