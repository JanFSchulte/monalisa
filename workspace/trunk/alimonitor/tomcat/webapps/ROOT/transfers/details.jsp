<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.Page,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,utils.IntervalQuery" %><%
    lia.web.servlets.web.Utils.logRequest("START /transfers/details.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Transfer details");
    
    final Page p = new Page("transfers/details.res");
    
    final Page pLine = new Page("transfers/details_el.res");
    
    final DB db = new DB();

    String sBookmark = "/transfers/details.jsp";
    
    final int id = rw.geti("id");
    
    sBookmark = IntervalQuery.addToURL(sBookmark, "id", ""+id);
    
    final int iStatus = rw.geti("status", -1);
    
    String sWhere = "";
        
    sWhere = IntervalQuery.cond(sWhere, "request_id="+id);
    
    if (iStatus>=0){
	sWhere = IntervalQuery.cond(sWhere, "status="+iStatus);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "status", ""+iStatus);
    }
	
    final String sID = rw.gets("alienid");
    
    if (sID.length()>0){
	sWhere = IntervalQuery.cond(sWhere, IntervalQuery.numberInterval(sID, "alienid"));
	
	p.modify("alienid", sID);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "alienid", sID);
    }
    
    final String sRetries = rw.gets("retries");
    
    if (sRetries.length()>0){
	sWhere = IntervalQuery.cond(sWhere, IntervalQuery.numberInterval(sRetries, "triesleft"));
	
	p.modify("retries", sRetries);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "retries", sRetries);
    }
    
    final String sPath = rw.gets("pathfilter");
    
    if (sPath.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "path LIKE '%"+Format.escSQL(sPath)+"%'");
	
	p.modify("pathfilter", sPath);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "pathfilter", sPath);
    }
    
    final String sReasonFilter = rw.gets("reason");
    
    if (sReasonFilter.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "failreason ILIKE '%"+Format.escSQL(sReasonFilter)+"%'");
	
	p.modify("reason", sReasonFilter);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "reason", sReasonFilter);
    }

    String sLimit = "";
	
    final int iLimit = 200;
	
    final int iPage = rw.geti("page", 0);
    
    final boolean bAll = rw.getb("all", false);
    
    if (!bAll){
	sLimit = "LIMIT "+(iLimit+1)+" OFFSET "+(iLimit*iPage);
	
	if (iPage>0)
	    sBookmark = IntervalQuery.addToURL(sBookmark, "page", ""+iPage);
    }    
    else{
	sBookmark = IntervalQuery.addToURL(sBookmark, "all", "true");
    }
    
    // -------------------
    
    db.query("SELECT * FROM transfer_requests WHERE id="+id+";");
    
    p.fillFromDB(db);
    
    db.query("SELECT * FROM transfers "+sWhere+" order by lower(path) "+sLimit+";");
    
    int iCount = 0;
    
    long lTotalSize = 0;
    
    boolean bHasNext = false;
    
    while (db.moveNext()){
	iCount++;
	
	if (iCount>iLimit && !bAll){
	    iCount--;
	    bHasNext = true;
	    break;
	}
	
	lTotalSize += db.getl("filesize");
    
	pLine.fillFromDB(db);
	
	switch(db.geti("status")){
	    case 0: pLine.modify("statustext", "Queued"); pLine.modify("statuscolor", "#DDDDDD"); break;
	    case 1: pLine.modify("statustext", "Running"); pLine.modify("statuscolor", "#FFFF00"); break;
	    case 2: pLine.modify("statustext", "Done"); pLine.modify("statuscolor", "#00FF00"); break;
	    case 3: pLine.modify("statustext", "Error"); pLine.modify("statuscolor", "#FF0000"); break;
	}
	
	int iID = db.geti("alienid");
	
	String sServer = null;
	
	String sReason = db.gets("failreason");
	
	if (sReason.startsWith("ID ")){
	    try{
		iID = Integer.parseInt(sReason.substring(3, sReason.indexOf(',', 3)));
	    }
	    catch (Exception e){
	    }
	}
	
	final String sSearch = "ALICE::CERN::CENTRAL";
	
	final int idx = sReason.indexOf(sSearch);
	
	if (iID > 0 &&  idx>= 0){
	    try{
		sServer = sReason.substring(idx+sSearch.length());
		sServer = sServer.substring(0, sServer.indexOf(':'));
		
		if (sServer.length()==1){
		    sServer = "aliendb"+sServer;
		}
		else{
		    sServer = "pcapiserv0"+sServer.substring(3);
		}
		
		pLine.modify("link_start", "<a target=_blank style='text-decoration:none' href='http://"+sServer+"/"+(iID/1000)+"/"+iID+".log'>");
		pLine.modify("link_end", "</a>");
	    }
	    catch (Exception e){
	    }
	}
	
	p.append(pLine);
    }
    
    p.modify("count", iCount);
    p.modify("filesize", lTotalSize);

    p.comment("com_next", bHasNext);
    p.comment("com_prev", iPage>0);
    p.comment("com_all", !bAll && (iPage>0 || bHasNext));
    
    p.modify("page_next", iPage+1);
    p.modify("page_prev", iPage-1);
    
    p.modify("status", iStatus);
    
    p.modify("status_"+iStatus, "selected");
    
    // ------------------------ final bits and pieces

    pMaster.modify("bookmark", sBookmark);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/transfers/details.jsp", baos.size(), request);

%>