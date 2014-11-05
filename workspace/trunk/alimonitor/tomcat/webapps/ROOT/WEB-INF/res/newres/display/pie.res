<form action="display" method="post" name="form1">
    <<:extra_fields:>>
    <table border=0 cellspacing=0 cellpadding=2 width=800 bgcolor="#778899">
	<tr>
	    <td>
		<table border=0 cellspacing=0 cellpadding=3 width=100% bgcolor="#eeeeee" style="font-family:Helvetica;font-size:10px">
		    <tr>
			<td align=left><b>Sites :</b></td>
		    </tr>
		    <tr>
		        <td align=left>
			    <<:continut:>>
			    <<:com_separate_start:>><hr size=1 noshade><<:separate:>><<:com_separate_end:>>
		        </td>
		    </tr>
		    <tr>
			<td align=left nowrap style="font-family:Helvetica;font-size:10px">
			    <table width=100% border=0 cellspacing=0 cellpadding=0 style="font-family:Helvetica;font-size:10px"><tr>
				<td>
				    (<a href="JavaScript:checkall();">check all</a> | <a href="JavaScript:uncheckall();">uncheck all</a>)
				</td>
				<td align=right>
				    <input type=submit name="submit_plot" value="Plot">
				</td>
				</tr>
			    </table>
			    <table width=100% border=0 cellspacing=0 cellpadding=0 style="font-family:Helvetica;font-size:10px"><tr>
				<<:com_history_start:>>
				
				<td align=left nowrap width=25%>
		    		    Data selection : 
		    		        <select name="pTime" onChange="JavaScript:modify();" style="font-family:Helvetica;font-size:10px">
					    <option value="now">Real-Time data</option>
					    <<:opt_ptime:>>
					</select>&nbsp;&nbsp;
				</td>
			
				<<:com_history_end:>>
				<<:com_interval_start:>>
				<td align=left nowrap>
		    		    Function : <select name="function" onChange="JavaScript:modify();" style="font-family:Helvetica;font-size:10px">
					<<:opt_f:>>
				    </select>
				</td>
				</tr>
				<tr>
				<td align=left nowrap>
								
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
	    var now = new Date("<<:current_date_time:>>");
	</script>
	<script language="JavaScript" src="/js/date_time.js">
	</script>
	&nbsp;
	<a href="javascript:move_next();" onmouseover="return overlib('Next interval');" onmouseout="return nd();"><font style="font-family:Arial;font-size:14px;font-weight:bold">&raquo;</font></a>
	
				</td>
				<<:com_interval_end:>>
				</tr>
			    </table>
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
		    </tr>
		</table>
	    </td>
	</tr>
    </table>
    <!-- parameters -->
    <<:parameters:>>
    <!-- extra -->
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
