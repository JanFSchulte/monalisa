<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*" %><%!
    private String getUser(HttpServletRequest request){
	if (request.isSecure()){
	    final X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

	    if (cert!=null && cert.length>0){
		String sDN = cert[0].getSubjectDN().getName();
	    
	        auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);
	        
	        return principal.getName();
	    }
	}
	
	return null;
    }
    
    private static String cond(final String sPrev, final String sCond){
	if (sPrev==null || sPrev.length()==0 || sPrev.toLowerCase().indexOf(" where ")<0)
	    return " WHERE ("+sCond+")";

	return sPrev+" AND ("+sCond+")";
    }
    
    private void archive(final int run, final HttpServletRequest request){
	//System.err.println("I would archive "+run);
    
	alien.managers.TransferManager tm = alien.managers.TransferManager.getInstance();

	tm.insertRawdataTransferRequest(run, "ALICE::CERN::T0ALICE", getUser(request));
    }
    
    private void toT1(final int run, final HttpServletRequest request){
	alien.managers.TransferManager tm = alien.managers.TransferManager.getInstance();

	tm.insertRawdataTransferRequest(run, getUser(request));
    }
    
    private void delete(int run){
	//System.err.println("I would delete "+run);
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/transfers/index.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    // do the operations
    for (String s: rw.getValues("a")){
	try{
	    archive(Integer.parseInt(s), request);
	}
	catch (Exception e){
	}
    }

    // do the operations
    for (String s: rw.getValues("t")){
	try{
	    toT1(Integer.parseInt(s), request);
	}
	catch (Exception e){
	}
    }
    
    for (String s: rw.getValues("d")){
	try{
	    delete(Integer.parseInt(s));
	}
	catch (Exception e){
	}
    }
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Raw data transfers");
    
    final Page p = new Page("admin/transfers/index.res");
    
    final Page pLine = new Page("admin/transfers/index_el.res");
    
    final DB db = new DB();
    
    String sPartition = request.getParameter("partition")!=null ? rw.gets("partition") : null;
    
    if (sPartition==null){
	db.query("select distinct partition from rawdata_runs where position('_' in partition)=0 order by 1 desc limit 1;");
	
	sPartition = db.gets(1);
    }
    
    String sWhere = "";
    
    if (sPartition.length()>0)
	sWhere = cond(sWhere, "partition='"+Format.escSQL(sPartition)+"'");
    
    int iDAQGoodRunFlag = request.getParameter("daqstatus")==null ? 1 : rw.geti("daqstatus", -1);
    
    if (iDAQGoodRunFlag>=0)
	sWhere = cond(sWhere, "daq_goodflag="+iDAQGoodRunFlag);

    String sShuttle = request.getParameter("shuttlestatus")==null ? "Done" : rw.gets("shuttlestatus");
    
    if (sShuttle.length()>0)
	sWhere = cond(sWhere, "shuttle_status='"+Format.escSQL(sShuttle)+"'");
    
    int iTransferStatus = rw.geti("transferstatus", -1);
    
    if (iTransferStatus>=0)
	sWhere = cond(sWhere, "status="+iTransferStatus);
    
    final String sRunRange = rw.gets("runrange").trim();
    
    p.modify("runrange", sRunRange);
    
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
			
			sb.append("(run>=").append(start).append(" AND run<=").append(end).append(')');
		    }
		    catch (Exception e){
		    }
		}
		else{
		    try{
			int run = Integer.parseInt(s);
			
			if (sb.length()>0)
			    sb.append(" OR ");
			
			sb.append("run="+run);
		    }
		    catch (Exception e){
		    }
		}
	    }
	}
	
	if (sb.length()>0)
	    sWhere = cond(sWhere, sb.toString());
    }

    
    // ------------------------

    int iLimit = rw.geti("show", 500);
    int iOffset = rw.geti("offset");
    
    if (iLimit<0){
	iLimit = 1000000000;
	iOffset = 0;
    }

    db.query("SELECT count(1) FROM rawdata_runs_transfer_view "+sWhere+";");
    
    int iRunCount = db.geti(1);

    if (iOffset+iLimit > iRunCount)
	iOffset = iRunCount - iLimit;
	
    if (iOffset<0)
	iOffset = 0;

    sWhere += " ORDER BY run DESC LIMIT "+iLimit+" OFFSET "+iOffset;

    db.query("SELECT max(chunks), max(size) from rawdata_runs WHERE run IN (SELECT run FROM rawdata_runs_transfer_view "+sWhere+");");
    
    long lMaxChunks = db.getl(1);
    long lMaxSize = db.getl(2);

    db.query("SELECT * FROM rawdata_runs_transfer_view "+sWhere+";");
    
    int iCount = 0;
    int iChunks = 0;
    long lSize = 0;
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	String sDAQStatusColor = "#DDDDDD";
	
	if (db.geti("daq_goodflag", 0) == 1)
	    sDAQStatusColor = "#00FF00";
	if (db.geti("daq_goodflag", 1) == 0)
	    sDAQStatusColor = "#FF0000";
	
	pLine.modify("daq_status_color", sDAQStatusColor);
	
	String sShuttleStatusColor = "#DDDDDD";
	
	String s = db.gets("shuttle_status");
	
	if (s.length()>0)
	    sShuttleStatusColor = "#FFFF00";
	
	if (s.equals("Done"))
	    sShuttleStatusColor = "#00FF00";
	else
	if (s.toLowerCase().indexOf("fail")>=0)
	    sShuttleStatusColor = "#FF0000";
	    
	pLine.modify("shuttle_status_color", sShuttleStatusColor);
	
	boolean bCERN = db.gets("targetse").toUpperCase().startsWith("ALICE::CERN::");
	
	boolean bT1 = !bCERN && db.gets("targetse").length()>0;
	
	boolean bAny = bCERN || bT1;
	
	pLine.comment("com_keep", !bCERN || db.geti("status")==3);
	pLine.comment("com_t1", !bAny || db.geti("status")==3);
	
	pLine.comment("com_notkeep", bCERN);
	pLine.comment("com_nott1", bT1);
	pLine.comment("com_delete", !bAny);
	
	if (bAny){
	    int iPending = db.geti("cnt_0");
	    int iRunning = db.geti("cnt_1");
	    int iDone = db.geti("cnt_2");
	    int iError = db.geti("cnt_3");
	    
	    int iTotal = db.geti("cnt");
	    
	    String sp = bT1 ? "t1" : "";
	
	    pLine.modify(sp+"transfer_tooltip_caption", "Requested by <b><i>"+db.gets("requestedby")+"</i></b>");
	    	    
	    if (iTotal<=0){
		iTotal = iPending = 1;
		iDone = iError = 0;
		
		pLine.modify(sp+"transfer_tooltip", "Transfer pending processing");
	    }
	    else{
		pLine.modify(sp+"transfer_tooltip", "Target: "+db.gets("targetse")+"<br>&nbsp;<br><b><font color=green>"+iDone+" done</font><br><font color=red>"+iError+" failed</font><br><font color=yellow>"+iRunning+" queued</font><br>"+iPending+" pending<BR><hr size=1>"+iTotal+" total files</b>");
	    }

	    pLine.modify(sp+"size_pending", (int) (iPending*100f / iTotal));
	    pLine.modify(sp+"size_running", (int) (iRunning*100f / iTotal));
	    pLine.modify(sp+"size_done", (int) (iDone*100f / iTotal));
	    pLine.modify(sp+"size_error", (int) (iError*100f / iTotal));
	}
	
	pLine.modify("chunkspercentage", (int) (db.getl("chunks")*100f / lMaxChunks));
	pLine.modify("sizepercentage", (int) (db.getl("size")*100f / lMaxSize));
	
	p.append(pLine);
	
	iCount++;
	iChunks += db.geti("chunks");
	lSize += db.getl("size");
    }

    p.modify("total_runs", iCount);
    p.modify("total_chunks", iChunks);
    p.modify("total_size", lSize);

    // ------------------------ build options
    
    db.query("select p, cnt from (select partition p, count(1) as cnt from rawdata_runs group by partition) x order by split_part(p, '_', 1) desc, p asc;");
    
    while (db.moveNext()){
	String partition = db.gets(1);
	
	p.append("options_partitions", "<option value='"+partition+"' "+(partition.equals(sPartition)?"selected":"")+">"+partition+" ("+db.gets(2)+")</option>");
    }
    
    p.modify("daqstatus_"+iDAQGoodRunFlag, "selected");
    p.modify("shuttlestatus_"+sShuttle, "selected");
    p.modify("transferstatus_"+iTransferStatus, "selected");

    p.comment("com_prev", iLimit<1000000000 && iOffset>0);
    p.comment("com_next", iLimit<1000000000 && iOffset+iLimit<iRunCount);
    p.comment("com_all", iRunCount>iLimit);
    
    p.modify("offset", iOffset);
    p.modify("limit", iLimit);

    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/admin/transfers/index.jsp", baos.size(), request);
%>