<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*,alien.pool.*"%><%!
public String highlight(final String s, final String search){
    if (search.length()==0)
	return s;

    final String sLower = s.toLowerCase();
    final String sSearchLower = search.toLowerCase();
    
    int idx = 0;
    int iLastIdx = 0;
    
    String sRet = "";
    
    while ( (idx=sLower.indexOf(sSearchLower, idx))>=0 ){
	sRet += s.substring(iLastIdx, idx) + "<b><font color=blue>"+s.substring(idx, idx+sSearchLower.length())+"</font></b>";
	
	idx += sSearchLower.length();
	
	iLastIdx = idx;
    }
    
    sRet += s.substring(iLastIdx);
    
    return sRet;
}

public String addToURL(final String sURL, final String sKey, final String sValue){
    String s = sURL;

    if (s.indexOf("?")<0)
	s += "?";
    else
	s += "&";

    return s+Format.encode(sKey)+"="+Format.encode(sValue);
}

public String toInList(final List<String> l){
    final StringBuilder sb = new StringBuilder(l.size()*6);
    
    for (String s: l){
	if (sb.length()>0){
	    sb.append(',');
	}
	sb.append('\'').append(s).append('\'');
    }
    
    return sb.toString();
}

public String getColor(final double dPercentage){
    if (dPercentage>99.9)
	return "#00FF00";

    if (dPercentage>95)
	return "#88FF00";

    if (dPercentage>50)
	return "#FFFF00";

    if (dPercentage>20)
	return "#FFAA00";

    return "#FF0000";
}

