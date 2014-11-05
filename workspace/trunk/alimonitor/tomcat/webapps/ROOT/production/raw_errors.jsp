<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;
	
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /production/raw_errors.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("production/raw_errors.res");
    final Page pLine = new Page("production/raw_errors_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    //pMaster.modify("refresh_time", "60");
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("title", "RAW data production - run details");
    pMaster.modify("bookmark", "/production/raw_errors.jsp?");

    // ----- parameters

    final String sRunFilter = rw.gets("runfilter");
    
    final boolean bOnlyErrors = rw.getb("onlyerr", false);
    
    String sReturn = rw.gets("return");
    
    if (sReturn.length()==0)
	sReturn = "/production/";
    
    p.modify("return", sReturn);
    
    // ----- page contents
    
    String sCond = "";
    
    if (sRunFilter.length()>0){
	sCond += sCond.length()>0 ? " AND " : " WHERE ";
	
	sCond += "run="+Integer.parseInt(sRunFilter);
	
	pMaster.append("bookmark", "runfilter="+Format.encode(sRunFilter)+"&");
    }
    
    if (bOnlyErrors){
	sCond += sCond.length()>0 ? " AND " : " WHERE ";
	
	sCond += "errorv_logfile IS NOT NULL";
	
	pMaster.append("bookmark", "onlyerr="+bOnlyErrors+"&");
    }
    
    p.modify("runfilter", sRunFilter);
    p.modify("onlyerr", bOnlyErrors);
    
    DB db = new DB("SELECT * FROM rawdata_details "+sCond+" ORDER BY addtime DESC LIMIT 10000;");
    
    int iCount = 0;
    
    long lTotalSize = 0;
    
    int iERRORV_count = 0;
    
    boolean bFirst = true;

    int iEvents = 0;
    
    while (db.moveNext()){
	if (bFirst){
	    p.modify("run", db.geti("run"));
	    p.modify("partition", db.gets("detector"));
	    
	    bFirst = false;
	}
    
	String sLFN = db.gets("lfn");
	
	String[] parts = sLFN.split("/");
	
	pLine.fillFromDB(db);
	
	pLine.modify("filename", parts[parts.length-1]);
	
	boolean bERROR_V = db.gets("errorv_logfile").length()>0;
	
	pLine.comment("com_errorv", bERROR_V);
	
	if (bERROR_V)
	    iERRORV_count++;
	
	lTotalSize += db.getl("size");
	
	iCount++;
	
	p.append(pLine);
	
	iEvents += db.geti("chunk_events");
    }
    
    db.query("select distinct run from rawdata_runs;");
    while (db.moveNext()){
	String sRun = db.gets(1);
    
	p.append("opt_runs", "<option value='"+sRun+"' "+(sRun.equals(sRunFilter)?"selected":"")+">"+sRun+"</option>");
    }

    p.modify("files", iCount);
    p.modify("totalsize", lTotalSize);
    p.modify("errorv_count", iERRORV_count);
    p.modify("events", iEvents);

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/production/raw_errors.jsp", baos.size(), request);
%>