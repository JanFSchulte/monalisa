<script type="text/javascript" src="/js/window/prototype.js"> </script>
<script type="text/javascript">
    var submitting = false;

    function submitJobData(label){
	if (submitting)
	    return false;
    
	var type = document.getElementById(label+'_type');
//	var description = document.getElementById(label+'_description');
	var field1 = document.getElementById(label+'_field1');
	var field2 = document.getElementById(label+'_field2');
	var field3 = document.getElementById(label+'_field3');
	var field4 = document.getElementById(label+'_field4');
	var known_issues = document.getElementById(label+'_known_issues');

	var url = '/admin/job_types_action.jsp?id='+encodeURIComponent(label)+
				    '&type='+encodeURIComponent(type.value)+
				    '&description='+encodeURIComponent(type.value)+
				    '&field1='+encodeURIComponent(field1.value)+
				    '&field2='+encodeURIComponent(field2.value)+
				    '&field3='+encodeURIComponent(field3.value)+
				    '&field4='+encodeURIComponent(field4.value)+
				    '&known_issues='+encodeURIComponent(known_issues.value)
				    ;
	//alert(url);
	
	submitting = true;
	
	new Ajax.Request(url, {
	    method: 'get',
	    onComplete: function(transport) {
	    	submitting=false;

		if(transport.status == "200" || transport.status == 0){
		    //alert (transport.responseText);
		
		    if(transport.responseText.indexOf('Error') > 0){
		        alert("Error: Please refresh the page and try again!");
		        
		        return false;
		    }
		    else{
			if(label == 0){
			    window.location.href='job_types.jsp';
			}
			else{
			    alert('Update complete');
			    return false;
    			}
		    }
		}
		else{
		    alert("Error: "+transport.status);
		    return false;
		}
	    	
		}
	    }
	);
	
	return false;
    }
    
    function deleteJobType(label){
	var url = '/admin/job_types_action.jsp?id='+encodeURIComponent(label)+'&delete=1';
	//alert(url);
	
	submitting=true;
	
	new Ajax.Request(url, {
	    method: 'post',
	    onComplete: function(transport) {
	    	submitting = false;

		    if(transport.status == "200" || transport.status == 0){
			if(transport.responseText.indexOf('Error') > 0){
		    	    alert("Error: Please refresh the page and try again!");
		    	    return false;
			}
		    }
		    else{
			return false;
		    }
		    
		    window.location.href='job_types.jsp';
	    	
	    }
	} );
	
	return false;
    }
</script>

<br />
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Job Types Administration</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width="100%">
		<tr height=25 class="table_header">
		    <td class="table_header">ID</td>
		    <td class="table_header">Type (job "comment" field)</td>
		    <td class="table_header">Production</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Data source</td>
		    <td class="table_header">Comments</td>
		    <td class="table_header">Known issues</td>
		    <td class="table_header">Modify</td>		    		    
		</tr>
		<form name="addType" action="/admin/job_types.jsp" method="POST" onsubmit="return submitJobData('0');">
		<tr class="table_row" bgcolor="#F0F0F0">
		    <td class="table_row">&nbsp;</td>
		    <td class="table_row"><input type="text" id="0_type" id="0_type" value="<<:type:>>" class="input_text" size="45"></td>
		    <td class="table_row"><input type="text" id="0_field1" id="0_field1" value="" class="input_text" size="15"></td>    
		    <td class="table_row">
			<select id="0_field2" id="0_field2" class="input_select">
			    <option value="Running">Running</option>
			    <option value="Quality check 10%">Quality check 10%</option>
			    <option value="Macros validation">Macros validation</option>
			    <option value="Software update">Software update</option>
			    <option value="Technical stop">Technical stop</option>
			    <option value="Completed">Completed</option>
			    <option value="Scheduled">Scheduled</option>
			</select>
		    </td>
		    <td class="table_row">
			<select id="0_field4" class="input_select">
		    	    <option value="MC" <<:MC:>>>MC</option>
			    <option value="RAW" <<:RAW:>>>RAW</option>
			    <option value="RAW_OTHER" <<:RAW_OTHER:>>>RAW (other)</option>
			    <option value="TRAIN" <<:TRAIN:>>>TRAIN</option>
			</select>
		    </td>
		    <td class="table_row"><input type="text" id="0_field3" id="0_field3" value="" class="input_text" size="30"></td>
		    <td class="table_row"><input type="text" id="0_known_issues" id="0_known_issues" value="" class="input_text" size="20"></td>
		    <td class="table_row"><input type="submit" id="buton" value="Add" class="input_submit" onclick="return submitJobData('0');"></td>
		</tr>		
		</form>
		<<:continut:>>
	    </table>
	</td>
    </tr>
</table>
