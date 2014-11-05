<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,alien.pool.*,lazyj.commands.*"%><%
    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    StringTokenizer st = new StringTokenizer(rw.gets("ids"), "\t ,;");
    
    response.setContentType("text/plain");
    
    while (st.hasMoreTokens()){
	int id = Integer.parseInt(st.nextToken());
	
	int resubmitted = new alien.repository.Masterjob(id).resubmitErrorJobs();
	
	out.println(id+" : "+resubmitted+" jobs");
	out.flush();
	
	System.err.println("resubmitList.jsp : "+id+ " : "+resubmitted);
    }
%>