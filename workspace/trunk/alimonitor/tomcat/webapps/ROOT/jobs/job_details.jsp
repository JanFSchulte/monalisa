<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*"%><%!
    private static final String getPercentage(final int total, final int state){
	if (total<=0)
	    return "";
    
	return " ( "+Format.point(state*100d / total)+"% )";
    }
%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /jobs/job_details.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);

    RequestWrapper.setCacheTimeout(response, 60);    
    
    final DB db = new DB();
    
    final int pid = rw.geti("pid");

    db.query("select * from job_stats where pid="+pid+";");
    
    if (!db.moveNext())
	return;

    final Page p = new Page("jobs/job_details.res");
    p.setWriter(out);
    
    p.modify("pid", pid);
    
    p.fillFromDB(db);
    
    int iErrors = 0;
    
    for (String sState : new String[]{"WAITING", "STARTED", "RUNNING", "SAVING", "DONE", "DONE_WARN", "ERROR_V", "ERROR_SV", "ERROR_E", "ERROR_IB", "ERROR_VN", "ERROR_VT", "ERROR_RE", "ERROR_W", "ERROR_EW", "ERROR_SPLT", "EXPIRED", "ZOMBIE"}){
	p.comment("com_"+sState, false);
    }

    db.query("select state,cnt from job_stats_details where pid="+pid+" ORDER BY state='TOTAL' desc;");
    
    int total = 0;
    
    while (db.moveNext()){
	String sKey = db.gets(1);
	
	if (sKey.equals("ERROR_W"))
	    sKey = "ERROR_EW";
	
	int iValue = db.geti(2);
    
	p.modify(sKey, iValue);
	
	if (sKey.startsWith("ERROR_") || sKey.equals("EXPIRED") || sKey.equals("ZOMBIE"))
	    iErrors += iValue;
	
	p.comment("com_"+sKey, iValue>0);
	
	if (sKey.equals("TOTAL"))
	    total = iValue;
	else
	    p.modify(sKey+"_percent", getPercentage(total, iValue));
    }
    
    p.modify("TOTAL_ERRORS", iErrors);
    p.modify("TOTAL_ERRORS_percent", getPercentage(total, iErrors));
    
    p.comment("com_TOTAL_ERRORS", iErrors>0);
    
    p.write();
    
    lia.web.servlets.web.Utils.logRequest("/jobs/job_details.jsp", 0, request);
%>