<form name=form1 action=raw_errors.jsp method=POST>
    <input type=hidden name=runfilter value="<<:run esc:>>">
    <input type=hidden name=return value="<<:return esc:>>">

<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>RAW run <a class=link href="https://alice-logbook.cern.ch/logbook/date_online.php?p_cont=rund&p_run=<<:run enc:>>"><b><<:run esc:>></b></a> / <<:partition esc:>> details</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr height=25>
		    <td class="table_header"><b>Timestamp</b></td>
		    <td class="table_header"><b>File name</b></td>
		    <td class="table_header"><b>Size</b></td>
		    <td class="table_header"><b>Events</b></td>
		    <td class="table_header"><b>ERROR_V</b></td>
		</tr>

		<tr height=25>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><input type=checkbox name=onlyerr <<:onlyerr check:>> onChange="document.form1.submit();" onMouseOver="overlib('Show only chunks with ERROR_V logs')" onMouseOut="nd()" value="1"></td>
		</tr>
		
		<<:content:>>
		
		<tr height=25>
		    <td class="table_header"><b>TOTAL</b></td>
		    <td class="table_header"><<:files:>> files</td>
		    <td class="table_header"><<:totalsize size:>></td>
		    <td class="table_header"><<:events dot:>></td>
		    <td class="table_header"><<:errorv_count:>></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=left>
	    <a href="<<:return esc:>>" class=link>&laquo; Back to RAW data production overview</a>
	</td>
    </tr>
</table>

</form>
