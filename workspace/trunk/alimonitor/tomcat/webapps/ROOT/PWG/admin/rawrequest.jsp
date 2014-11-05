<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.security.cert.*" %><%!

private static Collection<Integer> toRunList(final String s){

    final Set<Integer> ret = new HashSet<Integer>();

    final StringTokenizer st = new StringTokenizer(s, ",");
    
    while (st.hasMoreTokens()){
	final String sTok = st.nextToken().trim();
    
	try{
	    int i = Integer.parseInt(sTok);
	    
	    if (i>0)
		ret.add(Integer.valueOf(i));
	}
	catch (Exception e){
	}
    }

    return ret;
}

%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/rawrequest.jsp", 0, request);

    response.setContentType("text/plain");

    final RequestWrapper rw = new RequestWrapper(request);
    
    final DB db = new DB();

    final int op = rw.geti("op");
    final int iRun = rw.geti("run");
    final int iPass = rw.geti("pass", -1);
    
    String sDN = null;
    String sUsername = null;

    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
	
	if (cert!=null && cert.length>0){
	    sDN = cert[0].getSubjectDN().getName();
	    
	    auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);
	    
	    sUsername = principal.getName();
	}
    }
    
    String sMessage = "ERR:Unrecognized operation";
    
    switch (op){
	case 1:	// add
	    Collection<Integer> cRuns = toRunList(rw.gets("run"));
	    
	    int iInserts = 0;
	    
	    String sIgnoredRuns = "";
	
	    if (cRuns.size()>0 && iPass>=0){
		for (int run: cRuns){
		    db.query("SELECT 1 FROM rawdata_runs WHERE run="+run+";");
		
		    if (db.moveNext()){
			if (db.syncUpdateQuery("INSERT INTO rawdata_processing_requests (run, pass, requested_by, priority) VALUES ("+run+", "+iPass+", '"+Format.escSQL(sUsername)+"', 2);"))
			    iInserts ++;
			else
			    sIgnoredRuns += run+",";
		    }
		    else{
			sIgnoredRuns += run+",";
		    }
		}
		
		if (iInserts==0){
		    sMessage="ERR:Nothing was changed, the run numbers you specified are invalid (don't exist/are already requested)";
		}
		else
		if (iInserts!=cRuns.size()){
		    sMessage="ERR:Some of the runs you requested are not valid and were ignored: "+sIgnoredRuns;
		}
		else
		    sMessage="OK";
	    }
	    else{
		sMessage = "ERR: You have to provide a comma-separated list of run numbers and a pass";
	    }
	    
	    break;
	    
	case 2: // delete
	    db.syncUpdateQuery("DELETE FROM rawdata_processing_requests WHERE run="+iRun+" AND pass="+iPass+";");
	    
	    if (db.getUpdateCount()>0)
		sMessage = "OK";
	    else
		sMessage = "ERR:No such run/pass combination: "+iRun+"/"+iPass;
		
	    break;
	
	case 3: // reprocess
	    db.query("SELECT masterjob_id FROM rawdata_processing_requests WHERE run="+iRun+" AND pass="+iPass+" and masterjob_id is not null;");
	    
	    if (db.moveNext()){
		// clean previous error logs
		final int iOldMasterjobID = db.geti(1);
	    
		db.syncUpdateQuery("update rawdata set errorv_logfile=null where lfn like '%"+iRun+"/%' and errorv_logfile like '/joboutputs/"+iOldMasterjobID+"/%';");
	    }
	
	    db.syncUpdateQuery("UPDATE rawdata_processing_requests SET masterjob_id=null, masterjob_starttime=null, status=0 WHERE run="+iRun+" AND pass="+iPass+";");
	    
	    if (db.getUpdateCount()>0)
		sMessage = "OK";
	    else
		sMessage = "ERR:No such run/pass combination: "+iRun+"/"+iPass;
	
	    break;
	    	
	default:
	    sMessage = "ERR:Unrecognized operation code:"+op;
    }
    
    out.println(sMessage);
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/rawrequest.jsp", 0, request);
%>