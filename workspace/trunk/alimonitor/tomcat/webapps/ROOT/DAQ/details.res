<form name=form1 action=/DAQ/details.jsp method=POST>

<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>RAW Data Registration</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25>
		    <td class="table_header"><b>Timestamp</b></td>
		    <td class="table_header"><b>Run#</b></td>
		    <td class="table_header"><b>Partition</b></td>
		    <td class="table_header"><b>File name</b></td>
		    <td class="table_header"><b>Size</b></td>
		    <td class="table_header"><b>ERROR_V</b></td>
		</tr>

		<tr height=25>
		    <td class="table_header">
			<select name=time class="input_select" onChange="modify();">
			    <option value="0" <<:time_0:>>>- All -</option>
			    <option value="1" <<:time_1:>>>Last hour</option>
			    <option value="24" <<:time_24:>>>Last day</option>
			    <option value="168" <<:time_168:>>>Last week</option>
			    <option value="720" <<:time_720:>>>Last month</option>
			    <option value="1464" <<:time_1464:>>>Last 2 months</option>
			    <option value="2190" <<:time_2190:>>>Last 3 months</option>
			    <option value="2920" <<:time_2920:>>>Last 4 months</option>
			    <option value="4320" <<:time_4320:>>>Last 6 months</option>
			    <option value="8760" <<:time_8760:>>>Last year</option>
			</select>
		    </td>
		    <td class="table_header">
			<select name=runfilter class="input_select" onChange="modify();">
			    <option value="">- All -</option>
			    <<:opt_runs:>>
			</select>
		    </td>
		    <td class="table_header">
		    	<select name=detectorfilter class="input_select" onChange="modify();">
		    	    <option value="">- All -</option>
			    <<:opt_detectors:>>
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><input type=submit class=input_submit name=refreshbutton value="Refresh &raquo;"></td>
		</tr>
		<<:content:>>
		
		<tr height=25>
		    <td align=left class="table_header"><b>TOTAL</b></td>
		    <td align=right class="table_header"><<:runs:>> runs</td>
		    <td class="table_header"></td>
		    <td align=right class="table_header"><<:files:>> files</td>
		    <td align=right class="table_header"><<:totalsize size:>></td>
		    <td class="table_header"><<:errorv_count:>></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=left>
	    <a href="/DAQ/" class=link>&laquo; Back to DAQ overview</a>
	</td>
    </tr>
</table>

</form>
