<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,alien.pool.*,java.util.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /users/delete.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/delete.jsp : User is not authenticated");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);

    final String sPath = rw.gets("path");

    final AliEnFile f = FileCache.getFile(sPath);

    if (f==null){    
	System.err.println("users/delete.jsp : Invalid filename : "+sPath);
	return;
    }

    boolean bOk = false;
    String sReason = "";

    if (f.exists() && !f.isFile()){
	sReason = "This is not a file";
    }
    else{
	final AliEnFile fParent = FileCache.getFile(f.getPath());
    
	if (fParent==null){
	    System.err.println("users/delete.jsp : Invalid path for the parent: "+f.getPath());
	    return;
	}
    
	if (!Users.canWrite(fParent, p) || !Users.canWrite(f, p)){
	    sReason = "Sorry, you are not allowed to delete this file";
	}
	else{
	    if (!f.delete())
	        sReason = "Operation failed";
	    else
		bOk = true;
	}
    }
    
    if (bOk)
	out.println("OK");
    else
	out.println(sReason);
    
    lia.web.servlets.web.Utils.logRequest("/users/delete.jsp?path="+sPath+"&ok="+bOk+"&reason="+sReason+"&user="+p, 0, request);
%>