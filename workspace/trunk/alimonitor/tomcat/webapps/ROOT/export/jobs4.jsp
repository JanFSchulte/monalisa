<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.*,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%!
    static final double integrate(Vector v){
	if (v.size()<=0)
	    return -1;
    
	double d = 0;
	
	for (int i=0; i<v.size(); i++){
	    d += ((Result) v.get(i)).param[0] * 60 * 2;
	}
	
	return d;
    }
%><%
    response.setContentType("text/plain");

    RequestWrapper.setNotCache(response);

    RequestWrapper rw = new RequestWrapper(request);

    final long lNow = System.currentTimeMillis();
    
    final long lInterval = 1000L*60*60*24*365;
    
    final long lStart = lNow - lInterval;
    
    final monPredicate pJobs = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{"DONE_jobs_R", "ERR_jobs_R"}, null);

    final monPredicate pJobsSite = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{""}, null);
    
    DB db = new DB();
    
    db.query("SELECT name FROM abping_aliases WHERE name in (SELECT name from alien_sites) ORDER BY lower(name) ASC;");
    
    out.println("#site,date,parameter,value");
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    final DataSplitter ds = store.getDataSplitter(new monPredicate[]{pJobs}, 1000*60*60*24);
        
    final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
    while (db.moveNext()){
	final String sMLName = db.gets(1);
	
	pJobsSite.Node = sMLName;

	for (String sParam: new String[]{"DONE", "ERR"}){
	    pJobsSite.parameters[0] = sParam+"_jobs_R";
	
	    Vector<Result> vDone = (Vector<Result>)ds.get(pJobsSite);

	    for (Result r: vDone){
		int i = (int) Math.round(r.param[0]*60*60*24);
	    
		out.println(sMLName+","+sdf.format(new Date(r.time))+","+sParam+","+i);
	    }
	}
    }
%>
