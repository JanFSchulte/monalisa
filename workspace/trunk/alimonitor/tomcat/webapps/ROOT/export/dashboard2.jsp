<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /export/dashboard2.jsp", 0, request);

    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    out.println("VOBox,hostname,ip,alive,Services,Jobs,Storage IN (KB/s),Storage OUT (KB/s)");

    DB db = new DB();
    
    HashMap<String, Double> done_jobs = new HashMap<String, Double>();
    HashMap<String, Double> err_jobs  = new HashMap<String, Double>();
    
    db.query("select split_part(mi_key,'/',3),sum(mval) from monitor_ids inner join w4_1m_done_jobs_R on id=mi_id where mi_key like 'CERN/ALICE_Sites_Jobs_Summary/%/DONE_jobs_R' and rectime>extract(epoch from now()-'1 day'::interval)::int group by mi_key;");
    
    while (db.moveNext()){
	done_jobs.put(db.gets(1), db.getd(2));
    }
    
    db.query("select split_part(mi_key,'/',3),sum(mval) from monitor_ids inner join w4_1m_err_jobs_R on id=mi_id where mi_key like 'CERN/ALICE_Sites_Jobs_Summary/%/ERR_jobs_R' and rectime>extract(epoch from now()-'1 day'::interval)::int group by mi_key;");

    while (db.moveNext()){
	err_jobs.put(db.gets(1), db.getd(2));
    }
    
    db.query("select name,ip from (select distinct name,ip from abping_aliases inner join monitor_ids on name=split_part(mi_key,'/',1) and split_part(mi_key,'/',2)='AliEnServicesStatus' and name not like '%.cern.ch') as x order by lower(name) asc;");
    
    final String[] vsAlienServices = new String[]{"CE", "PackMan", "Monitor", "CMReport"};
    
    final monPredicate pAlien = new monPredicate("", "AliEnServicesStatus", "", -1, -1, new String[]{"Status"}, null);
    final monPredicate pSE  = new monPredicate("_TOTALS_", "", "_TOTALS_", -1, -1, new String[]{"total_traffic_in", "total_traffic_out"}, null);
    
    while (db.moveNext()){
	String sName = db.gets(1);
    
	out.print(sName+",");
	
	String sIP = db.gets(2);
	
	out.print(lazyj.Utils.getHostName(sIP)+","+sIP+",");
	
	Object o = Cache.getLastValue(ServletExtension.toPred(sName+"/MonaLisa/%/Load5"));
	
	out.print(o==null ? "-1," : "0,");
	
	int servicesCount = 0;
	int servicesOk = 0;
	
	for (String sService: vsAlienServices){
	    pAlien.Farm = sName;
	    pAlien.Node = sService;
	
	    o = Cache.getLastValue(pAlien);
	    
	    if (o!=null && (o instanceof Result)){
		servicesCount ++;
	    
		Result r = (Result) o;

		if (((int) r.param[0]) == 0)
		    servicesOk ++;
	    }
	}
	
	for (String sProxy: new String[]{"alien proxy", "Delegated proxy", "Proxy Server", "Proxy of the machine"}){
	    Double d = Cache.getDoubleValue(sName+"/*/"+sProxy+"/Status");
	
	    String sProxyUnder = sProxy.replaceAll(" ", "_");
	
	    if (d!=null){
		servicesCount ++;
		
		if (d.longValue()==0)
		    servicesOk ++;
	    }
	}

	int servicesStatus = -1;
    
	if (servicesCount>0){
	    if (servicesOk == servicesCount)
		servicesStatus = 0;
	    else
		servicesStatus = 1;
	}	
	
	out.print(servicesStatus+",");

	// --------------------------

	Double ddone = done_jobs.get(sName);
	Double derr = err_jobs.get(sName);
	
	double done = ddone!=null ? ddone.doubleValue() : 0;
	double err = derr!=null ? derr.doubleValue() : 0;
	
	double total = done + err;
	
	if (total<=0){
	    out.print("-1,");
	}
	else{
	    if (done/total < 0.3)
		out.print("1,");
	    else
		out.print("0,");
	}
	
	// --------------------------
	
	int storagesCount = 0;
	int storagesOk = 0;
	
	pSE.Cluster = "ALICE::"+sName+"::%";
	    
	Vector v = Cache.getLastValues(pSE);
	    
	double totalIn = 0;
	double totalOut = 0;
	    
	if (v!=null){
	    for (int i=0; i<v.size(); i++){
	        final Result r = (Result) v.get(i);
		    
		for (int j=0; j<r.param.length; j++){
		    if (r.param_name[j].endsWith("_in"))
			totalIn += r.param[j];
		    else
			totalOut += r.param[j];
		}
	    }
	}
	
	out.println(totalIn+","+totalOut);
    }

    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/dashboard2.jsp", 1, request);
%>