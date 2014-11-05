<%@ page import="lazyj.*,auth.*,alimonitor.*,alien.pool.*,alien.catalogue.*,java.util.*,lazyj.commands.*,alien.taskQueue.*,alien.user.*" %><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    final AlicePrincipal p = Users.get(request);
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    response.setContentType("text/html");
    
    if (p==null){
	out.println("You are not authenticated");
	return;
    }
    
    final String sRole = Users.getRole(p, request);
    
    final String sJDL = rw.gets("jdl").trim();
    final String sParameters = rw.gets("parameters").trim();
    
    if (sJDL.length()==0){
	out.println("No JDL");
	return;
    }
    
    final AliEnFile f = FileCache.getFile(sJDL);

    if (f==null){
	System.err.println("users/submit.jsp : invalid path : "+sJDL);
	return;
    }
    
    if (!f.exists() || !f.isFile()){
	out.println("The file you specified does not exist");
	return;
    }
    
    /*
    final List<CommandOutput> outputs = AliEnPool.executeCommands("admin", Arrays.asList(
	    "user - "+sRole,
	    "submit "+sJDL+(sParameters.length()>0 ? " "+sParameters : ""),
	    "user - admin"
	), Arrays.asList(
	    Boolean.TRUE, 
	    Boolean.TRUE, 
	    Boolean.TRUE
	)
    );
    
    if (outputs==null || outputs.size()!=3){
	out.println("Could not talk to AliEn");
	return;
    }
    
    final CommandOutput co = outputs.get(1);
    
    if (co==null){
	out.println("No output from submit command");
	return;
    }
    
    //out.println(outputs);
    
    out.println(co.stdout);
    */
    
    final int pid = TaskQueueUtils.submit(LFNUtils.getLFN(sJDL), UserFactory.getByUsername(sRole), sRole, TaskQueueUtils.splitArguments(sParameters));
%>
    New job ID: <a href="/jobs/details.jsp?pid=<%=pid%>"><%=pid%></a>
<%
    
    lia.web.servlets.web.Utils.logRequest("/users/submit.jsp?jdl="+sJDL+"&parameters="+sParameters+"&user="+p, 0, request);
%>