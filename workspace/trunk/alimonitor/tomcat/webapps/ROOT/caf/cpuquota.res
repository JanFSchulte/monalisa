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
</script>

<form name=form1 action=cpuquota.jsp method=get>
<table border=0 cellspacing=0 cellpadding=0 width=800>
<tr>
<td>
<table border=0 cellspacing=0 cellpadding=3 class=text width=100%>
    <tr>
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Cluster</b><br>
	    <select name="cluster" class="input_select" onChange="clusterChanged();">
		<<:opt_cluster:>>
	    </select>
	</td>
	<td align=left nowrap  class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Group</b><br>
	    <select name="group" class="input_select" onChange="groupChanged();">
		<option value="">- DISABLED -</option>
		<option value="*" <<:opt_group_all:>>>- ALL -</option>
		<<:opt_group:>>
	    </select>
	</td>
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>User</b><br>
	    <select name="user" class="input_select" onChange="userChanged();">
		<option value="">- DISABLED -</option>
		<option value="*" <<:opt_user_all:>>>- ALL -</option>
		<<:opt_user:>>
	    </select>
	</td>
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	    <b>Mode</b><br>
	    <select name="mode" class="input_select" onChange="submit();">
		<option value="history" <<:opt_mode_history:>>>history</option>
		<option value="pie" <<:opt_mode_pie:>>>pie chart</option>
	    </select>
	</td>
	
	<td align=left nowrap class="table_header" style="border-right: solid 1px #FFFFFF">
	
	<!-- INTERVAL SELECTION -->
			
	<b>Interval selection</b><br>
	<select name="quick_interval" onChange="javascript:quick_jump();" class="input_select">
	    <option value="-1">- choose -</option>
	    <option value="86400000">last day</option>
	    <option value="604800000">last week</option>
	    <option value="2628000000">last month</option>
	    <option value="5256000000">last 2 months</option>
	    <option value="7884000000">last 3 months</option>
	    <option value="15724800000">last 6 months</option>
	    <option value="31536000000">last year</option>
	    <option value="63072000000">last 2 years</option>
	    <option value="94608000000">last 3 years</option>
	    <option value="126144000000">last 4 years</option>
	    <option value="157680000000">last 5 years</option>
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
	<td rowspan=2 align=right width=100% valign=bottom class="table_header">
	    <input type="submit" name="submitbutton" value="Plot" class="input_submit" style="font-weight:bold">
	</td>
    </tr>
    <tr>
	<td align=center nowrap class="table_header" style="border-right: solid 1px #FFFFFF" colspan=5>
	    Params to display:
	    <input type=checkbox id=parameter_bytesread name=parameters <<:parameters_bytesread:>> value=bytesread>
	    <label for=parameter_bytesread>Bytes read</label>

	    <input type=checkbox id=parameter_count name=parameters <<:parameters_count:>> value=count>
	    <label for=parameter_count>No. of queries</label>

	    <input type=checkbox id=parameter_cputime name=parameters <<:parameters_cputime:>> value=cputime>
	    <label for=parameter_cputime>CPU time</label>

	    <input type=checkbox id=parameter_events name=parameters <<:parameters_events:>> value=events>
	    <label for=parameter_events>Events</label>

	    <input type=checkbox id=parameter_walltime name=parameters <<:parameters_walltime:>> value=walltime>
	    <label for=parameter_walltime>Wall time</label>

	    <!--
	    <input type=checkbox id=parameter_cpuquota name=parameters <<:parameters_cpuquota:>> value=cpuquota>
	    <label for=parameter_cpuquota>CPU quotas</label>
	    -->
	    
	    <select name=onlyactive class=input_select onChange="submit()">
		<option <<:onlyactive_true:>> value=t>active</option>
		<option <<:onlyactive_false:>> value=f>all</option>
	    </select>
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
</table>

</form>
