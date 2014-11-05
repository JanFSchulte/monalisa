<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*"%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    int pid = rw.geti("pid");
    
    String sReturn = rw.gets("return");
    
    if (pid==0){
	out.println("Error");
	return;
    }

    try{
	System.err.println("admin/updateStatus.jsp?pid="+pid+" : "+alien.repository.Masterjob.updateStatus(pid, false));
    }
    catch (Exception e){
    }
    
    response.sendRedirect(sReturn.length()>0 ? sReturn : "/raw/");
%>