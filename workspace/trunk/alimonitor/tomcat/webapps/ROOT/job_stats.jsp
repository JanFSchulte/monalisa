<%@ page import="alimonitor.*,lazyj.*,lia.web.utils.Formatare,java.util.*,utils.IntervalQuery,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils"%><%
    lia.web.servlets.web.Utils.logRequest("START /job_stats.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    String sBookmark = "/job_stats.jsp";
    
    pMaster.modify("title", "Currently running jobs");
    
    Page p = new Page("job_stats.res");
    
    Page pLine = new Page("job_stats_line.res");
    
    DB db = new DB();    

    final RequestWrapper rw = new RequestWrapper(request);

    // -----------------------------------------------
    
    String sPID = rw.gets("pid").trim();
    
    String sOwner = request.getParameter("owner");

    if (sOwner==null)
	sOwner = sPID.length()==0 ? "aliprod" : "";

    final StringBuffer sbWhere = new StringBuffer();    
	
    if (sOwner.trim().length()>0){
        if (sbWhere.length()>0)
    	    sbWhere.append(" AND ");
		
	sbWhere.append("owner='"+Formatare.mySQLEscape(sOwner)+"'");
	    
	sBookmark = IntervalQuery.addToURL(sBookmark, "owner", sOwner);
    }

    db.query("SELECT owner,count(1) as cnt FROM job_stats GROUP BY owner ORDER BY 1 ASC;");
    
    while (db.moveNext()){
	final String s = db.gets(1);
	final int iCnt = db.geti(2);
    
	p.append("opt_owner", "<option value=\""+s+"\" "+(s.equals(sOwner) ? "selected" : "")+">"+s+" ("+iCnt+")</option>");
    }
    
    final int iLastOption = rw.geti("lastseen", sPID.length()==0 ? 1 : 0);
    
    sBookmark = IntervalQuery.addToURL(sBookmark, "lastseen", ""+iLastOption);
    
    p.modify("opt_last_"+iLastOption, "selected");
    
    int iTimeConstraint = rw.geti("timesel", 0);
    
    p.modify("opt_time_"+iTimeConstraint, "selected");
    
    if (sPID.length()>0){
	try{
	    sBookmark = IntervalQuery.addToURL(sBookmark, "pid", sPID);
	
	    final String sClause = IntervalQuery.numberInterval(sPID, "pid");

	    if (sbWhere.length()>0)
		sbWhere.append(" AND ");
	
	    sbWhere.append(sClause);
	}
	catch (Exception e){
	}
    }
    else{
	if (iTimeConstraint>0){
	    if (sbWhere.length()>0)
		sbWhere.append(" AND ");
		
	    sbWhere.append("firstseen > extract(epoch from now()-'"+iTimeConstraint+" days'::interval)::int");
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, "timesel", ""+iTimeConstraint);
	}
	
	if (iLastOption==1 || iLastOption==2){
	    db.query("SELECT lastseen FROM job_stats ORDER BY lastseen DESC limit 1;");
	
	    final int iMax = db.geti(1);
	
    	    if (sbWhere.length()>0)
		sbWhere.append(" AND ");
	
	    sbWhere.append("lastseen "+(iLastOption==1 ? ">" : "<")+" "+(iMax-60*60));
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, "lastseen", ""+iLastOption);
	}
	else
	if (iLastOption==3){
	    if (sbWhere.length()>0)
		sbWhere.append(" AND ");
	
	    sbWhere.append("completion_date IS NOT NULL");
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, "lastseen", ""+iLastOption);
	}
    }
    
    db.query("SELECT * FROM job_stats "+ (sbWhere.length()>0 ? "WHERE "+sbWhere.toString() : "") +" ORDER BY lastseen DESC, firstseen DESC, pid DESC;");
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");

    int iCnt = 0;
    
    HashMap hmTotals = new HashMap();
    
    while (db.moveNext()){
	pLine.modify("pid", db.gets("pid"));
	
	File f = new File("/home/monalisa/MLrepository/tomcat/webapps/ROOT/jdl/"+db.gets("pid")+".html");
	
	if (f.exists())
	    pLine.comment("com_jdl_html", true);
	else
	    pLine.comment("com_jdl_html", false);
	
	pLine.modify("owner", db.gets("owner"));
	
	pLine.modify("firstseen", sdf.format(new Date(db.getl("firstseen")*1000)));
	pLine.modify("lastseen", sdf.format(new Date(db.getl("lastseen")*1000)));
	
	if (db.geti("completion_date")>0){
	    pLine.modify("last_seen_extra_start", "<a href='javascript:void(0);' onMouseOver=\"return overlib('Job completed at:<br>"+sdf.format(new Date(db.getl("completion_date")*1000))+"');\" onMouseOut=\"return nd();\"><b>");
	    pLine.modify("last_seen_extra_end", "</b>");
	}
	
	DB db2 = new DB("SELECT * FROM job_stats_details WHERE pid="+db.gets("pid")+" ORDER BY state='TOTAL' DESC;");
	
	int total=1;
	
	int err = 0;
	
	while (db2.moveNext()){
	    String sState = db2.gets("state");
	    int iCount = db2.geti("cnt");
	
	    pLine.modify(sState, ""+iCount);
	    
	    if (sState.equals("TOTAL"))
		total = iCount;
		
	    if (total>0){
	        pLine.modify("P_"+sState, ((iCount*100) / total)+"%");
	    }
	    else{
		pLine.modify("P_"+sState, " ? ");
	    }
	    
	    Integer i = (Integer) hmTotals.get(sState);
	    
	    hmTotals.put(sState, new Integer( (i==null ? 0 : i.intValue()) + iCount ));
	    
	    if (sState.startsWith("ERROR_") || sState.equals("EXPIRED") || sState.equals("ZOMBIE"))
		err += iCount;
	}
	
	if (err>0){
	    Integer i = (Integer) hmTotals.get("ERROR_ALL");
	    hmTotals.put("ERROR_ALL", new Integer( (i==null ? 0 : i.intValue()) + err ));
	    pLine.modify("ERROR_ALL", ""+err);
	    
	    if (total>0)
		pLine.modify("P_ERROR_ALL", ((err*100) / total)+"%");
	    else
		pLine.modify("P_ERROR_ALL", " ? ");
	}
	
	pLine.comment("com_color_0", iCnt%2==0);
	pLine.comment("com_color_1", iCnt%2!=0);
	
	iCnt++;
	
	p.append(pLine);
    }
    
    p.modify("TOTAL_JOBS", ""+iCnt);
    
    final Iterator it = hmTotals.entrySet().iterator();
    
    final Integer ioGrandTotal = (Integer) hmTotals.get("TOTAL");
    
    if (ioGrandTotal!=null && ioGrandTotal.intValue()>0){
	final int iGrandTotal = ioGrandTotal.intValue();
	
	while (it.hasNext()){
	    Map.Entry me = (Map.Entry) it.next();
	
	    String sState = (String) me.getKey();
	    int iCount = ((Integer) me.getValue()).intValue();
	    
	    p.modify(sState, ""+iCount);
	    p.modify("P_"+sState, ((iCount*100)/iGrandTotal)+"%");
	}
    }

    pMaster.modify("bookmark", sBookmark);

    p.modify("pid", sPID);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/job_stats.jsp", baos.size(), request);
%>