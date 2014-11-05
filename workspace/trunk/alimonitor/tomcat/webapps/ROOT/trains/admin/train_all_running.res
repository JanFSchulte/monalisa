<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/window/prototype.js"></script>
<script type="text/javascript" src="/js/window/effects.js"></script>

<script type=text/javascript>

function editRun(train_id, train_run_id){
    showIframeWindowSize('train_edit_run.jsp?train_id='+escape(train_id)+'&id='+escape(train_run_id), 'Editing run <b>'+train_run_id+'</b>', 950, 500);
}

</script>

</head>
<body>

Currently active trains:<br><br>
<table border=0 cellspacing=0 cellpadding=2 class=text>
	<tr class="table_header_stats">
	    <td class="table_header_stats">PWG</td>
	    <td class="table_header_stats">Train</td>
	    <td class="table_header_stats">Train ID</td>
	    <td class="table_header_stats">Type</td>
	    <td class="table_header_stats">Operator</td>
	    <td class="table_header_stats">Submitted on</td>
	    <td class="table_header_stats">Wagons</td>
	    <td class="table_header_stats">Output files</td>
	    <td class="table_header_stats">VMEM max</td>
	    <td class="table_header_stats">LPM</td>
	    <td class="table_header_stats">Submitted masterjobs</td>
	    <td class="table_header_stats">Job status</td>
	    <td class="table_header_stats">Merging status</td>
	    <td class="table_header_stats">Issues</td>
	</tr>
	<<:content:>>
	<tr class="table_header_stats">
	    <td class="table_header_stats" colspan=2><<:train_count:>> total trains</td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"><<:totaljob_stat:>></td>
	    <td class="table_header_stats"></td>
	    <td class="table_header_stats"></td>
	</tr>
    </table>
</table>

Copying failures:<br>
<<:copyingFailures:>>

</body>
</html>
