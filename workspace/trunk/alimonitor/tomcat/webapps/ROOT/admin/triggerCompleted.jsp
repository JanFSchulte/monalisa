<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,lazyj.commands.*,alien.catalogue.AliEnFile,java.util.Date,alien.catalogue.*,alien.user.*,java.io.*,java.util.*,alien.repository.*"%><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /work/triggerCompleted.jsp", 0, request);
    
    response.setContentType("text/html");
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    StringTokenizer st = new StringTokenizer(rw.gets("pid"), " \t\r\n,;");

%>
<html>
<head><title>Trigger completed</title></head>
<body>
<form name=form1 method=post>
<textarea name=pid cols=100 rows=20>
</textarea>
<br>
<input type=submit name=submit value="Trigger">
</form>
</body>
</html>
<%
    
    while (st.hasMoreTokens()){
        String s = st.nextToken();
	
	try{
	    final int pid = Integer.parseInt(s);
	    
	    DB db = new DB("SELECT alienuser,status FROM lpm_history WHERE pid="+pid);
	    
	    if (!db.moveNext()){
		out.println("Not an LPM job: "+pid+"<br>");
		continue;
	    }
	    
	    if (db.geti(2)!=2){
		out.println("Job not marked as completed yet: "+pid+"<br>");
		continue;
	    }
	    
	    out.println("<hr size=1><br>Triggering for "+pid+" of "+db.gets(1)+"<br>");
	    
	    final LPM lpm = new LPM(db.gets(1));
	    
	    lpm.setShouldNotify();
	    
	    final auth.AlicePrincipal p = alimonitor.Users.get(request);

	    lpm.log("Job finish manually triggered for parent pid "+pid+" by "+p+" @ "+request.getRemoteAddr());
	    
	    lpm.triggerCompleted(pid);
	    
	    alien.managers.LPMManager.sendMail(lpm);
	    
	    out.println(lpm.getLog()+"<br>");
	    out.flush();
	}
	catch (Exception e){
	    out.println("What is this: "+s+"<br>");
	}
    }

    lia.web.servlets.web.Utils.logRequest("/work/triggerCompleted.jsp", 0, request);
%>