<form name=form1>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>Disk usage by MC production tag</b></td>
    </tr>
    <tr>
	<td valign="top">
	    <table cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<tr class="table_header">
		    <td class="table_header"><input type=submit name=form_submit value="&raquo;" class=input_submit></td>
		    <td class="table_header">Exclude locked productions <input type=checkbox name=exclude value=1 <<:exclude:>> class=input_checkbox onChange="modify()"></td>
		    <td class="table_header" colspan=3></td>
		    <td class="table_header" colspan=5>All files</td>
		    <td class="table_header" colspan=5>AODs</td>
		    <td class="table_header" colspan=5>PWGs</td>
		    <td class="table_header" colspan=5>QAs</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.tag.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=tag value="<<:tag esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.locked_by.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=locked_by value="<<:locked_by esc:>>"></td>
		    <td class="table_header" colspan=1></td>
		    <td class="table_header" colspan=1>
			<select name="lastaccesstime" class=input_select onChange="modify()">
			    <option value="0" <<:lastaccesstime_0:>>>Any</option>
			    <option value="1" <<:lastaccesstime_1:>>>&lt; 1 month</option>
			    <option value="3" <<:lastaccesstime_3:>>>&lt; 3 months</option>
			    <option value="6" <<:lastaccesstime_6:>>>&lt; 6 months</option>
			    <option value="12" <<:lastaccesstime_12:>>>&lt; 1 year</option>
			</select>
		    </td>
		    <td class="table_header" colspan=1></td>
		    <td class="table_header" colspan=2>One replica</td>
		    <td class="table_header" colspan=2>All replicas</td>
		    <td class="table_header" colspan=1>Replication factor</td>
		    <td class="table_header" colspan=2>One replica</td>
		    <td class="table_header" colspan=2>All replicas</td>
		    <td class="table_header" colspan=1>Replication factor</td>
		    <td class="table_header" colspan=2>One replica</td>
		    <td class="table_header" colspan=2>All replicas</td>
		    <td class="table_header" colspan=1>Replication factor</td>
		    <td class="table_header" colspan=2>One replica</td>
		    <td class="table_header" colspan=2>All replicas</td>
		    <td class="table_header" colspan=1>Replication factor</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header" colspan=1>Production tag</td>
		    <td class="table_header" colspan=1>Locked by PWG(s)</td>
		    <td class="table_header" colspan=1>Output directory</td>
		    <td class="table_header" colspan=1>Last access time</td>
		    <td class="table_header" colspan=1>Access count</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">(%)</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">(%)</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">(%)</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">Size</td>
		    <td class="table_header">Files</td>
		    <td class="table_header">(%)</td>
		</tr>
		</thead>
		<tbody>
		<<:continut:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class="table_header" colspan=2>TOTAL</td>
		    <td class="table_header"><<:cnt db esc:>> productions</td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:logical_size db size:>></td>
		    <td class="table_header"><<:logical_count db ddot:>></td>
		    <td class="table_header"><<:physical_size db size:>></td>
		    <td class="table_header"><<:physical_count db ddot:>></td>
		    <td class="table_header"><<:factor db ddot:>></td>
		    
		    <td class="table_header"><<:aods_logical_size db size:>></td>
		    <td class="table_header"><<:aods_logical_count db ddot:>></td>
		    <td class="table_header"><<:aods_physical_size db size:>></td>
		    <td class="table_header"><<:aods_physical_count db ddot:>></td>
		    <td class="table_header"><<:aods_factor db ddot:>></td>
		    
		    <td class="table_header"><<:pwgs_logical_size db size:>></td>
		    <td class="table_header"><<:pwgs_logical_count db ddot:>></td>
		    <td class="table_header"><<:pwgs_physical_size db size:>></td>
		    <td class="table_header"><<:pwgs_physical_count db ddot:>></td>
		    <td class="table_header"><<:pwgs_factor db ddot:>></td>
		    
		    <td class="table_header"><<:qas_logical_size db size:>></td>
		    <td class="table_header"><<:qas_logical_count db ddot:>></td>
		    <td class="table_header"><<:qas_physical_size db size:>></td>
		    <td class="table_header"><<:qas_physical_count db ddot:>></td>
		    <td class="table_header"><<:qas_factor db ddot:>></td>
		</tr>
		</tfoot>
	    </table>
	    </form>
	</td>
    </tr>
</table>
</form>