%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /raw/raw_details.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "RAW data runs details");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    final Page p = new Page("raw/raw_details.res");
    final Page pLine = new Page("raw/raw_details_line.res");
    final Page pError = new Page("raw/raw_details_error.res");
    final Page pDone = new Page("raw/raw_details_done.res");
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    final DB db = new DB();
    
    final boolean bAuthenticated = session.getAttribute("user_authenticated")!=null;

    // -------------------

    if (bAuthenticated){
	final HashSet<Integer> prevHide = new HashSet<Integer>();
	final HashSet<Integer> hide = new HashSet<Integer>();
	
	for (String s: rw.getValues("h")){
	    hide.add(Integer.valueOf(s));
	}

	for (String s: rw.getValues("ph")){
	    prevHide.add(Integer.valueOf(s));
	}

	final HashSet<Integer> unsetHide = new HashSet<Integer>(prevHide);
	unsetHide.removeAll(hide);
    
	final HashSet<Integer> setHide = new HashSet<Integer>(hide);
	setHide.removeAll(prevHide);
    
	// remove hiding flag for the checkboxes that were unselected
	for (Integer i: unsetHide){
	    db.syncUpdateQuery("UPDATE rawdata_runs SET hide=false WHERE run='"+i+"';");
	}
    
	// set hiding flag for the checked runs
	for (Integer i: setHide){
	    db.syncUpdateQuery("UPDATE rawdata_runs SET hide=true WHERE run='"+i+"';");
	}
	
	prevHide.clear();
	hide.clear();
	
	for (String s: rw.getValues("hp")){
	    hide.add(Integer.valueOf(s));
	}
	
	for (String s: rw.getValues("php")){
	    prevHide.add(Integer.valueOf(s));
	}
	
	unsetHide.clear();
	unsetHide.addAll(prevHide);
	unsetHide.removeAll(hide);
    
	setHide.clear();
	setHide.addAll(hide);
	setHide.removeAll(prevHide);
    
	// remove hiding flag for the checkboxes that were unselected
	for (Integer i: unsetHide){
	    db.syncUpdateQuery("UPDATE job_runs_details SET hidden=0 WHERE pid="+i+";");
	}
    
	// set hiding flag for the checked runs
	for (Integer i: setHide){
	    db.syncUpdateQuery("UPDATE job_runs_details SET hidden=1 WHERE pid="+i+";");
	}
	
	// resubmit some runs
	final StringBuilder sbFoldersToDelete = new StringBuilder();
	for (String s: rw.getValues("r")){
	    int iRun = 0;
	    int iPass = 1;
	
	    try{
		int idx = s.indexOf('_');
	
		if (idx>0){
		    iRun = Integer.parseInt(s.substring(0, idx));
		    iPass = Integer.parseInt(s.substring(idx+1));
		}
		else{
		    iRun = Integer.parseInt(s.substring(0, idx));
		}
	    }
	    catch (NumberFormatException nfe){
		System.err.println("raw/raw_details.jsp : "+nfe);
		nfe.printStackTrace();
	    }
    
	    System.err.println("raw/raw_details.jsp : Run to delete: "+iRun+", pass "+iPass);
    
	    db.query("SELECT masterjob_id FROM rawdata_processing_requests WHERE run="+iRun+" AND pass="+iPass+" and masterjob_id is not null;");
	    
	    if (db.moveNext()){
		// clean previous error logs
		final int iOldMasterjobID = db.geti(1);
	    
		System.err.println("raw/raw_details.jsp :   Masterjob to remove: "+iOldMasterjobID);

		db.query("select outputdir from job_runs_details where pid="+iOldMasterjobID+";");
	    
		if (db.moveNext()){
		    final String sFolder = db.gets(1);
		
		    System.err.println("raw/raw_details.jsp :     Output dir: "+sFolder);
		
		    if (sFolder.length()>0){
			sbFoldersToDelete.append(' ').append(sFolder);
		    }
		}
	    
		String q;
	    
		q = "delete from rawdata_jobs where masterjob_id="+iOldMasterjobID;
		
		db.syncUpdateQuery(q);
	    
		System.err.println("raw/raw_details.jsp :       "+q+" -- "+db.getUpdateCount());
	    
		q = "delete from job_runs_details where pid="+iOldMasterjobID+";";
	    
		db.syncUpdateQuery(q);

		System.err.println("raw/raw_details.jsp :       "+q+" -- "+db.getUpdateCount());
	    
		q = "delete from job_stats where pid="+iOldMasterjobID+";";
	    
		db.syncUpdateQuery(q);

		System.err.println("raw/raw_details.jsp :       "+q+" -- "+db.getUpdateCount());
	    }
	
	    db.syncUpdateQuery("UPDATE rawdata_processing_requests SET masterjob_id=null, masterjob_starttime=null, status=0 WHERE run="+iRun+" AND pass="+iPass+";");
	}
    
	if (sbFoldersToDelete.length()>0){
	    new Thread("raw_details.jsp - delete ouput folders"){
		public void run(){
		    final String sFolders = sbFoldersToDelete.toString();
		
		    AliEnPool.executeCommand("alidaq", "rmdir "+sFolders);
		}
	    }.start();
	}

	final int iRunComment = rw.geti("comment_for_run");
	
	if (iRunComment>0){
	    final String sComment = rw.gets("comment");

	    db.syncUpdateQuery("DELETE FROM rawdata_comments WHERE run="+iRunComment);
	    
	    if (sComment.length()>0){
		final Object account = session.getAttribute("user_account");
		final String sAccount = account!=null ? account.toString() : "unknown";
		
		db.syncUpdateQuery("INSERT INTO rawdata_comments (run,comment,author) VALUES ("+iRunComment+",'"+Format.escSQL(sComment)+"','"+Format.escSQL(sAccount)+"');");
	    }
	}
    }

    // -------------------
    
    String sCond = "";

    String sBookmark = "/raw/raw_details.jsp";
    
    String sTypeFilter = rw.gets("filter_jobtype");
    String sDirFilter = rw.gets("filter_outputdir");
    String sCommentFilter = rw.gets("filter_comment");
    String sROOTFilter = rw.gets("filter_root");
    String sALIROOTFilter = rw.gets("filter_aliroot");
    boolean bRelaxed = rw.getb("relaxed", true);
    boolean bFilterLPM = rw.getb("filter_lpm", true);
    String sRunFilter = rw.gets("filter_runno");
    int iPassFilter = rw.geti("filter_pass", -1);
    
    String sPartitionFilter = request.getParameter("filter_partition");
    
    String sDetectorFilter = rw.gets("filter_detectors");
    
    final String sView = "raw_details_"+(bFilterLPM ? "lpm" : "all");
        
    if (sPartitionFilter==null){
	if (sTypeFilter.length()>0){
	    db.query("SELECT distinct partition,pass FROM "+sView+" where trim(jobtype) ilike '%"+Format.escSQL(sTypeFilter)+"%' order by 1;");

	    if (db.count()==1){
		sPartitionFilter = db.gets(1);
		
		if (iPassFilter<0)
		    iPassFilter = db.geti(2);
	    }
	    else{
		sPartitionFilter = "";
	    }
	}
	else{
	    if (sRunFilter.length()==0){
	        db.query("select distinct partition from rawdata_runs where position('_' in partition)=0 order by partition desc limit 1;");
	
		sPartitionFilter = db.gets(1);
	    }
	    else{
		sPartitionFilter = "";
	    }
	}
    }
    
    if (sTypeFilter.length()>0){
	if (bRelaxed){
	    sCond = "trim(jobtype) ilike '%"+Format.escSQL(sTypeFilter)+"%'";
	}
	else{
	    sCond = "trim(jobtype)='"+Format.escSQL(sTypeFilter)+"'";
	}
	
	sBookmark = addToURL(sBookmark, "filter_jobtype", sTypeFilter);
    }
    
    if (sDirFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	String sWildcard = bRelaxed ? "%" : "";
    
	sCond += "outputdir ilike '"+sWildcard+Format.escSQL(sDirFilter)+sWildcard+"'";
	
	sBookmark = addToURL(sBookmark, "filter_outputdir", sDirFilter);
    }
    
    if (sCommentFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	String sWildcard = bRelaxed ? "%" : "";
    
	sCond += "comment ilike '"+sWildcard+Format.escSQL(sCommentFilter)+sWildcard+"'";
	
	sBookmark = addToURL(sBookmark, "filter_comment", sCommentFilter);
    }
    
    if (sRunFilter.length()>0){
	String sRunCond = utils.IntervalQuery.numberInterval(sRunFilter, "run");
    	
	if (sRunCond.length()>0){
	    if (sCond.length()>0)
		sCond += " AND ";
	
	    sCond += "("+sRunCond+")";
	    
	    sBookmark = addToURL(sBookmark, "filter_runno", sRunFilter);
	}
    }
    
    if (sPartitionFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "partition='"+Format.escSQL(sPartitionFilter)+"'";
	
	sBookmark = addToURL(sBookmark, "filter_partition", sPartitionFilter);
    }

    if (sROOTFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "app_root='"+Format.escSQL(sROOTFilter)+"'";
	
	sBookmark = addToURL(sBookmark, "filter_root", sROOTFilter);
    }

    if (sALIROOTFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "app_aliroot='"+Format.escSQL(sALIROOTFilter)+"'";
	
	sBookmark = addToURL(sBookmark, "filter_aliroot", sALIROOTFilter);
    }
    
    if (iPassFilter>=0){
	if (sCond.length()>0)
	    sCond += " AND ";

	sCond += "pass="+iPassFilter;
	
	sBookmark = addToURL(sBookmark, "filter_pass", ""+iPassFilter);	
    }

    if (!bFilterLPM)
	sBookmark = addToURL(sBookmark, "filter_lpm", "0");
	
    if (!bRelaxed)
	sBookmark = addToURL(sBookmark, "relaxed", "0");

    if (!bAuthenticated){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "(hide is null or not hide) AND hidden=0";
    }

    final List<String> detp = new LinkedList<String>();
    final List<String> detn = new LinkedList<String>();
    
    if (sDetectorFilter.length()>0){	
	final StringTokenizer st = new StringTokenizer(sDetectorFilter, " ,_;.-\\'\"");
	
	while (st.hasMoreTokens()){
	    String s = st.nextToken().toUpperCase();
	    
	    if (s.startsWith("-")){
		detn.add(s.substring(1));
	    }
	    else
		detp.add(s);
	}
	
	if (detp.size()>0){
	    if (sCond.length()>0)
		sCond += " AND ";
	    
	    sCond += "( (select count(1) from shuttle where shuttle.run=rd.run and detector in ("+toInList(detp)+")) = "+detp.size()+")";
	}

	if (detn.size()>0){
	    if (sCond.length()>0)
		sCond += " AND ";
	    
	    sCond += "( (select count(1) from shuttle where shuttle.run=rd.run and detector in ("+toInList(detn)+")) = 0)";
	}
	
	sBookmark = addToURL(sBookmark, "filter_detectors", sDetectorFilter);
    }

    if (sCond.length()>0)
	sCond = " WHERE "+sCond;
	
    String sOrderBy = "run is null, run";
    String sOrder = "DESC";
    
    // -------------------

    p.modify("returnurl", sBookmark);

    
    db.query("SELECT greatest(max(size),max(size_pass1),max(size_pass2),max(size_pass3)) FROM "+sView+" rd "+sCond+";");
    
    long lMaxSize = db.getl(1);
    long lMaxSizePass1 = db.getl(1);
    long lMaxSizePass2 = db.getl(1);
    
    final String sQuery = "SELECT * FROM "+sView+" rd NATURAL LEFT JOIN rawdata_comments "+sCond+" ORDER BY "+sOrderBy+" "+sOrder+", pass desc";
    
    //System.err.println(sQuery);
    
    db.query(sQuery);
    
    long count = 0;
    long chunks = 0;
    long processed = 0;
    long events = 0;
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
    
    long lTotalErrors = 0;
    
    Page pComment = new Page("raw/raw_details_comment"+(bAuthenticated ? "_admin" : "")+".res");

    long lTotalRawSize = 0;
    long lTotalPass1Size = 0;
    long lTotalPass2Size = 0;
    long lTotalPass3Size = 0;

    Set<Integer> runsSet = new TreeSet<Integer>();

    StringBuilder sbJobs = new StringBuilder();
    
    double dWallTime = 0;
    double dSavingTime = 0;
    long lOutputSize = 0;

    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	if (sbJobs.length()>0){
	    sbJobs.append(", ");
	}
	
	dWallTime += db.getd("wall_time");
	dSavingTime += db.getd("saving_time");
	
	lOutputSize += db.getl("outputsize");
	
	runsSet.add(Integer.valueOf(db.geti("run")));
	sbJobs.append(db.geti("pid"));
	
	pLine.modify("outputdir", highlight(db.gets("outputdir"), sDirFilter));
	pLine.modify("jobtype", highlight(db.gets("jobtype"), sTypeFilter));
	
	pLine.comment("com_admin", bAuthenticated);
	
	count++;
	
	final int run_chunks = db.geti("chunks");
	final int run_processed = db.geti("processed_chunks");
	
	chunks += run_chunks;
	processed += run_processed;
	
	events += db.geti("events");
	
	final double dPercentage = run_chunks>0 ? run_processed*100d/run_chunks : 0;
	
	pLine.modify("processed_chunks_percentage", ""+dPercentage);
	pLine.modify("processed_color", getColor(dPercentage));
	
	pLine.modify("firstseen2", sdf.format(new Date(db.getl("firstseen")*1000)));
	
	int errors = db.geti("errorv_count");

	lTotalErrors += errors;

	pLine.modify("returnurl", sBookmark);
	
	if (errors>0 && run_processed < run_chunks){
	    pError.fillFromDB(db);
	    pError.modify("returnurl", sBookmark);
	
	    pLine.modify("errorv", pError);
	}
	else{
	    if (db.geti("status")==2 || run_processed==run_chunks){
		pDone.fillFromDB(db);
	    
		pLine.modify("errorv", pDone);
	    }
	}

	if (bAuthenticated){
	    final boolean bHide = lazyj.Utils.stringToBool(db.gets("hide"), false);
	    
	    if (bHide){
		pLine.modify("prev_hide", "<input type=hidden name=ph value='"+db.geti("run")+"'>");
	    }
	    
	    final boolean bHidePid = db.geti("hidden")==1;
	    
	    if (bHidePid){
		pLine.modify("prev_hide_pid", "<input type=hidden name=php value='"+db.geti("pid")+"'>");
	    }
	}
	
	String sComment = db.gets("comment");
	
	if (sComment.length()>0 || bAuthenticated){
	    pComment.fillFromDB(db);
	    pLine.modify("comment_place", pComment);
	}
	else{
	    pLine.modify("comment_place", "<td class=table_row></td>");
	}
	
	pLine.modify("events_nice", db.geti("events"));
	
	final long lSize = db.getl("size");
	final long lSizePass1 = db.getl("size_pass1");
	final long lSizePass2 = db.getl("size_pass2");
	final long lSizePass3 = db.getl("size_pass3");
	
	lTotalRawSize += lSize;
	lTotalPass1Size += lSizePass1;
	lTotalPass2Size += lSizePass2;
	lTotalPass3Size += lSizePass3;
	
	if (lMaxSize > 0)
	    pLine.modify("sizepercentage", lSize*100d / lMaxSize);
	
	if (lMaxSizePass1 > 0)
	    pLine.modify("sizepercentagepass1", lSizePass1*100d / lMaxSizePass1);
	
	if (lMaxSizePass2 > 0)
	    pLine.modify("sizepercentagepass2", lSizePass2*100d / lMaxSizePass2);
	
	p.append("content", pLine);
    }
    
    p.modify("total_rawdata_size", lTotalRawSize);
    p.modify("total_pass1_size", lTotalPass1Size);
    p.modify("total_pass2_size", lTotalPass2Size);
    p.modify("total_pass3_size", lTotalPass3Size);
    
    final long lTotalMaxSize = Math.max(Math.max(lTotalRawSize, lTotalPass1Size), lTotalPass2Size);
    
    if (lTotalMaxSize>0){
	p.modify("sizepercentage", lTotalRawSize*100d / lTotalMaxSize);
	p.modify("sizepercentagepass1", lTotalPass1Size*100d / lTotalMaxSize);
	p.modify("sizepercentagepass2", lTotalPass2Size*100d / lTotalMaxSize);
    }
    
    // -------------------
    
    db.query("select distinct app_root from job_stats inner join job_runs_details on job_stats.pid=job_runs_details.pid and owner='alidaq' and length(app_root)>0 order by 1;");
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_root", "<option value='"+s+"'"+(s.equals(sROOTFilter) ? " selected" : "")+">"+s+"</option>");
    }

    db.query("select distinct app_aliroot from job_stats inner join job_runs_details on job_stats.pid=job_runs_details.pid and owner='alidaq' and length(app_aliroot)>0 order by 1;");
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_aliroot", "<option value='"+s+"'"+(s.equals(sALIROOTFilter) ? " selected" : "")+">"+s+"</option>");
    }
    
    db.query("SELECT distinct partition FROM raw_details_lpm order by 1 desc;");
    while (db.moveNext()){
	String s = db.gets(1);
	
	p.append("opt_partition", "<option value='"+s+"'"+(s.equals(sPartitionFilter) ? " selected" : "")+">"+s+"</option>");
    }
    
    // At the end, set the values received by parameters
    
    p.modify("relaxed", bRelaxed ? 1 : 0);
    p.modify("option_lpm_"+bFilterLPM, "selected");
    p.modify("filter_jobtype", sTypeFilter);
    p.modify("filter_outputdir", sDirFilter);
    p.modify("filter_comment", sCommentFilter);
    p.modify("filter_runno", sRunFilter);
    p.modify("total_errors", lTotalErrors);
    p.modify("filter_detectors", sDetectorFilter);

    p.modify("wall_time", dWallTime);
    p.modify("saving_time", dSavingTime);
    p.modify("outputsize", lOutputSize);
    
    for (int pass=0; pass<20; pass++){
	p.append("pass_options", "<option value="+pass+(pass==iPassFilter ? " selected" : "")+">"+pass+"</option>");
    }

    // And produce last row of statistics
    
    p.modify("total_count", count);
    p.modify("total_chunks", chunks);
    p.modify("total_processed", processed);
    p.modify("total_events", events);
    
    final StringBuilder sbRuns = new StringBuilder(runsSet.size() * 10);
    
    for (final Integer run: runsSet){
	if (sbRuns.length()>0)
	    sbRuns.append(", ");
	
	sbRuns.append(run);
    }
    
    p.modify("runs_count", runsSet.size());
    p.modify("all_runs", sbRuns);
    p.modify("all_jobs", sbJobs);

    final double dPercentage = chunks>0 ? (processed*100d)/chunks : 0;
    p.modify("total_percent", ""+dPercentage);
    p.modify("total_percent_color", getColor(dPercentage));

    p.comment("com_authenticated", !bAuthenticated);
    
    p.comment("com_admin", bAuthenticated);

    p.modify("return_path", sBookmark);

    // Create the bookmarks
    
    pMaster.modify("bookmark", sBookmark);
    
    // -------------------
        
    pMaster.append(p);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
                    
    lia.web.servlets.web.Utils.logRequest("/raw/raw_details.jsp", baos.size(), request);
%>