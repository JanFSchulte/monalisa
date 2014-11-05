<%@page import="lazyj.*,alien.catalogue.*"%><%!
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String parentId = rw.gets("parentId");
    
    final AliEnFile f = FileCache.getFile(parentId);
    
    if (!f.exists() && !f.isDirectory())
	return;
	
    for (AliEnFile sub: f.list()){
	if (sub.isDirectory()){
	    final String p = Format.escHtml(sub.getCannonicalName());
	    
	    out.println("<li><a href=# path='"+p+"' name='"+p+"'>"+sub.getName()+"</a>");
	    
	    //if (sub.list()!=null)
		out.println("<ul><li parentId='"+sub.getCannonicalName()+"'><a href='#'>Loading</a></li></ul>");
	    
	    out.println("</li>");
	}
    }
    
    lia.web.servlets.web.Utils.logRequest("/catalogue/getFolderList.jsp?parentId="+parentId, 0, request);
%>