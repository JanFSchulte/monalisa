<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.util.regex.*,java.io.*,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.web.utils.HtmlColorer,lia.Monitor.Store.Cache,lia.Monitor.monitor.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /dashboard2/index.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final String PATH="dashboard2/";
    
    final Page p = new Page(baos, PATH+"index.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "300");
    
    pMaster.modify("bookmark", "/"+PATH);
    pMaster.modify("title", "Shifters' dashboard");

    // ----- parameters
    
    DB db = new DB();
    
    // ----- SHUTTLE
    
    final monPredicate predShuttle = new monPredicate("pcalishuttle01", "ROOT_SHUTTLE_PROD", "__PROCESSINGINFO__", -1, -1, new String[]{"SHUTTLE_status"}, null);    

    Object o = Cache.getLastValue(predShuttle);
    
    boolean bOnline = false;
    
    if (o!=null){
	long lTime = Cache.getResultTime(o);
	
	bOnline = lTime > System.currentTimeMillis() - 1000*60*15;
    }
    
    if (bOnline){
	p.modify("shuttle_status", "<font color=green><b>ONLINE</b></font>");
    }
    else{
	p.modify("shuttle_status", "<font color=red><b>OFFLINE</b></font>");
    }
    
    db.query("SELECT run FROM shuttle WHERE instance='PROD' AND runtype is not null ORDER BY tend DESC LIMIT 1;");
    
    predShuttle.parameters[0] = "SHUTTLE_openruns";
    
    o = Cache.getLastValue(predShuttle);

    if (o!=null && o instanceof Result){
	Result r = (Result) o;
	
	p.modify("shuttle_pending", ""+(int)r.param[0]);
    }
    else{
	p.modify("shuttle_pending", "?");
    }
    
    p.modify("shuttle_lastrun", db.gets(1));
    
    // DAQ RAW DATA REGISTRATION
    
    db.query("select * from rawdata_runs order by maxtime desc limit 1;");
    
    if (db.moveNext()){
	p.modify("raw_lastrun", db.geti("run"));
	p.modify("raw_time", db.geti("maxtime"));
	p.modify("raw_partition", db.gets("partition"));
    }
    
    // FTS
    
    Page pFTS_T1 = new Page(null, PATH+"index_fts_t1.res");
    
    monPredicate mpFTS = new monPredicate("", "AliEnServicesStatus", "FTD", -1, -1, new String[]{"Status"}, null);
    monPredicate mpFTSMessage = new monPredicate("", "AliEnServicesStatus", "FTD", -1, -1, new String[]{"Message"}, null);
    
    final Pattern pDateTime1 = Pattern.compile("([A-Z][a-z]{2}\\s)?[A-Z][a-z]{2}\\s+[0-9]{1,2}\\s[0-9]{1,2}:[0-9]{2}:[0-9]{2}(\\s[A-Z]+\\s[0-9]{4})? (info|warning|error|fine|finest) ");
    
    for (String sT1: new String[]{"CCIN2P3", "CNAF", "FZK", "NDGF", "NIKHEF", "RAL", "SARA"}){
	pFTS_T1.modify("site", sT1);
	
	/**
	 * 0 = ok
	 * 1 = error
	 * 2 = attention
	 * 3 = warning
	 */
	int iStatus=0;
	
	String sMessage = "";
	
	mpFTS.Farm = sT1;
	mpFTSMessage.Farm = sT1;
	
	o = Cache.getLastValue(mpFTS);
	
	if (o==null || !(o instanceof Result) || ((Result)o).param[0]!=0){
	    iStatus = 1;
	    
	    sMessage = "FTD is not running here";
	    
	    if (o!=null){
		o = Cache.getLastValue(mpFTSMessage);
		
		if (o!=null && (o instanceof eResult)){
		    sMessage = ((eResult) o).param[0].toString();
		}
	    }
	}
	
	switch (iStatus){
	    case 0:
		pFTS_T1.modify("color", "#00FF00");
		pFTS_T1.modify("status", "OK");
		break;
	    case 1:
		pFTS_T1.modify("color", "#FF0000");
		pFTS_T1.modify("status", "ERROR");
		break;
	    case 2:
		pFTS_T1.modify("color", "#FFFF00");
		pFTS_T1.modify("status", "ATTENTION");
		break;
	    case 3:
		pFTS_T1.modify("color", "#FF9900");
		pFTS_T1.modify("status", "WARNING");
		break;
	}
	
	Matcher m = pDateTime1.matcher(sMessage);

	StringBuffer sb = new StringBuffer(sMessage.length());
	
	int iLastIndex = 0;
		
	while (m.find(iLastIndex)){
	    if (m.start()>0){
	        sb.append(sMessage.substring(iLastIndex, m.start()));
		sb.append("\n");
	    }
	    sb.append(sMessage.substring(m.start(), m.end()));
	    //sb.append(sSuffix);
	    iLastIndex = m.end();
	}
	
	sb.append(sMessage.substring(iLastIndex));

	sMessage = sb.toString();
	
	pFTS_T1.modify("message", HtmlColorer.logColorer(sMessage));
	
	p.append("fts_t1s", pFTS_T1);
    }
    
    // CENTRAL SERVICES

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/"+PATH+"index.jsp", baos.size(), request);
%>