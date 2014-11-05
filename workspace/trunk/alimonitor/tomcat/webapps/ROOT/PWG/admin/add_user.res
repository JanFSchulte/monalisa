<form name="addUser" method="POST" action="/PWG/admin/users.jsp">
<input type="hidden" name="action" value="2">
<input type="hidden" name="uid" value="<<:pu_id db:>>">
<tr>
    <td align=left class="table_row">&nbsp;<<:pu_id db:>></td>
    <td align=left class="table_row">
	<select name="group" class="input_select">
	    <<:group:>>
	</select>
    </td>    
    <td align=left class="table_row"><input type="text" name="username" id="username" value="<<:pu_username db:>>" class="input_text"></td>    
    <td align=left class="table_row"><input type="text" name="email" id="email" value="<<:pu_email db:>>" class="input_text"></td>    
    <td align=left class="table_row"><input type="submit" name="buton" value="Insert" class="input_submit" onclick="return verifyUser();"></td>    
</tr>