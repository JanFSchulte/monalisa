<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.*,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%!
    static final String getAlias(final String sSite){
	return sSite;
    }
    
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
    lia.web.servlets.web.Utils.logRequest("START /export/jobs.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    out.println("site,vo,activity,parallel jobs(number),completed jobs(number),cpu time(seconds),cpu si2k time(seconds),wall time(seconds),wall si2k time(seconds),start time(epoch in seconds),end time(epoch in seconds)");

    DB db = new DB("select name,ip from (select distinct name,ip from abping_aliases inner join monitor_ids on name=split_part(mi_key,'/',1) and split_part(mi_key,'/',2)='AliEnServicesStatus' and name not like '%.cern.ch') as x order by lower(name) asc;");
    
    long lNow = System.currentTimeMillis();
    long lStart = lNow - 1000*60*60;
    
    final monPredicate pJobs = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -1000*60*60, -1, new String[]{"RUNNING_jobs", "DONE_jobs_R"}, null);
    
    final monPredicate pJobsSite = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -1, -1, new String[]{""}, null);
    
    final String[] sParameters = new String[]{"cpu_time_R", "cpu_ksi2k_R", "run_time_R", "run_ksi2k_R"};
    
    final monPredicate pResources = new monPredicate("*", "Site_Jobs_Summary", "sum", -1000*60*60, -1, sParameters, null);
    
    final monPredicate pResourcesSite = new monPredicate("*", "Site_Jobs_Summary", "sum", -1000*60*60, -1, new String[]{""}, null);
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();
    
    final DataSplitter ds = store.getDataSplitter(new monPredicate[]{pJobs, pResources}, 1000*60*2);
    
    while (db.moveNext()){
	String sName = getAlias(db.gets(1));
	
	pJobsSite.Node = sName;
	pResourcesSite.Farm = sName;
	
	out.print(sName+",ALICE,Overall jobs,");
	
	long lAverageRunningJobs = -1;
	
	double dDoneJobs = -1;
	
	pJobsSite.parameters[0] = "RUNNING_jobs";
	
	Vector v = ds.get(pJobsSite);
	
	if (v.size()>0){
	    lAverageRunningJobs = 0;
	    
	    for (int i=0; i<v.size(); i++){
		lAverageRunningJobs += ((Result) v.get(i)).param[0];
	    }
	    
	    lAverageRunningJobs /= v.size();
	}
	
	pJobsSite.parameters[0] = "DONE_jobs_R";
	
	out.print( lAverageRunningJobs+"," + (long) integrate(ds.get(pJobsSite))+",");
	
	for (String sParameter: sParameters){
	    pResourcesSite.parameters[0] = sParameter;
	
	    out.print( (long) integrate(ds.get(pResourcesSite)) + ",");
	}
	
	pJobsSite.parameters[0] = "DONE_jobs_R";
	
	dDoneJobs = integrate(ds.get(pJobsSite));
	
	out.println((lStart/1000)+","+(lNow/1000) );
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/jobs.jsp", 1, request);
%>