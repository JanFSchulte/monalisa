<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/users.jsp", 0, request);
%>
<html>
<head>
    <link type="text/css" rel="StyleSheet" href="/style/style.css" />
</head>
<body bgcolor=white class="text">
<%
    RequestWrapper rw = new RequestWrapper(request);

    //DB db = new DB("select pu_username, pu_email from pwg_users inner join pwg_responsibles on pu_id=pr_puid where pr_pid="+rw.geti("id")+";");
    DB db = new DB("select pu_username,pu_email from pwg inner join pwg_groups on pwg.p_group=pg_id inner join pwg_users on pwg_users.pu_group=pg_id where p_id="+rw.geti("id")+";");
    
    while (db.moveNext()){
	out.println(db.gets("pu_username")+" &lt;<a class='link' href='mailto:"+db.gets("pu_email")+"'>"+db.gets("pu_email")+"</a>&gt;");
	
	out.println("<BR>");
    }
%>
    <br>
    <a class="link" href="admin/users.jsp?action=2" target="_parent">Edit users</a>
</body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/PWG/users.jsp", 0, request);
%>