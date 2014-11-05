<script language=JavaScript>
    var ftdURL = '/display?annotation.enabled=false&img=true&width='+chartWidth+'&height='+chartHeight+'&interval.max=0&page=FTD%2FSE_img&interval.min=';
    
    registerTab('ftd', ftdURL);
</script>

<table width=100% class="table_content" style="border:0">
    <tr class="table_title" height=25>
        <td class="table_title"><b>Transfers to T1s</b></td>
    </tr>
    <tr>
	<td>
	    <table border=0 cellspacing=1 cellpadding=3 bgcolor=#A1A1A1 width=100% style="font-family:Verdana,Helvetica,Arial;font-size:10px;cursor:pointer">
    		<tr>
    		    <script type="text/javascript">
    			for (i=0; i<intervalNames.size(); i++){
			    document.write('<td id="tabftd'+i+'" align=center bgcolor=#E6E6FF onClick="changeTabs('+i+');">'+intervalNames[i]+'</td>');
			}
		    </script>
		</tr>
	    </table>
	    
	    <script type="text/javascript">
		document.write('<img id="chartftd" width='+chartWidth+' height='+chartHeight+' src="'+ftdURL+intervalTimes[defaultTab]+'">');
	    </script>
	</td>
    </tr>
    <tr>
        <td align=right valign=bottom>
	    <a href="/display?page=FTD/SE" class="link" target="_blank">Full details &raquo;</a>
	</td>
    </tr>
</table>
