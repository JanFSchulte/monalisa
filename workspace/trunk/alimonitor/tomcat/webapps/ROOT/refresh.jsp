<%@ page import="alimonitor.*,java.util.*,java.io.*,lazyj.*"%><%
    final RequestWrapper rw = new RequestWrapper(request);

    String path = rw.gets("path");
    
    if (path.length()==0){
	String s = rw.gets("display");
	
	if (s.length()>0){
	    path = "/display?page="+Format.encode(s);
	}
	else{
	    s = rw.gets("stats");
	    
	    if (s.length()>0){
		path = "/stats?page="+Format.encode(s);
	    }
	}
    }
    
    if (!path.startsWith("/"))
	return;
	
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(1000);

    final Page p = new Page(baos, "refresh.res");
    
    p.modify("path", path);
    
    p.modify("refreshTime", rw.geti("interval", 600) * 1000);
    
    p.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/refresh.jsp?path="+Format.encode(path), baos.size(), request);
%>