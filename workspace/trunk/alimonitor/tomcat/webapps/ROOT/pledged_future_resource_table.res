<div class="tabbertab">
<h2><a name="<<:name:>>"><em><<:title:>></em></a></h2>
<p>
<form name="<<:name:>>_form" onSubmit="return genChart(<<:resource:>>, this);">
<table cellspacing=0 cellpadding=2 style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; border: solid 1px #CCCC99">
    <tr height=25>
	<td bgcolor="#FFFFFF" style="color: #000000; font-size: 12px; padding: 10px; align: left" align="center"><b><<:description:>></b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;">
		<tr height=25 bgcolor="#CCCCCC" style="font-weight: bold; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px">
		    <td class="table_header">
			<input type="checkbox" name="all" value="1" onMouseOver="overlib('Select all for comparision');" onMouseOut="nd();" onClick="checkAll(document.forms['<<:name js:>>_form']);">
			<b>Site name</b>
		    </td>
		    <<:header:>>
    		</tr>
		<<:continut:>>
		<tr height=25 bgcolor="#CCCCCC" style="font-weight: bold; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px">
		    <td class="table_header">
			<input type="submit" name="submit" value="Compare" class="input_submit">
			<a class="link" href="javascript:void(0);" onClick="nd(); return showChart(<<:resource:>>, 's=_TOTALS_');" onMouseOver="overlib('Click for chart')" onMouseOut="return nd();"><b>TOTAL</b></a>
			<input type="checkbox" name="s" value="_TOTALS_" class="input_checkbox">
		    </td>
		    <<:footer:>>
		</tr>
	    </table>
	</td>
    </tr>
</form>
</table>
</p>
</div>
