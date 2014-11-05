<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /raw/raw_errors.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("raw/raw_errors.res");
    final Page pLine = new Page("raw/raw_errors_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    //pMaster.modify("refresh_time", "60");
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("title", "RAW data production - run details");
    pMaster.modify("bookmark", "/raw/raw_errors.jsp?");


    // ----- parameters

    String sReturn = rw.gets("return");
    
    if (sReturn.length()==0)
	sReturn = "/raw/";
    
    p.modify("return", sReturn);
    
    final int iMasterjob = rw.geti("id");
    
    final boolean bOnlyErrors = rw.getb("onlyerr", false);

    pMaster.append("bookmark", "id="+iMasterjob+"&onlyerr="+(bOnlyErrors ? 1 : 0)+"&"); 
    
    // ----- page contents

    p.modify("onlyerr", bOnlyErrors);
    p.modify("id", iMasterjob);

    final DB db = new DB();
    
    db.query("SELECT * FROM rawdata_processing_requests WHERE masterjob_id="+iMasterjob);
    
    p.fillFromDB(db);

    db.query("SELECT lfn,r.size as original_size,rj.size,errorv_file,events FROM rawdata_jobs rj INNER JOIN rawdata r USING (lfn) WHERE masterjob_id="+iMasterjob+(bOnlyErrors ? " AND errorv_file IS NOT NULL" : "")+" ORDER BY lfn ASC;");
    
    int iCount = 0;
    
    long lTotalSize = 0;
    long lTotalOriginalSize = 0;
    
    int iERRORV_count = 0;
    
    boolean bFirst = true;

    int iEvents = 0;
    
    while (db.moveNext()){
	String sLFN = db.gets("lfn");
	
	String[] parts = sLFN.split("/");
	
	pLine.fillFromDB(db);
	
	pLine.modify("filename", parts[parts.length-1]);
	
	boolean bERROR_V = db.gets("errorv_file").length()>0;
	
	pLine.comment("com_errorv", bERROR_V);
	
	if (bERROR_V)
	    iERRORV_count++;
	
	lTotalOriginalSize += db.getl("original_size");
	lTotalSize += db.getl("size");
	
	iCount++;
	
	p.append(pLine);
	
	iEvents += db.geti("events");
    }
    
    p.modify("files", iCount);
    p.modify("totalsize", lTotalSize);
    p.modify("totaloriginalsize", lTotalOriginalSize);
    p.modify("errorv_count", iERRORV_count);
    p.modify("events", iEvents);

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/raw/raw_errors.jsp?id="+iMasterjob+"&onlyerr="+(bOnlyErrors?1:0), baos.size(), request);
%>