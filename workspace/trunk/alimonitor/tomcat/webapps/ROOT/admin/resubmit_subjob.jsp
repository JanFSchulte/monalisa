<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*"%><%
    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final int pid = rw.geti("pid");
    
    final int id = rw.geti("id");
    
    String sReturn = rw.gets("return_path");
    
    if (pid==0 || id==0 || sReturn.length()==0){
	out.println("Error");
	return;
    }

    int iOldPid = -1;
    int iNewPid = -1;
    
    try{
	final alien.repository.Masterjob job = new alien.repository.Masterjob(pid);

	iOldPid = job.getPID();

	job.resubmitSubjob(id);
	
	iNewPid = job.getPID();
    }
    catch (Exception e){
	out.println(e);
	return;
    }
    
    if (iNewPid > iOldPid)
	sReturn = Format.replace(sReturn, "="+iOldPid, "="+iNewPid);
    
    response.sendRedirect(sReturn);
%>