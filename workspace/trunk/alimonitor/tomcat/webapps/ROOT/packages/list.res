<form name=form1 action=list.jsp method=GET>
    <input type=hidden name=filter value="<<:filter:>>">
    <input type=hidden name=restrict value="<<:restrict:>>">
</form>

<script type="text/javascript">
    bDivFurat=true;
    
    function resetFilters(){
	document.form1.filter.value='';
	document.form1.restrict.value='0';
	document.form1.submit();
    }
    
    function doFilter(filter){
	document.form1.filter.value=filter;
	document.form1.submit();
    }
    
    function doRestrict(restrict){
	document.form1.restrict.value=restrict;
	document.form1.submit();
    }
</script>    

      <table cellspacing=0 cellpadding=2 class="table_content">
        <tr height=25>
            <td class="table_title"><b>Packages on sites</b></td>
        </tr>
        <tr>
    	    <td align=left class=text>
    		<a style="padding-right:20px" href="javascript:resetFilters()" class=link onMouseOver="overlib('Clear the filter set by clicking on one of the three header levels')" onMouseOut="nd()">Reset filters</a>
    		Show only : <a class=link href="javascript:doRestrict(1)"><<:com_restrict1_start:>><b><<:com_restrict1_end:>>globally defined packages<<:com_restrict1_start:>></b><<:com_restrict1_end:>></a> | 
    			    <a class=link href="javascript:doRestrict(2)"><<:com_restrict2_start:>><b><<:com_restrict2_end:>>removed packages<<:com_restrict2_start:>></b><<:com_restrict2_end:>></a>
    	    </td>
        </tr>
        <tr>
            <td>
                <table cellspacing=1 cellpadding=2 width="330">
            	    <tr height=25>
            		<td colspan=2 class="table_header">User</td>
            		<<:users:>>
            	    </tr>
            	    
            	    <tr height=25>
            		<td colspan=2 class="table_header">Package</td>
            		<<:packagenames:>>
            	    </tr>
                    <tr height=25>
			<td colspan=2 align=left nowrap class="table_header"><b>Version</b></td>
			<<:versions:>>
		    </tr>

		    <tr height=25>
			<td align=left nowrap class="table_header"><b>Sites</b></td>
			<td align=left nowrap class="table_header"><b>Count</b></td>
			<<:footer:>>
		    </tr>
		    
		    <<:content:>>
		    
		    <tr height=25>
			<td align=left nowrap class="table_header" colspan=2><b>TOTAL</b></td>
			<<:footer:>>
		    </tr>
		</table>
            </td>
        </tr>
	<tr>
	    <td align=right>
		Matrix updated once every hour
	    </td>
	</tr>
      </table>
