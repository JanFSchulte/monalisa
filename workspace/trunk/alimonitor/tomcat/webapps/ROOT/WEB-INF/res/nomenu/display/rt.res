<form action="display" method="post" name="form1">
    <input type=hidden name="page" value="<<:page:>>">
    <table border=0 cellspacing=0 cellpadding=2 width=790 bgcolor="#778899">
	<tr>
	    <td>
		<table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:9px">
		    <tr>
			<td>
			    <table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:10px" class=checkboxmenu>
			      <tr>
				<td><b>Sites :</b></td>
				<td align=right nowrap class="checkboxmenu" colspan=2>
				    (<a href="JavaScript:checkall();">check all</a> | <a href="JavaScript:uncheckall();">uncheck all</a>)
				</td>
			      </tr>
			    </table>
			</td>
		    </tr>
		    <tr>
		        <td width=100% class="checkboxmenu" align=left>
			    <<:continut:>>
			    <<:com_separate_start:>><hr size=1 noshade><<:separate:>><<:com_separate_end:>>
		        </td>
		    </tr>
		    <tr>
		    </tr>
		    <tr>
			<td align=left nowrap style="font-family:Helvetica;font-size:10px">
			    <table border=0 cellspacing=0 cellpadding=0 width=100% style="font-family:Helvetica;font-size:10px">
				<tr>
				    <<:options:>>
				    <td align=right>
					<nobr>Image size: <select name="imgsize" onChange="JavaScript:modify();"  style="font-family:Helvetica;font-size:10px">
					</select><script language=JavaScript>
					    displayImgResOptions(document.form1.imgsize);
					</script></nobr>
		    		        <input type=submit name="submit_plot" value="Plot" class="checkboxmenu" style="font-weight:bold">
		    		    </td>
				</tr>
			    </table>
			</td>
		    </tr>

		</table>
	    </td>
	</tr>
    </table>
    <<:extra:>>
</form>

<table border=0 cellspacing=0 cellpadding=0 align=center width=70%>
    <tr>
        <td valign=top align=center>
            <<:map:>><img src="display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
        </td>
    </tr>
    <tr>
	<td align=left><br><font style="font-family:Helvetica;font-size:12px"><<:description:>></font></td>
    </tr>
</table>
