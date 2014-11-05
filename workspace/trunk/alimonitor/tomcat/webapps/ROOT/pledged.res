    <form name="pledged_cpus_form" action="<<:jsp enc:>>" method=POST>
	<table cellspacing=0 cellpadding=2 class="table_content">
	    <tr height=25>
		<td bgcolor="#FFFFFF" class="table_title"><b>Sites grouping</b></td>
	    </tr>
	    <tr>
		<td>
		    <table cellspacing=1 cellpadding=2>
			<tr height=25 class="table_header">
			    <td align="center" width="20" class="table_header">No</td>
			    <td align="center" width="140" class="table_header">Site</td>
			    <!--
			    <td align="center" width="70" class="table_header">ML ver</td>
			    <td align="center" width="70" class="table_header">Online</td>
			    <td align="center" width="70" class="table_header">Pledged CPUs</td>
			    <td align="center" width="70" class="table_header">Pledged kSI2K</td>
			    -->
			    <td align="center" width="70" class="table_header">Group</td>
			    <!--
			    <td align="center" width="70" class="table_header">Options</td>
			    -->
			</tr>
			<<:continut:>>
			<tr height=25 class="table_header">
			    <!--
			    <td align="center" width="20" class="table_header">&nbsp;</td>
			    <td align="center" width="140" class="table_header">&nbsp;</td>
			    <td align="center" width="70" class="table_header">&nbsp;</td>
			    <td align="center" width="70" class="table_header">&nbsp;</td>
			    <td align="center" width="70" class="table_header">&nbsp;</td>
			    -->
			    <td colspan="2" align="center" width="70" class="table_header"><input type="text" name="group" class="input_text" value="<<:edit_group esc:>>"></td>
			    <td align="center" width="70" class="table_header"><input type=submit name=submit value="Group" class="input_submit"></td>
			</tr>

		    </table>
		</td>
	    </tr>
	</table>    
	</form>
