<tr><td>
<form name="form_<<:testname:>>" action="/bits/bits_pertest.jsp" method=POST>
<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b><<:testname:>></b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header"><b>Test</b></td>
		    <td class="table_header"><b>Start</b></td>
		    <td class="table_header"><b>End</b></td>
		    <td class="table_header"><b>Duration</b></td>
		    <td class="table_header"><b>State</b></td>
		    <td class="table_header"><b>CPU time</b></td>
		    <td class="table_header"><b>Wall time</b></td>
		    <td class="table_header"><b>Total memory</b></td>
		    <td class="table_header"><b>RSS memory</b></td>
		    <td class="table_header"><b>File size</b></td>		
		</tr>
		<tr height=25>
		    <td class="table_row">
			<select class="input_select" name="test" onChange="document.forms['form_<<:testname:>>'].submit();">
			    <<:options_tests:>>
			</select>
		    </td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row">
			<select class="input_select" name="filter_state" onChange="document.forms['form_<<:testname:>>'].submit();">
			    <option value="-1">- All -</option>
			    <option value="0" <<:filter_state_0:>>>Failed</option>
			    <option value="1" <<:filter_state_1:>>>Successful</option>
			</select>
		    </td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row" colspan="5" align="center">
			<<:com_showall_start:>>
			    <input type="button" class="input_submit" name="reset_button" value="Reset selection" onClick="resetForm('form_<<:testname:>>')">
			    <input type="submit" class="input_submit" name="submit_button" value="Filter">
			<<:com_showall_end:>>
		    </td>
		</tr>
		<<:continut:>>
	    </table>
	</td>
    </tr>
</table>
<table width=100% cellspacing=0 cellpadding=0>
    <tr>
	<td align=right>
	    <a class="link" href="/bits/bits_benchmark.jsp"><u>Benchmarks overview</u></a>
	</td>
    </tr>
</table>
<br>
<br>
</form>
</td></tr>
