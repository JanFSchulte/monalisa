<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*"%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    int run = rw.geti("run");
    int pass = rw.geti("pass", 1);
    
    String sReturn = rw.gets("return");
    
    if (run==0){
	out.println("Error");
	return;
    }

    try{
	(new alien.runs.Run(run)).updateProcessingStatus(pass);
    }
    catch (Exception e){
    }
    
    response.sendRedirect(sReturn.length()>0 ? sReturn : "/raw/");
%>