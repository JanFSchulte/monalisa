<%@ page import="alien.catalogue.*,lazyj.*"%><%!
%><%
    RequestWrapper rw =new RequestWrapper(request);

    if (rw.getb("clear", false))    
	FileCache.getInstance().refresh();

    response.setContentType("text/plain");
    
    out.println("Size: "+FileCache.getInstance().size()+", "+FileCache.getHits()+" hits, "+FileCache.getMisses()+" misses");
    
    for (String s: FileCache.getInstance().getKeys()){
	out.println(s);
    }
%>