<%@ page import="lia.web.utils.Formatare,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.Store.Fast.DB" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/lpm_submit.jsp", 0, request);

    response.setContentType("text/html");
%>
<html>
    <head>
	<title>Manual submit of a JDL</title>
    </head>
    <body bgcolor=white>
	<div style="font-family:Verdana,Helvetica,Arial;font-size:12px">
<%
    final int id;

    try{
	id = Integer.parseInt(request.getParameter("id"));
    }
    catch (Exception e){
	out.println("id parameter missing");
	return;
    }

    final DB db = new DB();
    db.query("SELECT alienuser,lastrun,maxrun,parentid FROM lpm_chain WHERE id="+id+";");
    
    alien.repository.LPM lpm = new alien.repository.LPM(db.gets(1));
    lpm.setShouldNotify();
    
    final auth.AlicePrincipal p = alimonitor.Users.get(request);

    lpm.log("Activity triggered manually for chain "+id+" by "+p+" @ "+request.getRemoteAddr());

    final int parentid = db.geti(4);
    
    if (parentid>0){
	DB db2 = new DB("select pid from lpm_history l1 where chain_id="+parentid+" and status=2 and not exists (select 1 from lpm_history where chain_id="+id+" and parentpid=l1.pid) order by pid desc limit 1");
	
	if (db2.moveNext()){
	    out.println("Found pid "+db2.geti(1)+" that lacks a subjob of type "+id+"<BR>");
	    int count = lpm.submit(id, db2.geti(1));
	    //out.println("Count = "+count);
	}
	else{
	    out.println("No parent job lacking this subjob!<br>");
	}
    }
    else{
	final int iLastRun = db.geti(2);
        final int iMaxRun = db.geti(3);
    
	if (iMaxRun > 0 && iLastRun >= iMaxRun){
	    final DB db2 = new DB();
	    db2.syncUpdateQuery("UPDATE lpm_chain SET maxrun="+(iLastRun+1)+" WHERE id="+id+";");
	}
	
	lpm.submit(id, 0);
    }
    
    out.println(lpm.getLog());
    
    alien.managers.LPMManager.sendMail(lpm);
%>
	</div>
    </body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/admin/lpm_submit.jsp?id="+id, 0, request);
%>