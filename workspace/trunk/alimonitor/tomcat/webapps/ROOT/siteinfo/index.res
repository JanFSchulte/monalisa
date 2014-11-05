<script type="text/javascript" src="/js/htmlsuite/rounded-corners.js"></script>

<div id="siteselection" align="center" style="font-family:Verdana,Helvetica,Arial,sans-serif;font-size:12px;color:#FFFFFF;font-weight:bold;width:300px;height:50px;padding-bottom:25px">
    <p class="text">
	<form name="form1" action="index.jsp" method="POST">
	    Select site:
	    <select name="site" class="input_select" onChange="document.form1.submit();">
		<<:opt_sites:>>
	    </select>
	    <input type="submit" name="s" value="&raquo;" class="input_submit">
	</form>
    </p>
</div>

<script type="text/javascript">
    function showMessage(msg, title, tooltip){
	if (msg && msg.length>0){
	    if (tooltip)
		overlib(msg, CAPTION, title);
	    else{
		nd(); showCenteredWindow('<div align=left>'+msg+'</div>', title);
	    }
	}
	
	return false;
    }
    
    function showURL(url, title){
	if (url && url.length>0){
	    nd();
	    showCenteredWindowSize('<iframe src="'+url+'" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="no" align="absmiddle" vspace="0" hspace="0"></iframe>', title, 500, 400);
	}
	    
	return false;
    }
    
    function samMsg(msg){
	return showURL(msg, 'SAM test details');
    }
    
    function openURL(url, title){
	nd();
    
	showCenteredWindowSize('<iframe src="'+url+'" border=0 width=100% height=100% frameborder="0" marginwidth="0" marginheight="0" scrolling="no" align="absmiddle" vspace="0" hspace="0"></iframe>', title, 500, 400);
    
	return false;
    }
    
    function ntpSync(ok){
	if (ok) overlib('MonALISA service was able to contact external NTP servers');
	else overlib('MonALISA service was not able to contact external NTP servers.<br>This is not a problem by itself, but please check if the machine\'s time is in sync.');
	
	return false;
    }
    
    function ntpOffset(ok){
	if (!ok) overlib('Time on this machine is out of sync! Please consider using NTP!');
    }
</script>

