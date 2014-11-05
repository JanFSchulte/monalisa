<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*,auth.*"%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    final RequestWrapper rw = new RequestWrapper(request);

    RequestWrapper.setNotCache(response);

    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/resubmit.jsp : User is not authenticated");
	return;
    }

    final int pid = rw.geti("pid");
    
    final int id = rw.geti("id");
    
    final String state = rw.gets("state");
    
    String sReturn = rw.gets("return_path");
    
    if (pid==0 || (id==0 && state.length()==0) || sReturn.length()==0){
	out.println("Error");
	return;
    }

    int iOldPid = -1;
    int iNewPid = -1;
    
    try{
	final alien.jobs.Masterjob m = new alien.jobs.Masterjob(pid);
	
	if (m.getStatus()==null){
	    out.println("Job no longer in the queue");
	    return;
	}
	
	String sUser = m.getUsername();

	System.err.println("users/resubmit.jsp : "+p+" wants to resubmit pid="+pid+", id="+id+" || state = "+state+", of "+sUser);
	
	if (!p.canBecome(sUser)){
	    out.println("You are not authorized to manage these jobs");
	    System.err.println("users/resubmit.jsp :  but it is not authorized to do that");
	    return;
	}
    
	final alien.repository.Masterjob job = new alien.repository.Masterjob(pid);

	iOldPid = job.getPID();

	if (id>0){
	    final int newid = job.resubmitSubjob(id);
	    System.err.println("users/resubmit.jsp :     new (sub)job id   : "+newid);
	}
	
	if (state.length()>0){
	    final int count = job.resubmitErrorJobs(state);
	    System.err.println("users/resubmit.jsp :     resubmitted "+count+" subjobs");
	}
	
	iNewPid = job.getPID();
	
	if (iNewPid > iOldPid){
	    System.err.println("users/resubmit.jsp :       masterjob ID has changed from "+iOldPid+" to "+iNewPid);
	}
    }
    catch (Exception e){
	out.println(e);
	return;
    }
    
    if (iNewPid > iOldPid)
	sReturn = Format.replace(sReturn, "="+iOldPid, "="+iNewPid);
    
    response.sendRedirect(sReturn);
%>