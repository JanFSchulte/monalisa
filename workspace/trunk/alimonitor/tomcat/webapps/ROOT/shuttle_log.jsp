<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lazyj.*"%><%
    Utils.logRequest("START shuttle_log.jsp", 0, request);

    if (request.getRemoteAddr().equals("137.138.137.157")){
	out.println("Please go away CERN indexing service, you are killing the service with infinite loop requests!");
	return;
    }

    DB db = new DB();

    final RequestWrapper rw = new RequestWrapper(request);

    String sDetector = rw.gets("detector");
    String sRun = rw.gets("run");
    String sInstance = rw.gets("instance");

    String sQuery = "SELECT * FROM shuttle_history WHERE instance='"+Formatare.mySQLEscape(sInstance)+"' AND run='"+Formatare.mySQLEscape(sRun)+
	    "' AND detector='"+Formatare.mySQLEscape(sDetector)+"' ORDER BY id DESC LIMIT 1000;";

    //System.err.println(sQuery);

    db.query(sQuery);

    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
%>
<html>
    <head>
	<title>Operational log for <%=sDetector%>, run# <%=sRun%></title>
    </head>
    <body>
	<font style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px"><b>Operational log for <%=sDetector%>, run# <%=sRun%></b></font><br>
	<br>
	<table border=0 cellspacing=1 cellpadding=2 bgcolor="#555555" style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px">
	    <tr bgcolor=white>
		<th>Event time</th>
		<th>Status</th>
		<th>Count</th>
	    </tr>
<%	
    String sOldStatus = null;
    String sOldCount = null;
    String sOldTime = null;

    while (db.moveNext()){
	String sTime = sdf.format(new Date(db.getl("event_time")*1000));
	String sStatus = db.gets("status");
	String sCount = db.gets("count");

	if (sOldStatus!=null && sStatus.equals(sOldStatus) && sCount.equals(sOldCount) && sTime.equals(sOldTime))
	    continue;
	    
	sOldStatus = sStatus;
	sOldCount = sCount;
	sOldTime = sTime;

	String sColor = "FFFF55";

	if (sStatus.toLowerCase().equals("done"))
	    sColor = "55FF55";
	else if (sStatus.toLowerCase().equals("failed"))
	    sColor = "FF5555";

	out.println("<tr bgcolor=white><td>"+sTime+"</td><td bgcolor=#"+sColor+">"+sStatus+"</td><td>"+sCount+"</td></tr>");
    }
%>
	</table>
    </body>
</html>
<%
    Utils.logRequest("shuttle_log.jsp", 1, request);
%>