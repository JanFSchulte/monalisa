
<form name="form1" action="dcs.jsp" method="POST">
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="600">
    <tr height="25">
	<td class="table_title" nowrap><b>Test DCS</b></td>
    </tr>
    <tr>
	<td valign="top">
	    <table cellspacing=1 cellpadding=2 width="100%" border=0>
		<tr class="table_header">
		    <td class="table_header">Field</td>
		    <td class="table_header">Value</td>
		    <td class="table_header">Comment</td>
		</tr>
		
		<tr class="table_row text">
		    <td class="table_row" nowrap align=left><b>Amanda server</b></td>
		    <td class="table_row" nowrap>
			<label><input type=radio name=instance value=test checked> test</label> or 
			<label><input type=radio name=instance value=prod> prod</label> or
			<label><input type=radio name=instance value=prod2> prod2</label> or
			<label><input type=radio name=instance value=prod3> prod3</label>
		    </td>
		    <td class=table_row nowrap><i>Which instance?</i></td>
		</tr>
		
		<tr class="table_row text">
		    <td class="table_row" nowrap align=left><b>Detector</b></td>
		    <td class="table_row" nowrap>
			<select name=detector class=input_select>
			    <option value="ACO">ACO</option>
			    <option value="EMC">EMC</option>
			    <option value="FMD">FMD</option>
			    <option value="HMP">HMP</option>
			    <option value="MCH">MCH</option>
			    <option value="MTR">MTR</option>
			    <option value="PHS">PHS</option>
			    <option value="CPV">CPV</option>
			    <option value="PMD">PMD</option>
			    <option value="SPD">SPD</option>
			    <option value="SDD">SDD</option>
			    <option value="SSD">SSD</option>
			    <option value="TOF">TOF</option>
			    <option value="TPC">TPC</option>
			    <option value="TRD">TRD</option>
			    <option value="T00">T00</option>
			    <option value="V00">V00</option>
			    <option value="ZDC">ZDC</option>
			    <option value="GRP">GRP</option>
			</select>
		    </td>
		    <td class=table_row nowrap><i>Select one</i></td>
		</tr>

		<tr class="table_row text">
		    <td valign=top  nowrap><b>Time interval</b></td>
		</tr>

		<tr class="table_row text">
		    <td nowrap align=left style="padding-left:20px">Starting</td>
		    <td nowrap>
			<input type=text class=input_text name=start_time value="" size=20>
		    </td>
		    <td nowrap><i>Epoch time or any reasonable time format</i></td>
		</tr>
		
		<tr class="table_row text">
		    <td  style="padding-left:20px" class="table_row" nowrap>Ending</td>
		    <td class="table_row" nowrap>
			<input type=text class=input_text name=end_time value="" size=20>
		    </td>
		    <td class=table_row nowrap><i>Same as above</i></td>
		</tr>

		<tr class="table_row text">
		    <td class="table_row" nowrap align=left><b>Alias</b></td>
		    <td class="table_row" nowrap>
			<input type=text class=input_text name=numeric_field size=3>
		    </td>
		    <td class=table_row nowrap><i>Alias number (-1 = all)</i></td>
		</tr>

		<tr class="table_row text">
		    <td class="table_row" nowrap align=left><b>Verbose</b></td>
		    <td class="table_row" nowrap>
			<label><input type=radio name=verbose value=1>yes</label> or <label><input type=radio name=verbose value=0 checked>no</label>
		    </td>
		    <td class=table_row nowrap><i>Verbose output</i></td>
		</tr>

		<tr>
		    <td></td>
		    <td align=right>
			<input type=submit name=submit value="Test..." class=input_submit>
		    </td>
		    <td></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
