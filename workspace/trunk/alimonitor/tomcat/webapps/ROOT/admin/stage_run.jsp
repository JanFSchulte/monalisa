<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/stage_run.jsp", 0, request);

    response.setContentType("text/plain");

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();

    // -----
    final int iRun = rw.geti("run");

    if (iRun>0){
        String sQuery = "UPDATE rawdata_runs SET staging_status=1 WHERE run='"+iRun+"' AND staging_status=0;";
	    
        db.syncUpdateQuery(sQuery);
        
        out.println(db.getUpdateCount()>0 ? "OK" : "Error scheduling: nothing was updated in the DB (?!)");
    }
    
    final int iDel = rw.geti("delete");
    
    if (iDel>0){
        String sQuery = "UPDATE rawdata_runs SET staging_status=0 WHERE run='"+iDel+"' AND staging_status=3;";

        db.syncUpdateQuery(sQuery);
        
        out.println(db.getUpdateCount()>0 ? "OK" : "Error dismissing: nothing was updated in the DB (?!)");
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/admin/stage_run.jsp", 1, request);
%>