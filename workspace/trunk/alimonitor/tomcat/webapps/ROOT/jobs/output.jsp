<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*,alien.catalogue.*,alien.jobs.*,alien.taskQueue.*"%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /jobs/output.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();
    
    final int pid = rw.geti("pid");

    final int subjobid = rw.geti("id");

    try{
	final Job j = TaskQueueUtils.getJob(subjobid);
	
	if (j!=null && j.isDone()){
	    final String sJDL = j.getJDL();
	    
	    if (sJDL!=null){
		final alien.taskQueue.JDL jdl = new alien.taskQueue.JDL(sJDL);
	
		response.sendRedirect("/catalogue/?path="+Format.encode(jdl.getOutputDir()));
		return;
	    }
	}
    
	Masterjob job = new Masterjob(pid);
	
	if (job.getUsername()==null)
	    job = new Masterjob(pid, "admin");
	
	String path = job.registerOutput(subjobid);

	//System.err.println("RegisterOutput of "+subjobid+"@"+pid+" says path is : "+path);

	AliEnFile file = FileCache.getRefreshed(path, false);
	
	AliEnFile parent = FileCache.getRefreshed(file.getPath(), false);
	
	//file = new AliEnFile(path);
	
	String sFile = rw.gets("file");
	
	List<AliEnFile> list = file.list();
	
	if (list==null){
	    out.println("No files found in "+path);
	    return;
	}
	
	if (sFile.length()==0){
	    out.println("<B>Files of masterjob "+pid+", subjob "+subjobid+"</B><BR>");
	    out.println("<B>RegisterOutput folder: <a target=_blank href='/catalogue/?path="+Format.encode(path)+"'>"+Format.escHtml(path)+"</a><br><br>");
	    out.println("<table border=1 cellspacing=0 cellpadding=5>");
	    out.println("<tr bgcolor=#BBBBBB><th>Permissions</th><th>Owner</th><th>Group</th><th>Size</th><th>Date</th><th>File name</th></tr>");
	
	    for (AliEnFile f: list){
		out.println("<tr><td align=left>"+f.getPermissions()+"</td><td align=right>"+f.getOwner()+"</td><td align=right>"+f.getGroup()+"</td><td align=right>"+Format.size(f.getSize())+"</td><td align=right>"+new Date(f.getDate())+"</td><td align=left><a href='/users/download.jsp?view=true&path="+Format.encode(f.getCannonicalName())+"'>"+f.getName()+"</a></td></tr>");
	    }
	}
	else{
	    for (AliEnFile f: list){
		if (sFile.equals(f.getName())){
		    out.println(f.getContents(true));
		}
	    }
	}
    }
    catch (Exception e){
	e.printStackTrace();
    }
    
    lia.web.servlets.web.Utils.logRequest("/jobs/output.jsp", 0, request);
%>