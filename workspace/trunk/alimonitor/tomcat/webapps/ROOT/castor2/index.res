<form action="/display" method=post name=form1>
    <input type=hidden name=page value="">
</form>
<table border=0 cellspacing=0 cellpadding=0>
<tr>
<td>
<form action=index.jsp method=get name=form2>
    <table border=0 cellspacing=5 cellpadding=0 class=text width=100%>
	<tr>
	    <td width=25% align=left>
		Castor2x diskpool:
	        <select class="input_select" name=cluster onChange="document.form2.submit()">
		    <<:opt_clusters:>>
		</select>
	    </td>
	    <td width=25% align=left>
		Log scale:
		<select class="input_select" name=log onChange="document.form2.submit()">
		    <option value='true' <<:opt_log_true:>>>enabled</option>
		    <option value='false' <<:opt_log_false:>>>disabled</option>
		</select>
	    </td>
	    <td valign=center rowspan=2 align=right>
		<input class="input_submit" type=submit name=plot value="Plot &raquo;">
	    </td>
	</tr>
    </table>
</form>
</td>
</tr>
<tr>
    <td style="padding-top:20px">
	<<:map:>>
	<img src="/display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
    </td>
</tr>
</table>
