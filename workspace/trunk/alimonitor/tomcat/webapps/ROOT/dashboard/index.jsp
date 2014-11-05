<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,lia.Monitor.monitor.Result" %><%
    lia.web.servlets.web.Utils.logRequest("START /dashboard/index.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("dashboard/index.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "300");
    
    pMaster.modify("bookmark", "/dashboard/");
    pMaster.modify("title", "ALICE Shifter's dashboard");

    // ----- parameters
    
    final int iTab = rw.geti("tab");
    
    p.modify("tab", iTab);
    
    // ----- SHUTTLE
    final Page pShuttle = new Page("dashboard/index_shuttle.res");
    final Page pShuttleRun = new Page("dashboard/index_shuttle_run.res");
    
    DB db = new DB("SELECT distinct run,runtype,tstart,tend FROM shuttle WHERE instance='PROD' AND runtype is not null ORDER BY run DESC LIMIT 9;");
    
    long lMax = 0;
    
    while (db.moveNext()){
	pShuttleRun.fillFromDB(db);
	pShuttle.append("content", pShuttleRun);
	
	lMax = lMax > db.getl("tend") ? lMax : db.getl("tend");
    }
    
    Object o = Cache.getLastValue(ServletExtension.toPred("pcalishuttle01/ROOT_SHUTTLE_PROD/__PROCESSINGINFO__/SHUTTLE_status"));
    
    boolean bOnline = false;
    
    if (o!=null){
	long lTime = Cache.getResultTime(o);
	
	bOnline = lTime > System.currentTimeMillis() - 1000*60*15;
    }
    
    if (bOnline){
	pShuttle.modify("status", "<font color=green><b>ONLINE</b></font>");
    }
    else{
	pShuttle.modify("status", "<font color=red><b>OFFLINE</b></font>");
    }
    
    db.query("SELECT run FROM shuttle WHERE instance='PROD' AND runtype is not null ORDER BY tend DESC LIMIT 1;");
    
    o = Cache.getLastValue(ServletExtension.toPred("pcalishuttle01/ROOT_SHUTTLE_PROD/__PROCESSINGINFO__/SHUTTLE_openruns"));

    if (o!=null && o instanceof Result){
	Result r = (Result) o;
	
	pShuttle.modify("unprocessed", ""+(int)r.param[0]);
    }
    else{
	pShuttle.modify("unprocessed", "?");
    }
    
    pShuttle.modify("lastprocessed", db.gets(1));
    
    p.modify("shuttle", pShuttle);

    // ----- DAQ registration
    
    final Page pRegistration = new Page("dashboard/index_registration.res");
    
    p.modify("registration", pRegistration);

    // ----- DAQ summary
    
    final Page pDAQSummary = new Page("dashboard/index_registrationsummary.res");
    final Page pDAQSummaryLine = new Page("dashboard/index_registrationsummary_run.res");
    
    db.query("select * from rawdata_runs order by maxtime desc limit 11;");
    
    while (db.moveNext()){
	pDAQSummaryLine.fillFromDB(db);
	
	pDAQSummary.append("content", pDAQSummaryLine);
    }
    
    p.modify("registrationsummary", pDAQSummary);

    // ----- FTD
    
    final Page pFTD = new Page("dashboard/index_ftd.res");
    
    p.modify("ftd", pFTD);

    // ----- Castor2x

    final Page pCastor2x = new Page("dashboard/index_castor2x.res");
    
    p.modify("castor2x", pCastor2x);

    // ----- SEs
    
    final Page pSEs = new Page("dashboard/index_ses.res", false);
    final Page pSEsEl = new Page("dashboard/index_ses_el.res", false);
    
    for (String se: Arrays.asList("ALICE::CERN::T0ALICE", "ALICE::CERN::EOS", "ALICE::CERN::OCDB")){
	pSEsEl.modify("se_name", se);
	
	db.query("SELECT status,message,testtime FROM se_testing WHERE se_name='"+se+"' and se_test='ADD';");
	
	int status=db.geti(1);
	String message = db.gets(2);
	
	pSEsEl.modify("testtime", db.gets(3));
	
	if (status==0){
	    pSEsEl.comment("com_ok", true);
	}
	else{
	    pSEsEl.comment("com_ok", false);
	    pSEsEl.modify("message", "<div align=left>"+lia.web.utils.HtmlColorer.logColorer(message)+"</div>");
	}
	
	pSEs.append(pSEsEl);
    }
    
    p.modify("ses", pSEs);

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/dashboard/index.jsp", baos.size(), request);
%>