<script type="text/javascript">
    function submit(){
	document.form1.submit();
    }
    
    function clusterChanged(){
	document.form1.group.selectedIndex=0;
	document.form1.user.selectedIndex=0;
	submit();
    }
    
    function groupChanged(){
	document.form1.user.selectedIndex=0;
	submit();
    }
    
    function userChanged(){
	document.form1.group.selectedIndex=0;
	submit();
    }
    
    function openAnnotations(){
        window.open('/annotations.jsp?series_names=<<:series_names enc:>>&groups=1', 'annwindow', 'toolbar=0,width=900,height=600,scrollbars=1,resizable=1,titlebar=1');
	return false;
    }
    
    bDivFurat=true;

</script>

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
		<option value="800x800" <<:imgsize_800x800:>>>800x800</option>
		<option value="1000x1000" <<:imgsize_1000x1000:>>>1000x1000</option>
		<option value="1200x1200" <<:imgsize_1200x1200:>>>1200x1200</option>
	    </select>
	</td>
	
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Bins</b><br>
	    <select name="bins" onChange="submit();" class=input_select>
		<!--
		<option value=40 <<:bins_40:>>>40</option>
		<option value=60 <<:bins_60:>>>60</option>
		<option value=80 <<:bins_80:>>>80</option>
		-->
		<option value=100 <<:bins_100:>>>100</option>
		<option value=150 <<:bins_150:>>>150</option>
		<option value=200 <<:bins_200:>>>200</option>
		<option value=250 <<:bins_250:>>>250</option>
		<option value=300 <<:bins_300:>>>300</option>
		<option value=350 <<:bins_350:>>>350</option>
		<option value=400 <<:bins_400:>>>400</option>
	    </select>
	</td>
	
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Annotations</b><br>
	    <select name="annotations" onChange="submit();" class=input_select>
		<option value=0 <<:annotations_0:>>>- None -</option>
		<option value=2 <<:annotations_2:>>>2</option>
		<option value=5 <<:annotations_5:>>>5</option>
		<option value=10 <<:annotations_10:>>>10</option>
		<option value=15 <<:annotations_15:>>>15</option>
		<option value=20 <<:annotations_20:>>>20</option>
		<option value=-1 <<:annotations_-1:>>>- All -</option>
	    </select>
	</td>
	
	<td align=right valign=bottom class="table_header">
	    <input type="submit" name="submitbutton" value="Plot" class="input_submit" style="font-weight:bold">
	</td>
    </tr>
    <tr>
	<td align=left>
	    <a href="javascript:void(0);" onClick="return openAnnotations();" class="link" accesskey="n">A<u>n</u>notations</a>
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
<!--
<tr>
    <td bgcolor=#f3f3f3 align=center>
	<table border=0 cellspacing=0 cellpadding=0 style="font-family:Helvetica;font-size:12px">
	    <tr>
		<td align=left style="padding-left:30px;padding-right:20px"><b>Color map</b> </td>
		<td style="width:15px;border:solid 1px #CACACA" bgcolor=red>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 0 &rarr; 95%</td>
		
		<td style="width:15px;border:solid 1px #CACACA" bgcolor=orange>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 95 &rarr; 97%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=yellow>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 97 &rarr; 98%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#9EE600>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 98 &rarr; 99%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#00FF00>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 99 &rarr; 100%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#26bd26>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 100%</td>
	    </tr>
	</table>
    </td>
</tr>
-->
<tr>
    <td align=center style="padding-top:20px">
	<table border=0 cellspacing=0 cellpadding=0 class="table_content" width=800>
	    <tr height=25>
		<td class="table_title"><b>Statistics</b></td>
	    </tr>
	    <tr>
		<td>
		    <table border=0 cellspacing=1 cellpadding=2 width=100%>
			<tr>
			    <td align=left nowrap width=20% class="table_header" rowspan=2 colspan=2><b>Account</b></td>
			    <td align=left nowrap width=20% class="table_header" colspan=2><b>Activity</b></td>
			    <td align=left nowrap width=20% class="table_header" colspan=2><b>Usage</b></td>
			</tr>
			<tr>
			    <td align=left nowrap width=20% class="table_header">Starts</td>
			    <td align=left nowrap width=20% class="table_header">Ends</td>
			    <td align=left nowrap width=20% class="table_header">Usage(%)</td>
			    <td align=left nowrap width=20% class="table_header">Total time</td>
			</tr>
			<<:statistics:>>
			<tr>
			    <td align=left nowrap width=20% class="table_header" colspan=2>TOTAL</td>
			    <td align=left nowrap width=20% class="table_header" colspan=2><<:interval:>></td>
			    <td align=left nowrap width=20% class="table_header"><<:availability:>> avg active usr</td>
			    <td align=left nowrap width=20% class="table_header"><<:uptime:>></td>
			</tr>
		    </table>
		</td>
	    </tr>
	</table>
    </td>
</tr>
</table>

</form>
