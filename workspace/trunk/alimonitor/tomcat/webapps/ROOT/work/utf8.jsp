<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*,alien.catalogue.*,java.util.regex.*"%><%!
%><%
    response.setContentType("text/html; charset=UTF-8");

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String s = rw.gets("s");
    
    final StringBuilder sb = new StringBuilder(s.length() + 100);
    
    for (final char c: Format.escHtml(s).toCharArray()){
	if (c>127){
	    sb.append("&#x").append(Format.byteToHex((byte) (c/256))).append(Format.byteToHex((byte) (c%256))).append(";");
	}
	else
	if (c=='\n'){
	    sb.append("<br>");
	}
	else{
	    sb.append(c);
	}
    }
    
    final String r = sb.toString();
%>
<html>
    <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<title>UTF8 convert</title>
    </head>
    <Body>
	<form method=post>
	    <textarea style="width:1000px;height:400px" name=s><%out.println(s);%></textarea>
	    <br>
	    <input type=submit>
	</form>
	<hr size=1>
	<% out.println(Format.escHtml(r)); %>
	<hr size=1>
	<% out.println(r); %>
    </body>
</html>
