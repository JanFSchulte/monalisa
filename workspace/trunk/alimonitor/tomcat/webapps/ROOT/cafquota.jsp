<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils"%><%
    lia.web.servlets.web.Utils.logRequest("START /cafquota.jsp", 0, request);

    response.setContentType("text/plain");

    String sCluster = request.getParameter("cluster");

    String sUser = request.getParameter("user");
    
    boolean bUser = false;
    
    if (sUser!=null && sUser.toLowerCase().startsWith("t"))
	bUser = true;
	
    long lHours = 24*7;
    
    try{
	lHours = Integer.parseInt(request.getParameter("hours"));
    }
    catch (Exception e){
    }
    
    String sName = request.getParameter("name");
    
    String sParameter = request.getParameter("parameter");
    
    String q = "SELECT cafcluster, isuser, name, parameter, sum(value) FROM cafquota WHERE period >= date_trunc('hours', now()-'"+lHours+" hours'::interval) ";
    
    if (sCluster!=null)
	q+="AND cafcluster='"+Formatare.mySQLEscape(sCluster)+"' ";
    
    if (sUser!=null)
	q+="AND isuser="+bUser+" ";

    if (sName!=null)
	q+="AND name='"+Formatare.mySQLEscape(sName)+"' ";

    if (sParameter!=null)
	q+="AND parameter='"+Formatare.mySQLEscape(sParameter)+"' ";
    
    q += "GROUP BY cafcluster, isuser, name, parameter ORDER BY lower(cafcluster), isuser, lower(name), lower(parameter);";

    DB db = new DB(q);
    
    out.println("#cluster|user|name|parameter|value");
    
    while (db.moveNext()){
	out.println(db.gets(1)+"|"+db.gets(2)+"|"+db.gets(3)+"|"+db.gets(4)+"|"+db.getd(5));
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/cafquota.jsp", 1, request);
%>