<%@ page import="alimonitor.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*" %><%!

%><%

    lia.web.servlets.web.Utils.logRequest("START /lpm/lpm_ignore.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "lpm/lpm_ignore.res");
    
    Page pLine = new Page("lpm/lpm_ignore_id.res");
        
    DB db = new DB();
    
    for (String sID: rw.getValues("add")){
	try{
	    int id = Integer.parseInt(sID);
	    
	    db.syncUpdateQuery("INSERT INTO lpm_ignore (jobid) VALUES ("+id+");");
	}
	catch (Exception e){
	}
    }

    for (String sID: rw.getValues("remove")){
	try{
	    int id = Integer.parseInt(sID);
	    
	    db.syncUpdateQuery("DELETE FROM lpm_ignore WHERE jobid="+id+";");
	}
	catch (Exception e){
	}
    }
    
    db.query("SELECT li.jobid,outputdir FROM lpm_ignore li left outer join job_runs_details jr on li.jobid=jr.pid ORDER BY li.jobid DESC");
    
    while (db.moveNext()){
	pLine.modify("id", db.geti(1));
	pLine.modify("outputdir", db.gets(2));
	pLine.modify("name", "remove");
	pMaster.append("ignored", pLine);
    }
    
    db.query("select js.pid,outputdir from job_stats js left outer join job_runs_details jr ON js.pid=jr.pid where lastseen>extract(epoch from now()-'1 hour'::interval)::int and owner='aliprod' and js.pid not in (select jobid from lpm_ignore) ORDER BY pid ASC;");
    
    while (db.moveNext()){
	pLine.modify("id", db.geti(1));
	pLine.modify("outputdir", db.gets(2));
	pLine.modify("name", "add");
	pMaster.append("newignore", pLine);
    }

    pMaster.write();
        
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/lpm/lpm_ignore.jsp", baos.size(), request);
%>
