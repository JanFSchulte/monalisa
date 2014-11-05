<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.Monitor.Store.*,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /siteinfo/index.jsp", 0, request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    // -------------------
    // Sites drop-down

    String sSite = rw.gets("site");
    
    if (sSite.length()==0){
	sSite = rw.getCookie("siteinfo_site");
    }

    final Page p = new Page(null, "siteinfo/index.res");

    final DB db = new DB("select name,contact_name,contact_email,version,java_ver,get_pledged(name, 2) AS ksi2k,ip from abping_aliases where name in (select name from alien_sites) order by lower(name) asc;");
    
    long lKSI2K=0;

    String sHostName = null;
    
    boolean bHostNameResolved = false;
    
    while (db.moveNext()){
	if (sSite.length()==0)
	    sSite = db.gets(1);
    
	p.append("opt_sites", "<option value='"+db.gets(1)+"' "+(db.gets(1).equals(sSite) ? "selected" : "")+">"+db.gets(1)+"</option>");
	
	if (db.gets(1).equals(sSite)){
	    p.fillFromDB(db);
	    lKSI2K = db.getl("ksi2k");
	    
	    sHostName = lia.web.utils.ThreadedPage.getHostName(db.gets("ip"));
	    
	    bHostNameResolved = !sHostName.equals(db.gets("ip"));
	    
	    p.modify("address", sHostName);
	}
    }

    // save the site
    final Cookie cookie = new Cookie("siteinfo_site", sSite);
    cookie.setMaxAge(Integer.MAX_VALUE);
    response.addCookie(cookie); 
    // -------------

    pMaster.modify("title", "Detailed site monitoring information for "+sSite);
    pMaster.modify("bookmark", "/siteinfo/?site="+Format.encode(sSite));
    
    p.modify("site", sSite);

    // -------------------
    // MonALISA status
    
    Double d = Cache.getDoubleValue(sSite+"/MonaLisa/localhost/ntpstatus");
    Object o;
    
    if (d!=null){
	p.modify("ntp_status", d.longValue()==0 ? "<font color=green>SYNC</font>" : "<font color=red>UNSYNC</font>");
	p.modify("ntp_sync", ""+(d.longValue()==0));
    }
    else{
	p.modify("ntp_status", "n/a");
    }
    
    d = Cache.getDoubleValue(sSite+"/MonaLisa/localhost/ntpoffset");
    
    if (d!=null){
	p.modify("ntp_offset", (d<0?"-":"")+Formatare.showInterval(Math.abs(d.longValue())));
	
	if (Math.abs(d.longValue())>1000){
	    p.modify("ntp_offset_font", "<font color=red><b>");
	}
	
	p.modify("ntp_offset_ok", ""+(Math.abs(d.longValue())<1000));
    }
    
    // -------------------
    // Services status
    
    p.modify("alien_version", (String) Cache.getObjectValue(sSite+"/AliEnTestsStatus/alien version/Message"));
    
    for (String sService: new String[]{"CE", "Monitor", "PackMan"}){
	d = Cache.getDoubleValue(sSite+"/AliEnServicesStatus/"+sService+"/Status");
	
	if (d!=null){
	    p.modify(sService+"_status", d.longValue()==0 ? "<font color=green><b>OK</b></font>" : "<font color=red><b>DOWN</b></font>");
	    
	    if (d.longValue()>0){
		String sstatus = (String) Cache.getObjectValue(sSite+"/AliEnServicesStatus/"+sService+"/Message");
		p.modify(sService+"_message", sstatus);
	    }
	}
	else{
	    p.modify(sService+"_status", "n/a");
	}
    }
    
    final Object oCEInfo = Cache.getLastValue(new monPredicate(sSite, "AliEnServicesStatus", "CE", -1, -1, new String[]{"Info"}, null));

    if (oCEInfo!=null && (oCEInfo instanceof eResult)){
	final eResult rCEInfo = (eResult) oCEInfo;

	String info = (String) rCEInfo.param[0];

	if (info.indexOf("No job matched your")>=0){
	    info = "<font color=#009ad2>"+info+"</font>";
	}
	else{
	    info = "<font color=#999900>"+info+"</font>";
	}

	p.modify("CE_info", info);
	p.modify("CE_info_time", rCEInfo.time);
    }
    
    if (bHostNameResolved){
	final Set<String> sMaxQueuedJobs = auth.LDAPHelper.checkLdapInformation("host="+sHostName, "ou=CE,ou=Services,ou="+sSite+",ou=Sites,", "maxqueuedjobs");
	
	if (sMaxQueuedJobs!=null && sMaxQueuedJobs.size()>0){
	    final Iterator<String> it = sMaxQueuedJobs.iterator();
	    p.modify("CE_maxqueuedjobs", it.next());

	    // try to get the second parameter only if the first was found
	    final Set<String> sMaxJobs = auth.LDAPHelper.checkLdapInformation("host="+sHostName, "ou=CE,ou=Services,ou="+sSite+",ou=Sites,", "maxjobs");
	
	    if (sMaxJobs!=null && sMaxJobs.size()>0){
		final Iterator<String> it2 = sMaxJobs.iterator();
		p.modify("CE_maxjobs", it2.next());
	    }
	}
    }
    
    // -------------------
    // Proxies
    
    for (String sProxy: new String[]{"alien proxy", "Delegated proxy", "Proxy Server", "Proxy of the machine"}){
	d = Cache.getDoubleValue(sSite+"/*/"+sProxy+"/Status");
	
	String sProxyUnder = sProxy.replaceAll(" ", "_");
	
	if (d!=null){
	    p.modify(sProxyUnder+"_status", d.longValue()==0 ? "<font color=green><b>OK</b></font>" : "<font color=red><b>FAIL</b></font>");
	}
	else{
	    p.modify(sProxyUnder+"_status", "n/a");
	}

	d = Cache.getDoubleValue(sSite+"/*/"+sProxy+"/timeleft");
	
	if (d!=null)
	    p.modify(sProxyUnder+"_timeleft", (d<0?"-":"")+Formatare.showInterval(Math.abs(d.longValue()*1000)));
	else
	    p.modify(sProxyUnder+"_timeleft", "n/a");

	o = Cache.getObjectValue(sSite+"/*/"+sProxy+"/Message");
	
	if (o!=null)
	    p.modify(sProxyUnder+"_message", o.toString());
    }
    
    // -------------------
    // SAM tests
    /*
    for (String sTest: new String[]{"DPD", "PM", "PR", "PSR", "RBS", "SA", "SS", "UPR", "WMS"}){
	d = Cache.getDoubleValue("_TOTALS_/SAMTests/"+sSite+"/"+sTest+"_Status");
	
	if (d!=null){
	    p.append(sTest+"_status", "<font color=");
	    p.append(sTest+"_status", d.longValue()==0 ? "green><b>OK" : (d.longValue()==1 ? "red><b>ERROR" : "orange><b>WARNING"));
	    p.append(sTest+"_status", "</b></font>");
	}
	else{
	    p.modify(sTest+"_status", "n/a");
	}
	
	p.modify(sTest+"_link", (String) Cache.getObjectValue("_TOTALS_/SAMTests/"+sSite+"/"+sTest+"_Link"));
    }
    */
    
    // -------------------
    // Active jobs
    for (String sState: new String[]{"ASSIGNED", "RUNNING", "SAVING"}){
	d = Cache.getDoubleValue("CERN/ALICE_Sites_Jobs_Summary/"+sSite+"/"+sState+"_jobs");
	
	if (d!=null){
	    String sValue = ""+d.longValue();
	
	    if (sState.equals("RUNNING"))
		sValue = "<font color="+(d.longValue()>0 ? "green" : "red")+"><b>"+sValue+"</b></font>";
	
	    p.modify(sState+"_jobs", sValue);
	}
	else{
	    p.modify(sState+"_jobs", "n/a");
	}
    }
    
    // -------------------
    // Accounting
    
    final long lMinTime = 86400000;
    final long lMaxTime = 0;
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    final Properties prop = new Properties();
    prop.setProperty("compact.min_interval", "120000");
    prop.setProperty("compact.displaypoints", "200");
    prop.setProperty("history.integrate.enable", "true");
    prop.setProperty("history.integrate.timebase", "1");
    prop.setProperty("data.align_timestamps", "true");
    prop.setProperty("default.measurement_interval", "120");

    for (String sState: new String[] {"DONE", "FAILED", "ERR"}){
	monPredicate pred = Formatare.toPred("CERN/ALICE_Sites_Jobs_Summary/"+sSite+"/-"+lMinTime+"/-1/"+sState+"_jobs_R");
    
	DataSplitter ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);
    
	Vector v = ds.get(pred);
    
	if (v!=null && v.size()>0){
	    lia.web.servlets.web.Utils.integrateSeries(v, prop, true, lMinTime, lMaxTime);
	
	    long l = (long) ((Result) v.lastElement()).param[0];
	
	    String sValue = ""+l;
	
	    if (sState.equals("DONE"))
		sValue = "<font color="+(l==0 ? "red" : "green")+"><b>"+sValue+"</b></font>";
	    else
		sValue = "<font color="+(l>0 ? "red" : "green")+"><b>"+sValue+"</b></font>";
	
    	    if (v!=null && v.size()>0){
		p.modify(sState+"_jobs", sValue);
	    }
	}
    }
    
    // -------------------
    // SI2k
    monPredicate pred = Formatare.toPred(sSite+"/Site_Jobs_Summary/sum/-"+lMinTime+"/-1/run_ksi2k_R");
    
    DataSplitter ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);

    Vector v = ds.get(pred);
    
    if (v!=null && v.size()>0){
        lia.web.servlets.web.Utils.integrateSeries(v, prop, true, lMinTime, lMaxTime);
	
    	if (v!=null && v.size()>0){
    	    long l = (long) (((Result) v.lastElement()).param[0]/87600);

	    String sValue = "<font color="+(l*100<lKSI2K*75 ? "red" : "green")+">"+l+"</font>";
    	
	    p.modify("si2k_consumed", sValue);
	}
    }
    
    p.modify("si2k_consumed", "<font color=red><b>0</b></font>");
    
    // -------------------
    // Site averages
    
    double dCount = 0;
    
    for (String sParam: new String[]{"count", "ksi2k_factor"}){
	pred = Formatare.toPred(sSite+"/Site_Nodes_Summary/sum/-"+lMinTime+"/-1/"+sParam);
    
	ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);

	v = ds.get(pred);
    
	if (v!=null && v.size()>0){
	    double dSum = 0;
	
	    for (int i=0; i<v.size(); i++){
		Result r = (Result) v.get(i);
	        dSum += r.param[0];
	    }
	
	    if (sParam.equals("count"))
		dCount = dSum/v.size();
	
	    if (sParam.equals("ksi2k_factor") && dCount>0)
		dSum /= dCount;
	
	    p.modify("avg_"+sParam, DoubleFormat.point(dSum/v.size()));
	}
    }
    
    // -------------------
    // VoBox parameters (MonaLisa cluster)
    for (String sParam: new String[]{"mem_usage", "total_mem", "processes", "sockets_tcp", "sockets_udp", "no_CPUs", "cpu_MHz", "uptime"}){
	d = Cache.getDoubleValue(sSite+"/Master/*/"+sParam);
	
	if (d!=null && d>=0){
	    String sValue = sParam.equals("total_mem") ? DoubleFormat.size(d, "M")+"B" : DoubleFormat.point(d);
	    
	    if (sParam.equals("uptime"))
		sValue = Formatare.showInterval((long) (d*1000*60*60*24));
	    
	    p.modify(sParam, sValue);
	}
    }
    
    for (String sParam: new String[]{"load1"}){
	pred = Formatare.toPred(sSite+"/Master/*/-3600000/-1/"+sParam);
	
	ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);
	
	v = ds.get(pred);
	
	if (v!=null && v.size()>0){
	    double dSum = 0;
	
	    for (int i=0; i<v.size(); i++){
		Result r = (Result) v.get(i);
	        dSum += r.param[0];
	    }
	    
	    dSum /= v.size();
	    
	    String sValue = sParam.equals("total_mem") ? DoubleFormat.size(dSum, "M")+"B" : DoubleFormat.point(dSum);
	    
	    if (sParam.equals("load1")){
		sValue = "<font color="+(dSum>1 ? "red" : "green")+"><b>"+sValue+"</b></font>";
	    }
	    
	    p.modify("avg_"+sParam, sValue);
	}
    }
    
    for (String sParam: new String[]{"CPU_idle", "CPU_int", "CPU_iowait", "CPU_nice", "CPU_softint", "CPU_steal", "CPU_sys", "CPU_usr"}){
	pred = Formatare.toPred(sSite+"/MonaLisa/localhost/-3600000/-1/"+sParam);
	
	ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);
	
	v = ds.get(pred);
	
	double dSum = 0;
	
	if (v!=null && v.size()>0){
	    for (int i=v.size()-1; i>=0; i--){
		Result r = (Result) v.get(i);
	        dSum += r.param[0];
	    }
	    
	    dSum /= v.size();
	}
	    
	p.modify("avg_"+sParam, DoubleFormat.point(dSum));
    }
    
    // -------------------
    // SE status
    Page pSE = new Page(null, "siteinfo/index_storage.res");
    
    String sSiteBaseName = sSite;
    
    if (sSiteBaseName.indexOf('-')>0)
	sSiteBaseName = sSiteBaseName.substring(0, sSiteBaseName.indexOf('-'));
    
    db.query("select distinct split_part(mi_key,'/',3) from monitor_ids where mi_key ilike '_TOTALS_/Site_SE_Status/ALICE::"+Format.escSQL(sSiteBaseName)+"::%' and split_part(mi_key,'/',3)!='SCRIPTRESULT';");
    while (db.moveNext()){
	String sSE = db.gets(1);
	
	String sSiteSE = "_TOTALS_/Site_SE_Status/"+sSE+"/";
    
	pSE.modify("name", sSE);
	
	for (String sParam: new String[]{"Status", "type"}){
	    pSE.modify(sParam, (String) Cache.getObjectValue(sSiteSE+sParam));
	}
	
	for (String sParam: new String[]{"avail_gb", "size_gb", "used_gb", "usage", "n_files"}){
	    d = Cache.getDoubleValue(sSiteSE+sParam);
	    
	    if (d!=null && d.doubleValue()>=0){
		String sValue;
		
		if (sParam.endsWith("_gb"))
		    sValue = DoubleFormat.size(d, "G")+"B";
		else
		if (sParam.equals("usage"))
		    sValue = DoubleFormat.point(d)+"%";
		else
		    sValue = DoubleFormat.size(d, "B");
	    
		pSE.modify(sParam, sValue);
	    }
	    else{
		pSE.modify(sParam, "-");
	    }
	}
	
	d = Cache.getDoubleValue("_STORAGE_/"+sSE+"/ADD/Status");
	
	if (d!=null){
	    pSE.modify("test_add", d.longValue()==0 ? "<font color=green><b>OK</b></font>" : "<font color=red><b>FAIL</b></font>");
	}
	
	pSE.modify("test_add_message", (String) Cache.getObjectValue("_STORAGE_/"+sSE+"/ADD/Message"));
	
	p.append("selist", pSE);
    }
    
    // -------------------
    // VoBox paths
    
    Page pPath = new Page(null, "siteinfo/index_path.res");
    
    for (String sPath: new String[]{"TMP", "LOG", "CACHE"}){
	String sPred = sSite+"/Master/*/"+sPath+"_DIR_";
	
	pPath.modify("name", sPath);
	pPath.modify("path", (String) Cache.getObjectValue(sPred+"path"));
	
	boolean bErr = false;
	boolean bWarn = false;
	boolean bKnown = false;
	
	for (String sParam: new String[]{"free", "total", "used", "usage"}){
	    d = Cache.getDoubleValue(sPred+sParam);
	    
	    String sValue = "n/a";
	    
	    if (d!=null){
		if (d>=0){
	    	    sValue = sParam.equals("usage") ? DoubleFormat.point(d)+"%" : DoubleFormat.size(d, "M")+"B";
	    	    
	    	    if ( (sParam.equals("free") && d.longValue()<1000) || (sParam.equals("usage") && d.longValue()>=95) )
	    		bWarn = true;
	    	}
	    	else{
	    	    bErr = true;
	    	}
	    	
	    	bKnown = true;
	    }
	    
	    pPath.modify(sParam, sValue);
	}
	
	if (bErr){
	    pPath.modify("message", (String) Cache.getObjectValue(sPred+"msg"));
	    pPath.modify("name_color", "red");
	}
	else
	if (bWarn){
	    pPath.modify("message", "Low disk space. Consider freeing some space on this partition!");
	    pPath.modify("name_color", "orange");
	}
	else
	if (bKnown)
	    pPath.modify("name_color", "green");
	else
	    pPath.modify("name_color", "grey");
	    
	p.append("path_status", pPath);
    }
    
    // -------------------

    pMaster.append(p);
    
    // -------------------
    
    pMaster.write();
    
    out.println(new String(baos.toByteArray()));
    
    lia.web.servlets.web.Utils.logRequest("/siteinfo/index.jsp?site="+sSite, baos.size(), request);
%>