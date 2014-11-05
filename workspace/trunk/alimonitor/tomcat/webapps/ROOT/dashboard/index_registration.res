<script language=JavaScript>
    var regURL = '/display?img=true&width='+chartWidth+'&height='+chartHeight+'&interval.max=0&page=DAQ2%2Fdaq_image&interval.min='
    
    registerTab('reg', regURL);
</script>

<table width=100% class="table_content" style="border:0">
    <tr class="table_title" height=25>
        <td class="table_title"><b>RAW data registration</b></td>
    </tr>
    <tr>
	<td>
	    <table border=0 cellspacing=1 cellpadding=3 bgcolor=#A1A1A1 width=100% style="font-family:Verdana,Helvetica,Arial;font-size:10px;cursor:pointer">
    		<tr>
    		    <script type="text/javascript">
    			for (i=0; i<intervalNames.size(); i++){
			    document.write('<td id="tabreg'+i+'" align=center bgcolor=#E6E6FF onClick="changeTabs('+i+');">'+intervalNames[i]+'</td>');
			}
		    </script>
		</tr>
	    </table>
	    
	    <script type="text/javascript">
	        document.write('<img id="chartreg" width='+chartWidth+' height='+chartHeight+' src="'+regURL+intervalTimes[defaultTab]+'">');
	    </script>
	</td>
    </tr>
    <tr>
        <td align=right valign=bottom>
	    <a href="/display?page=DAQ2/daq_size" class="link" target="_blank">Full details &raquo;</a>
	</td>
    </tr>
</table>
