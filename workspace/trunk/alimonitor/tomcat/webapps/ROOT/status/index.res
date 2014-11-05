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
    
    var dAltHidden = objById('d_alternate_hidden');
    
    bDivFurat=true;

    function showTransitions(){
	var transitions = '<div align=center><<:transitions js:>></div>';
	
	return showCenteredWindow(transitions, 'Link state changes');
    }
</script>

<form name=form1 action=/status/index.jsp method=post>
<table border=0 cellspacing=0 cellpadding=0 width=800>
<tr>
<td align=center>
<table  width="790" cellspacing="0" cellpadding="0" border="0" class="text">
	<tr>
		<td>
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr>
					<td width="90" class="hist_menu"><span onclick="switchDiv('div_series', true, 0.3);"><a accesskey="s" onclick="switchDiv('div_series', true, 0.3);" href="javascript:void(0);" class="menu_link"><b><u>S</u>eries</b> <img id="div_series_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span></td>
					<script type="text/javascript">
					    if (dAltHidden)
						document.write('<td width="130" class="hist_menu"><span onclick="switchDiv(\'div_alternatives\', true, 0.3);"><a accesskey="a" onclick="switchDiv(\'div_alternatives\', true, 0.3);" href="javascript:void(0);" class="menu_link"><b><u>A</u>lternative Views</b> <img id="div_alternatives_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span></td>');
					</script>
					<td class="hist_menu" style="border-right: 0px;">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
    <tr>
	<td align=center style="border-bottom: solid 1px #B5B5BD; padding-bottom: 5px; font-family: Verdana, Arial" bgcolor="#F0F0F0">
		<table width=100% cellspacing="0" cellpadding="0" border=0>
		    <tr>
			<td><div id="div_alternatives" style="display: none; padding: 0"></div>
			    <script type="text/javascript">
				if (dAltHidden)
				    objById('div_alternatives').innerHTML = dAltHidden.innerHTML;
			    </script>
			</td>
		    </tr>
		    <tr>
			<td>
			    <div id="div_series" style="display: none"><div>
				<table border=0 cellspacing=0 cellpadding=3 width=100% style="border-bottom: 2px solid #FFFFFF;">
				    <tr>
					<td align=right style="padding:0px">
					    (<a class="link" href="JavaScript:checkall();" class="link">check all</a> | <a class="link" href="JavaScript:uncheckall();" class="link">uncheck all</a>)
					</td>
				    </tr>
				    <tr>
					<td align=left class="text">
    					    <<:continut:>>
					</td>
				    </tr>
		    		</table>
			    </div></div>
			</td>
		    </tr>

	                        <tr>
	                                                    <td nowrap  valign=bottom>
	<table border=0 cellspacing=0 cellpadding=3 width=100% class=text></tr><td>
	<!-- INTERVAL SELECTION -->
			
	<b>Interval selection</b><br><select name="quick_interval" onChange="javascript:quick_jump();" class="input_select">
	    <option value="-1">- choose -</option>
	    <option value="86400000">last day</option>
	    <option value="604800000">last week</option>
	    <option value="2628000000">last month</option>1;3B
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
	
	<td align=left>
	    <b>Image width</b><br>
	    <select name="imgsize" onChange="submit();" class=input_select>
		<option value="800" <<:imgsize_800:>>>800</option>
		<option value="1000" <<:imgsize_1000:>>>1000</option>
		<option value="1200" <<:imgsize_1200:>>>1200</option>
	    </select>
	</td>
	
	<td align=left>
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
	<!--
	<td align=left>
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
	-->
	<td align=right valign=bottom>
	    <input type="submit" name="submitbutton" value="Plot" class="input_submit" style="font-weight:bold">
	</td>
    </tr>
    </table></td></tr>
    </table></td></tr>
    <!--
    <tr>
	<td align=left>
	    <a href="javascript:void(0);" onClick="return openAnnotations();" class="link" accesskey="n">A<u>n</u>notations</a>
	</td>
	<td align=right colspan=4>
	    <a href="javascript:void(0);" onClick="return showTransitions();" class="link" accesskey="s">Link <u>s</u>tate changes</a>
	</td>
    </tr>
    -->
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
    <td bgcolor=#FFFFFF align=center>
	<table border=0 cellspacing=0 cellpadding=0 style="font-family:Helvetica;font-size:12px">
	    <tr>
		<td align=left style="padding-left:30px;padding-right:20px"><b>Color map</b> </td>
		<td style="width:15px;border:solid 1px #CACACA" bgcolor=red>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 0 &rarr; 80%</td>
		
		<td style="width:15px;border:solid 1px #CACACA" bgcolor=orange>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 80 &rarr; 90%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=yellow>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 90 &rarr; 95%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#9EE600>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 95 &rarr; 98%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#00FF00>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 98 &rarr; 100%</td>

		<td style="width:15px;border:solid 1px #CACACA" bgcolor=#26bd26>&nbsp;</td>
		<td align=left style="padding-right:30px;padding-left:5px"> 100%</td>
	    </tr>
	</table>
    </td>
</tr>
<tr>
    <td align=left>
	<span onclick="switchDiv('div_stats', true, 0.3);"><a accesskey="t" onclick="switchDiv('div_stats', true, 0.3);" href="javascript:void(0);" class="menu_link"><b>S<u>t</u>atistics</b> <img id="div_stats_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span></td>
    </td>
</tr>
<tr>
    <td align=center style="padding-top:20px">
    	<div id="div_stats" style="display: none"><div>
	<table border=0 cellspacing=0 cellpadding=0 class="table_content" width=800>
	    <tr height=25>
		<td class="table_title"><b>Statistics</b></td>
	    </tr>
	    <tr>
		<td>
		    <table border=0 cellspacing=1 cellpadding=2>
			<tr>
			    <td align=left nowrap width=20% class="table_header" rowspan=2 colspan=2><b>Link name</b></td>
			    <td align=left nowrap width=20% class="table_header" colspan=2><b>Data</b></td>
			    <td align=left nowrap width=20% class="table_header" colspan=3><b>Individual tests</b></td>
			    <td align=left nowrap width=20% class="table_header"><b>Overall</b></td>
			</tr>
			<tr>
			    <td align=left nowrap width=20% class="table_header">Starts</td>
			    <td align=left nowrap width=20% class="table_header">Ends</td>
			    <td align=left nowrap width=20% class="table_header">Successful</td>
			    <td align=left nowrap width=20% class="table_header">Failed</td>
			    <td align=left nowrap width=20% class="table_header">Success ratio</td>
			    <td align=left nowrap width=20% class="table_header">Availability</td>
			</tr>
			<<:statistics:>>
		    </table>
		</td>
	    </tr>
	</table>
	</div></div>
    </td>
</tr>
</table>

</form>
<script type="text/javascript">
    checkDivs(['div_alternatives', 'div_series', 'div_stats']);
</script>
