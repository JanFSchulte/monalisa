<script type="text/javascript" src="/js/window/prototype.js"> </script>
<script type="text/javascript" src="/js/window/window.js"> </script> 
<script type="text/javascript" src="/js/window/windowutils.js"> </script> 
<!-- Add this to have a specific theme--> 
<link href="/js/window/default.css" rel="stylesheet" type="text/css"></link>
<link href="/js/window/mac_os_x.css" rel="stylesheet" type="text/css"></link>

<script type="text/javascript">
    function stop(site){
	if (confirm('Are you sure you want to stop dPROOF@'+site+'?')){
	    showCenteredWindow('<iframe src=\'/dproof/admin/control.jsp?stop='+site+'\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>');
	}
    }
    
    function restart(site){
	if (confirm('Are you sure you want to restart dPROOF@'+site+'?')){
	    showCenteredWindow('<iframe src=\'/dproof/admin/control.jsp?restart='+site+'\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>');
	}
    }
</script>

<div align=left>
<table border=0 cellspacing=0 cellpadding=0><tr><td>

<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title"><b>dPROOF clusters</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header">VoBox hostname</td>
		    <td class="table_header">Workers</td>
		    <td class="table_header">xrootd port</td>
		    <td class="table_header">xproofd port</td>
		    <td class="table_header">ProofAgent port</td>
		    <td class="table_header">Options</td>
		</tr>
		<<:content:>>
		<tr height=25>
		    <td class="table_header">TOTALS</td>
		    <td class="table_header"><<:total_workers:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
    </tr>
</table>
</td></tr>
</table>
</div>
