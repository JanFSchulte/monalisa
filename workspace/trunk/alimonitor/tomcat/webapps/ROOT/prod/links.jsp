<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lazyj.*,utils.IntervalQuery"%><%
    lia.web.servlets.web.Utils.logRequest("START /prod/links.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    final int id = rw.geti("id");
    
    final DB db = new DB("SELECT * FROM job_types_links WHERE jt_id="+id+" ORDER BY jt_add_timestamp ASC;");
%>
<html>
<link rel="stylesheet" type="text/css" href="/style/style.css" />
<body>
<ul style="padding-left:10px; padding-top:10px">
<%
    while (db.moveNext()){
	out.println("<li><a target=_blank class=link href='"+Format.escHtml(db.gets("jt_link"))+"'>"+Format.escHtml(db.gets("jt_descr"))+"</a><br>");
    }

    lia.web.servlets.web.Utils.logRequest("/prod/links.jsp", 0, request);
%>
</ul>
</body>
</html>
