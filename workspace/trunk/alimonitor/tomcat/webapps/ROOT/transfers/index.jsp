<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.Page,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,utils.IntervalQuery" %><%
    lia.web.servlets.web.Utils.logRequest("START /transfers/index.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Transfers");
    
    final Page p = new Page("transfers/index.res");
    
    final Page pLine = new Page("transfers/index_el.res");
    
    final DB db = new DB();
    
    String sWhere = "";
    
    String sBookmark = "/transfers/";
    
    final String sPathFilter = rw.gets("path").trim();
    
    if (sPathFilter.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "path like '%"+Format.escSQL(sPathFilter)+"%'");
	
	p.modify("path", sPathFilter);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "path", sPathFilter);
    }
    
    final String sTargetFilter = rw.gets("target").trim();
    
    if (sTargetFilter.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "targetse ilike '%"+Format.escSQL(sTargetFilter)+"%'");
	
	p.modify("target", sTargetFilter);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "target", sTargetFilter);
    }
    
    final String sIDFilter = rw.gets("id").trim();
    
    if (sIDFilter.length()>0){
	sWhere = IntervalQuery.cond(sWhere, IntervalQuery.numberInterval(sIDFilter, "id"));
	
	p.modify("id", sIDFilter);
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "id", sIDFilter);
    }
    
    final int iStatusFilter = rw.geti("status", -1);
    
    if (iStatusFilter>=0){
	sWhere = IntervalQuery.cond(sWhere, "status="+iStatusFilter);
    
	p.modify("status_"+iStatusFilter+"_selected", "selected");
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "status", ""+iStatusFilter);
    }
    
    int iPage = rw.geti("p", 0);
    
    int iLimit = rw.geti("l", 100);

    db.query("SELECT count(1) from transfer_requests_view"+sWhere);
    
    int iTotalCnt = db.geti(1);
    
    String sLimit = "";
    
    if (iLimit > 0){
	if (iPage<0)
	    iPage = 0;
    
	sLimit = " LIMIT "+iLimit+" OFFSET "+(iPage*iLimit);
	
	if (iTotalCnt>(iPage+1)*iLimit){
	    p.comment("com_next", true);
	    p.modify("next_page", iPage+1);
	}
	else{
	    p.comment("com_next", false);
	}
	
	if (iPage>0){
	    p.comment("com_prev", true);
	    p.modify("prev_page", iPage-1);
	}
	else{
	    p.comment("com_prev", false);
	}
    }
    else{
	p.comment("com_next", false);
	p.comment("com_prev", false);
    }
    
    p.modify("limit_"+iLimit, "selected");
    
    // -------------------


    String q = "SELECT sum(cnt) as total_count, sum(total_size) as total_size, sum(done_size) as done_size, max(cnt) AS max_cnt, max(total_size) AS max_size, count(1) as transfers_count FROM (SELECT * FROM transfer_requests_view"+sWhere+" ORDER BY id DESC "+sLimit+") x;";
    
    db.query(q);
    
    p.fillFromDB(db);

    final long lMaxCnt = db.getl(1);
    final long lMaxSize = db.getl(2);
    
    db.query("SELECT * FROM transfer_requests_view"+sWhere+" ORDER BY id desc"+sLimit+";");
    
    long lPendingCount = 0;
    long lRunningCount = 0;
    long lDoneCount = 0;
    long lErrorCount = 0;

    final StringBuilder sbIDs = new StringBuilder();
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	int iStatus = db.geti("status");

	int iPending = db.geti("cnt_0");
	int iRunning = db.geti("cnt_1");
	int iDone = db.geti("cnt_2");
	int iError = db.geti("cnt_3");
	int iTotal = db.geti("cnt");

	if (sbIDs.length()>0)
	    sbIDs.append(", ");
	
	sbIDs.append(db.geti("id"));

	/*
	if (db.geti("id")==13){
	    iPending = 974;
	    iRunning = 500;
	    iDone = iTotal - iPending - iRunning;
	    iStatus = 1;
	}
	*/	    
	
	switch(iStatus){
	    case 0: pLine.modify("statustext", "Queued"); break;
	    case 1: pLine.modify("statustext", "<font color=navy>Running</font>"); break;
	    case 2: pLine.modify("statustext", "<font color=green>Done</font>"); break;
	    case 3: pLine.modify("statustext", "<font color=red>Error</font>"); break;
	}

	if (iTotal<=0){
	    iTotal = iPending = 1;
	    iDone = iError = 0;
		
	    pLine.modify("transfer_tooltip", "Transfer pending processing");
	}
	else{
	    lPendingCount += iPending;
	    lRunningCount += iRunning;
	    lDoneCount    += iDone;
	    lErrorCount   += iError;
	
	    pLine.modify("transfer_tooltip", 
		"<b><font color=green>"+iDone+" done</font><br>"+
		"<font color=red>"+iError+" failed</font><br>"+
		"<font color=yellow>"+iRunning+" queued</font><br>"+
		iPending+" pending<BR>"+
		"<hr size=1>"+
		iTotal+" total files</b>"
	    );
	}
	    
	pLine.modify("size_pending", (int) (iPending*100f / iTotal));
	pLine.modify("size_running", (int) (iRunning*100f / iTotal));
	pLine.modify("size_done", (int) (iDone*100f / iTotal));
	pLine.modify("size_error", (int) (iError*100f / iTotal));

	if (lMaxCnt>0)
	    pLine.modify("cntpercentage", (int) (iTotal*100f / lMaxCnt) );

	if (lMaxSize>0)	    
	    pLine.modify("total_sizepercentage", (int) (db.getl("total_size") *100f / lMaxSize) );
	
	p.append(pLine);
    }
    
    // ------------------------ final bits and pieces

    final long lTotal = lDoneCount + lErrorCount + lRunningCount + lPendingCount;

    p.modify("transfer_tooltip", 
		"<b><font color=green>"+lDoneCount+" done</font><br>"+
		"<font color=red>"+lErrorCount+" failed</font><br>"+
		"<font color=yellow>"+lRunningCount+" queued</font><br>"+
		lPendingCount+" pending<BR>"+
		"<hr size=1>"+
		lTotal+" total files</b>"
	    );    

    if (lTotal>0){
	p.modify("size_pending", (int) (lPendingCount*100f / lTotal));
	p.modify("size_running", (int) (lRunningCount*100f / lTotal));
	p.modify("size_done", (int) (lDoneCount*100f / lTotal));
	p.modify("size_error", (int) (lErrorCount*100f / lTotal));
    }
    
    p.modify("transfer_ids", sbIDs);

    pMaster.modify("bookmark", sBookmark);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/transfers/index.jsp", baos.size(), request);
%>