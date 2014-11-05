<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*,alien.quotas.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/jquota.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final RequestWrapper rw = new RequestWrapper(request);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Job Quotas");
    pMaster.modify("class_quota", "_active");

    final Page p = new Page("admin/jquota.res");
    final Page pEl = new Page("admin/jquota_el.res");

    // ------- Operations ---------

    // --------- Display ---------

    final List<Quota> quotas = QuotaUtilities.getJobQuotas();
    
    for (final Quota q: quotas){
	pEl.modify("account", q.user);

	pEl.modify("unfinished_jobs", q.waiting+q.running);
	pEl.modify("unfinished_jobs_quota", q.maxUnfinishedJobs);
	pEl.modify("unfinished_jobs_ratio_int", 100*(q.waiting+q.running)/q.maxUnfinishedJobs);
	pEl.modify("unfinished_jobs_ratio_real", 100d*(q.waiting+q.running)/q.maxUnfinishedJobs);
	pEl.modify("complement_unfinished_jobs_ratio_int", 100-100*(q.waiting+q.running)/q.maxUnfinishedJobs);
	pEl.modify("complement_unfinished_jobs_ratio_real", 100d-100d*(q.waiting+q.running)/q.maxUnfinishedJobs);
		

	pEl.modify("total_cpu_cost", q.totalCpuCostLast24h);
	pEl.modify("total_cpu_cost_quota", q.maxTotalCpuCost);
	pEl.modify("total_cpu_cost_ratio_int", 100*q.totalCpuCostLast24h/q.maxTotalCpuCost);
	pEl.modify("total_cpu_cost_ratio_real", 100d*q.totalCpuCostLast24h/q.maxTotalCpuCost);
	pEl.modify("complement_total_cpu_cost_ratio_int", 100-100*q.totalCpuCostLast24h/q.maxTotalCpuCost);
	pEl.modify("complement_total_cpu_cost_ratio_real", 100d-100d*q.totalCpuCostLast24h/q.maxTotalCpuCost);

	pEl.modify("total_running_time", q.totalRunningTimeLast24h);
	pEl.modify("total_running_time_quota", q.maxTotalRunningTime);
	pEl.modify("total_running_time_ratio_int", 100*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
	pEl.modify("total_running_time_ratio_real", 100d*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
	pEl.modify("complement_total_running_time_ratio_int", 100-100*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
	pEl.modify("complement_total_running_time_ratio_real", 100d-100d*q.totalRunningTimeLast24h/q.maxTotalRunningTime);

	p.append(pEl);
    }

    // --------- Close -----------
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/jquota.jsp", baos.size(), request);
%>
