<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,java.security.cert.*,auth.*,lazyj.*,alimonitor.*,lia.Monitor.Store.Fast.DB,utils.IntervalQuery"%><%
    lia.web.servlets.web.Utils.logRequest("START /job_events.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("title", "Job details, events, software versions");
    
    Page p = new Page(null, "job_events.res");
    
    Page pLine = new Page(null, "job_events_line.res");
    
    RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();
    
    ///////////////////
    
    final boolean bAuthenticated = session.getAttribute("user_authenticated")!=null;
    
    if (bAuthenticated){
	int iOp = rw.geti("op");
	
	//System.err.println("OP = "+iOp);
	
	if (iOp>0){
	    String sIDs = "";
	    
	    for (String s: rw.getValues("bulk_stage")){
		sIDs += (sIDs.length()>0 ? "," : "") + Format.escSQL(s);
	    }
	    
	    if (sIDs.length()>0){
		String sQuery = "UPDATE job_runs_details SET staging_status="+(iOp==1 ? "1" : "0")+" WHERE pid in ("+sIDs+") AND staging_status"+(iOp==1 ? "=0" : ">0")+";";
	    
		db.query(sQuery);
	    }
	}
    }

    ///////////////////    
    
    db.query("SELECT owner,count(1) as cnt FROM job_stats GROUP BY owner ORDER BY count(1) DESC;");
    
    String sOwner = request.getParameter("owner");
    
    if (sOwner==null)
	sOwner = "aliprod";
    
    while (db.moveNext()){
	String s = db.gets("owner");
	int iCnt = db.geti("cnt");
    
	p.append("opt_owner", "<option value=\""+s+"\" "+(s.equals(sOwner) ? "selected" : "")+">"+s+" ("+iCnt+")</option>");
    }
    
    String sbWhere = "";
    
    if (sOwner!=null && sOwner.trim().length()>0)
	sbWhere = IntervalQuery.cond(sbWhere, "owner='"+Format.escSQL(sOwner)+"'");
	
    int iTimeConstraint = -1;
    
    try{
	iTimeConstraint = Integer.parseInt(request.getParameter("timesel"));
    }
    catch (Exception e){
    }
    
    if (iTimeConstraint < 0)
	iTimeConstraint = 7;
    
    p.modify("opt_time_"+iTimeConstraint, "selected");
    
    if (iTimeConstraint>0){
	sbWhere = IntervalQuery.cond(sbWhere, "firstseen > extract(epoch from now()-'"+iTimeConstraint+" days'::interval)::int");
    }

    int iStagedConstraint = 0;
    
    try{
	iStagedConstraint = Integer.parseInt(request.getParameter("staged"));
    }
    catch (Exception e){
    }
    
    p.modify("opt_staged_"+iStagedConstraint, "selected");
    
    String sROOTFilter = request.getParameter("filter_root");
    if (sROOTFilter!=null && sROOTFilter.length()>0){
	sbWhere = IntervalQuery.cond(sbWhere, "app_root ILIKE '%"+Format.escSQL(sROOTFilter)+"%'");
    }
    p.modify("filter_root", sROOTFilter);

    String sALIROOTFilter = request.getParameter("filter_aliroot");
    if (sALIROOTFilter!=null && sALIROOTFilter.length()>0){
	sbWhere = IntervalQuery.cond(sbWhere, "app_aliroot ILIKE '%"+Format.escSQL(sALIROOTFilter)+"%'");
    }
    p.modify("filter_aliroot", sALIROOTFilter);

    String sGEANTFilter = request.getParameter("filter_geant");
    if (sGEANTFilter!=null && sGEANTFilter.length()>0){
	sbWhere = IntervalQuery.cond(sbWhere, "app_geant ILIKE '%"+Format.escSQL(sGEANTFilter)+"%'");
    }
    p.modify("filter_geant", sGEANTFilter);

    String sOUTPUTDIRFilter = request.getParameter("filter_outputdir");
    if (sOUTPUTDIRFilter!=null && sOUTPUTDIRFilter.length()>0){
	sbWhere = IntervalQuery.cond(sbWhere, "outputdir ILIKE '%"+Format.escSQL(sOUTPUTDIRFilter)+"%'");
    }
    p.modify("filter_outputdir", sOUTPUTDIRFilter);

    String sJOBTYPEFilter = request.getParameter("filter_jobtype");
    if (sJOBTYPEFilter!=null && sJOBTYPEFilter.length()>0){
	sbWhere = IntervalQuery.cond(sbWhere, "jobtype ILIKE '%"+Format.escSQL(sJOBTYPEFilter)+"%'");
    }
    p.modify("filter_jobtype", sJOBTYPEFilter);
    
    String sRunFilter = request.getParameter("filter_run");
    
    if (sRunFilter!=null && sRunFilter.length()>0){
	String sCond = IntervalQuery.numberInterval(sRunFilter, "job_runs_details.runno");
	
	System.err.println("Filter : "+sRunFilter+" / "+sCond);
	
	if (sCond.length()>0)
	    sbWhere = IntervalQuery.cond(sbWhere, sCond);
    }
    
    p.modify("filter_run", sRunFilter);
    
    p.modify("usage_help", (new Page("job_events_usage.res")).toString());

    int iEvents = 0;

    Map mRemarks = new HashMap();
    
    db.query("SELECT * FROM job_runs_remarks;");
    
    while (db.moveNext()){
	mRemarks.put(db.gets("runint"), db.gets("remark"));
    }
    
    int iOrder = 0;
    
    try{
	iOrder = Integer.parseInt(request.getParameter("order"));
    }
    catch(Exception e){
    }
    
    String sOrder = "job_runs_details.runno";
    
    switch (iOrder/2){
	case 1: 
	    sOrder = "job_stats.pid";
	    break;
	case 2:
	    sOrder = "owner";
	    break;
	case 3:
	    sOrder = "events";
	    break;
	case 4:
	    sOrder = "app_root";
	    break;
	case 5:
	    sOrder = "app_aliroot";
	    break;
	case 6:
	    sOrder = "app_geant";
	    break;
	case 7:
	    sOrder = "firstseen";
	    break;
	case 8:
	    sOrder = "outputdir";
	    break;
	case 9:
	    sOrder = "jobtype";
	    break;
    }
    
    for (int i=0; i<=9; i++){
	p.modify("order_"+i, iOrder/2 == i ? (iOrder/2)*2 + (iOrder%2==0 ? 1 : 0) : i*2);
	
	p.comment("com_bold"+i, iOrder/2==i);
	
	if (iOrder/2==i){
	    p.modify("img"+i, "<img border=0 src=/img/"+(iOrder%2==1 ? "desc" : "asc")+".gif>");
	}
    }
    
    sOrder += iOrder%2==0 ? " DESC" : " ASC";

    db.query("select dirname,collections.filename,collections.files,run,collections_runs.files from collections inner join collections_runs on collections.filename=collections_runs.filename;");
    
    final HashMap hmCollections = new HashMap();

    while (db.moveNext()){
	final TreeMap tmCollection = new TreeMap();
	
	tmCollection.put("dirname", db.gets(1));
	tmCollection.put("filename", db.gets(2));
	tmCollection.put("totalfiles", db.gets(3));
	tmCollection.put("files", db.gets(5));
    
	ArrayList al = (ArrayList) hmCollections.get(db.gets(4));
	
	if (al==null){
	    al = new ArrayList(1);
	    hmCollections.put(db.gets(4), al);
	}
	
	al.add(tmCollection);
    }
    
    File fStagedCache = new File("/home/monalisa/MLrepository/bin/staging/cache/");
    
    for (String sCache: fStagedCache.list()){
	if (sCache.endsWith(".filelist")){
	    int iRun = Integer.parseInt(sCache.substring(0, sCache.indexOf(".")));
	    
	    BufferedReader br = new BufferedReader(new FileReader(new File(fStagedCache, sCache)));
	    
	    int iCount = 0;
	    
	    while (br.readLine()!=null){
		iCount++;
	    }
	    
	    final TreeMap tmCollection = new TreeMap();
	
	    tmCollection.put("dirname", "unknown");
	    tmCollection.put("filename", "collection.xml");
	    tmCollection.put("totalfiles", ""+iCount);
	    tmCollection.put("files", ""+iCount);
    
	    ArrayList al = (ArrayList) hmCollections.get(""+iRun);
	
	    if (al==null){
		al = new ArrayList(1);
	        hmCollections.put(""+iRun, al);
	    }
	
	    al.add(tmCollection);	    
	}
    }

    String q = "SELECT job_runs_details.*,owner,firstseen,lastseen,completion_date,lpm_history.runno as lpm_runno,wall_time,saving_time,job_events.* FROM job_stats INNER JOIN job_runs_details USING(pid) LEFT OUTER JOIN lpm_history USING (pid) LEFT OUTER JOIN job_events USING (pid) "+ sbWhere +" ORDER BY "+sOrder+", job_stats.pid desc;";
    
    db.query(q);
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");

    int iCnt = 0;

    final String[] fields = new String[]{"pid", "owner", "app_root", "app_aliroot", "app_geant", "outputdir", "jobtype"};
    
    Enumeration en = request.getParameterNames();
    
    String sReturnPath="/job_events.jsp?";
    
    while (en.hasMoreElements()){
	String sParam = (String) en.nextElement();
	
	String sValue = request.getParameter(sParam);
	
	if (sValue!=null && sValue.length()>0)
	    sReturnPath = sReturnPath + Format.encode(sParam)+"="+Format.encode(sValue)+"&";
    }
    
    p.modify("return_path", sReturnPath);
    
    pMaster.modify("bookmark", sReturnPath);

    p.comment("com_authenticated", !bAuthenticated);
    
    p.comment("com_admin", bAuthenticated);

    StringBuffer sbFolders = new StringBuffer();
    
    int iStagingCompleted = 0;
    int iStagingStarted   = 0;
    int iStagingUnknown   = 0;

    TreeSet<String> tsFolders = new TreeSet<String>();

    TreeSet<Integer> runList = new TreeSet<Integer>();
    TreeSet<Integer> jobList = new TreeSet<Integer>();
    
    double dWallTime = 0;
    double dSavingTime = 0;
    long lOutputSize = 0;

    while (db.moveNext()){
	int iRun = db.geti("runno");

	if (iRun<=0)
	    iRun = db.geti("lpm_runno");
	    
	runList.add(Integer.valueOf(iRun));

	// collections
	ArrayList alCollection = (ArrayList) hmCollections.get(""+iRun);
	
	if ( (iStagedConstraint==1 && alCollection==null) || (iStagedConstraint==2 && alCollection!=null) )
	    continue;
	
	if (alCollection!=null){
	    String s = "";
	
	    int max = 0;
	
	    for (int i=0; i<alCollection.size(); i++){
		Map m = (Map) alCollection.get(i);
	    
		s += m.get("dirname")+"/"+m.get("filename")+" : "+m.get("files")+" files, "+m.get("totalfiles")+" total files<br>";
		
		try{
		    max = Math.max(max, Integer.parseInt((String) m.get("files")));
		}
		catch (Exception e){
		}
	    }
	
	    pLine.modify("staged", "<img src=/img/trend_ok.png onMouseOver=\"overlib('Click for details');\" onMouseOut=\"nd();\" onClick=\"nd(); showCenteredWindow('"+Format.escJS(s)+"', 'Collections that contain run "+iRun+"')\"> "+max);
	}
	
	//System.err.println("RunNo : "+iRun);
	
	if (iRun>0)
	    pLine.modify("runno", ""+iRun);

    	dWallTime += db.getd("wall_time");
	dSavingTime += db.getd("saving_time");
	
	lOutputSize += db.getl("outputsize");
	    
    	pLine.modify("firstseen", sdf.format(new Date(db.getl("firstseen")*1000)));
	pLine.modify("lastseen", sdf.format(new Date(db.getl("lastseen")*1000)));
	
	pLine.modify("wall_time", db.getd("wall_time"));
	pLine.modify("saving_time", db.getd("saving_time"));
	pLine.modify("outputsize", db.getl("outputsize"));
	
	pLine.modify("return_path", sReturnPath);
	pLine.comment("com_authenticated", bAuthenticated);
    
	File f = new File("/home/monalisa/MLrepository/tomcat/webapps/ROOT/jdl/"+db.gets("pid")+".html");
	
	jobList.add(Integer.valueOf(db.geti("pid")));
	
	if (f.exists())
	    pLine.comment("com_jdl_html", true);
	else
	    pLine.comment("com_jdl_html", false);
	
	if (db.geti("completion_date")>0){
	    pLine.modify("last_seen_extra_start", "<a href=# onMouseOver=\"return overlib('Job completed at:<br>"+sdf.format(new Date(db.getl("completion_date")*1000))+"');\" onMouseOut=\"return nd();\"><b>");
	    pLine.modify("last_seen_extra_end", "</b>");
	}
	
	pLine.comment("com_color_0", iCnt%2==0);
	pLine.comment("com_color_1", iCnt%2!=0);
	
	for (String sField : fields){
	    pLine.modify(sField, db.gets(sField));
	}
	
	int iEv = db.geti("events");
	
	if (iEv<=0)
	    iEv = db.geti("mc_events");
	    
	if (iEv<=0)
	    iEv = db.geti("train_output");
	
	if (iEv>0){
	    pLine.modify("events", ""+iEv);
	    iEvents+=iEv;
	}
	
	// filter fields
	String s = Format.escHtml(db.gets("app_root"));
	if (sROOTFilter!=null && sROOTFilter.length()>0) s = Format.replace(s, sROOTFilter, "<B><FONT color=#00BBBB>"+sROOTFilter+"</FONT></B>");
	pLine.modify("tag_app_root", s);

	s = Format.escHtml(db.gets("app_aliroot"));
	if (sALIROOTFilter!=null && sALIROOTFilter.length()>0) s = Format.replace(s, sALIROOTFilter, "<B><FONT color=#00BBBB>"+sALIROOTFilter+"</FONT></B>");
	pLine.modify("tag_app_aliroot", s);
	
	s = Format.escHtml(db.gets("app_geant"));
	if (sGEANTFilter!=null && sGEANTFilter.length()>0) s = Format.replace(s, sGEANTFilter, "<B><FONT color=#00BBBB>"+sGEANTFilter+"</FONT></B>");
	pLine.modify("tag_app_geant", s);

	s = db.gets("outputdir");
	
	if (s.length()>0)
	    tsFolders.add(s);
	
	s = Format.escHtml(s);
	if (sOUTPUTDIRFilter!=null && sOUTPUTDIRFilter.length()>0) s = Format.replace(s, sOUTPUTDIRFilter, "<B><FONT color=#00BBBB>"+sOUTPUTDIRFilter+"</FONT></B>");
	pLine.modify("tag_outputdir", s);
	
	s = Format.escHtml(db.gets("jobtype"));
	if (sJOBTYPEFilter!=null && sJOBTYPEFilter.length()>0) s = Format.replace(s, sJOBTYPEFilter, "<B><FONT color=#00BBBB>"+sJOBTYPEFilter+"</FONT></B>");
	pLine.modify("tag_jobtype", s);

	// check remarks now
	
	Iterator it = mRemarks.entrySet().iterator();
	
	while (it.hasNext()){
	    Map.Entry me = (Map.Entry) it.next();
	    
	    String runint = (String) me.getKey();
	    String remark = (String) me.getValue();
	    
	    StringTokenizer st = new StringTokenizer(runint, " ,;");
	    
	    while (st.hasMoreTokens()){
		String sToken = st.nextToken();
		
		try{
	    	    if (sToken.indexOf("-")>0){
			int iMin = Integer.parseInt(sToken.substring(0, sToken.indexOf("-")));
			int iMax = Integer.parseInt(sToken.substring(sToken.indexOf("-")+1));
			
			if (iRun >= iMin && iRun <= iMax){
			    pLine.modify("remark", remark);
			    break;
			}
		    }
		    else{
			int iSingleRun = Integer.parseInt(sToken);
			
			if (iSingleRun == iRun){
			    pLine.modify("remark", remark);
			    break;
			}
		    }
		}
		catch (Exception e){
		}
	    }
	}
	
	iCnt++;
	
	int iStagingStatus = db.geti("staging_status");
	
	switch (iStagingStatus){
	    case  3: iStagingCompleted++; break;
	    case  2:
	    case  1: iStagingStarted++; break;
	    default: iStagingUnknown++;
	}
	
	if (iStagingStatus>0){
	    pLine.modify("stagingstatus_bgcolor", iStagingStatus==3 ? "#00FF00" : "#FFFF00");
	    
	    if (bAuthenticated)
		pLine.modify("stagingstatus_bgcolor_auth", iStagingStatus==3 ? "#00FF00" : "#FFFF00");
	    
	    pLine.comment("com_order", false);
	}
	
	pLine.comment("com_remove", iStagingStatus==3);
	
	p.append(pLine);
    }
    
    p.modify("TOTAL_JOBS", ""+iCnt);
    p.modify("EVENTS", ""+iEvents);

    p.modify("wall_time", dWallTime);
    p.modify("saving_time", dSavingTime);
    p.modify("outputsize", lOutputSize);

    
    p.modify("TOTAL_RUNS", runList.size());
    
    p.modify("run_list", IntervalQuery.toCommaList(runList));
    p.modify("job_list", IntervalQuery.toCommaList(jobList));
    
    for (String sFolder: tsFolders){
	p.append("TOTAL_FOLDERS", sFolder+"<BR>");
    }
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/job_events.jsp", baos.size(), request);
%>