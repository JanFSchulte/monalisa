<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lazyj.*,utils.IntervalQuery"%><%
    lia.web.servlets.web.Utils.logRequest("START /prod/jobs.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    final RequestWrapper rw = new RequestWrapper(request);
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    final int iProdID = rw.geti("t");
    
    final String sOwner = rw.gets("owner");

    final DB db = new DB("SELECT * FROM job_types WHERE jt_id="+iProdID);

    pMaster.modify("title", "Production - "+db.gets("jt_type"));
    
    final boolean cPass0Merging = db.gets("jt_type").matches(".*CPass.*merging.*");
    
    final boolean qaFinalMerging = db.gets("jt_type").matches("^QA(\\d+)?_LHC\\d\\d\\w_Stage5:.*");
    
    final Page p = new Page("prod/jobs.res", false);

    p.fillFromDB(db, false);
    
    p.comment("com_cpass0merging", cPass0Merging);
    
    p.comment("com_qafinalmerging", qaFinalMerging);
    
    final Page pLine = new Page("prod/jobs_el.res", false);

    String sBookmark = "/prod/jobs.jsp?t="+iProdID;
    
    if (sOwner.length()>0)
        sBookmark = IntervalQuery.addToURL(sBookmark, "owner", sOwner);

    final DB db2 = new DB();
    
    String sWhere = "WHERE job_types_id="+iProdID;

    for (String sField : Arrays.asList("pid", "runno", "input_events", "train_passed", "train_output")){
	String sValue = rw.gets(sField);
    
	String sCond = IntervalQuery.numberInterval(sValue, sField);
	
	if (sCond.length() > 0){
	    sWhere = IntervalQuery.cond(sWhere, sCond);
	    
	    p.modify(sField, sValue);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sField, sValue);
	}
    }
    
    for (String sField : Arrays.asList("app_root", "app_aliroot", "outputdir")){
	String sValue = rw.gets(sField);
	
	if (sValue.length()>0){
	    String sCond = sField+" ilike '%"+sValue+"%'";
	    
	    p.modify(sField, sValue);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sField, sValue);
	    
	    sWhere = IntervalQuery.cond(sWhere, sCond);
	}
    }
    
    sWhere = IntervalQuery.cond(sWhere, "owner in ('alidaq', 'alitrain', 'aliprod')");

    String sQuery = "SELECT *,(select count(1) from psqa where psqa.pid=job_runs_details.pid) AS psqa_count,iostats IS NOT NULL as has_iostats FROM job_runs_details INNER JOIN job_stats USING(pid) LEFT OUTER JOIN job_events USING(pid) LEFT OUTER JOIN job_iostats USING(pid) ";
    
    if (qaFinalMerging){
	sQuery += " LEFT OUTER JOIN configuration ON runno=run ";
    }
    
    sQuery += sWhere+" ORDER BY runno DESC, pid DESC;";
    
    //System.err.println(sQuery);
    
    db.query(sQuery);

    int iJobs = 0;

    final Set<Integer> pids = new TreeSet<Integer>();
    final Set<Integer> runs = new TreeSet<Integer>();
    final Set<Integer> goodRuns = new TreeSet<Integer>();
    
    int iTTotal = 0;
    int iTDone = 0;
    int iTRunning = 0;
    int iTWaiting = 0;
    int iTError = 0;
    int iTOther = 0;
  
    int iinput_events = 0;  
    int itrain_output = 0;
    int itrain_passed = 0;
    
    double dWallTime = 0;
    double dSavingTime = 0;
    long lOutputSize = 0;
    
    boolean anyPSQA = false;
    
    boolean anyIOStat = false;

    final Set<Integer> psqaPIDs = new TreeSet<Integer>();
    final Set<Integer> iostatPIDs = new TreeSet<Integer>();
    
    final Map<String, Set<Integer>> detStatus = new TreeMap<String, Set<Integer>>();

    while (db.moveNext()){
	pLine.comment("com_cpass0merging", cPass0Merging);
	
	pLine.comment("com_qafinalmerging", qaFinalMerging);
    
	if (db.geti("psqa_count")>0){
	    pLine.comment("com_psqa", true);
	    anyPSQA = true;
	    psqaPIDs.add(Integer.valueOf(db.geti("pid")));
	}
	else{
	    pLine.comment("com_psqa", false);
	}
	
	if (db.getb("has_iostats", false)){
	    pLine.comment("com_iostat", true);
	    anyIOStat = true;
	    iostatPIDs.add(Integer.valueOf(db.geti("pid")));
	}
	else{
	    pLine.comment("com_iostat", false);
	}
    
	pLine.fillFromDB(db);

	int iTotal = 0;
	int iDone = 0;
	int iRunning = 0;
	int iWaiting = 0;
	int iError = 0;
	int iOther = 0;
	
	iinput_events += db.geti("input_events");
	itrain_passed += db.geti("train_passed");
	itrain_output += db.geti("train_output");
	
	dWallTime += db.getd("wall_time");
	dSavingTime += db.getd("saving_time");
	
	lOutputSize += db.getl("outputsize");
	
	if (db.geti("input_events")>0){
	    double percentage = (100d * db.geti("train_passed")) / db.geti("input_events");
	    
	    pLine.modify("passed_percentage", Format.point(percentage)+"%");
	}

	final Integer runno = Integer.valueOf(db.geti("runno"));

	pids.add(Integer.valueOf(db.geti("pid")));
	runs.add(runno);

	db2.query("SELECT state,cnt FROM job_stats_details WHERE pid="+db.geti("pid")+" AND cnt>0;");

	while (db2.moveNext()){
	    final String sState = db2.gets(1);
	    final int iCnt = db2.geti(2);
	    
	    if (sState.equals("TOTAL"))
		iTotal = iCnt;
	    else
	    if (sState.startsWith("DONE"))
		iDone += iCnt;
	    else
	    if (sState.startsWith("ERROR") || sState.equals("EXPIRED") || sState.equals("ZOMBIE"))
		iError += iCnt;
	    else
	    if (sState.equals("INSERTING") || sState.equals("WAITING"))
		iWaiting += iCnt;
	    else
	    if (sState.equals("RUNNING") || sState.equals("SAVING") || sState.equals("STARTED") || sState.equals("ASSIGNED") || sState.startsWith("SAVED"))
		iRunning += iCnt;
	    else
		iOther += iCnt;
	}
	
	iTTotal   += iTotal;
	iTDone    += iDone;
	iTRunning += iRunning;
	iTWaiting += iWaiting;
	iTError   += iError;
	iTOther   += iOther;
	
	if (iTotal > 0){
	    pLine.modify("jobs_total", iTotal);
	    
	    int iCompletion = iDone * 100 / iTotal;
	    
	    pLine.modify("jobs_completion", iCompletion+"%");

	    if (db.geti("state")==2){
		if (iCompletion>=95)
		    pLine.modify("completion_bgcolor", "#54E715");
		else
		if (iCompletion>=90)
		    pLine.modify("completion_bgcolor", "yellow");
		else
		if (iCompletion>=80)
		    pLine.modify("completion_bgcolor", "orange");
		else
		    pLine.modify("completion_bgcolor", "red");
	    }
	    
	    if (iDone>0) pLine.modify("jobs_done", iDone);
	    if (iRunning>0) pLine.modify("jobs_running", iRunning);
	    if (iWaiting>0) pLine.modify("jobs_waiting", iWaiting);
	    if (iError>0) pLine.modify("jobs_error", iError);
	    if (iOther>0) pLine.modify("jobs_other", iOther);
	}

	pLine.comment("com_rawdata", sOwner.equals("alidaq") || db.gets("owner").equals("alidaq"));
	
	pLine.modify("tr_bgcolor", iJobs % 2 == 0 ? "#FFFFFF" : "#F0F0F0");    
	
	if (cPass0Merging){
	    String q = "SELECT det,status FROM cpass0_status WHERE pid="+db.geti("pid")+" ORDER BY length(det), det;";
	
	    db2.query(q);
	    
	    Set<String> seenDet = new HashSet<String>();
	    
	    boolean allOk = true;
	    	
	    while (db2.moveNext()){
		String det = db2.gets(1);
		int status = db2.geti(2);
		
		Set<Integer> sruns = null;
		
		if (!det.endsWith("_statistic")){
		    sruns = detStatus.get(det+"/"+status);
		    if (sruns==null){
			sruns = new TreeSet<Integer>();
			detStatus.put(det+"/"+status, sruns);
		    }
		}
		
	        String color = null;
		String msg = "<a target=_blank href='/users/download.jsp?view=true&path="+db.gets("outputdir")+"/ocdb.log' class=link>log</a>";
		
		if (det.indexOf('_')<0){
		    switch (status){
			case 0: color="#99FF99"; msg=null; break;
			case 1: color="#FF2222"; allOk = false; break;
			case 2: color="orange"; allOk = false; break;
		    }
		    
		    seenDet.add(det);
		    
		    if (det.equals("GRP"))
			seenDet.add("MeanVertex");
		    
		    sruns.add(runno);
		}
		else{
		    String realDet = det;
		    
		    for (String s: new String[]{"_", "events", "tracks"}){
			int idx = realDet.indexOf(s);
			
			if (idx>=0)
			    realDet = realDet.substring(0, idx);
		    }
		
		    if (seenDet.contains(realDet)){
			if (det.endsWith("_status")){
			    msg = "<a target=_blank href='/users/download.jsp?view=true&path="+db.gets("outputdir")+"/ocdb.log' class=link>"+status+"</a>";
		    	    color = status<0 ? "" : (status==0 ? "#99FF99" : "#FF2222");
		    	    
		    	    sruns.add(runno);
		    	}
		    	else{
		    	    pLine.modify("cpass0_"+det, status);
		    	    continue;
		    	}
		    }
		    else{
			continue;
		    }
		}
		
    		pLine.modify("cpass0_"+det+"_color", color);
		pLine.modify("cpass0_"+det, msg);
	    }
	    
	    if (allOk && iDone>0)
		goodRuns.add(runno);
	}
		
	p.append(pLine);
	
	iJobs ++;
    }

    p.modify("tinput_events", iinput_events);
    p.modify("ttrain_output", itrain_output);
    p.modify("ttrain_passed", itrain_passed);

    if (iinput_events>0){
	p.modify("tpassed_percentage", Format.point(itrain_passed*100d/iinput_events)+"%");
    }
    
    if (anyPSQA){
	p.comment("com_psqa", true);
	p.modify("psqa_pids", IntervalQuery.toCommaList(psqaPIDs));
    }
    else{
	p.comment("com_psqa", false);
    }
    
    if (anyIOStat){
	p.comment("com_iostat", true);
	p.modify("iostat_pids", IntervalQuery.toCommaList(iostatPIDs));
    }
    else{
	p.comment("com_iostat", false);
    }
    
    String oldDet = null;
    int oldDetCounter = 0;
    
    for (final Map.Entry<String, Set<Integer>> entry: detStatus.entrySet()){
	final Set<Integer> runlist = entry.getValue();
	
	if (runlist.size()==0)
	    continue;
    
	final String key = entry.getKey();
	
	final String det = key.substring(0, key.lastIndexOf('/'));
	final int status = Integer.parseInt(key.substring(key.lastIndexOf('/')+1));
	
	if (!det.equals(oldDet)){
	    if (oldDet!=null)
		p.modify(oldDet+"_counter", oldDetCounter);
	
	    oldDet = det;
	    oldDetCounter = runlist.size();
	}
	else
	    oldDetCounter += runlist.size();
	
	String msg = "OK";
	
	if (status>0)
	    msg = "ERR ("+status+")";
	else
	if (status<0)
	    msg = "IGN ("+status+")";
	
	p.append(det+"_statusshort", msg + " : "+entry.getValue().size()+"<BR>");
	p.append(det+"_statuslong", "<B>"+msg + " : "+entry.getValue().size()+" runs</B>:<br>"+IntervalQuery.toCommaList(runlist)+"<BR><BR>");
    }
    
    if (oldDet!=null)
	p.modify(oldDet+"_counter", oldDetCounter);
    
    p.modify("pids_list", IntervalQuery.toCommaList(pids));
    
    if (cPass0Merging){
	p.append("runs_list_compiled", "<b>Good runs : "+goodRuns.size()+"</B><BR>" + IntervalQuery.toCommaList(goodRuns)+"<BR><BR>");
	
	final TreeSet<Integer> failedRuns = new TreeSet<Integer>(runs);
	failedRuns.removeAll(goodRuns);
	
	p.append("runs_list_compiled", "<b>Failed or active runs : "+failedRuns.size()+"</B><BR>" + IntervalQuery.toCommaList(failedRuns)+"<BR><BR>");
	p.append("runs_list_compiled", "<b>All runs : "+runs.size()+"</b><BR>" + IntervalQuery.toCommaList(runs));
	
	p.modify("good_runs_cnt", goodRuns.size());
    }
    else{
	p.modify("runs_list_compiled", IntervalQuery.toCommaList(runs));
    }
    
    p.modify("jobs_cnt", iJobs);
    p.modify("runs_cnt", runs.size());

    p.modify("jobs_total", iTTotal);
    p.modify("jobs_done",  iTDone);
    p.modify("jobs_running", iTRunning);
    p.modify("jobs_waiting", iTWaiting);
    p.modify("jobs_error", iTError);
    p.modify("jobs_other", iTOther);
    
    p.modify("wall_time", dWallTime);
    p.modify("saving_time", dSavingTime);
    p.modify("outputsize", lOutputSize);

    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/prod/jobs.jsp", baos.size(), request);
%>