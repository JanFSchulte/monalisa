<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*"%><%!
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

    if (true){
	response.sendRedirect("/raw/raw_details.jsp?"+request.getQueryString());
	return;
    }

    lia.web.servlets.web.Utils.logRequest("START /production/raw_details.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "RAW data production requests");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    Page p = new Page("production/raw_details.res");
    Page pLine = new Page("production/raw_details_line.res");
    Page pError = new Page("production/raw_details_error.res");
    
    RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();
    
    final boolean bAuthenticated = session.getAttribute("user_authenticated")!=null;
    
    // -------------------

    final HashSet<Integer> prevHide = new HashSet<Integer>();
    final HashSet<Integer> hide = new HashSet<Integer>();
    
    for (String s: rw.getValues("h")){
	hide.add(Integer.parseInt(s));
    }

    for (String s: rw.getValues("ph")){
	prevHide.add(Integer.parseInt(s));
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

    // resubmit some runs
    final StringBuilder sbFoldersToDelete = new StringBuilder();
    for (String s: rw.getValues("r")){
	final int iRun = Integer.parseInt(s);
    
	//System.err.println("Run to delete: "+iRun);
    
	db.query("SELECT masterjob_id FROM rawdata_processing_requests WHERE run="+iRun+" AND pass=1 and masterjob_id is not null;");
	    
	if (db.moveNext()){
	    // clean previous error logs
	    final int iOldMasterjobID = db.geti(1);
	    
	    //System.err.println("  Masterjob to remove: "+iOldMasterjobID);

	    db.query("select outputdir from job_runs_details where pid="+iOldMasterjobID+";");
	    
	    if (db.moveNext()){
		final String sFolder = db.gets(1);
		
		//System.err.println("    Output dir: "+sFolder);
		
		if (sFolder.length()>0){
		    sbFoldersToDelete.append(' ').append(sFolder);
		}
	    }
	    
	    String q = "update rawdata set errorv_logfile=null where lfn like '%"+iRun+"/%' and errorv_logfile like '/joboutputs/"+iOldMasterjobID+"/%';";
	    
	    db.syncUpdateQuery(q);
	    
	    //System.err.println("      "+q+" -- "+db.getUpdateCount());
	    
	    q = "update rawdata set errorv_logfile=null where lfn in (select lfn from rawdata_details where run="+iRun+" and errorv_logfile is not null);";

	    db.syncUpdateQuery(q);

	    //System.err.println("      "+q+" -- "+db.getUpdateCount());
	    
	    q = "delete from job_runs_details where pid="+iOldMasterjobID+";";
	    
	    db.syncUpdateQuery(q);

	    //System.err.println("      "+q+" -- "+db.getUpdateCount());
	    
	    q = "delete from job_stats where pid="+iOldMasterjobID+";";
	    
	    db.syncUpdateQuery(q);

	    //System.err.println("      "+q+" -- "+db.getUpdateCount());
	}
	
	db.syncUpdateQuery("UPDATE rawdata_processing_requests SET masterjob_id=null, masterjob_starttime=null, status=0 WHERE run="+iRun+" AND pass=1;");
    }
    
    if (sbFoldersToDelete.length()>0){
	new Thread("raw_details.jsp - delete ouput folders"){
	    public void run(){
		final String sFolders = sbFoldersToDelete.toString();
		
		try{
		    //System.err.println("    Deleting output folders: "+sFolders);
		    final String[] cmd = new String[]{"/home/monalisa/alien", "login", "-role", "alidaq", "-exec", "rmdir "+sFolders};
		
		    final Process p = Runtime.getRuntime().exec(cmd);
		    
		    p.getOutputStream().close();
		    
		    p.waitFor();
		    //System.err.println("      done");
		}
		catch (Exception e){
		    // ignore
		}
	    }
	}.start();
    }

    // -------------------
    
    String sCond = "";

    String sBookmark = "/production/raw_details.jsp";
    
    String sTypeFilter = rw.gets("filter_jobtype");
    String sDirFilter = rw.gets("filter_outputdir");
    String sROOTFilter = rw.gets("filter_root");
    String sALIROOTFilter = rw.gets("filter_aliroot");
    boolean bRelaxed = rw.getb("relaxed", true);
    boolean bFilterLPM = rw.getb("filter_lpm", true);
    String sRunFilter = rw.gets("filter_runno");
    String sPartitionFilter = rw.gets("filter_partition");
    
    if (sTypeFilter.length()>0){
	String sWildcard = bRelaxed ? "%" : "";
    
	sCond = "jobtype ilike '"+sWildcard+Format.escSQL(sTypeFilter)+sWildcard+"'";
	
	sBookmark = addToURL(sBookmark, "filter_jobtype", sTypeFilter);
    }
    
    if (sDirFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	String sWildcard = bRelaxed ? "%" : "";
    
	sCond += "outputdir ilike '"+sWildcard+Format.escSQL(sDirFilter)+sWildcard+"'";
	
	sBookmark = addToURL(sBookmark, "filter_outputdir", sDirFilter);
    }
    
    if (sRunFilter.length()>0){
	StringTokenizer st = new StringTokenizer(sRunFilter, ",");
	
	String sRunCond = "";
	
	while (st.hasMoreTokens()){
	    String sTok = st.nextToken().trim();
	    
	    String sEl = "";
	    
	    if (sTok.indexOf("-")<0){
		try{
		    int i = Integer.parseInt(sTok);
		    
		    sEl = "run="+i;
		}
		catch (Exception e){
		}
	    }
	    else{
		try{
		    int i1 = Integer.parseInt(sTok.substring(0, sTok.indexOf("-")));
		    int i2 = Integer.parseInt(sTok.substring(sTok.indexOf("-")+1));
		    
		    sEl = "(run>="+i1+" AND run<="+i2+")";
		}
		catch (Exception e){
		}
	    }
	    
	    if (sEl.length()>0){
		if (sRunCond.length()>0)
		    sRunCond += " OR ";
		    
		sRunCond += sEl;
	    }
	}
	
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

    if (!bFilterLPM)
	sBookmark = addToURL(sBookmark, "filter_lpm", "0");
	
    if (!bRelaxed)
	sBookmark = addToURL(sBookmark, "relaxed", "0");

    if (!bAuthenticated){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "(hide is null or not hide)";
    }

    if (sCond.length()>0)
	sCond = " WHERE "+sCond;
	
    String sOrderBy = "run is null, run";
    String sOrder = "DESC";
    
    // -------------------
    
    final String sQuery = "SELECT * FROM raw_details_"+(bFilterLPM ? "lpm" : "all")+sCond+" ORDER BY "+sOrderBy+" "+sOrder+";";
    
    db.query(sQuery);
    
    long count = 0;
    long chunks = 0;
    long processed = 0;
    long events = 0;
    
    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
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

	pLine.modify("returnurl", sBookmark);
	
	if (errors>0){
	    pError.fillFromDB(db);
	    pError.modify("returnurl", sBookmark);
	
	    pLine.modify("errorv", pError);
	}

	if (bAuthenticated){
	    final boolean bHide = lazyj.Utils.stringToBool(db.gets("hide"), false);
	    
	    if (bHide){
		pLine.modify("prev_hide", "<input type=hidden name=ph value='"+db.geti("run")+"'>");
	    }
	}	
	
	pLine.modify("events_nice", db.geti("events"));
	
	p.append("content", pLine);
    }
    
    // -------------------
    
    db.query("select distinct app_root from job_stats inner join job_runs_details on job_stats.pid=job_runs_details.pid and owner='alidaq' and length(app_root)>0;");
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_root", "<option value='"+s+"'"+(s.equals(sROOTFilter) ? " selected" : "")+">"+s+"</option>");
    }

    db.query("select distinct app_aliroot from job_stats inner join job_runs_details on job_stats.pid=job_runs_details.pid and owner='alidaq' and length(app_aliroot)>0;");
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_aliroot", "<option value='"+s+"'"+(s.equals(sALIROOTFilter) ? " selected" : "")+">"+s+"</option>");
    }
    
    db.query("SELECT distinct partition FROM raw_details_lpm;");
    while (db.moveNext()){
	String s = db.gets(1);
	
	p.append("opt_partition", "<option value='"+s+"'"+(s.equals(sPartitionFilter) ? " selected" : "")+">"+s+"</option>");
    }
    
    // At the end, set the values received by parameters
    
    p.modify("relaxed", bRelaxed ? 1 : 0);
    p.modify("option_lpm_"+bFilterLPM, "selected");
    p.modify("filter_jobtype", sTypeFilter);
    p.modify("filter_outputdir", sDirFilter);
    p.modify("filter_runno", sRunFilter);
    
    // And produce last row of statistics
    
    p.modify("total_count", count);
    p.modify("total_chunks", chunks);
    p.modify("total_processed", processed);
    p.modify("total_events", events);
    
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
                    
    lia.web.servlets.web.Utils.logRequest("/production/raw_details.jsp", baos.size(), request);
%>