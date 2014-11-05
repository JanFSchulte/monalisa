<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.repository.*"%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    int pid = rw.geti("pid");

    String sState = rw.gets("state");    
    
    String sReturn = rw.gets("return_path");
    
    if (pid==0 || sState.length()==0 || sReturn.length()==0){
	out.println("Error");
	return;
    }

    int iOldPid = -1;
    int iNewPid = -1;
    
    try{
	final alien.repository.Masterjob job = new alien.repository.Masterjob(pid);

	iOldPid = job.getPID();

	job.resubmitErrorJobs(sState);

	iNewPid = job.getPID();
    }
    catch (Exception e){
	out.println(e);
	return;
    }
    
    if (iNewPid > iOldPid){
	System.err.println("admin/resubmit_state.jsp : Old pid : "+iOldPid+" - new pid : "+iNewPid);
	sReturn = Format.replace(sReturn, "="+iOldPid, "="+iNewPid);
    }
    
    response.sendRedirect(sReturn);
%>