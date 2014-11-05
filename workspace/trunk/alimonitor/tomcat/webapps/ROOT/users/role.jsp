<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*,auth.*"%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /users/upload.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	out.println("You are not authenticated");
	return;
    }
    
    final String sRole = Users.getRole(p, request);
    
    response.setContentType("text/html");
    
    final Page pRole = new Page("users/role.res");
    final Page pLine = new Page("users/role_line.res");

    pRole.modify("role", sRole);
    
    boolean bFound = false;
    
    final Set<String> names = new TreeSet<String>(p.getNames());

    for (String s : names){
	pLine.modify("role", s);
	
	if (s.equals(sRole)){
	    pLine.append("style", "font-weight:bold;");
	    bFound = true;
	}
	
	pRole.append(pLine);
    }
    
    try{
        final Set<String> roles = new TreeSet<String>(p.getRoles());
    
	for (String s : roles){
	    if (!names.contains(s)){
		pLine.modify("role", s);
		pLine.append("style", "font-style:italic;");
		
		if (s.equals(sRole)){
		    pLine.append("style", "font-weight:bold");
		    bFound = true;
		}
		
		pRole.append(pLine);
	    }
	}
    }
    catch (Throwable t){
	// ignore
    }
    
    if (!bFound){
	pLine.modify("role", sRole);
	pLine.modify("style", "color:orange;font-weight:bold");
	pRole.append(pLine);
    }

    pRole.comment("admin", p.canBecome("admin"));    
    
    out.println(pRole);
    
    lia.web.servlets.web.Utils.logRequest("/catalogue/role.jsp?user="+p+"&role="+sRole, 0, request);
%>