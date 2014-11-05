<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /users/quotas.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final AlicePrincipal user = Users.get(request);
    
    if (user==null){
	System.err.println("users/quotas.jsp : Not authenticated");
	return;
    }

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    final Page p = new Page("users/quotas.res");

    p.modify("account", user.getName());

    pMaster.modify("title", "Grid quotas of "+user.getName());

    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/users/quotas.jsp?u="+user, baos.size(), request);
%>