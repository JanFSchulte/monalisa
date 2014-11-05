<form name="addGroup" action="/PWG/admin/users.jsp" method="POST">
<input type="hidden" name="action" value="1">
<input type="hidden" name="gid" id="gid" value="<<:pg_id:>>">
<tr>
    <td align=left class="table_row">&nbsp;<<:pg_id:>></td>
    <td align=left class="table_row"><input type="text" name="group" id="group" value="<<:pg_name esc:>>" class="input_text"></td>    
    <td align="center" class="table_row"><input type="submit" name="buton" value="Insert" class="input_submit" onclick="return verifyGroup();"></td>    
</tr>
</form>