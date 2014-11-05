<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.ServletExtension,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lazyj.*,lia.Monitor.Store.Cache,lia.Monitor.monitor.Result,utils.IntervalQuery"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    response.setHeader("Connection", "keep-alive");

    Utils.logRequest("START /shuttle.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    int iTime = rw.geti("time", 24);
    
    String sDetectorFilter = rw.gets("filter");

    String sInstance = rw.gets("instance");
    String sInstanceUnder = sInstance.length()>0 ? "_"+sInstance : "";
    
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "600");
    
    pMaster.modify("bookmark", "/shuttle.jsp?time="+iTime+"&filter="+Format.encode(sDetectorFilter)+"&instance="+Format.encode(sInstance));
    
    pMaster.modify("title", "SHUTTLE details for each run and detector");
    
    Page p = new Page("shuttle.res");
    
    p.modify("time_"+iTime, "selected");
    p.modify("filter", sDetectorFilter);
    p.modify("instance", sInstance);
    
    p.modify("shuttle_instance_descr", sInstance.equals("PROD") ? "SHUTTLE for data taking at Point2" : "SHUTTLE test setup");
    p.modify("shuttle_other_instance", sInstance.equals("PROD") ? "" : "PROD");
    p.modify("shuttle_other_instance_descr", sInstance.equals("PROD") ? "test setup" : "production setup");
    
    p.modify("instanceunder", sInstanceUnder);
    p.modify("under_"+sDetectorFilter, "<u>");
    
    Page pLine = new Page("shuttle_line.res");
    
    DB db = new DB();
    
    db.query("SELECT value,firstseen FROM shuttle_meta WHERE instance='"+Format.escSQL(sInstance)+"' AND key='AliRootVersion' ORDER BY firstseen DESC LIMIT 1;");
    if (db.moveNext()){
	p.modify("aliroot_version", db.gets(1));
	p.modify("aliroot_version_timestamp", (new Date(db.getl(2)*1000)).toString());
    }
    
    db.query("SELECT value FROM shuttle_meta WHERE instance='"+Format.escSQL(sInstance)+"' AND key='AliRootRevision' ORDER BY firstseen DESC LIMIT 1;");
    if (db.moveNext()){
	p.modify("aliroot_revision", db.gets(1));
    }
    
    String sQuery = "SELECT * FROM shuttle WHERE instance='"+Format.escSQL(sInstance)+"' ";
    
    final String sRunRange = rw.gets("runrange").trim();
    
    p.modify("runrange", sRunRange);
    
    if (iTime>0 && sRunRange.length()==0)
	sQuery += " AND run IN (SELECT distinct run FROM shuttle WHERE instance='"+Format.escSQL(sInstance)+"' AND detector='SHUTTLE' AND tend>extract(epoch from now())::int-"+iTime+"*60*60)";
    
    if (sRunRange.length()>0){
	final String sClause = IntervalQuery.numberInterval(sRunRange, "run");
	    
	if (sClause.length()>0)
	    sQuery = IntervalQuery.cond(sQuery, sClause);
    }
    
    sQuery+=" ORDER BY run DESC, tstart ASC;";
    
    //System.err.println(sQuery);
    
    db.query(sQuery);
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");

    String sOldRun = null;

    long lMaxEnd = 0;

    int iCount=0;

    boolean bWriteLine = sDetectorFilter.length()==0;

    final long lNow = System.currentTimeMillis();

    long lMaxTime = 0;

    while (db.moveNext()){
	String sRun = db.gets("run");
    
	if (sOldRun!=null && !sRun.equals(sOldRun)){
	    if (lMaxEnd>0){
		Date d = new Date(lMaxEnd);
	    
		pLine.modify("last_seen", Format.showNiceDate(d)+" "+Format.showTime(d));
		pLine.modify("last_seen_timestamp", lMaxEnd);

		lMaxTime = lMaxTime > lMaxEnd ? lMaxTime : lMaxEnd;
	    }
	
	    pLine.modify("color", iCount%2==0 ? "#F0F0F0" : "#FFFFFF");
	
	    if (bWriteLine)
	        p.append(pLine);
	    else
		pLine.toString();
	
	    bWriteLine = sDetectorFilter.length()==0;
	
	    lMaxEnd = 0;
	    
	    iCount++;
	}
    
	sOldRun = sRun;
    
	pLine.modify("run", sRun);
	pLine.modify("instance", sInstance);
	
	Date d = new Date(db.getl("tstart")*1000);
	
	pLine.modify("first_seen", Format.showNiceDate(d)+" "+Format.showTime(d));
	pLine.modify("first_seen_timestamp", db.getl("tstart")*1000);
	
	String sDetector = db.gets("detector");
	String sStatus = db.gets("status");
	String sLink = db.gets("link");
	
	pLine.modify(sDetector+"_state", sStatus);
	
	int iCnt = db.geti("count");
	
	String sMsg = sDetector.equals("SHUTTLE") ? sStatus : sStatus+" ("+iCnt+")";
	
	//if (sInstance.length()==0){
	//    sLink = Format.replace(sLink, "pcalishuttle01.cern.ch:8880", "pcalishuttle02.cern.ch/test");
	//}
	//else{
	    sLink = Format.replace(sLink, "pcalishuttle01.cern.ch:8880", "pcalishuttle02.cern.ch");
	//}
	
	if (sStatus.equals("Skipped") && sDetector.equals("SHUTTLE")){
	    pLine.modify(sDetector, sMsg);
	}
	else{
	    pLine.modify(db.gets("detector"), (sLink.length()>0 ? "<a target=_blank href=\""+sLink+"\">" + sMsg + "</a>" : sMsg) + 
		" <a target=_blank href=\"shuttle_log.jsp?run="+sRun+"&detector="+Format.encode(sDetector)+"&instance="+Format.encode(sInstance)+"\">h</a>");
	}
	
	sStatus = sStatus.toLowerCase();
	
	if (sStatus.equals("done")){
	    if (sDetector.equals("GRP") && iCnt>1)
		pLine.modify(sDetector+"_color", "#FFA858");
	    else	
		pLine.modify(sDetector+"_color", "#55FF55");
	}
	else
	if (sStatus.equals("skipped"))
	    pLine.modify(sDetector+"_color", "#DDDDDD");
	else
	if (sStatus.equals("failed") || sStatus.equals("aborted") || sStatus.equals("fxserror") || sStatus.equals("dcserror") || sStatus.equals("ocdberror"))
	    pLine.modify(sDetector+"_color", "#FF5555");
	else
	    pLine.modify(sDetector+"_color", "#FFFF55");
	
	long lEnd = db.getl("tend")*1000;
	
	if (lEnd > lMaxEnd)
	    lMaxEnd = lEnd;
	    
	if (sDetector.equals("SHUTTLE"))
	    pLine.modify("runtype", db.gets("runtype"));
	    
	if (sDetector.equals(sDetectorFilter))
	    bWriteLine = true;
    }
    
    if (lMaxEnd>0){
	Date d = new Date(lMaxEnd);
    
	pLine.modify("last_seen", Format.showNiceDate(d)+" "+Format.showTime(d));
	lMaxTime = lMaxTime > lMaxEnd ? lMaxTime : lMaxEnd;
    }

    pLine.modify("color", iCount%2==0 ? "#F0F0F0" : "#FFFFFF");

    if (bWriteLine)
	p.append(pLine);
    
    Object o = Cache.getLastValue(ServletExtension.toPred("pcalishuttle*/ROOT_SHUTTLE"+sInstanceUnder+"/__PROCESSINGINFO__/SHUTTLE_status"));
    
    boolean bOnline = false;
    
    if (o!=null){
	long lTime = Cache.getResultTime(o);
	
	bOnline = lTime > System.currentTimeMillis() - 1000*60*15;
    }
    
    p.modify("status", bOnline ? "<font color=green><b>ONLINE</b></font>" : "<font color=red><b>OFFLINE</b></font>");
    
    
    o = Cache.getLastValue(ServletExtension.toPred("pcalishuttle*/ROOT_SHUTTLE"+sInstanceUnder+"/__PROCESSINGINFO__/SHUTTLE_openruns"));

    if (o!=null && o instanceof Result){
	Result r = (Result) o;
	
	p.modify("unprocessed", ""+(int)r.param[0]);
    }
    else{
	p.modify("unprocessed", "?");
    }
    
    db.query("SELECT run FROM shuttle WHERE instance='"+Format.escSQL(sInstance)+"' ORDER BY tend DESC,run ASC LIMIT 1;");
    
    p.modify("lastprocessed", db.gets(1));
    
    db.query("select count(distinct run) from shuttle_history where instance='"+Format.escSQL(sInstance)+"' and status='DCSError' and event_time>extract(epoch from now()-'1 hour'::interval)::int;");
    
    int iDCSErrors = db.geti(1);
    
    p.modify("dcserrors", iDCSErrors);

    db.query("select count(distinct run) from shuttle_history where instance='"+Format.escSQL(sInstance)+"' and status='OCDBError' and event_time>extract(epoch from now()-'1 hour'::interval)::int;");
    
    int iOCDBErrors = db.geti(1);
    
    p.modify("ocdberrors", iOCDBErrors);
    
    db.query("select count(distinct run) from shuttle_history where instance='"+Format.escSQL(sInstance)+"' and status='FXSError' and event_time>extract(epoch from now()-'1 hour'::interval)::int;");
    
    int iFXSErrors = db.geti(1);
    
    p.modify("fxserrors", iFXSErrors);
    
    db.query("select count(distinct run) from shuttle_history where detector='GRP' and instance='"+Format.escSQL(sInstance)+"' and event_time>extract(epoch from now()-'1 hour'::interval)::int and (status='Failed' or status='PPError');");
    
    int iGRPFailures = db.geti(1);
    
    p.modify("grpfailures", iGRPFailures);
    
    p.comment("com_errors", iFXSErrors+iDCSErrors+iGRPFailures+iOCDBErrors > 0);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    Utils.logRequest("/shuttle.jsp", baos.size(), request);
%>