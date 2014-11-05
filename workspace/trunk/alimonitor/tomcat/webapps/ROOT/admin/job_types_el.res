<tr class="table_row" bgcolor="<<:color:>>">
    <td class="table_row" nowrap><a href="javascript:void(0)" onClick="showIframeWindow('job_types_links.jsp?id=<<:id:>>', 'Edit links for #<<:id:>>')" class=link><<:id:>></a></td>
    <td class="table_row" nowrap><input type="text" id="<<:id:>>_type" id="<<:id:>>_type" value="<<:type:>>" class="input_text" size="45"></td>
    <td class="table_row" nowrap><input type="text" id="<<:id:>>_field1" id="<<:id:>>_field1" value="<<:field1:>>" class="input_text" size="15"></td>    
    <td class="table_row" nowrap>
	<select id="<<:id:>>_field2" class="input_select">
	    <option value="Running" <<:Running:>>>Running</option>
	    <option value="Quality check 10%" <<:Quality:>>>Quality check 10%</option>
	    <option value="Macros validation" <<:Macros:>>>Macros validation</option>
	    <option value="Software update" <<:Software:>>>Software update</option>
	    <option value="Technical stop" <<:Technical:>>>Technical stop</option>
	    <option value="Completed" <<:Completed:>>>Completed</option>
	    <option value="Scheduled" <<:Scheduled:>>>Scheduled</option>
	</select>
    </td>
    <td class="table_row" nowrap>
	<select id="<<:id:>>_field4" class="input_select">
	    <option value="MC" <<:MC:>>>MC</option>
	    <option value="RAW" <<:RAW:>>>RAW</option>
	    <option value="RAW_OTHER" <<:RAW_OTHER:>>>RAW (other)</option>
	    <option value="TRAIN" <<:TRAIN:>>>TRAIN</option>
	</select>
    </td>
    <td class="table_row" nowrap><input type="text" id="<<:id:>>_field3" id="<<:id:>>_field3" value="<<:field3:>>" class="input_text" size="30"></td>    
    <td class="table_row" nowrap><input type="text" id="<<:id:>>_known_issues" id="<<:id:>>_known_issues" value="<<:known_issues:>>" class="input_text" size="20"></td>
    <td class="table_row" nowrap><input type="submit" id="buton" value="Modify" class="input_submit" onclick="submitJobData('<<:id:>>');">&nbsp;<input type="submit" id="buton" value="Delete" class="input_submit" onclick="if(confirm('Are you sure you want to delete this row?')) deleteJobType('<<:id:>>'); return false;"></td>
</tr>
