<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>RAW Production Cycles</b></td>
    </tr>
    <tr height=1>
	<td align=right><a href="requests.jsp" class=link>Processing requests &raquo;</a></td>
    </tr>
    <tr>
	<td valign="top">
	    <table cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<form method=post name=form1>
		<tr class="table_header">
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" colspan=3>Raw data</td>
		    <td class="table_header" colspan=5>Reconstructed</td>
		    <td class="table_header" colspan=2>Timing <input type=submit name=submit value="&raquo;" class=input_submit></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.jt_field1.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=jt_field1 value="<<:jt_field1 esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.jt_description.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text style="width:100%" name=jt_description value="<<:jt_description esc:>>"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		</tr>
		</form>
		<tr class="table_header">
		    <td class="table_header">Production</td>
		    <td class="table_header">Description</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Run Range</td>
		    <td class="table_header">Runs</td>
		    <td class="table_header">Chunks</td>
		    <td class="table_header">Size</td>
		    <td class="table_header" colspan=2>Chunks</td>
		    <td class="table_header" colspan=2>Size</td>
		    <td class="table_header">Events</td>
		    <td class="table_header">Running</td>
		    <td class="table_header">Saving</td>
		</tr>
		</thead>
		<tbody>
		<<:content:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:esds_size db size:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap align=right><<:wall_time intervalh:>></td>
		    <td class="table_header" nowrap align=right><<:saving_time intervalh:>></td>
		</tr>
		</tfoot>
	    </table>
	</td>
    </tr>
</table>
