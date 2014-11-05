<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /DAQ/details.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("DAQ/details.res");
    final Page pLine = new Page("DAQ/details_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    //pMaster.modify("refresh_time", "60");
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("title", "DAQ RAW Data Registration");
    pMaster.modify("bookmark", "/DAQ/");

    // ----- parameters

    final int iHours = rw.geti("time", 1);
    final String sRunFilter = rw.gets("runfilter");
    final String sDetectorFilter = rw.gets("detectorfilter");
    
    // ----- page contents
    
    p.modify("time_"+iHours, "selected");
    
    String sCond = iHours<=0 ? "" : "WHERE addtime>extract(epoch from now()-'"+iHours+" hours'::interval)::int";
    
    final String sTimeConstraint = iHours<=0 ? "" : "WHERE maxtime>extract(epoch from now()-'"+iHours+" hours'::interval)::int";
    
    if (sRunFilter.length()>0){
	sCond += sCond.length()>0 ? " AND " : " WHERE ";
	
	sCond += "run="+Integer.parseInt(sRunFilter);
    }
    
    if (sDetectorFilter.length()>0){
	sCond += sCond.length()>0 ? " AND " : " WHERE ";
	
	sCond += "detector='"+Format.escSQL(sDetectorFilter)+"'";
    }
        
    DB db = new DB("SELECT * FROM rawdata_details "+sCond+" ORDER BY addtime DESC;");
    
    int iCount = 0;
    
    long lTotalSize = 0;
    
    int iERRORV_count = 0;
    
    TreeSet<Integer> tsRuns = new TreeSet<Integer>();
    
    while (db.moveNext()){
	String sLFN = db.gets("lfn");
	
	String[] parts = sLFN.split("/");
	
	tsRuns.add(db.geti("run"));
	
	pLine.fillFromDB(db);
	
	pLine.modify("filename", parts[parts.length-1]);
	
	boolean bERROR_V = db.gets("errorv_logfile").length()>0;
	
	pLine.comment("com_errorv", bERROR_V);
	
	if (bERROR_V)
	    iERRORV_count++;
	
	lTotalSize += db.getl("size");
	
	iCount++;
	
	p.append(pLine);
    }
    
    db.query("select distinct run from rawdata_runs "+sTimeConstraint+";");
    while (db.moveNext()){
	String sRun = db.gets(1);
    
	p.append("opt_runs", "<option value='"+sRun+"' "+(sRun.equals(sRunFilter)?"selected":"")+">"+sRun+"</option>");
    }

    db.query("select distinct partition from rawdata_runs "+sTimeConstraint+";");
    
    while (db.moveNext()){
	String sDetector = db.gets(1);
    
	p.append("opt_detectors", "<option value='"+sDetector+"' "+(sDetector.equals(sDetectorFilter)?"selected":"")+">"+sDetector+"</option>");
    }

    p.modify("runs", tsRuns.size());
    p.modify("files", iCount);
    p.modify("totalsize", lTotalSize);
    p.modify("errorv_count", iERRORV_count);

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/DAQ/details.jsp", baos.size(), request);
%>