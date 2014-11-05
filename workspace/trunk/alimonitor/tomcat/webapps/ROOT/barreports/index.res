<form name=form1 action=index.jsp method=post>
<table border=0 cellspacing=0 cellpadding=0 width=800>
<tr>
<td>
<table border=0 cellspacing=0 cellpadding=3 class=text width=100%>
    <tr>
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	
	<!-- INTERVAL SELECTION -->
			
	<b>Interval selection</b><br><select name="quick_interval" onChange="javascript:quick_jump();" class="input_select">
	    <option value="-1">- choose -</option>
	    <option value="86400000">last day</option>
	    <option value="604800000">last week</option>
	    <option value="2628000000">last month</option>
	    <option value="5256000000">last 2 months</option>
	    <option value="7884000000">last 3 months</option>
	    <option value="15724800000">last 6 months</option>
	    <option value="31536000000">last year</option>
	</select>
	
	&nbsp;&nbsp;or&nbsp;&nbsp;

	<a href="javascript:move_back();" onmouseover="return overlib('Previous interval');" onmouseout="return nd();" class="linkb"  style="font-size: 14px;">&laquo;</a>&nbsp;
	<input type="text" name="interval_date_low" id="min" value="" onclick="nd(); pickDate(this, document.getElementById('min'), calendarObjForFormMin);" size="14" readonly class="input_text">
	&nbsp;&nbsp;-&nbsp;&nbsp;
	<input type="text" name="interval_date_high" id="max" size=15 readonly class="input_text" onClick="nd(); pickDate(this, document.getElementById('max'), calendarObjForFormMax);">

	<input type=hidden name="interval.min" id="interval.min" value="<<:interval_min:>>">
	<input type=hidden name="interval.max" id="interval.max" value="<<:interval_max:>>">

	&nbsp;
	<a href="javascript: void(0)" onclick="move_next();" onmouseover="return overlib('Next interval');" onmouseout="return nd();" class="linkb" style="font-size: 14px;">&raquo;</a>

	<script language="JavaScript">
	    <!--
	    var now = new Date("<<:current_date_time:>>");
	    init_form();
	    -->
	</script>
				
	<!-- /INTERVAL SELECTION -->
	
	
	</td>
	
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Image size</b><br>
	    <select name="imgsize" onChange="submit();" class=input_select>
		<option value="800x350" <<:imgsize_800x350:>>>800x350</option>
		<option value="1000x400" <<:imgsize_1000x400:>>>1000x400</option>
		<option value="1200x500" <<:imgsize_1200x500:>>>1200x500</option>
	    </select>
	</td>
	
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Per</b><br>
	    <select name="sites" onChange="submit();" class=input_select>
		<option value=1 <<:sites_1:>>>Site</option>
		<option value=0 <<:sites_0:>>>Country</option>
	    </select>
	</td>
	
	<td align=right valign=bottom class="table_header">
	    <input type="submit" name="submitbutton" value="Plot" class="input_submit" style="font-weight:bold">
	</td>
    </tr>
</table>
<br><br>
</td>
</tr>
<tr>
    <td>
	<<:map:>><img src="/display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
    </td>
</tr>
<tr>
    <td align=center style="padding-top:10px">
      <table cellspacing=0 cellpadding=2 class="table_content">
	<tr height=25>
	    <td class="table_title"><b>Resources usage report</b></td>
	</tr>
	<tr>
	    <td>
		<table cellspacing=1 cellpadding=2 width="330">
		    <tr height=25>
			<td align=left nowrap width=20% class="table_header"><b><<:header_name:>></b></td>
			<td align=right nowrap width=15% class="table_header"><b>Delivered</b>&nbsp;</td>
			<td align=right nowrap width=15% class="table_header"><b>Pledged</b>&nbsp;</td>
		    </tr>
		    <<:content:>>
		    <tr height=25>
			<td align=left nowrap width=20% class="table_header"><b>TOTAL</b></td>
			<td align=right nowrap width=20% class="table_header"><font color=<<:color:>>><<:delivered:>></font></td>
			<td align=right nowrap width=20% class="table_header"><<:pledged:>></td>
		    </tr>
		</table>
	    </td>
	</tr>
      </table>
    </td>
</tr>
</table>

</form>
