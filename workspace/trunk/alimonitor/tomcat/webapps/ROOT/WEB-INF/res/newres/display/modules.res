<script language=JavaScript>
function checkallmodules(){
    var fields = document.form1.modules;
    for (i=0; i<fields.length; i++)
        fields[i].checked=true;
}
	    
function uncheckallmodules(){
    var fields = document.form1.modules;
    for (i=0; i<fields.length; i++)
	fields[i].checked=false;
}
</script>

    <table border=0 cellspacing=0 cellpadding=2 width=800 bgcolor="#778899" style="font-family:Helvetica;font-size:10px">
	<tr>
	    <td>
	        <table border=0 cellspacing=0 cellpadding=0 width=100% bgcolor="#eeeeee">
		    <tr>
			<td nowrap>&nbsp;<b>Graphs :</b></td>
			<td align=right nowrap width=100%>
			    (<a href="JavaScript:checkallmodules();"><b>check all</b></a> | <a href="JavaScript:uncheckallmodules();"><b>uncheck all</b></a>)
		    	</td>
		    </tr>
		</table>

		<table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:10px">
		    <tr>
			<<:continut:>>
		    </tr>
		</table>
	    </td>
	</tr>
    </table>
