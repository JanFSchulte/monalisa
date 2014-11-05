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
    lia.web.servlets.web.Utils.logRequest("START /export/jobs2.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    final RequestWrapper rw = new RequestWrapper(request);

    out.println("#site,activity,parameter,value,pledged,status,start_time,end_time,url");

    final DB db = new DB("select name,ip,get_pledged(name, 2),lcg_name from (select distinct name,ip,lcg_name from abping_aliases inner join monitor_ids on name=split_part(mi_key,'/',1) and split_part(mi_key,'/',2)='AliEnServicesStatus' and name not like '%.cern.ch') as x where name not in ('CERN', 'CERN_lxgate') order by lower(name) asc;");
    
    final long lNow = System.currentTimeMillis();
    
    final int iHours = rw.geti("hours", 1);
    
    final long lInterval = 1000L*60*60*iHours;
    
    final long lStart = lNow - lInterval;
    
    final monPredicate pJobs = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{"RUNNING_jobs", "DONE_jobs_R", "ERR_jobs_R"}, null);
    
    final monPredicate pJobsSite = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{""}, null);
    
    final String[] sParameters = new String[]{"cpu_time_R", "cpu_ksi2k_R", "run_time_R", "run_ksi2k_R"};
    
    final monPredicate pResources = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInterval, -1, sParameters, null);
    
    final monPredicate pResourcesSite = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInterval, -1, new String[]{""}, null);
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    final DataSplitter ds = store.getDataSplitter(new monPredicate[]{pJobs, pResources}, 1000*60*2);
    
    final DB db2 = new DB();
    
    while (db.moveNext()){
	final String sMLName = db.gets(1);
	String sName = db.gets(4);
	
	if (sName.length()==0){
	    sName = sMLName;
	
	    int idx = sName.indexOf('_');
	    
	    if (idx<0)
		idx = sName.indexOf('-');
	
	    if (idx>0){
		sName = sName.substring(0, idx);
	    }
	    
	    String q = "select lcg_name from (select *,(exists (select name from hidden_sites h where h.name=a.name)) as hide from abping_aliases a) x where ((lower(name)='"+Format.escSQL(sName.toLowerCase())+"' and not hide) OR (name ~* '^"+Format.escSQL(sName)+"[_-].+$' and hide)) and length(lcg_name)>0;";
	    
	    //System.err.println(q);
	    
	    db2.query(q);
		
	    if (db2.moveNext()){
	        sName = db2.gets(1);
	    }
	    else
		sName = sMLName;
	}
	
	if (sName.length()==0)
	    sName = sMLName;
	
	if (sName.startsWith("#"))
	    sName = Format.replace(sName, "#", "");
	
	pJobsSite.Node = sMLName;
	pResourcesSite.Farm = sMLName;
	
	out.print(sName+",job_processing,parallel_jobs,");
	
	long lAverageRunningJobs = -1;
	
	double dDoneJobs = -1;
	
	pJobsSite.parameters[0] = "RUNNING_jobs";
	
	// parallel jobs
	
	Vector v = ds.get(pJobsSite);
	
	if (v.size()>0){
	    lAverageRunningJobs = 0;
	    
	    for (int i=0; i<v.size(); i++){
		lAverageRunningJobs += ((Result) v.get(i)).param[0];
	    }
	    
	    lAverageRunningJobs /= v.size();
	}
	
	out.println(lAverageRunningJobs+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/display?page=jobs_per_site&SiteBase="+Format.encode(sMLName));

	// done jobs

	pJobsSite.parameters[0] = "DONE_jobs_R";
	
	Vector vDone = ds.get(pJobsSite);
	
	long lDoneJobs = (long) integrate(vDone);

	// completed jobs
	
	pJobsSite.parameters[0] = "ERR_jobs_R";
	
	long lErrJobs = (long) integrate(ds.get(pJobsSite));
	
	long lCompletedJobs = lDoneJobs + lErrJobs;
	
	if (lCompletedJobs<-1) lCompletedJobs = -1;

	// set status fn(done/total)

	String sStatus = "good";

	if (lCompletedJobs>0){
	    final double ratio = (double) lDoneJobs / lCompletedJobs;
	    
	    if (ratio<0.4)
		sStatus = "error";
	    else
	    if (ratio<0.8)
		sStatus = "warning";
	    else
	    if (ratio<0.9)
		sStatus = "normal";
	}
	else{
	    sStatus = "idle";
	}

	out.println(sName+",job_processing,successfully_completed_jobs,"+lDoneJobs+",-1,"+sStatus+","+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/display?page=jobs_per_site_done&SiteBase="+Format.encode(sMLName));	
	out.println(sName+",job_processing,completed_jobs,"+lCompletedJobs+",-1,"+sStatus+","+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/display?page=jobs_per_site_done&SiteBase="+Format.encode(sMLName));
	
	for (String sParameter: sParameters){
	    pResourcesSite.parameters[0] = sParameter;
	
	    //out.print( (long) integrate(ds.get(pResourcesSite)) + ",");
	    
	    String s = sParameter;
	    
	    String sURL = "http://alimonitor.cern.ch/display?plot_series="+Format.encode(sMLName)+"&page=";
	    
	    long lPledged = -1;
	    
	    if (sParameter.equals("cpu_time_R")) {
		s = "CPU_time";
		sURL += "jobResUsageSum_time_cpu";
	    }
	    else
	    if (sParameter.equals("cpu_ksi2k_R")){
		s = "CPU_time_KSI2K";
		sURL += "jobResUsageSum_time_si2k";
	    }
	    else
	    if (sParameter.equals("run_time_R")){
		s = "wall_time";
		sURL += "jobResUsageSum_time_run";
	    }
	    else
	    if (sParameter.equals("run_ksi2k_R")){
		 s = "wall_time_KSI2K";
		 lPledged = db.getl(3, -1);
		sURL += "jobResUsageSum_time_run_si2k";
	    }
	    else
		continue;
	    
	    long lValue = (long) (integrate(ds.get(pResourcesSite))/3600);
	    
	    out.println(sName+",job_processing,"+s+","+lValue+","+lPledged+",unknown,"+(lStart/1000)+","+(lNow/1000)+","+sURL);
	}
	
	String sJobsURL = "http://alimonitor.cern.ch/display?plot_series="+Format.encode(sMLName)+"&page=jobs_per_site_done";
	
	out.println(sName+",general,all,-1,-1,ok,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/siteinfo/?site="+Format.encode(sMLName));
	out.println(sName+",general,MLname,"+sMLName+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/stats?page=vobox_status");
	out.println(sName+",general,IPaddr,"+db.gets(2)+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/stats?page=siteMLstatus");
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/jobs2.jsp", 1, request);
%>