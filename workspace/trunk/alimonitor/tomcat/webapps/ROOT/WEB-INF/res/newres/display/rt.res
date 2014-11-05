<form action="display" method="post" name="form1">
    <input type=hidden name="page" value="<<:page:>>">
    <<:extra_fields:>>
    <table border=0 cellspacing=0 cellpadding=2 width=800 bgcolor="#778899">
	<tr>
	    <td>
		<table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:10px">
		    <tr>
			<td colspan=2>
			    <table border=0 cellspacing=0 cellpadding=0 width=100%  style="font-family:Helvetica;font-size:10px">
				<tr>
				    <td><b>Sites : </b></td>
				    <td align=right>(<a href="JavaScript:checkall();"><b>check all</b></a> | <a href="JavaScript:uncheckall();"><b>uncheck all</b></a>)</td>
				</tr>
			    </table>
			</td>
		    </tr>
		    <tr>
		        <td width=100% colspan=2>
			    <<:continut:>>
			    <<:com_separate_start:>><hr size=1 noshade><<:separate:>><<:com_separate_end:>>
		        </td>
		    </tr>
		    <tr>
			<td align=left nowrap style="font-family:Helvetica;font-size:10px">
			    <table border=0 cellspacing=0 cellpadding=0 width=100% style="font-family:Helvetica;font-size:10px">
				<tr>
				    <<:options:>>
				</tr>
			    </table>
			</td>
			<td align=right>
		            <input type=submit name="submit_plot" value="Plot" style="font-family:Helvetica;font-size:10px;font-weight:bold">
		        </td>
		    </tr>

		</table>
	    </td>
	</tr>
    </table>
    <<:extra:>>
</form>

<table border=0 cellspacing=0 cellpadding=0>
    <tr>
        <td valign=top>
            <<:map:>><img src="display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
        </td>
        <td valign=top><<:description:>></td>
    </tr>
</table>
