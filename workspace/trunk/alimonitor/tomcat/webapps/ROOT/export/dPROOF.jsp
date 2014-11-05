<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.*,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /export/dPROOF.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    final monPredicate dPROOF = new monPredicate("*", "dPROOF", "*", -1000*60*10, -1, new String[]{"workers"}, null);

    final Vector v = Cache.getLastValues(dPROOF);
    
    final ArrayList al = Cache.filterByTime(v, dPROOF);
    
    for (Object o: al){
	if (o instanceof Result){
	    final Result r = (Result) o;
	    
	    if (r.param_name[0].equals("workers")){
		out.println(r.NodeName + "|workers|" + (int) r.param[0]);
	    }
	}
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/dPROOF.jsp", 1, request);
%>