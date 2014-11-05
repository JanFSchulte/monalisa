<form action=plugin.jsp method=POST>
<input type=hidden name=change value=1>
<table border=0 cellspacing=0 cellpadding=5 class=text>
    <tr>
	<td align=left>Message of the day:</td>
	<td align=left><input type=text name="value" value="<<:value esc:>>" class=input_text style="width:700px"></td>
    </tr>
    <tr>
	<td align=left>Tooltip:</td>
	<td align=left><input type=text name="tooltiptext" value="<<:tooltiptext esc:>>" class=input_text style="width:700px"></td>
    </tr>
    <tr>
	<td align=left>URL to point to:</td>
	<td align=left><input type=text name="href" value="<<:href esc:>>" class=input_text style="width:300px"></td>
    </tr>
    <tr>
	<td align=left>Text color:</td>
	<td align=left><input type=text name="color" value="<<:color esc:>>" class=input_text size=7 maxlength=7> (Sample: <font color="<<:color esc:>>"><<:value esc:>></font>)</td>
    </tr>
    <tr>
	<td align=left></td>
	<td align=left><input type=submit name=submit value="Update" class=input_submit></td>
    </tr>
</table>
</form>
