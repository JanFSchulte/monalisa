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
    lia.web.servlets.web.Utils.logRequest("START /export/jobs3.jsp", 0, request);

    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    RequestWrapper rw = new RequestWrapper(request);

    out.println("#site,activity,parameter,value,pledged,status,start_time,end_time,url");

    final DB db = new DB("select name,ip,get_pledged(name, 2),lcg_name from (select distinct name,ip,lcg_name from abping_aliases inner join monitor_ids on name=split_part(mi_key,'/',1) and split_part(mi_key,'/',2)='AliEnServicesStatus' and name not like '%.cern.ch') as x where name not in ('CERN', 'CERN_lxgate') AND name='NIHAM' order by lower(name) asc;");
    
    final long lNow = System.currentTimeMillis();
    
    final int iHours = rw.geti("hours", 1);
    
    final long lInterval = 1000L*60*60*iHours;
    
    final long lStart = lNow - lInterval;
    
    final monPredicate pJobs = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{"RUNNING_jobs", "DONE_jobs_R", "ERR_jobs_R"}, null);

    //System.err.println("IDs: "+lia.Monitor.Store.Fast.IDGenerator.getIDs(pJobs));
    
    final monPredicate pJobsSite = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -lInterval, -1, new String[]{""}, null);
    
    final String[] sParameters = new String[]{"cpu_time_R", "cpu_ksi2k_R", "run_time_R", "run_ksi2k_R"};
    
    final monPredicate pResources = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInterval, -1, sParameters, null);
    
    final monPredicate pResourcesSite = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInterval, -1, new String[]{""}, null);
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    //System.err.println("Jobs: "+pJobs);
    //System.err.println("Resources: "+pResources);
    
    final DataSplitter ds = store.getDataSplitter(new monPredicate[]{pJobs, pResources}, 1000*60*2);
    
    //System.err.println("DS: "+ds);
    
    while (db.moveNext()){
	final String sMLName = db.gets(1);
	final String sName = db.gets(4).length()>0 ? db.gets(4) : sMLName;
	
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
	
	if (sName.equals("NIHAM")){
	    //System.err.println("Done data:\n"+vDone.size());
	    //System.err.println("Integrated done jobs: "+lDoneJobs);
	    
	    //System.err.println("Running data:\n"+v.size());
	}
	
	out.println(sName+",job_processing,successfully_completed_jobs,"+lDoneJobs+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/display?page=jobs_per_site_done&SiteBase="+Format.encode(sMLName));

	// completed jobs
	
	pJobsSite.parameters[0] = "ERR_jobs_R";
	
	long lErrJobs = (long) integrate(ds.get(pJobsSite));
	
	long lCompletedJobs = lDoneJobs + lErrJobs;
	
	if (lCompletedJobs<-1) lCompletedJobs = -1;
	
	out.println(sName+",job_processing,completed_jobs,"+lCompletedJobs+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/display?page=jobs_per_site_done&SiteBase="+Format.encode(sMLName));
	
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
	
	out.println(sName+",general,all,-1,-1,ok,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/siteinfo/?site="+Format.encode(sMLName));
	out.println(sName+",general,MLname,"+sMLName+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/stats?page=vobox_status");
	out.println(sName+",general,IPaddr,"+db.gets(2)+",-1,unknown,"+(lStart/1000)+","+(lNow/1000)+",http://alimonitor.cern.ch/stats?page=siteMLstatus");
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/jobs3.jsp", 1, request);
%>