
<form name="form1" action="upload.jsp" method="POST" enctype="multipart/form-data">
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="600">
    <tr height="25">
	<td class="table_title" nowrap><b>Upload corrected OCDB files</b></td>
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
		    <td class="table_row" nowrap align=left><b>Entry path</b></td>
		    <td class="table_row" nowrap>
			<input type=text class=input_text name=path size=40>
		    </td>
		    <td class=table_row nowrap><i>e.g. DET/Calib/RecoParam</i></td>
		</tr>
		
		

		<tr class="table_row text">
		    <td valign=top  nowrap align=left><b>Source entry</b></td>
		</tr>

		<tr class="table_row text">
		    <td valign=top nowrap align=left style="padding-left:20px">Either from file</td>
		    <td nowrap>
			<input type=file class=input_select name=file><br>
		    </td>
		    <td nowrap><i>.root file</i></td>
		</tr>
		<tr class="table_row text">
		    <td class=table_row nowrap align=left style="padding-left:20px"><b>or</b> from OCDB</td>
		    <td class="table_row" nowrap>
			<table border=0 cellspacing=2 cellpadding=0 class=text><tr>
			<td align=center>
			    <input type=text class=input_text name=sourceuri value="alien://folder=/alice/" size=30><br>
			    URI
			</td>
			<td align=center>
			    <input type=text class=input_text name=sourceurirun value="" size=7><br>
			    Run number
			</td>
			</tr></table>
		    </td>
		    <td class=table_row nowrap><i>alien://folder=/alice/...&nbsp;&nbsp;&nbsp;&nbsp;95040</i></td>
		</tr>

		<tr class="table_row text">
		    <td valign=top  nowrap><b>Destination entry</b></td>
		</tr>

		<tr class="table_row text">
		    <td nowrap align=left style="padding-left:20px">OCDB URI</td>
		    <td nowrap>
			<input type=text class=input_text name=destinationuri value="alien://folder=/alice/" size=40>
		    </td>
		    <td nowrap><i>alien://folder=/alice/...</i></td>
		</tr>
		
		<tr class="table_row text">
		    <td  style="padding-left:20px" class="table_row" nowrap>Run range</td>
		    <td class="table_row" nowrap>
			<input type=text class=input_text name=runrange value="0-999999999" size=15>
		    </td>
		    <td class=table_row nowrap><i>e.g. &quot;same&quot; or 95040-95120</i></td>
		</tr>


		<tr>
		    <td></td>
		    <td align=right>
			<input type=submit name=submit value="Upload..." class=input_submit>
		    </td>
		    <td></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
