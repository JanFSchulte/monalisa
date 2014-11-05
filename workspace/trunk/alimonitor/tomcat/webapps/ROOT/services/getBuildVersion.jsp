<%@ page import="lazyj.*,utils.*,lia.Monitor.Store.Fast.DB,java.util.*" %><%

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String ver = rw.gets("ver").trim();
    final String time = rw.gets("time").trim();
    
    if (ver.length()==0){
        response.setContentType("text/html");
        
	out.println("Arguments: ver=&lt;version&gt; &amp; time=&lt;date+time&gt<br><br>");
	
	final DB db = new DB("select version,max(lastchange),max(vernumber) from buildsystem_versions group by version ORDER BY 1 DESC;");
	
	out.println("<table border=1 cellspacing=0 cellpadding=2><tr><th>Version</th><th>Timestamp of last change</th><th>Last build number</th></tr>");
	while (db.moveNext()){
	    final Date d = new Date(db.getl(2) * 1000);
	
	    out.println("<tr><td><a href='getBuildVersion.jsp?ver="+Format.encode(db.gets(1))+"'>"+Format.escHtml(db.gets(1))+"</td>"+
		    "<td>"+db.geti(2)+" ("+Format.showNiceDate(d)+" "+Format.showTime(d)+")</a></td><td>"+db.geti(3)+"</td></tr>");
	}
	
	out.println("</table>");

	lia.web.servlets.web.Utils.logRequest("/services/getBuildVersion.jsp", 0, request);
	
	return;
    }
    
    if (time.length()==0){
	final DB db = new DB("SELECT lastchange,vernumber FROM buildsystem_versions WHERE version='"+Format.escSQL(ver)+"' ORDER BY lastchange DESC;");
	
        response.setContentType("text/html");

	out.println("<b>History for version "+Format.escHtml(ver)+"</b><br><br>");
	
	out.println("<table border=1 cellspacing=0 cellpadding=2><tr><th>Timestamp</th><th>Build number</th></tr>");
	
	while (db.moveNext()){
	    final Date d = new Date(db.getl(1) * 1000);
	    
	    out.println("<tr><td>"+db.geti(1)+" ("+Format.showNiceDate(d)+" "+Format.showTime(d)+")</td><td>"+db.geti(2)+"</td></tr>");
	}
	
	out.println("</table><br>");
	
	out.println("<a href=getBuildVersion.jsp>Back to global view</a>");
	
	lia.web.servlets.web.Utils.logRequest("/services/getBuildVersion.jsp?ver="+ver, 0, request);
	
	return;
    }

//    if (!request.getRemoteAddr().startsWith("137.138.47.")){
//	out.println("You are not allowed here");
//	return;
//    }

    response.setContentType("text/plain");
    
    out.println(BuildVersion.getVersion(ver, BuildVersion.getTimestamp(time)));
    
    lia.web.servlets.web.Utils.logRequest("/services/getBuildVersion.jsp?ver="+ver+"&time="+time, 0, request);
%>