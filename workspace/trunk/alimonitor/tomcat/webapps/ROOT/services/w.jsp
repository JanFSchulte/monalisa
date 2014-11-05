<%@ page import="lia.Monitor.monitor.*,java.io.*,java.util.*,lazyj.*,lia.Monitor.Store.Cache,lia.Monitor.monitor.*" %><%!
    private static final monPredicate predRunning = new monPredicate("%", "%_Users_Jobs_Summary", "%", -1, -1, new String[]{"RUNNING_jobs"}, null);
    private static final monPredicate predWaiting = new monPredicate("%", "%_Users_Jobs_Summary", "%", -1, -1, new String[]{"WAITING_jobs"}, null);
    
    private static final String toString(final int i){
	String s = String.valueOf(i);
	
	while (s.length()<8)
	    s = " "+s;
	
	return s;
    }
    
    private static final class UserRecord{
        public int running = 0;
        public int waiting = 0;
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /services/uptime.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/plain");

    final RequestWrapper rw = new RequestWrapper(request);

    // is the content still valid in the cache?
    CachingStructure cs = PageCache.get(request, null);

    final boolean bCache = cs!=null;

    // if not, we have to generate it
    if (cs==null){
	final ByteArrayOutputStream os = new ByteArrayOutputStream(1024);
	
	final StringBuilder sResponse = new StringBuilder();
	
	final Vector<Object> running = Cache.getLastValues(predRunning);
	
	int totalRunning = 0;
	int users = 0;
	
	final Map<String, UserRecord> m = new TreeMap<String, UserRecord>();
	
	for (final Object o: running){
	    if (o instanceof Result){
		final Result r = (Result) o;
		
		if (r.NodeName.equals("_TOTALS_"))
		    totalRunning = (int) r.param[0];
		else
		    users++;
	    }
	}
	
	int totalWaiting = 0;
	
	final Vector<Object> waiting = Cache.getLastValues(predWaiting);
	
	for (final Object o: waiting){
	    if (o instanceof Result){
		final Result r = (Result) o;
		
		if (r.NodeName.equals("_TOTALS_"))
		    totalWaiting = (int) r.param[0];
	    }
	}
	
	sResponse.append(totalRunning+" running jobs, "+totalWaiting+" queued jobs, "+users+" active users");
	
	os.write(sResponse.toString().getBytes());
        os.flush();
	os.close();
	
	// save the content in the cache for 2 minutes
	//cs = PageCache.put(request, null, os.toByteArray(), 120*1000, "text/plain");
	cs = PageCache.put(request, null, os.toByteArray(), 1*1000, "text/plain");
    }
    
    // write output to the client
    cs.setHeaders(response);
    
    out.write(cs.getContentAsString());
    out.flush();
    
    // log the request
    lia.web.servlets.web.Utils.logRequest("/services/uptime.jsp?cache="+bCache, cs.length(), request);
%>