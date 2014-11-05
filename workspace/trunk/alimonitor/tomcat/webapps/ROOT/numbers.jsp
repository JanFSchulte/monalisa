<%@ page import="lia.Monitor.monitor.*,java.io.*,java.util.*,lazyj.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /numbers.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/plain");

    final RequestWrapper rw = new RequestWrapper(request);

    // the parameter that is requested. for now only "runningjobs" is understood, anything else is ignored
    final String s = rw.gets("series");
    
    // is the content still valid in the cache?
    CachingStructure cs = PageCache.get(request, null);

    final boolean bCache = cs!=null;

    // if not, we have to generate it
    if (cs==null){
	final ByteArrayOutputStream os = new ByteArrayOutputStream(50);
	
	String sResponse = "";
	
	try{
	    if (s.length()==0 || s.equals("runningjobs")){
		// build the predicate that will give the required parameter
		monPredicate pred = lia.web.utils.Formatare.toPred("CERN/ALICE_Sites_Jobs_Summary/_TOTALS_/RUNNING_jobs");
	
		// extract the last received value from the values cache
		Result r = (Result) lia.Monitor.Store.Cache.getLastValue(pred);
	    
		// show the value
	        sResponse = ""+Math.round(r.param[0]);
	        
	        //sResponse = "25001";
	    }
	}
	catch (Exception e){
	    // ignore any error
	}
	
	os.write(sResponse.getBytes());
        os.flush();
	os.close();
	
	// save the content in the cache for 2 minutes
	cs = PageCache.put(request, null, os.toByteArray(), 120*1000, "text/plain");
    }
    
    // write output to the client
    cs.setHeaders(response);
    
    out.write(cs.getContentAsString());
    out.flush();
    
    // log the request
    lia.web.servlets.web.Utils.logRequest("/numbers.jsp?series="+s+"&cache="+bCache, cs.length(), request);
%>