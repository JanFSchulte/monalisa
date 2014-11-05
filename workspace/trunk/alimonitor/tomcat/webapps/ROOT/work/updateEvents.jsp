<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*,alien.catalogue.*,java.util.regex.*"%><%!
%><%
    if (!request.getRemoteAddr().equals("127.0.0.1")){
	out.println("no");
	return;
    }

    lia.web.servlets.web.Utils.logRequest("START /work/updateEvents.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    final int iRun = rw.geti("run");
    
    if (iRun<=0){
	out.println("No run");
	return;
    }

    final int pass = rw.geti("pass", 1);
    
    out.println("Changed:"+alien.repository.RawDataRun.updateProcessingStatus(iRun, pass));    	
    
    lia.web.servlets.web.Utils.logRequest("/work/se_hist.jsp", 0, request);
%>