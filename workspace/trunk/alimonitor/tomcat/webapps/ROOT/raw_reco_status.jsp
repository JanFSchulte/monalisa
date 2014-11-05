<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.ServletExtension,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lazyj.*,lia.Monitor.Store.Cache,lia.Monitor.monitor.Result,auth.*,java.security.cert.*"%><%
    Utils.logRequest("START /raw_reco_status.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    RequestWrapper rw = new RequestWrapper(request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    int iTime = rw.geti("time", 24);
    
    String sInstance = rw.gets("instance", "PROD");
    String sInstanceUnder = sInstance.length()>0 ? "_"+sInstance : "";
    
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "600");
        
    pMaster.modify("title", "Raw data reconstruction status");
    
    Page p = new Page("raw_reco_status.res");
    
    p.modify("time_"+iTime, "selected");
    p.modify("instance", sInstance);
    
    p.modify("shuttle_instance_descr", sInstance.equals("PROD") ? "SHUTTLE for data taking at Point2" : "SHUTTLE test setup");
    p.modify("shuttle_other_instance", sInstance.equals("PROD") ? "" : "PROD");
    p.modify("shuttle_other_instance_descr", sInstance.equals("PROD") ? "test setup" : "production setup");
    
    p.modify("instanceunder", sInstanceUnder);
        
    Page pLine = new Page("raw_reco_status_line.res");
    
    DB db = new DB();

    String sUsername = null;    
    
    if (request.getRemoteAddr().equals("137.138.136.181"))
	sUsername = "Offline Shifter @ P2";
    
    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

	if (cert!=null && cert.length>0){
	    AlicePrincipal principal = new AlicePrincipal(cert[0].getSubjectDN().getName());
	    
	    String sName = principal.getName();
	    
	    if (sName!=null && sName.length()>0){
		sUsername = sName;
	    }
	}
    }

    db.query("SELECT value,firstseen FROM shuttle_meta WHERE instance='"+Format.escSQL(sInstance)+"' AND key='AliRootVersion' ORDER BY firstseen DESC LIMIT 1;");
    if (db.moveNext()){
	p.modify("aliroot_version", db.gets(1));
	p.modify("aliroot_version_timestamp", (new Date(db.getl(2)*1000)).toString());
    }
    
    String sRuntypeFilter = request.getParameter("runtype");
    
    if (sRuntypeFilter==null)
	sRuntypeFilter = "PHYSICS";
    
    db.query("SELECT trim(split_part(runtype,'(',1)),count(1) FROM shuttle WHERE instance='PROD' and detector='SHUTTLE' and length(runtype)>0 GROUP BY 1 ORDER BY 1;");
    
    while (db.moveNext()){
	final String sRuntype = db.gets(1);
    
	p.append("options_runtype", "<option value='"+sRuntype+"' "+(sRuntype.equals(sRuntypeFilter) ? "selected" : "")+">"+sRuntype+" ("+db.geti(2)+")</option>");
    }
    
    db.query("SELECT value FROM shuttle_meta WHERE instance='"+Format.escSQL(sInstance)+"' AND key='AliRootRevision' ORDER BY firstseen DESC LIMIT 1;");
    if (db.moveNext()){
	p.modify("aliroot_revision", db.gets(1));
    }
    
    int iRunNo = rw.geti("runno");
    
    if (iRunNo > 0 && sUsername!=null){
	final String sComment = rw.gets("comment");
	
	final int iCafReco = rw.geti("caf_reco");
	final int iGridReco = rw.geti("grid_reco");
	    
	db.syncUpdateQuery("UPDATE shuttle_comments SET comment='"+Format.escSQL(sComment)+"',author='"+Format.escSQL(sUsername)+"',addtime=extract(epoch from now())::int,caf_reco="+iCafReco+",grid_reco="+iGridReco+" WHERE run="+iRunNo+";");
	
	if (db.getUpdateCount()==0){
	    db.syncUpdateQuery("INSERT INTO shuttle_comments (run, comment, author, caf_reco, grid_reco) VALUES ("+iRunNo+", '"+Format.escSQL(sComment)+"', '"+Format.escSQL(sUsername)+"', "+iCafReco+", "+iGridReco+");");
	}
    }
    
    String sQueryMain = "SELECT shuttle.*,rawdata_runs.chunks,sc.comment,sc.author,sc.caf_reco,sc.grid_reco,sc.addtime,"+
	"max(max(tend, coalesce(rawdata_runs.maxtime, 0)), coalesce(sc.addtime, 0)) AS lastchange,"+
	"rm1.rm_value as rm_status, rm1.rm_time as rm_time, rm2.rm_value as rm_event_count, "+
	"rawdata_runs.events,rawdata_runs.size "+
	"FROM shuttle LEFT OUTER JOIN rawdata_runs USING (run) "+
	"  LEFT OUTER JOIN shuttle_comments sc USING (run) "+
	"  LEFT OUTER JOIN rawreco_messages rm1 ON rm1.rm_run=run AND rm1.rm_key='Status' "+
	"  LEFT OUTER JOIN rawreco_messages rm2 ON rm2.rm_run=run AND rm2.rm_key='Event_count'";
	
    String sQueryOverall = "SELECT max(rawdata_runs.size) FROM shuttle INNER JOIN rawdata_runs USING (run) ";
	
    String sQuery = " WHERE instance='"+Format.escSQL(sInstance)+"' ";
    
    boolean bWithChunks = true;
    
    if (request.getParameter("wchunks")!=null){
	bWithChunks = rw.getb("wchunks", false);
    }
    
    p.modify("wchunks", bWithChunks);
    
    if (bWithChunks){
	sQuery += " AND rawdata_runs.chunks>0 ";
    }
    
    final String sRunRange = rw.gets("runrange").trim();
    
    p.modify("runrange", sRunRange);

    pMaster.modify("bookmark", "/raw_reco_status.jsp?time="+iTime+"&instance="+Format.encode(sInstance)+"&runrange="+Format.encode(sRunRange)+"&runtype="+Format.encode(sRuntypeFilter));
    
    if (iTime>0 && sRunRange.length()==0)
	sQuery += " AND shuttle.run IN (SELECT distinct run FROM shuttle WHERE instance='"+Format.escSQL(sInstance)+"' AND detector='SHUTTLE' AND tend>extract(epoch from now())::int-"+iTime+"*60*60)";
    
    if (sRunRange.length()>0){
	final StringTokenizer st = new StringTokenizer(sRunRange, ",");
	
	final StringBuilder sb = new StringBuilder();
	
	while (st.hasMoreTokens()){
	    final String s = st.nextToken().trim();
	    
	    if (s.length()>0){
		final int idx = s.indexOf('-');
	    
		if (idx>0){
		    try{
			int start = Integer.parseInt(s.substring(0, idx).trim());
			int end = Integer.parseInt(s.substring(idx+1).trim());
			
			if (start>end){
			    final int tmp = start;
			    start = end;
			    end = tmp;
			}
			
			if (sb.length()>0)
			    sb.append(" OR ");
			
			sb.append("(shuttle.run>=").append(start).append(" AND shuttle.run<=").append(end).append(')');
		    }
		    catch (Exception e){
		    }
		}
		else{
		    try{
			int run = Integer.parseInt(s);
			
			if (sb.length()>0)
			    sb.append(" OR ");
			
			sb.append("shuttle.run="+run);
		    }
		    catch (Exception e){
		    }
		}
	    }
	}
	
	if (sb.length()>0)
	    sQuery+=" AND ("+sb+")";
    }
    
    db.query(sQueryOverall + sQuery);
    
    long lMaxSize = db.getl(1, 1);
    
    sQueryMain += sQuery + " ORDER BY run DESC, tstart ASC;";

    System.err.println(sQueryMain);
    
    db.query(sQueryMain);
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");

    String sOldRun = null;

    long lMaxEnd = 0;

    int iCount=0;

    boolean bWriteLine = false;

    final long lNow = System.currentTimeMillis();

    long lMaxTime = 0;

    int iPPDone = 0;
    int iPPErr = 0;
    int iGridEvents = 0;

    int iTotalRuns=0;
    int iTotalDone = 0;
    int iTotalErr = 0;
    int iTotalChunks = 0;
    
    int iChunks = 0;

    int iTotalGridEvents = 0;
    int iTotalCafEvents = 0;

    while (db.moveNext()){
	String sRun = db.gets("run");
    
	if (sOldRun!=null && !sRun.equals(sOldRun)){
	    if (lMaxEnd>0){
		Date d = new Date(lMaxEnd);
	    
		pLine.modify("last_seen", Format.showNiceDate(d)+" "+Format.showTime(d));

		lMaxTime = lMaxTime > lMaxEnd ? lMaxTime : lMaxEnd;
	    }
	
	    pLine.modify("color", iCount%2==0 ? "#F0F0F0" : "#FFFFFF");

	    String sPP = "";
	    
	    if (iPPDone>0){
		sPP = "<font color=green><B>"+iPPDone+"</B></font>";
	    }
	    
	    if (iPPErr>0){
		if (sPP.length()>0) sPP+=" / ";
		
		sPP += "<font color=red><B>"+iPPErr+"</B></font>";
	    }
	    
	    pLine.modify("PP", sPP.length() > 0 ? sPP : "&nbsp;");
	
	    if (bWriteLine){
	        iTotalDone += iPPDone;
		iTotalErr += iPPErr;
		iTotalRuns ++;
		iTotalChunks += iChunks;
	        iCount++;
		iTotalGridEvents += iGridEvents;
	        p.append(pLine);
	    }
	    else
		pLine.toString();

	    iGridEvents = iPPDone = iPPErr = iChunks = 0;
	
	    //bWriteLine = sDetectorFilter.length()==0;
	
	    lMaxEnd = 0;
	}
    
	sOldRun = sRun;
    
	pLine.modify("run", sRun);
	pLine.modify("instance", sInstance);
	pLine.modify("events", db.gets("events"));
	
	pLine.modify("size", db.getl("size"));
	pLine.modify("sizepercentage", db.getl("size") * 100d / lMaxSize);
	
	iGridEvents = db.geti("events");
	
	Date d = new Date(db.getl("tstart")*1000);
	
	pLine.modify("first_seen", Format.showNiceDate(d)+" "+Format.showTime(d));
	
	String sDetector = db.gets("detector");
	String sStatus = db.gets("status");
	String sLink = db.gets("link");
	
	int iCnt = db.geti("count");
	
	String sMsg = sDetector.equals("SHUTTLE") ? sStatus : sStatus+" ("+iCnt+")";
	
//	if (sInstance.length()==0){
	    sLink = Format.replace(sLink, "pcalishuttle01.cern.ch:8880", "pcalishuttle02.cern.ch");
//	}
	
	if (sStatus.equals("Skipped") && sDetector.equals("SHUTTLE")){
	    pLine.modify(sDetector, sMsg);
	}
	else{
	    pLine.modify(db.gets("detector"), (sLink.length()>0 ? "<a target=_blank href=\""+sLink+"\">" + sMsg + "</a>" : sMsg) + 
		" <a target=_blank href=\"shuttle_log.jsp?run="+sRun+"&detector="+Format.encode(sDetector)+"&instance="+Format.encode(sInstance)+"\">h</a>");
	}
	
	sStatus = sStatus.toLowerCase();
	
	if (sStatus.equals("done")){
	    if (sDetector.equals("GRP") && iCnt>1){
		iPPErr ++;
		pLine.modify(sDetector+"_color", "#FF5555");
	    }
	    else{
		if (!sDetector.equals("SHUTTLE"))
		    iPPDone ++;
		    
		pLine.modify(sDetector+"_color", "#55FF55");
	    }
	}
	else
	if (sStatus.equals("skipped"))
	    pLine.modify(sDetector+"_color", "#DDDDDD");
	else
	if (sStatus.equals("failed") || sStatus.equals("aborted") || sStatus.equals("fxserror") || sStatus.equals("dcserror")){
	    iPPErr ++;
	    pLine.modify(sDetector+"_color", "#FF5555");
	}
	else
	    pLine.modify(sDetector+"_color", "#FFFF55");
	
	long lEnd = db.getl("lastchange")*1000;
	
	if (lEnd > lMaxEnd)
	    lMaxEnd = lEnd;
	    
	if (sDetector.equals("SHUTTLE")){
	    bWriteLine = true;
	    
	    if (!sStatus.equals("done")){
		bWriteLine = false;
		continue;
	    }
	
	    if (sRuntypeFilter.length()>0){
		final String sRuntype = db.gets("runtype").trim();
		
		if (!sRuntype.equals(sRuntypeFilter) && !sRuntype.startsWith(sRuntypeFilter+'(')){
		    bWriteLine = false;
		    continue;
		}
	    }
	
	    pLine.modify("runtype", db.gets("runtype"));
	    
	    String sComment = db.gets("comment");
	    
	    p.append("comments", "var old_comment_"+sRun+"='"+Format.escJS(sComment)+"';\n");
	    pLine.modify("comment", sComment);
	    pLine.modify("author", db.gets("author"));
	    pLine.modify("addtime", db.gets("addtime"));
	    
	    iChunks = db.geti("chunks");
	    
	    pLine.modify("chunks", iChunks>0 ? ""+iChunks : "");
	    
	    int iCafReco = db.geti("caf_reco");
	    int iGridReco = db.geti("grid_reco");
	    
	    pLine.modify("caf_reco_code", iCafReco);
	    pLine.modify("grid_reco_code", iGridReco);
	    
	    if (iCafReco>0)
		pLine.modify("caf_reco_color", iCafReco==1 ? "#00FF00" : "#FF0000");
	
	    if (iGridReco>0)
		pLine.modify("grid_reco_color", iGridReco==1 ? "#00FF00" : "#FF0000");
	    
	    
	    String sRMStatus = db.gets("rm_status");
	    
	    if (sRMStatus.length()>0){
		pLine.modify("rm_status", sRMStatus);
	
		if (sRMStatus.startsWith("Fail")){
		    pLine.modify("rm_status_color", "#FF0000");
		}
		else
		if (sRMStatus.startsWith("Done")){
		    pLine.modify("rm_status_color", "#00FF00");
		}		    
		else
		if (sRMStatus.startsWith("Start")){
		    pLine.modify("rm_status_color", "#FFFF00");
		}
	
		int iEvents = (int) db.getd("rm_event_count");
		
		if (iEvents>0){
		    pLine.modify("rm_event_count", iEvents);
		    
		    iTotalCafEvents += iEvents;
		}
		
		pLine.modify("rm_time", db.gets("rm_time"));
	    }
	}
	    
	//if (sDetector.equals(sDetectorFilter))
	//    bWriteLine = true;
    }
    
    if (lMaxEnd>0){
	Date d = new Date(lMaxEnd);
    
	pLine.modify("last_seen", Format.showNiceDate(d)+" "+Format.showTime(d));
	lMaxTime = lMaxTime > lMaxEnd ? lMaxTime : lMaxEnd;
    }

    pLine.modify("color", iCount%2==0 ? "#F0F0F0" : "#FFFFFF");

    String sPP = "";
	    
    if (iPPDone>0){
	sPP = "<font color=green><B>"+iPPDone+"</B></font>";
    }
	    
    if (iPPErr>0){
	if (sPP.length()>0) sPP+=" / ";
		
	sPP += "<font color=red><B>"+iPPErr+"</B></font>";
    }


    pLine.modify("PP", sPP.length() > 0 ? sPP : "&nbsp;");

    if (bWriteLine){
	iTotalDone += iPPDone;
	iTotalErr += iPPErr;
	iTotalChunks += iChunks;
	iTotalRuns ++;
	p.append(pLine);
    }
    
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
    
    db.query("select count(distinct run) from shuttle_history where instance='"+Format.escSQL(sInstance)+"' and status='FXSError' and event_time>extract(epoch from now()-'1 hour'::interval)::int;");
    
    int iFXSErrors = db.geti(1);
    
    p.modify("fxserrors", iFXSErrors);
    
    db.query("select count(distinct run) from shuttle_history where detector='GRP' and instance='"+Format.escSQL(sInstance)+"' and event_time>extract(epoch from now()-'1 hour'::interval)::int and (status='Failed' or status='PPError');");
    
    int iGRPFailures = db.geti(1);
    
    p.modify("grpfailures", iGRPFailures);
    
    p.comment("com_errors", iFXSErrors+iDCSErrors+iGRPFailures > 0);

    p.modify("ask_pass", request.getRemoteAddr().equals("137.138.136.181") ? "false" : "true");

    sPP = "";
	    
    if (iTotalDone>0){
	sPP = "<font color=green><B>"+iTotalDone+"</B></font>";
    }
	    
    if (iTotalErr>0){
	if (sPP.length()>0) sPP+=" / ";
		
	sPP += "<font color=red><B>"+iTotalErr+"</B></font>";
    }
    
    p.modify("total_grid_events", iTotalGridEvents);
    p.modify("total_caf_events", iTotalCafEvents);

    p.modify("PP", sPP);
    p.modify("total_runs", iTotalRuns);
    p.modify("total_chunks", iTotalChunks);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    Utils.logRequest("/raw_reco_status.jsp", baos.size(), request);
%>