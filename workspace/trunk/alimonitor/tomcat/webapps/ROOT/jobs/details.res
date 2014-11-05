<html>
<head>
<title>Details for master job ID <<:pid esc:>></title>

<script type="text/javascript" src="/overlib/overlib.js"></script>
<script type="text/javascript" src="/overlib/overlib_crossframe.js"></script>
<script type="text/javascript" src="/js/tooltips.js"></script>
<script src="/js/sorttable.js"></script>

<link type="text/css" rel="StyleSheet" href="/style/style.css" />

<style>
a:link,
a:active,
a:visited{
	color: #3A6C9A;
	text-decoration: none
}

a:hover{
	color: #3A6C9A;
	text-decoration: underline
}                                                
</style>
<<:com_refresh_start:>><meta http-equiv="refresh" content="30"><<:com_refresh_end:>>
</head>
<body style="font-family:Verdana,Helvetica,Times,Arial; font-size:10px">
    Masterjob <a target=_blank href="/jdl/<<:pid:>>.html"><<:pid esc:>></a> of <a target=_blank href="/users/jobs.jsp?user=<<:owner enc:>>"><<:owner esc:>></a>, status : <b><<:masterjob_status:>></b>	
    (
    <a href="details.jsp?pid=<<:pid:>>&details=<<:details:>>">refresh</a> 
    | <a target=_blank href='jdl.jsp?pid=<<:pid enc:>>'>JDL</a> 
    | <a target=_blank href='trace.jsp?pid=<<:pid enc:>>'>trace</a> 
    | <a href="details.jsp?pid=<<:pid:>>&details=<<:not_details:>>&input=<<:input:>>"><<:details_text:>> details</a> 
    | <a href="details.jsp?pid=<<:pid:>>&details=<<:details:>>&input=<<:not_input:>>"><<:input_text:>> input data</a>
    | <a target=_blank href='gantt.jsp?pid=<<:pid:>>'>Gantt</a>
    )
    <<:com_updateprocessing_start:>>
    <br>
    Processing pass <<:pass:>> of run <a onMouseOver='runDetails(<<:run esc js:>>)' onMouseOut='nd()' target=_blank href="/raw/raw_details.jsp?filter_runno=<<:run enc:>>"><<:run esc:>></a>
    <<:com_updateprocessing_end:>>
    <<:com_jobtype_start:>>
    <br><<:jobtype:>>
    <<:com_jobtype_end:>>
    <<:com_parent_start:>>
    <br><a target=_blank href="/runview/gantt.jsp?pid=<<:parentpid enc:>>&filter=false&run=<<:run enc:>>">Parent process</a>: <a href="details.jsp?pid=<<:parentpid enc:>>&input=<<:input:>>&details=<<:details:>>" title="<<:parentcomment esc:>>"><<:parentpid esc:>></a>
    <<:com_parent_end:>>
    <<:com_children_start:>>
    <br><a target=_blank href="/runview/gantt.jsp?pid=<<:pid enc:>>&filter=false&run=<<:run enc:>>">Child process<<:children_s:>></a>: <<:children:>>
    <<:com_children_end:>>
    <br>Subjobs: <<:subjobs:>>
    <dl>    
    <<:content:>>
    </dl>
    
    <<:com_summary_start:>>
    <br>
    <table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td align=center>
	    Summaries per site
	</td>
    </tr>
    <tr>
	<td>
    <table border=0 cellspacing=1 cellpadding=2 class=sortable>
	<thead>
	<tr class=table_header>
	    <th class=table_header_stats></th>
	    <th colspan=4 class=table_header_stats>Number of jobs</th>
	    <th colspan=3 class=table_header_stats>RSS</th>
	    <th colspan=3 class=table_header_stats>Virtual</th>
	    <th colspan=2 class=table_header_stats>Average time</th>
	    <th colspan=1 class=table_header_stats>CPU</th>
	    <<:com_input_data_start:>>
	    <th colspan=2 class=table_header_stats>Input Data</th>
	    <<:com_input_data_end:>>
	</tr>
	<tr class=table_header>
	    <th class=table_header_stats>Site</th>
	    <th class=table_header_stats><font color=blue>Running</font></th>
	    <th class=table_header_stats><font color=blue>Saving</font></th>
	    <th class=table_header_stats><font color=green>Done</th>
	    <th class=table_header_stats><font color=red>Error</th>
	    
	    <th class=table_header_stats>Min</th>
	    <th class=table_header_stats>Avg</th>
	    <th class=table_header_stats>Max</th>

	    <th class=table_header_stats>Min</th>
	    <th class=table_header_stats>Avg</th>
	    <th class=table_header_stats>Max</th>

	    <th class=table_header_stats>Running</th>
	    <th class=table_header_stats>Saving</th>
	    
	    <th class=table_header_stats>Efficiency</th>
	    
	    <<:com_input_data_start:>>
	    <th class=table_header_stats>Size</th>
	    <th class=table_header_stats>Rate</th>
	    <<:com_input_data_end:>>
	</tr>
	</thead>
	<tbody>
	<<:summary:>>
	</tbody>
	<tfoot>
	<tr class=table_header>
	    <th class=table_header_stats><<:summary_jobs:>> jobs on <<:summary_sites:>> sites</th>
	    <th class=table_header_stats align=right><font color=blue>&nbsp;<<:RUNNING:>></font></th>
	    <th class=table_header_stats align=right><font color=blue>&nbsp;<<:SAVING:>></font></th>
	    <th class=table_header_stats align=right><font color=green>&nbsp;<<:DONE:>></font></th>
	    <th class=table_header_stats align=right><font color=red>&nbsp;<<:ERROR:>></font></th>
	    
	    <th class=table_header_stats align=right><<:rss_min size:>></th>
	    <th class=table_header_stats align=right><<:rss_avg size:>></th>
	    <th class=table_header_stats align=right><<:rss_max size:>></th>
	    
	    <th class=table_header_stats align=right><<:vms_min size:>></th>
	    <th class=table_header_stats align=right><<:vms_avg size:>></th>
	    <th class=table_header_stats align=right><<:vms_max size:>></th>

	    <th class=table_header_stats align=right><<:avg_running intervalms:>></th>
	    <th class=table_header_stats align=right><<:avg_saving intervalms:>></th>
	    
	    <th class=table_header_stats align=right><<:cpu_efficiency:>></th>
	    
	    <<:com_input_data_start:>>
	    <th class="table_header_stats" align=right><<:inputDataSize:>></th>
	    <th class="table_header_stats" align=right><<:inputDataRate:>></th>
	    <<:com_input_data_end:>>
	</tr>
	</tfoot>
    </table>
	</td>
    </tr></table>
    <<:com_summary_end:>>
<script type="text/javascript">
    if (self.document.location.hash && self.document.location.hash.length>0){
	var obj = document.getElementById(self.document.location.hash.substring(1));
	
	if (obj){
	    obj.style.color='red';
	    obj.style.fontWeight = 'bold';
	}
    }
</script>
</body>

</html>
