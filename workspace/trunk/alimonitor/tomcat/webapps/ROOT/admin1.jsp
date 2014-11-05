<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin1.jsp", 0, request);

    String JSP = "admin.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    String sName = request.getParameter("delete");
    String sIP   = request.getParameter("ip");
    String sSure = request.getParameter("sure");
    String sBan  = request.getParameter("ban");
    
    if (((sName!=null && sName.length()>0) || (sBan!=null && sBan.length()>0)) && sIP!=null && sIP.length()>0){
	if (sSure==null || sSure.length()<=0){
	    %>
		<html><head><title>Confirmation</title></head>
		<body bgcolor=white>
		    Are you sure you want to <%= sName!=null ? "delete" : "ban"%> <b><%= sName!=null ? sName : sBan%></b> ? <br>
		    <a href="<%= JSP%>?<%= sName!=null ? "delete" : "ban"%>=<%= Formatare.encode(sName!=null ? sName : sBan)%>&ip=<%= Formatare.encode(sIP)%>&sure=yes"><b>YES</b></a>
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		    <a href=<%= JSP%>><b>NO</b></a>
		</body></html>
	    <%
	    return;
	}
	else{
	    if (sBan!=null){
		FarmBan.banFarm(sBan);
		FarmBan.banIP(sIP);
		sName = sBan;
	    }
	
	    if (sName!=null){
		DB db = new DB();
	        db.query("DELETE FROM abping_aliases WHERE name='"+Formatare.mySQLEscape(sName)+"' AND ip='"+Formatare.mySQLEscape(sIP)+"';");
    	        db.query("DELETE FROM abping WHERE mfarmsource='"+Formatare.mySQLEscape(sIP)+"' OR mfarmdest='"+Formatare.mySQLEscape(sIP)+"';");
	    }
	    
	    response.sendRedirect(JSP);
	    return;
	}
    }
    
    String sUnBan = request.getParameter("unban_farm");
    if (sUnBan!=null && sUnBan.length()>0){
	FarmBan.unbanFarm(sUnBan);
        response.sendRedirect(JSP);
        return;
    }
    
    sUnBan = request.getParameter("unban_ip");
    if (sUnBan!=null && sUnBan.length()>0){
	FarmBan.unbanIP(sUnBan);
        response.sendRedirect(JSP);
        return;
    }
    
%>


<html>
    <head>
	<title>
	    Visible ML Farms
	</title>
    </head>
    <body bgcolor=white>
	<table border=1 cellspacing=0 cellpadding=3>
	    <tr bgcolor="EEEEEE">
		<th>No</th>
		<th>Farm</th>
		<th>IP</th>
		<th>ML ver</th>
		<th>Online</th>
		<th>Options</th>
	    </tr>
	<%
	    DB db = new DB("SELECT * FROM abping_aliases ORDER BY name ASC;");
	    
	    int i = 1;
	    
	    while (db.moveNext()){
		monPredicate pred = new monPredicate(db.gets("name"), "*", "*", -1, -1, new String[]{"*"}, null);
	    %>
		<tr>
		    <td align=right><%= i++%>.</td>
		    <td align=left><%= db.gets("name")%></td>
		    <td align=left><%= db.gets("ip")%></td>
		    <td align=right><%= db.gets("version", "&nbsp;")%></td>
		    <td align=center><%= Cache.getLastValue(pred)!=null ? "<font color=green><b>ON</b></font>" : "<font color=red><b>OFF</b></font>"%></td>
		    <td align=right>
			<a href="admin.jsp?delete=<%= Formatare.encode(db.gets("name"))%>&ip=<%= Formatare.encode(db.gets("ip"))%>">delete</a> |
			<a href="admin.jsp?ban=<%= Formatare.encode(db.gets("name"))%>&ip=<%= Formatare.encode(db.gets("ip"))%>">ban</a>
		    </td>
		</tr>
	    <%}
	%>
	</table>
	<br clear=all>
	<table border=1 cellspacing=0 cellpadding=3>
	    <tr bgcolor="EEEEEE">
		<th>Banned Farms</th>
		<th>Options</th>
	    </tr>
	    
	    <%
	    db.query("SELECT * FROM ban_farm ORDER BY name ASC;");
	    while (db.moveNext()){%>
		<tr>
		    <td><%= db.gets("name")%></td>
		    <td><a href="<%= JSP%>?unban_farm=<%= Formatare.encode(db.gets("name"))%>">unban</a></td>
		</tr>
	    <%}%>
	</table>
	<br clear=all>
	<table border=1 cellspacing=0 cellpadding=3>
	    <tr bgcolor="EEEEEE">
		<th>Banned IPs</th>
		<th>Options</th>
	    </tr>
	    
	    <%
	    db.query("SELECT * FROM ban_ip ORDER BY ip ASC;");
	    while (db.moveNext()){%>
		<tr>
		    <td><%= db.gets("ip")%></td>
		    <td><a href="<%= JSP%>?unban_ip=<%= Formatare.encode(db.gets("ip"))%>">unban</a></td>
		</tr>
	    <%}
	%>
	</table>
	
    </body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/admin1.jsp", 1, request);
%>