<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.util.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /pledged.jsp", 0, request);

    String JSP = "pledged.jsp";

    response.setHeader("Connection", "keep-alive");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    Enumeration en = request.getParameterNames();
    
    while (en.hasMoreElements()){
	String sName = (String) en.nextElement();
	
	if (sName.startsWith("cpus_") || sName.startsWith("ksi2k_")){
	    String sParam = sName.substring(0, sName.indexOf("_"));
	    String sFarm = sName.substring(sName.indexOf("_")+1);
	    
	    int value;
	    
	    try{
		value = Integer.parseInt(request.getParameter(sName));
	    }
	    catch (Exception e){
		continue;
	    }
	    
	    DB db = new DB();
	    
	    db.query("UPDATE pledged_dynamic SET "+sParam+"="+value+" WHERE site='"+sFarm+"';");
	}
    }
%><html>
    <head>
	<title>
	    Pledged CPUs
	</title>
    </head>
    <body bgcolor=white>
	<form name="pledged_cpus_form" action="<%= JSP%>" method=POST>
	<table border=1 cellspacing=0 cellpadding=3>
	    <tr bgcolor="EEEEEE">
		<th>No</th>
		<th>Farm</th>
		<th>ML ver</th>
		<th>Online</th>
		<th>Pledged CPUs</th>
		<th>Pledged kSI2K</th>
		<th>Options</th>
	    </tr>
	<%
	    DB db = new DB();
	    
	    db.query("SELECT fill_pledged_dynamic();");
	    
	    db.query("SELECT name,version,cpus,ksi2k FROM abping_aliases LEFT OUTER JOIN pledged_dynamic ON name=site ORDER BY name ASC;");
	    
	    int i = 1;
	    
	    while (db.moveNext()){
		monPredicate pred = new monPredicate(db.gets("name"), "*", "*", -1, -1, new String[]{"*"}, null);
	    %>
		
		<tr>
		    <td align=right><%= i++%>.</td>
		    <td align=left><%= db.gets("name")%></td>
		    <td align=right><%= db.gets("version", "&nbsp;")%></td>
		    <td align=center><%= Cache.getLastValue(pred)!=null ? "<font color=green><b>ON</b></font>" : "<font color=red><b>OFF</b></font>"%></td>
		    <td align=center><input type=text size=4 maxlength=6 name="cpus_<%= db.gets("name")%>" value="<%= db.geti("cpus")%>"></td>
		    <td align=center><input type=text size=4 maxlength=6 name="ksi2k_<%= db.gets("name")%>" value="<%= db.geti("ksi2k")%>"></td>
		    <td align=center><input type=submit name=submit value=Update></td>
		</tr>
	    <%}
	%>
	</table>
	</form>
    </body>
</html>
<%
        lia.web.servlets.web.Utils.logRequest("/pledged.jsp", 0, request);
%>