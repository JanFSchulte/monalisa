<table width=100% border=0 cellspacing=0 cellpadding=2 class=text>
<tr>
    <td align=left>
	<form name=form1 action="/runview/" method=get>
	Select run: <input type=text class=input_text name=run value="<<:run esc:>>"><input type=submit class=input_submit name=submit value="&raquo;">
	</form>
    </td>
</tr>
<tr>
    <td align=center style="font-size:14px"><b>Run 
    	    <a target=_blank class="link_header" style="text-decoration:none"  
		href="https://alice-logbook.cern.ch/logbook/date_online.php?p_cont=rund&p_run=<<:run enc:>>"
		onMouseOver="runDetails(<<:run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"><<:run db esc:>></a>

    processing details</b></td>
</tr>
<tr>
<td style="height:100%">
    <table border=0 cellspacing=3 cellpadding=0 bgcolor=#0A92D0 width=100% style="height:100%">
	<<:content:>>
    </table>
</td>
</tr>
</table>
