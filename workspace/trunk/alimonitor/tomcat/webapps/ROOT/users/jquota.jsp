<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,alien.pool.*,java.util.*,alien.quotas.*" buffer="16kb"%><%
    lia.web.servlets.web.Utils.logRequest("START /users/edit.jsp", 0, request);

    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;
    
    response.setContentType("text/html");
    
    final AlicePrincipal p = Users.get(request);
    
    RequestWrapper.setCacheTimeout(response, 60);
    
    if (p==null){
	System.err.println("users/jquota.jsp : Not authenticated");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String sAccount = rw.gets("u", p.getName());

    if (!p.canBecome(sAccount)){
	out.println("No privileges");
	return;
    }    
    
    final Quota q = QuotaUtilities.getJobQuota(sAccount);
    
    if (q==null)
	return;
    
    Page pQuota = new Page(response.getOutputStream(), "users/jquota.res");

    pQuota.modify("unfinished_jobs", q.waiting+q.running);
    pQuota.modify("unfinished_jobs_quota", q.maxUnfinishedJobs);
    pQuota.modify("unfinished_jobs_ratio_int", 100*(q.waiting+q.running)/q.maxUnfinishedJobs);
    pQuota.modify("unfinished_jobs_ratio_real", 100d*(q.waiting+q.running)/q.maxUnfinishedJobs);
    pQuota.modify("complement_unfinished_jobs_ratio_int", 100-100*(q.waiting+q.running)/q.maxUnfinishedJobs);
    pQuota.modify("complement_unfinished_jobs_ratio_real", 100d-100d*(q.waiting+q.running)/q.maxUnfinishedJobs);
		
    pQuota.modify("total_cpu_cost", q.totalCpuCostLast24h);
    pQuota.modify("total_cpu_cost_quota", q.maxTotalCpuCost);
    pQuota.modify("total_cpu_cost_ratio_int", 100*q.totalCpuCostLast24h/q.maxTotalCpuCost);
    pQuota.modify("total_cpu_cost_ratio_real", 100d*q.totalCpuCostLast24h/q.maxTotalCpuCost);
    pQuota.modify("complement_total_cpu_cost_ratio_int", 100-100*q.totalCpuCostLast24h/q.maxTotalCpuCost);
    pQuota.modify("complement_total_cpu_cost_ratio_real", 100d-100d*q.totalCpuCostLast24h/q.maxTotalCpuCost);

    pQuota.modify("total_running_time", q.totalRunningTimeLast24h);
    pQuota.modify("total_running_time_quota", q.maxTotalRunningTime);
    pQuota.modify("total_running_time_ratio_int", 100*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
    pQuota.modify("total_running_time_ratio_real", 100d*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
    pQuota.modify("complement_total_running_time_ratio_int", 100-100*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
    pQuota.modify("complement_total_running_time_ratio_real", 100d-100d*q.totalRunningTimeLast24h/q.maxTotalRunningTime);
    
    pQuota.write();
%>