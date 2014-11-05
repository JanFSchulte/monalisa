<script lanquage="javascript">
    function verifyGroup(){
	var sGroup = document.getElementById("group").value;
	var sGroupId = document.getElementById("gid").value;
	
	if(sGroup.length == 0){
	    alert("Please type a group name!");
	    return false;
	}
	    
        var url = "/PWG/admin/check.jsp?action=1&group="+sGroup+"&gid="+sGroupId;
       
	var bResponse = false;
       
        new Ajax.Request(url, {
	    asynchronous : false,
            method: 'post',
            onComplete: function(transport) {
                   
		if(transport.status == "200"){
            	    if(transport.responseText.indexOf('ERROR') >= 0){
            		alert("Error: .This group already exists in the database!");
        	    }
        	    else{
        		bResponse = true;
        	    }
    		}
    		else{
    		    alert("Error: .Please refresh the page and try again!");
    		}
    	    }
    	}
        );
        
	return bResponse;
    }
    
    function verifyDeleteGroup(group){
	if(!confirm('Are you sure that you want to delete this group'))
	    return false;
    
	var groupId = group;
	
	url = "/PWG/admin/check.jsp?action=3&gid="+groupId;
	
	var bResponse = false;
       
        new Ajax.Request(url, {
	    asynchronous : false,
            method: 'post',
            onComplete: function(transport) {
                   
		if(transport.status == "200"){
            	    if(transport.responseText.indexOf('ERROR') >= 0){
            		alert("Error: There are users in this group!");
        	    }
        	    else{
        		bResponse = true;
        	    }
    		}
    		else{
    		    alert("Error: .Please refresh the page and try again!");
    		}
    	    }
    	}
        );
        
	return bResponse;
	
    }
</script>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>PWG Groups Admin</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25>
		    <td class="table_header">
			<b>ID</b>			
		    </td>
		    <td class="table_header">
			<b>Name</b>			
		    </td>
		    <td class="table_header">
			<b>Options</b>			
		    </td>
    		</tr>
		<<:continut:>>
	    </table>
	</td>
    </tr>
</table>
