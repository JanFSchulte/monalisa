<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /production/job_details.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    final DB db = new DB();
    
    final int pid = rw.geti("pid");

    db.query("select state,cnt from job_stats_details where pid="+pid+";");
    
    final Page p = new Page(null, "production/job_details.res");
    p.setWriter(out);
    
    p.modify("pid", pid);
    
    int iErrors = 0;
    
    while (db.moveNext()){
	String sKey = db.gets(1);
	int iValue = db.geti(2);
    
	p.modify(sKey, iValue);
	
	if (sKey.startsWith("ERROR_") || sKey.equals("EXPIRED") || sKey.equals("ZOMBIE"))
	    iErrors += iValue;
    }
    
    p.modify("TOTAL_ERRORS", iErrors);
    
    p.write();
    
    lia.web.servlets.web.Utils.logRequest("/production/job_details.jsp", 0, request);
%>