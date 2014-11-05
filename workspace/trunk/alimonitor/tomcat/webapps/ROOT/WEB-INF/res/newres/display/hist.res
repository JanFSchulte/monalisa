<form action="display" method="post" name="form1">
    <input type=hidden name="page" value="<<:page:>>">
    <<:extra_fields:>>
    <table border=0 cellspacing=0 cellpadding=2 width=800 bgcolor="#778899">
	<tr>
	    <td>
		<table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:10px">
		    <tr>
			<td>
			    <table border=0 cellspacing=0 cellpadding=0 width=100%  style="font-family:Helvetica;font-size:10px">
				<tr>
				    <td><b>Sites : </b></td>
				    <td align=right>(<a href="JavaScript:checkall();"><b>check all</b></a> | <a href="JavaScript:uncheckall();"><b>uncheck all</b></a>)</td>
				</tr>
			    </table>
			</td>
		    </tr>
		    <tr>
		        <td width=100%>
			    <<:continut:>>
			    <<:com_separate_start:>><hr size=1 noshade><<:separate:>><<:com_separate_end:>>
			    <hr size=1 noshade>
		        </td>
		    </tr>
		    <tr>
			<td width=100%><table width=100% border=0 cellspacing=0 cellpadding=0  style="font-family:Helvetica;font-size:10px"><tr><td nowrap>

				<!-- INTERVAL SELECTION -->
				
	Interval selection:
	<select name="quick_interval" onChange="javascript:quick_jump();" style="font-family:Helvetica;font-size:10px">
	    <option value="-1">- choose -</option>
	    <option value="3600000">last hour</option>
	    <option value="86400000">last day</option>
	    <option value="604800000">last week</option>
	    <option value="2678400000">last month</option>
	    <option value="31536000000">last year</option>
	</select>
	
	</td>
	<td width=30 align=center nowrap valign=bottom>or</td>
	<td align=left width=100% nowrap valign=bottom>

	<a href="javascript:move_back();" onmouseover="return overlib('Previous interval');" onmouseout="return nd();"><font style="font-family:Arial;font-size:14px;font-weight:bold">&laquo;</font></a>
	&nbsp;
	
	<a href="javascript:cal1.popup();" onmouseover="return overlib('Select start date');" onmouseout="return nd();"><img src="img/cal.gif" border=0></a>
	<input type="text" name="interval_date_low"  size=10 readonly onChange="javascript:recalc();" style="font-family:Helvetica;font-size:10px">
	<select name="interval_hour_low" onChange="javascript:recalc();" style="font-family:Helvetica;font-size:10px"></select>
	&nbsp;&nbsp;-&nbsp;&nbsp;
	<a href="javascript:cal2.popup();" onmouseover="return overlib('Select end date');" onmouseout="return nd();"><img src="img/cal.gif" border=0></a>
	<input type="text" name="interval_date_high" size=10 readonly onChange="javascript:recalc();" style="font-family:Helvetica;font-size:10px">
	<select name="interval_hour_high" onChange="javascript:recalc();" style="font-family:Helvetica;font-size:10px"></select>
	
	<input type=hidden name="interval.min" value="<<:interval.min:>>">
	<input type=hidden name="interval.max" value="<<:interval.max:>>">

	<script language="JavaScript">
	    <!--
	    var now = new Date("<<:current_date_time:>>");
	    -->
	</script>
	<script language="JavaScript" src="/js/date_time.js">
	</script>
	&nbsp;
	<a href="javascript:move_next();" onmouseover="return overlib('Next interval');" onmouseout="return nd();"><font style="font-family:Arial;font-size:14px;font-weight:bold">&raquo;</font></a>
	
				
				<!-- /INTERVAL SELECTION -->


			</td>
			<td align=right>
			    <input type=submit name="submit_plot" value="Plot"  style="font-family:Helvetica;font-size:10px;font-weight:bold">
			</td>
			</tr></table>
			</td>
		    </tr>
		    <tr><td><table border=0 cellspacing=0 cellpadding=0  style="font-family:Helvetica;font-size:10px" width=100%>
			<<:com_log_start:>>
			<td align=left nowrap valign=absmiddle style="font-family:Helvetica;font-size:10px">Logarithmic scale
				<select name="log" onChange="JavaScript:modify();"  style="font-family:Helvetica;font-size:10px">
				    <option value="0" <<:log_0:>>>disabled</option>
				    <option value="1" <<:log_1:>>>enabled</option>
				</select>
			</td>
			<<:com_log_end:>>
			<<:com_err_start:>>
			<td align=left nowrap valign=absmiddle style="font-family:Helvetica;font-size:10px">Fluctuations
				<select name="err" onChange="JavaScript:modify();" style="font-family:Helvetica;font-size:10px">
				    <option value="0" <<:err_0:>>>disabled</option>
				    <option value="1" <<:err_1:>>>enabled</option>
				</select>
			</td>
			<<:com_err_end:>>
			<<:com_sum_start:>>
			<td align=left nowrap valign=absmiddle style="font-family:Helvetica;font-size:10px">Sum series
			    <select name="sum" onChange="JavaScript:modify();" style="font-family:Helvetica;font-size:10px">
				<option value="0" <<:sum_0:>>>disabled</option>
				<option value="1" <<:sum_1:>>>enabled</option>
			    </select>
			</td>
			<<:com_sum_end:>>
			<<:com_int_start:>>
			<td align=left nowrap valign=absmiddle style="font-family:Helvetica;font-size:10px">Integral series
			    <select name="int" onChange="JavaScript:modify();" style="font-family:Helvetica;font-size:10px">
				<option value="0" <<:int_0:>>>disabled</option>
				<option value="1" <<:int_1:>>>enabled</option>
			    </select>
			</td>
			<<:com_int_end:>>
			
			<<:options:>>
			</tr>
			</table></td>

		    </tr>
		</table>
	    </td>
	</tr>
    </table>
    
    <<:extra:>>
</form>
<script language=JavaScript>
    function updateQuickInt(){
        intmin = document.getElementById('intmin');
	intmax = document.getElementById('intmax');
		    
	qint   = document.getElementById('quickint');
			    
	if (intmax.selectedIndex == intmax.length - 1){
	    value = intmin.length - 1 - intmin.selectedIndex;
	
	    switch (value){
	        case 1:         qint.selectedIndex=1; break;
	        case 24:        qint.selectedIndex=2; break;
	        case 168:       qint.selectedIndex=3; break;
	        case 720:       qint.selectedIndex=4; break;
	        case 2208:      qint.selectedIndex=5; break;
	        case 4416:      qint.selectedIndex=6; break;
	    }
	}
    }

    updateQuickInt();
</script>
																							
<table border=0 cellspacing=0 cellpadding=0>
    <tr>
        <td valign=top>
            <<:map:>><img src="display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
        </td>
        <td valign=top><<:description:>></td>
    </tr>
</table>				    

<br clear=all>
<br clear=all>
<table width=800 border=0 cellspacing=0 cellpadding=0>
    <tr>
	<td align=center>
<<:statistics:>>		
	</td>
    </tr>
</table>
