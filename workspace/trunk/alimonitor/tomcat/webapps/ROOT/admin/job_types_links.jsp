<%@ page import="lazyj.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/job_types_links.jsp", 0, request);
    
    RequestWrapper rw = new RequestWrapper(request);
    
    final int id = rw.geti("id");
    
    DB db = new DB();
    
    if (rw.gets("jt_link").length()>0){
	String account = "grigoras";
    
	db.syncUpdateQuery("INSERT INTO job_types_links (jt_id, jt_link, jt_descr, jt_added_by) VALUES ("+id+", '"+Format.escSQL(rw.gets("jt_link"))+"', '"+Format.escSQL(rw.gets("jt_descr"))+"', '"+Format.escSQL(account)+"');");
    }
    
    if (rw.gets("del").length()>0){
	db.syncUpdateQuery("DELETE FROM job_types_links WHERE jt_id="+id+" AND jt_link='"+Format.escSQL(rw.gets("del"))+"';");
    }
    
    db.query("SELECT * FROM job_types_links WHERE jt_id="+id+" ORDER BY jt_add_timestamp ASC;");
%>
<html>
<link rel="stylesheet" type="text/css" href="/style/style.css" />
<body>

<div style="padding-top:10px;padding-left:10px">
<table border=1 cellspacing=0 cellpadding=2 class=text>
<tr>
    <th>Link</th>
    <th>Description</th>
    <th>Options</th>
</tr>
<%
    while (db.moveNext()){
	out.println("<tr><td><a class=link target=_blank href='"+Format.escHtml(db.gets("jt_link"))+"'>"+Format.escHtml(db.gets("jt_link"))+"</a></td><td>"+Format.escHtml(db.gets("jt_descr"))+"</td><td><a href='job_types_links.jsp?id="+id+"&del="+Format.encode(db.gets("jt_link"))+"' class=link>Del</a></tr>");
    }
%>
<form name=form1 action=job_types_links.jsp method=post>
<input type=hidden name=id value=<%=id%>>
<tr>
    <td>
	<input type=text name=jt_link class=input_text>
    </td>
    <td>
	<input type=text name=jt_descr class=input_text>
    </td>
    <td>
	<input type=submit name=submit value="Add" class=input_submit>
    </td>
</tr>
</form>
</table>
</div>
</body>
</html>
<%    
    lia.web.servlets.web.Utils.logRequest("/admin/job_types.jsp", 0, request);
%>