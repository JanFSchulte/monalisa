<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.AliEnFile,java.io.*,alien.pool.*,java.util.*" buffer="16kb"%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /users/su.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);

    String sRole = rw.gets("role");

    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	out.println("Who are you ?");
	return;
    }

    if (sRole.length()>0){
	if (!p.canBecome(sRole)){
	    out.println("You are not allowed to become "+sRole);
	    return;
	}

	final Cookie cookie = new Cookie("alien_role", sRole);
	cookie.setMaxAge(Integer.MAX_VALUE);
	cookie.setPath("/");
	response.addCookie(cookie);
    }

    if (rw.getb("redirect", false)){
	response.sendRedirect("role.jsp");
    }
    else{
	out.println("OK");
    }
%>