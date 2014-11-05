<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.*,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%!
%><%
    DB db = new DB("select name,geo_lat,geo_long from abping_aliases;");
    
    response.setContentType("text/csv");
    
    out.println("site name,lat,long");
    
    while (db.moveNext()){
	out.println(db.gets(1)+","+db.gets(2)+","+db.gets(3));
    }
%>