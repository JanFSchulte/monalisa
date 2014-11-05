<script language="javascript">
function verifyUser(){
    var sUsername = document.getElementById("username").value;
    var sEmail = document.getElementById("email").value;
    
    if(sUsername.length == 0){
	alert("Please type an username!");
	return false;
    }
    
    if(sEmail.length == 0){
	alert("Please type an email");
	return false;
    }

    return true;
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
			<b>Group</b>			
		    </td>
		    <td class="table_header">
			<b>Name</b>			
		    </td>
		    <td class="table_header">
			<b>Email</b>		
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
