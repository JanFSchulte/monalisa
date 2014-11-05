<script type="text/javascript">
    function hide(id){
	setDiv(id, 'none');
    }
    
    function show(id){
	setDiv(id, 'inline');
    }
    
    function setDiv(id, t){
	try{
	    document.getElementById(id).style.display = t;
	}
	catch (e){
	    alert(e);
	}
    }

    function showChart(){
	hide('contents_as_table');
	show('contents_as_chart');
    }

    function showTable(){
	hide('contents_as_chart');
	show('contents_as_table');
    }
</script>

<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td align=left>
	    Welcome <span onMouseOver="overlibIframe('jquota.jsp', CAPTION, 'Jobs quota', WIDTH, 680);" onMouseOut="nd()"><b><<:username:>></b></span>,
	</td>
    </tr>
    <tr height=25>
	<td class="table_title"><b>Jobs management</b> : 
	    <a class="link_header" style="text-decoration:none" href="jobs.jsp">my own jobs</a> | <a class="link_header" style="text-decoration:none" href="jobs.jsp?j=1">all my roles</a> | <a class="link_header" style="text-decoration:none" href="jobs.jsp?j=2">all jobs</a>
	</td>
    </tr>
    <tr height=25>
	<td align=right>
	    Show as <a class=link href="javascript:showChart()">chart</a> or <a class=link href="javascript:showTable()">table</a>.
	</td>
    </tr>
    <tr>
	<td>
	    <div id="contents_as_table" style="display:<<:table_display esc:>>">

	    <table cellspacing=1 cellpadding=2 class=sortable>
		<thead>
		<tr class="table_header" style="border-top: 0px">
		    <td nowrap class="table_header" align=center colspan=5>Status</td>
		    <td nowrap class="table_header" align=center colspan=5>Active jobs</td>
		    <td nowrap class="table_header" align=center colspan=9>Error states</td>
		</tr>
		<tr class="table_header" style="border-top: 0px">
		    <td nowrap class="table_header" align=center style="border-top: 0px">PID</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Command</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Owner</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">State</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Total</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Done</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Running</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Waiting</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Started</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Saving</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Validation</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Execution</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">InputBox</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Inserting</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Saving</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">V.script</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">VT</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Expired</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Zombie</td>
		</tr>
		</thead>
		<tbody>
		<<:content:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class=table_header align=left colspan=3>TOTAL: <<:count:>> jobs</td>
		    <td class=table_header align=left></td>
	    	    <td class=table_header align=right><font color=navy><<:total_count esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:DONE js:>> done jobs');" onMouseOut="nd()" class=table_header align=right><font color=green><<:DONE esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:RUNNING js:>> running jobs');" onMouseOut="nd()" class=table_header align=right><font color=blue><<:RUNNING esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:WAITING js:>> waiting jobs');" onMouseOut="nd()" class=table_header align=right><font color=magenta><<:WAITING esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:STARTED js:>> just started jobs');" onMouseOut="nd()" class=table_header align=right><font color=orange><<:STARTED esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:SAVING js:>> currently saving jobs');" onMouseOut="nd()" class=table_header align=right><font color=darkgreen><<:SAVING esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_V js:>> validation error jobs');" onMouseOut="nd()" class=table_header align=right><font color=red><<:ERROR_V esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_E js:>> execution error jobs');" onMouseOut="nd()" class=table_header align=right><font color=orangered><<:ERROR_E esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_IB js:>> input box error jobs');" onMouseOut="nd()" class=table_header align=right><font color=red><<:ERROR_IB esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_I js:>> inserting error jobs');" onMouseOut="nd()" class=table_header align=right><font color=orangered><<:ERROR_I esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_SV js:>> saving error jobs');" onMouseOut="nd()" class=table_header align=right><font color=red><<:ERROR_SV esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_VN js:>> validation script error jobs');" onMouseOut="nd()" class=table_header align=right><font color=orangered><<:ERROR_VN esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ERROR_VT js:>> VT error jobs');" onMouseOut="nd()" class=table_header align=right><font color=red><<:ERROR_VT esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:EXPIRED js:>> expired jobs');" onMouseOut="nd()" class=table_header align=right><font color=orangered><<:EXPIRED esc:>></font></td>
	    	    <td onMouseOver="overlib('<<:ZOMBIE js:>> zombie jobs');" onMouseOut="nd()" class=table_header align=right><font color=red><<:ZOMBIE esc:>></font></td>
		</tr>
		</tfoot>
	    </table>
	    
	    </div>
	    
	    <div id="contents_as_chart" style="display:<<:chart_display esc:>>">
		<<:map:>><img src="/display?image=<<:image:>>" usemap="#<<:image:>>" border=0>
	    </div>
	</td>
    </tr>
</table>
