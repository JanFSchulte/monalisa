    <tr bgcolor="<<:color:>>" class="table_row_right">
	<td nowrap align=right  class="table_row_right"><<:run db esc:>>&nbsp;</td>
	<td nowrap align=left  class="table_row_right"><<:partition esc:>></td>
	<td nowrap align=right  class="table_row_right">
	    <<:chunks db esc:>><br>
	    <table border=0 cellspacing=0 cellpadding=0 style="width:<<:chunkspercentage:>>px">
		<tr style="height:2px">
		    <td bgcolor=blue></td>
		</tr>
	    </table>
	</td>
	<td nowrap align=right  class="table_row_right">
	    <<:size db size:>><br>
	    <table border=0 cellspacing=0 cellpadding=0 style="width:<<:sizepercentage:>>px">
		<tr style="height:2px">
		    <td bgcolor=blue></td>
		</tr>
	    </table>
	</td>
	<td nowrap align=center class="table_row_right" bgcolor="<<:daq_status_color:>>"><<:daq_status:>></td>
	<td nowrap align=center class="table_row_right" bgcolor="<<:shuttle_status_color:>>"><<:shuttle_status:>></td>
	<td nowrap align=center class="table_row_right">
	    <<:com_keep_start:>>
		<input type=checkbox class=input_checkbox name=a value="<<:run db esc:>>">
	    <<:com_keep_end:>>
	    <<:com_notkeep_start:>>
		<table cellspacing=0 cellpadding=0 style="width:100px" onMouseOver="overlib('<<:transfer_tooltip js:>>', CAPTION, '<<:transfer_tooltip_caption js:>>');" onMouseOut="nd()">
		    <tr style="height:20px">
			<td style="width:<<:size_done:>>px" bgcolor=#00FF00></td>
			<td style="width:<<:size_running:>>px" bgcolor=#FFFF00></td>
			<td style="width:<<:size_error:>>px" bgcolor=#FF0000></td>
			<td style="width:<<:size_pending:>>px" bgcolor=#DDDDDD></td>
		    </tr>
		</table>
	    <<:com_notkeep_end:>>
	</td>
	<td nowrap align=center class="table_row_right">
	    <<:com_t1_start:>>
		<input type=checkbox class=input_checkbox name=t value="<<:run db esc:>>">
	    <<:com_t1_end:>>
	    <<:com_nott1_start:>>
		<table cellspacing=0 cellpadding=0 style="width:100px" onMouseOver="overlib('<<:t1transfer_tooltip js:>>', CAPTION, '<<:t1transfer_tooltip_caption js:>>');" onMouseOut="nd()">
		    <tr style="height:20px">
			<td style="width:<<:t1size_done:>>px" bgcolor=#00FF00></td>
			<td style="width:<<:t1size_running:>>px" bgcolor=#FFFF00></td>
			<td style="width:<<:t1size_error:>>px" bgcolor=#FF0000></td>
			<td style="width:<<:t1size_pending:>>px" bgcolor=#DDDDDD></td>
		    </tr>
		</table>
	    <<:com_nott1_end:>>
	</td>
	
	<td nowrap align=center class="table_row_right">
	    <<:com_delete_start:>>
		<input type=checkbox class=input_checkbox name=d value="<<:run db esc:>>">
	    <<:com_delete_end:>>
	</td>
    </tr>
