<table border=0 cellspacing=10 cellpadding=0 width=620 style="font-family:Verdana,Helvetica,Arial;font-size:10px">
    <tr>
	<th colspan=2>Unfinished jobs</th>
	<th colspan=2>Running time (last 24h)</th>
	<th colspan=2>CPU cost (last 24h)</th>
    </tr>
    <tr>
	<td colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=10>
		    <td width="<<:unfinished_jobs_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_unfinished_jobs_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>

	<td colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=10>
		    <td width="<<:total_running_time_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_total_running_time_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
	
	<td colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=10>
		    <td width="<<:total_cpu_cost_ratio_int:>>%" bgcolor=red></td>
		    <td width="<<:complement_total_cpu_cost_ratio_int:>>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=left>
	    Current:<br>
	    Quota:
	</td>
	<td align=left>
	    <<:unfinished_jobs dot:>><br>
	    <<:unfinished_jobs_quota dot:>>
	</td>
	<td align=left>
	    Current:<br>
	    Quota:
	</td>
	<td align=left>
	     <<:total_running_time intervals:>><br>
	     <<:total_running_time_quota intervals:>>
	</td>
	<td align=left>
	    Current:<br>
	    Quota:
	</td>
	<td align=left>
	     <<:total_cpu_cost intervals:>><br>
	     <<:total_cpu_cost_quota intervals:>>
	</td>
    </tr>
</table>