<table border=0 cellspacing=0 cellpadding=0><tr><td>
<div id="contentwrapper" align=center" style="padding-bottom:30px">
    <div id="content" align="left">
	<table border=0 cellspacing=0 cellpadding=2 class="text" style="color:#000000">
	    <tr>
		<td align="left" valign="top"><a target=_blank class=link href="/stats?page=siteMLstatus"><b>MonALISA information</b></a></td>
		<td align="left" valign="top" colspan=3>
		    Version: <<:version db esc:>> (JDK <<:java_ver db esc:>>)<br>
		    Running on: <span onMouseOver="overlib('<<:ip db js:>>');" onMouseOut="nd();"><<:address esc:>></span><br>
		    Administrator: <<:contact_name db esc:>> &lt;<a href='mailto:<<:contact_email db esc:>>' class="link"><<:contact_email db esc:>></a>&gt;
		</td>
		<td align="left" valign="top" style="padding-left: 20px"><b>Service health</b></td>
		<td align="left" valign="top">
		    NTP: <span onMouseOver="ntpSync(<<:ntp_sync:>>);" onMouseOut="nd();"><<:ntp_status:>></a></span>, offset: <span onMouseOver="ntpOffset(<<:ntp_offset_ok:>>);" onMouseOut="nd();"><<:ntp_offset_font:>><<:ntp_offset:>></span>
		</td>
	    </tr>
	    <tr>
		<td colspan=6><hr size=1></td>
	    </tr>
	    <tr>
		<td align="left" valign="top"><a target=_blank class=link href="/stats?page=services_status"><b>Services status</b></a><br>AliEn: <<:alien_version:>></td>
		<td align="left" valign="top">
		    ClusterMonitor: <span onMouseOver="showMessage('<<:Monitor_message esc js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:Monitor_message esc ntobr js:>>', 'ClusterMonitor test details', false);"><<:Monitor_status:>></span><br>
		    PackMan: <span onMouseOver="showMessage('<<:PackMan_message esc js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:PackMan_message esc js:>>', 'PackMan test details', false);"><<:PackMan_status:>></span><br>
		    CE: <span onMouseOver="showMessage('<<:CE_message esc js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:CE_message esc js:>>', 'CE test details', false);"><<:CE_status:>></span><br>
		    CE info: <span onMouseOver="showMessage('<<:CE_info esc js:>>', 'Message at <<:CE_info_time time:>>', true);" onMouseOut='return nd();' onClick="return showMessage('<<:CE_info js:>>', 'CE info details at <<:CE_info_time time:>>', false);"><<:CE_info cut30:>></span><br>
		    Max running jobs: <<:CE_maxjobs:>><br>
		    Max queued jobs: <<:CE_maxqueuedjobs:>><br>
		</td>
		<td align="left" valign="top" style="padding-left: 20px"><a target=_blank class=link href="/stats?page=proxies"><b>Proxies status</b></a></td>
		<td align="left" valign="top">
		    AliEn proxy: <span onMouseOver="showMessage('<<:alien_proxy_message js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:alien_proxy_message js:>>', 'AliEn Proxy details', false);"><<:alien_proxy_status:>></span> (<<:alien_proxy_timeleft:>>)<br>
		    Delegated proxy: <span onMouseOver="showMessage('<<:Delegated_proxy_message js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:Delegated_proxy_message js:>>', 'LCG Delegated proxy details', false);"><<:Delegated_proxy_status:>></span> (<<:Delegated_proxy_timeleft:>>)<br>
		    Proxy server: <span onMouseOver="showMessage('<<:Proxy_Server_message js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:Proxy_Server_message js:>>', 'LCG Proxy server details', false);"><<:Proxy_Server_status:>></span> (<<:Proxy_Server_timeleft:>>)<br>
		    Proxy of the machine: <span onMouseOver="showMessage('<<:Proxy_of_the_machine_message js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:Proxy_of_the_machine_message js:>>', 'LCG Proxy of the machine details', false);"><<:Proxy_of_the_machine_status:>></span> (<<:Proxy_of_the_machine_timeleft:>>)<br>
		    <!--FTD proxy: <span onMouseOver="showMessage('<<:FTS_Proxy_message js:>>', 'Click for details', true);" onMouseOut='return nd();' onClick="return showMessage('<<:FTS_Proxy_message js:>>', 'LCG FTD proxy details', false);"><<:FTS_Proxy_status:>></span> (<<:FTS_Proxy_timeleft:>>)<br>-->
		</td>
		<!--
		<td align="left" valign="top" style="padding-left: 20px"><a target=_blank class=link href="/sam/sam.jsp"><b>SAM tests</b></a></td>
		<td align="left" valign="top">
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=DPD_OK', 'Delegated proxy duration: <<:DPD_status js:>>');" href="javascript:void(0);" class="link">Delegated proxy duration: <<:DPD_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=PM_OK', 'Proxy of the machine: <<:PM_status js:>>');" href="javascript:void(0);" class="link">Proxy of the machine: <<:PM_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=PR_OK', 'Proxy renewal: <<:PR_status js:>>');" href="javascript:void(0);" class="link">Proxy renewal: <<:PR_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=PSR_OK', 'Proxy server registration: <<:PSR_status js:>>');" href="javascript:void(0);" class="link">Proxy server registration: <<:PSR_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=RB_OK', 'RB status: <<:RB_status js:>>');" href="javascript:void(0);" class="link">RB status: <<:RBS_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=SA_OK', 'Software area: <<:SA_status js:>>');" href="javascript:void(0);" class="link">Software area: <<:SA_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=UPR_OK', 'User proxy registration: <<:UPR_status js:>>');" href="javascript:void(0);" class="link">User proxy registration: <<:UPR_status:>></a><br>
		    <a onClick="return openURL('/sam/samchart.jsp?site=<<:site enc:>>&test=WMS_OK', 'WMS stats: <<:WMS_status js:>>');" href="javascript:void(0);" class="link">WMS stats: <<:WMS_status:>></a>
		</td>
		-->
	    </tr>
	    <!--
	    <tr>
		<td colspan=6 align=right><input type=button class="input_submit" style="color:green;font-weight:bold" value="Make everything OK" onClick="alert('Sorry, for miracles try the second floor!');"></td>
	    </tr>
	    -->
	    <tr>
		<td colspan=6><hr size=1></td>
	    </tr>
	    <tr>
		<td align="left" valign="top"><b>Current jobs status</b></td>
		<td align="left" valign="top">
		    Assigned: <<:ASSIGNED_jobs:>><br>
		    <a href="/display?page=jobStatusSites_RUNNING&plot_series=<<:site enc:>>" class="link" target="_blank">Running: <<:RUNNING_jobs:>></a><br>
		    Saving: <<:SAVING_jobs:>>
		</td>
		<td align="left" valign="top" style="padding-left: 20px"><b>Accounting</b><br>(last 24h)</b></td>
		<td align="left" valign="top">
		    <a href="/display?SiteBase=<<:site enc:>>&interval.max=0&interval.min=86400000&page=jobs_per_site_done" class="link" target="_blank">Success jobs: <<:DONE_jobs:>></a> 
			(<a target=_blank class=link href="/Correlations?SITE=<<:site enc:>>&page=timings%2Fpersite&interval.max=0&interval.min=86400000">profile</a>)<br>
		    Failed jobs: <<:FAILED_jobs:>><br>
		    <a href="javascript:void(0);" onClick="return showURL('errors.jsp?site=<<:site enc:>>', 'Detailed error states, last 24 hours @ <<:site js:>>');" class="link">Error jobs: <<:ERR_jobs:>></a><br>
		    <a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=jobResUsageSum_time_run_si2k&plot_series=<<:site enc:>>">kSI2k units: <<:si2k_consumed:>></a> / <a target=_blank href="/pledged_future.jsp" class="link"><<:ksi2k db:>> pledged</a>
		</td>
		<td align="left" valign="top" style="padding-left: 20px"><b>Site averages</b><br>(last 24h)</b></td>
		<td align="left" valign="top">
		    Active nodes: <<:avg_count:>><br>
		    Average kSI2k/node: <<:avg_ksi2k_factor:>>
		</td>
	    </tr>
	    <tr>
		<td colspan=6><hr size=1></td>
	    </tr>
	    <tr>
		<td align="left" valign="top"><a target=_blank class=link href="/stats?page=SE/table"><b>Storages status</b></a></td>
		<td align="left" valign="top" colspan=5>
		    <table border=0 cellspacing=1 cellpadding=2 class="table_content" style="border: 0px;width:100%">
			<tr>
			    <td class="table_header" align=center><b>Name</b></td>
			    <td class="table_header" align=center><b>Status</b></td>
			    <td class="table_header" align=center><b>Size</b></td>
			    <td class="table_header" align=center><b>Used</b></td>
			    <td class="table_header" align=center><b>Free</b></td>
			    <td class="table_header" align=center><b>Usage</b></td>
			    <td class="table_header" align=center><b>No of files</b></td>
			    <td class="table_header" align=center><b>Type</b></td>
			    <td class="table_header" align=center><b>ADD test</b></td>
			</tr>
			<<:selist:>>
		    </table>
		</td>
	    </tr>
	    <tr>
		<td colspan=6><hr size=1></td>
	    </tr>
	    <tr>
		<td align="left" valign="top" rowspan="2"><a target=_blank class=link href="/stats?page=vobox_status"><b>VoBox health</b></a></td>
		<td align="left" valign="top">
		    CPUs: <<:no_CPUs:>>x <<:cpu_MHz:>>MHz<br>
		    <a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=siteVoBoxHist_mem_usage&plot_series=<<:site enc:>>">Mem usage: <<:mem_usage:>>% of <<:total_mem:>></a><br>
		    <a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=siteVoBoxHist_processes&plot_series=<<:site enc:>>">Processes: <<:processes:>></a><br>
		    <a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=siteVoBoxHist_sockets_tcp&plot_series=<<:site enc:>>">Sockets: <<:sockets_tcp:>> TCP</a> / <<:sockets_udp:>> UDP<br>
		    Uptime: <<:uptime:>>
		</td>
		<td align="left" valign="top" style="padding-left: 20px"><a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=siteVoBoxHist_cpu_usage&plot_series=<<:site enc:>>"><b>CPU usage</b></a><br>(last 1h avg)</td>
		<td align="left" valign="top">
		    <a target=_blank class="link" href="/display?interval.max=0&interval.min=86400000&page=siteVoBoxHist_load5&plot_series=<<:site enc:>>"><i>Load: <<:avg_load1:>></i></a><br>
		    User: <<:avg_CPU_usr:>>%<br>
		    System: <<:avg_CPU_sys:>>%<br>
		    IOWait: <<:avg_CPU_iowait:>>%<br>
		    Idle: <<:avg_CPU_idle:>>%
		</td>
		<td align="left" valign="top">
		    <br clear=all>
		    Int: <<:avg_CPU_int:>>%<br>
		    Soft int: <<:avg_CPU_softint:>>%<br>
		    Nice: <<:avg_CPU_nice:>>%<br>
		    Steal: <<:avg_CPU_steal:>>%
		</td>
	    </tr>
	    <tr>
		<td colspan=5 style="padding-top:10px">
		    <table border=0 cellspacing=1 cellpadding=2 class="table_content" style="width:100%;border:0px"">
			<tr>
			    <td class="table_header" align=center><b>AliEn LDAP var</b></td>
			    <td class="table_header" align=center><b>VoBox path</b>
			    <td class="table_header" align=center><b>Size</b>
			    <td class="table_header" align=center><b>Used</b>
			    <td class="table_header" align=center><b>Free</b>
			    <td class="table_header" align=center><b>Use%</b>
			</tr>
			<<:path_status:>>
		    </table>
		</td>
	    </tr>
	</table>
    </div>
</div>
</td></tr></table>

<script type="text/javascript">
    //color = '#7190E0';
    color = '#F0F5FF';

    rC = new DHTMLgoodies_roundedCorners();

    rC.addTarget('siteselection',15,15,'#9FBCD1','#FFFFFF',0,'40');
    
    rC.addTarget('contentwrapper',10,10,color,'#FFFFFF',2,'100%');
    rC.addTarget('content',10,10,'#FFFFFF',color,5,'100%');
    rC.init();
</script>
