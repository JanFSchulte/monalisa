<html>
<head>
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<link type="text/css" rel="StyleSheet" href="/img/dynamic/style.css" />
</head>
<body>
<form action=lpm_ignore.jsp method=post>
<table border=0 cellspacing=10 cellpadding=0 width=100%>
    <tr>
	<td valign=top width=50%>
	    <table border=1 cellspacing=0 cellpadding=4 width=100% class=text>
		<tr>
		    <th width=100%>Ignored job IDs:</th>
		    <th>&nbsp;</th>
		</tr>
		<<:ignored:>>
		<tr>
		    <td colspan=2 align=right><input type=submit name=remove class=input_submit value="Remove"></td>
		</tr>
	    </table>
	</td>
	<td valign=top width=50%>
	    <table border=1 cellspacing=0 cellpadding=4 width=100% class=text>
		<Tr>
		    <th width=100%>Ignore some job:</th>
		    <th>&nbsp;</th>
		</tr>
		<<:newignore:>>
		<tr>
		    <td>Other ID: <input type=text name=add value="" size=9 class=input_text></td>
		    <td><input type=submit value="Ignore" class=input_submit></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</form>
</body>
</html>
