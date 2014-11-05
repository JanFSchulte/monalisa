<script type="text/javascript">
    var dAltHidden = objById('d_alternate_hidden');
    
    bDivFurat = true;
</script>

<form action="psqa.jsp" method="post" name="form1">
    <input type=hidden name="pid" value="<<:pidlist esc:>>">
    <table width="790" cellspacing="0" cellpadding="0" border="0" class="text">
	<tr>
	    <td style="border-bottom: solid 1px #B5B5BD; padding-bottom: 5px; font-family: Verdana, Arial" bgcolor="#F0F0F0">
		<table width=100% cellspacing="0" cellpadding="0">
		    <!--
		    <tr>
			<td>
				<table border=0 cellspacing=0 cellpadding=3 width=100% style="border-bottom: 2px solid #FFFFFF;">
				    <tr>
					<td align=right style="padding:0px">
					    (<a class="link" href="JavaScript:checkall();" class="link">check all</a> | <a class="link" href="JavaScript:uncheckall();" class="link">uncheck all</a>)
					</td>
				    </tr>
				    <tr>
					<td align=left class="text">
    					    <<:content:>>
					</td>
				    </tr>
		    		</table>
			</td>
		    </tr>
		    -->
		    <tr>	
			<td>
			<table border=0 cellspacing=0 cellpadding=3 width=100% class="text">
			    <tr>
				<td align=left nowrap valign=absmiddle>Series to display
				    <select name="key" onChange="JavaScript:modify();" class="input_select">
					<<:opt_series:>>
				    </select>
				</td>
				<td align=left nowrap valign=absmiddle style="font-family:Helvetica;font-size:10px">Error bars
				    <select name="err" onChange="JavaScript:modify();" class="input_select">
					<option value="0" <<:err_0 esc:>>>disabled</option>
					<option value="1" <<:err_1 esc:>>>enabled</option>
				    </select>
				</td>
			    </tr>
			</table>
		    </tr>
		</table>
	    </td>
	</tr>
    </table>
</form>

<<:map:>>
<img src="/display?image=<<:image:>>" usemap="#<<:image:>>" border=0 style="padding-top:10px">
