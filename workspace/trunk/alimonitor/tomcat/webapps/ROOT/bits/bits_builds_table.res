<table border=0 cellspacing=0 cellpadding=0 width=100%>
    <tr>
	<td align=center style="padding-bottom:10px;font-family:Tahoma,Arial;font-size:16px">
	    <b>AliRoot builds</b>
	</td>
    </tr>

<tr><td>
<form name="form_build" action="/bits/bits_benchmark.jsp" method=POST>
<input type="hidden" name="test" value="build">
<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b>Builds</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header"><b>Start</b></td>
		    <td class="table_header"><b>Duration</b></td>
		    <td class="table_header"><b>Status</b></td>
		    <td class="table_header"><b>OS</b></td>
		    <td class="table_header"><b>Arch</b></td>
		    <td class="table_header"><b>Release</b></td>
		    <td class="table_header"><b>Prepare</b></td>
		    <td class="table_header"><b>Make</b></td>
		    <td class="table_header"><b>-install</b></td>
		    <td class="table_header"><b>-test</b></td>
		    <td class="table_header"><b>-cache</b></td>
		    <td class="table_header"><b>-autopkg</b></td>
		</tr>
		<tr height=25>
		    <td class="table_row">
			<select class="input_select" name="filter_date" onChange="document.forms['form_build'].submit();">
			    <option value="0">- All -</option>
			    <option value="7" <<:filter_date_7:>>>Last week</option>
			    <option value="30" <<:filter_date_30:>>>Last month</option>
			    <option value="61" <<:filter_date_61:>>>Last 2 months</option>
			    <option value="91" <<:filter_date_91:>>>Last 3 months</option>
			    <option value="182" <<:filter_date_182:>>>Last 6 months</option>
			    <option value="365" <<:filter_date_365:>>>Last year</option>
			</select>
		    </td>
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row">
			<select class="input_select" name="filter_state" onChange="document.forms['form_build'].submit();">
			    <option value="">- All -</option>
			    <option value="0" <<:filter_state_0:>>>Failed</option>
			    <option value="1" <<:filter_state_1:>>>Successful</option>
			</select>
		    </td>
		    <td class="table_row">
			<select class="input_select" name="filter_os" onChange="document.forms['form_build'].submit();">
			    <option value="">- All -</option>
			    <<:options_filter_os:>>
			</select>
		    </td>
		    <td class="table_row">
			<select class="input_select" name="filter_arch" onChange="document.forms['form_build'].submit();">
			    <option value="">- All -</option>
			    <<:options_filter_arch:>>
			</select>
		    </td>
		    <td class="table_row">
			<select class="input_select" name="filter_build_version" onChange="document.forms['form_build'].submit();">
			    <option value="">- All -</option>
			    <<:options_filter_build_version:>>
			</select>
		    </td>
		    <td class="table_row" colspan="6" align="right">
			<<:com_showall_start:>>
			    <input type="button" class="input_submit" name="reset_button" value="Reset selection" onClick="resetForm('form_build')">
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
	<td align=left>
	    <a class="link" href="/bits/bits_benchmark.jsp?test=build"><u>Show entire builds history</u></a>
	</td>
	<<:com_showall_start:>>
	<td align=right>
	    <a class="link" href="/bits/bits_benchmark.jsp"><u>Benchmarks overview</u></a>
	</td>
	<<:com_showall_end:>>
    </tr>
</table>
<br>
<br>
</form>
</td></tr>
</table>
