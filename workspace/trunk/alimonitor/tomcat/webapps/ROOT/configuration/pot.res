<script type="text/javascript">
function showRuns(){
    showCenteredWindow('<<:runlist esc js:>>', 'Selected runs');
}
</script>

<form name="form1" action="pot.jsp" method=GET>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" width="100%">
    <tr>
	<td class="table_title"><b>Production Overview Table</b></td>
    </tr>
    <!--
    <tr>
	<td align=right>
	    <a href="javascript:void(0);" onClick="JavaScript:window.open('/doc/index.jsp?page=configuration_pot', 'docwindow', 'toolbar=0,width=600,height=400,scrollbars=1,resizable=1,titlebar=1'); return false;" class="link" style="cursor:help">Help on syntax</a>
	</td>
    </tr>
    -->
    <tr>
	<td valign="top">
	    <table border=0 cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<tr class="table_header">
		    <td class="table_header">
			<select name=partition class=input_select onChange='modify()'>
			    <<:opt_partitions:>>
			</select>
		    </td>
	            <td class="table_header" colspan=3>Run info</td>
	            <td class="table_header" colspan=2>Pass <<:pass:>></td>
	            <td class="table_header" colspan=2>CPass 0</td>
	            <td class="table_header" colspan=1>Pass <<:pass:>></td>
	            <td class="table_header" colspan=3>QA</td>
	            <td class="table_header" colspan=1>AliRoot</td>
	            <td class="table_header"><input type=submit name=s class=input_submit value="&raquo;"></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.raw_run.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=raw_run value="<<:raw_run esc:>>"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.total_events.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=total_events value="<<:total_events esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.event_count_physics.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=event_count_physics value="<<:event_count_physics esc:>>"></td>
		    
		    <td class="table_header" colspan=2>
			<select name=pass class=input_select onChange="modify();">
			    <option value=1 <<:pass_1:>>>Pass 1</option>
			    <option value=2 <<:pass_2:>>>Pass 2</option>
			</select>
		    </td>
		    
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    
		    <td class="table_header"></td>
		    
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    
		    <td class="table_header"></td>
		    
		    <td class="table_header"></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header">Run#</td>

	            <td class="table_header">Date</td>
	            <td class="table_header">#total ev.</td>
	            <td class="table_header">#total ph. ev.</td>
	            
	            <td class="table_header">#reconstructed ev.</td>
	            <td class="table_header">Fraction of ph. ev.</td>
	            
	            <td class="table_header">Success (%)</td>
	            <td class="table_header">Merging ok</td>
	            
	            <td class="table_header">Success (%)</td>
	            
	            <td class="table_header">Events</td>
	            <td class="table_header">Fraction of reco. ev.</td>
	            <td class="table_header">Merging stage</td>
	            
	            <td class="table_header">Revision</td>
	            <td class="table_header">Comment</td>
		</tr>
		</thead>
		
		<tbody>
		<<:content:>>
		</tbody>
		
		<tfoot>
                <tr class="table_header">
            	    <td class="table_header" style="text-align:left">In total: <a href="#" class=link_header style="text-decoration:none" onClick="showRuns();"><<:runcount:>> runs</a></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"><<:sum_total_events ddot:>></td>
        	    <td class="table_header" style="text-align:right"><<:sum_event_count_physics ddot:>></td>
        	    <td class="table_header" style="text-align:right"><<:sum_pass1_events ddot:>></td>
        	    <td class="table_header" style="text-align:right"><<:pass1_events_fraction:>></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"><<:sum_qa_events ddot:>></td>
        	    <td class="table_header" style="text-align:right"><<:qa_events_fraction:>></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"></td>
        	    <td class="table_header" style="text-align:right"></td>
                </tr>
		</tfoot>
		
	    </table>
	</td>
    </tr>
</table>
</form>
