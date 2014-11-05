<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,java.util.concurrent.atomic.*,utils.IntervalQuery"%><%!
    private static final String[] NUMERIC_FIELDS = new String[]{"raw_run", "total_events", "event_count_physics"};

    private static final String[] SUM_FIELDS = new String[]{
	"total_events", "event_count_physics", "pass1_events", "qa_events"
    };
	
    private static final String[] STRING_FIELDS = new String[]{""};
    
%><%
    lia.web.servlets.web.Utils.logRequest("START /configuration/pot.jsp", 0, request);
    
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Production Overview Table");

    final Page p = new Page("configuration/pot.res", false);
    final Page pLine = new Page("configuration/pot_line.res", false);
    
    final DB db = new DB();
    
    // ------------------------ parameters
    
    String q = "SELECT c.*, r.mintime FROM configuration_view2 c INNER JOIN rawdata_runs r USING (run) ";
    
    String sPartition = rw.gets("partition");
    
    db.query("select distinct partition from raw_details_lpm where partition not like '%\\\\_%' order by 1 desc;");
    
    while (db.moveNext()){
	String s = db.gets(1);
    
	if (sPartition.length()==0)
	    sPartition = s;
	
	p.append("opt_partitions", "<option value='"+Format.escHtml(s)+"' "+(s.equals(sPartition) ? "selected" : "")+">"+Format.escHtml(s)+"</option>");
    }

    int iPass = rw.geti("pass", 1);
    
    p.modify("pass", iPass);
    
    p.modify("pass_"+iPass, "selected");
    
    String sWhere;

    if (sPartition.indexOf('%')>=0)
	sWhere = " WHERE c.partition LIKE '"+Format.escSQL(sPartition)+"'";
    else
	sWhere = " WHERE c.partition='"+Format.escSQL(sPartition)+"'";
    
    sWhere += " AND sum_trigger>0 AND pass="+iPass;
    
    String sBookmark = "/configuration/pot.jsp?partition="+Format.encode(sPartition);
    
    int iRunsCount = 0;
    
    if (iPass!=1){
	sBookmark = IntervalQuery.addToURL(sBookmark, "pass", ""+iPass);
    }
    
    for (final String sNumericField: NUMERIC_FIELDS){
	final String s = rw.gets(sNumericField).trim();

	if (s.length()>0){
	    sBookmark = IntervalQuery.addToURL(sBookmark, sNumericField, s);
	    
	    p.modify(sNumericField, s);
	    
	    final String sClause = IntervalQuery.numberInterval(s, sNumericField);
	    
	    if (sClause.length()>0){
		boolean bNegate = s.matches(".*(^|,)\\s*!\\s*(,|$).*");
		
		if (bNegate){
		    if (sNumericField.startsWith("det_")){
		        String sDet = Format.escSQL(sNumericField.substring(4).trim().toUpperCase());
		        sWhere = IntervalQuery.cond(sWhere, "("+sClause+") OR (detectors_list NOT LIKE '%"+sDet+"%')");
		    }
		    else{
			sWhere = IntervalQuery.cond(sWhere, "("+sClause+") OR ("+sNumericField+" IS NULL)");
		    }
		}
                else{
		    sWhere = IntervalQuery.cond(sWhere, sClause);
		}
	    }
	    else{
		// some letter = make sure it either exists or doesn't exist
		
		boolean bExists = !s.equals("!");
		
		if (sNumericField.startsWith("det_")){
		    String sDet = Format.escSQL(sNumericField.substring(4).trim().toUpperCase());
		    sWhere = IntervalQuery.cond(sWhere, "detectors_list "+(bExists ? "" : "NOT")+" LIKE '%"+sDet+"%'");
		}
		else{
		    sWhere = IntervalQuery.cond(sWhere, sNumericField+" IS "+(bExists ? "NOT" : "")+" NULL");
		}
	    }
	}
    }
    
    for (final String sStringField: STRING_FIELDS){
	final String s = rw.gets(sStringField);
	
	if (s.length()>0){
	    StringTokenizer st = new StringTokenizer(s, ",");
	    
	    String sSearchFor = "";
	    String sSkip = "";
	    
	    while (st.hasMoreTokens()){
		String sValue = st.nextToken().trim();
		
		if (sValue.equals("*")){
		    sSearchFor = "length(trim("+sStringField+"))>0";
		}
		
		if (sValue.length()>0){
		    boolean bNegated = false;
		
		    if (sValue.startsWith("!")){
			sValue = sValue.substring(1);
			bNegated = true;
		    }
		
		    if (sValue.length()==0){
			if (bNegated){
			    sSkip = "length(trim("+sStringField+"))=0";
			    sSearchFor = "";
			    break;
			}
		    }
		    else{
			if (bNegated){
			    if (sSkip.length()>0)
				sSkip += " AND ";
			    
			    sSkip += sStringField+" NOT ILIKE '%"+Format.escSQL(sValue)+"%'";
			}
		        else{
		    	    if (sSearchFor.length()>0)
		    		sSearchFor += " OR ";
		    	
		    	    sSearchFor += sStringField+" ILIKE '%"+Format.escSQL(sValue)+"%'";
			}
		    }
		}
	    }
	    
	    if (sSearchFor.length()>0){
		sWhere = IntervalQuery.cond(sWhere, sSearchFor);
	    }
	    
	    if (sSkip.length()>0){
		if (sSearchFor.length()==0)
		    sSkip = sStringField+" IS NULL OR ("+sSkip+")";
		    
		sWhere = IntervalQuery.cond(sWhere, sSkip);
	    }
	    
	    p.modify(sStringField, s);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sStringField, s);
	}
    }
    
    q += sWhere+" ORDER BY raw_run DESC";
   
    //System.err.println(q);
    
    db.query(q);
    
    long lEvents = 0;
    long lRecoEvents = 0;
    long lChunks = 0;
    long lRecoChunks = 0;
    
    final HashMap<String, TreeMap<Integer, AtomicInteger>> totals = new HashMap<String, TreeMap<Integer, AtomicInteger>>();
    
    final StringBuilder runlist = new StringBuilder();
    
    final HashMap<String, AtomicLong> hmSums = new HashMap<String, AtomicLong>(SUM_FIELDS.length);
    
    String sDump = request.getParameter("dump");
    
    if (sDump!=null && sDump.length()==0){
	response.setContentType("text/plain");
	
	out.println("Possible columns to ask dump for:");
	out.println("    * (meaning all listed below)");
	
	for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
	    String s = db.getMetaData().getColumnName(i);
	    if (s.equals("run"))
		continue;
	    
	    if (s.equals("raw_run"))
		s = "run";
		
	    out.println("    "+s);
	}
	
	return;
    }
    
    if (sDump!=null && sDump.length()>0){
	if (sDump.equals("*")){
	    sDump = "";
	    
	    for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
	        String s = db.getMetaData().getColumnName(i);
		if (s.equals("run"))
		    continue;
	    
		if (s.equals("raw_run"))
		    s = "run";

		if (sDump.length()>0)
		    sDump += ",";
		
		sDump += s;		
	    }
	}
    
	response.setContentType("text/csv");
	out.println("#"+sDump);
	
	String[] vsFields = sDump.split("[,; ]+");
	
	while (db.moveNext()){
	    boolean bFirst = true;
	
	    for (String sField: vsFields){
		if (sField.equals("run"))
		    sField = "raw_run";
		    
		String s = db.gets(sField);
		
		if (!s.matches("^[a-zA-Z0-9._-]*$")){
		    s = Format.replace(s,"\\", "\\\\");
		    s = Format.replace(s,"\"", "\\\"");
		    s = '"' + s + '"';
		}

		if (!bFirst)
		    out.print(",");
		else
		    bFirst = false;
		
		out.print(s);
	    }
	    
	    out.println();
	}
	
	return;
    }
    
    DB db2 = new DB();
    DB db3 = new DB();

    for (String sField: SUM_FIELDS)
	hmSums.put(sField, new AtomicLong());
    
    while (db.moveNext()){
	iRunsCount++;
    
	final int iRun = db.geti("raw_run");
	
	if (iRunsCount>1){
	    runlist.append(", ");
	}
	
	runlist.append(iRun);
	
	pLine.modify("tr_bgcolor", iRunsCount % 2 == 0 ? "#FFFFFF" : "#F0F0F0");
	
	lEvents += db.getl("events");
	
	lRecoEvents += db.getl(iPass==1 ? "pass1_events" : "pass3_events");
	
	lChunks += db.getl("chunks");
	lRecoChunks += db.getl("processed_chunks");
	
	for (String sField: SUM_FIELDS){
	    final int i = db.geti(sField);
	    
	    if (i>0){
		final AtomicLong al = hmSums.get(sField);
		
		al.addAndGet(i);
	    }
	}
	
	int cpass0pid = -1;
	int cpass0_mergingpid = -1;
	int pass1pid = -1;                                                                                                                                                  
	
	db2.query("select run,pass,events_count,masterjob_id,status,(select pid from lpm_history where parentpid=masterjob_id and (jdl~'.*/QA\\\\_.*' or jdl like '%/rec%') order by jdl~'.*/QA\\\\_.*' desc limit 1) as child_pid,"+
	          "(select sum(cnt) from job_stats_details where pid=masterjob_id and state like 'DONE%') as done_jobs,cnt as total_jobs from rawdata_processing_requests inner join job_stats_details on pid=masterjob_id and state='TOTAL' "+
	          "where run="+iRun+" and pass in ("+(iPass==1 ? "0,1" : "2,3")+");");
	
	while (db2.moveNext()){
	    int total = db2.geti("total_jobs");
	    int done = db2.geti("done_jobs");
	    
	    String field = "cpass0";
	    String color = "#FFFF99";

	    int child_pid = db2.geti("child_pid");

	    switch (db2.geti("status")){
	        case 1: color="#9999FF"; break;
	        case 2: color="#99FF99"; break;
	    }
	    
	    if (db2.geti("pass", -1)%2 == 0){
		if (child_pid>0){
		    pLine.modify("cpass0_merging_pid", child_pid);
		
	    	    db3.query("select lpm_history.status,sum(cnt) from job_stats_details inner join lpm_history using(pid) where pid="+child_pid+" and job_stats_details.state like 'DONE%' group by 1;");
		
		    if (db3.geti(1)==2){
			if (db3.geti(2)==1){
			    pLine.modify("cpass0_merging_success", "OK");
			    pLine.modify("cpass0_merging_color", "#99FF99");
			}
			else{
			    pLine.modify("cpass0_merging_success", "ERR");
			    pLine.modify("cpass0_merging_color", "#FF9999");
			}
		    }
		    else{
			pLine.modify("cpass0_merging_success", "ACTIVE");
			pLine.modify("cpass0_merging_color", "#9999FF");
		    }
		}
	    }
	    else{
		field = "pass1";
			
		int pass1_events = db2.geti("events_count", -1);
			
		if (pass1_events>=0){
		    pLine.modify("pass1_events", pass1_events);
		
		    if (db.geti("event_count_physics")>0){
			pLine.modify("pass1_fraction", Format.point(100d*pass1_events/db.geti("event_count_physics"))+"%");
		    }
		    
		    hmSums.get("pass1_events").addAndGet(pass1_events);
		}
				
		if (child_pid>0){
		    int stage = 1;
		    
		    do{
			db3.query("SELECT pid,parameters FROM lpm_history WHERE parentpid="+child_pid+" AND jdl~'.*/QA\\\\_.*';");
		    
			if (db3.moveNext()){
			    child_pid = db3.geti(1);
			    
			    StringTokenizer st = new StringTokenizer(db3.gets(2));
			    st.nextToken();			    
	                    stage = Integer.parseInt(st.nextToken());
			}
			else
			    break;
		    }
		    while (true);
		    
		    if (stage==1){
			db3.query("SELECT parameters FROM lpm_history WHERE pid="+child_pid);
		    
			StringTokenizer st = new StringTokenizer(db3.gets(1));
			st.nextToken();			    
	                stage = Integer.parseInt(st.nextToken());
		    }
		    
		    pLine.modify("qa_stage", stage);
		    pLine.modify("qa_pid", child_pid);
		    
		    db3.query("select lpm_history.status,job_runs_details.app_aliroot,sum(cnt) from job_stats_details inner join lpm_history using(pid) inner join job_runs_details using(pid) where pid="+child_pid+" and job_stats_details.state like 'DONE%' group by 1,2;");
		    
        	    pLine.modify("app_aliroot", db3.gets(2));
	    
		    if (db3.geti(1)==2){
			if (db3.geti(3)==1){
			    pLine.modify("qa_color", "#99FF99");
			}
			else{
			    pLine.modify("qa_color", "#FF9999");
			}
		    }
		    else{
			pLine.modify("qa_color", "#9999FF");
		    }
		    
		    db3.query("select train_passed from job_events where pid="+child_pid);
		    
		    if (db3.moveNext()){
			int qa_events = db3.geti(1);
			
			hmSums.get("qa_events").addAndGet(pass1_events);
			
			pLine.modify("qa_events", qa_events);
			
			if (pass1_events>0){
			    pLine.modify("qa_fraction", Format.point(100d*qa_events / pass1_events)+"%");
			}
		    }
		}
	    }
	    
	    pLine.modify(field+"_pid", db2.geti("masterjob_id"));
	    pLine.modify(field+"_success", total>0 ? Format.point(100d*done / total)+"%" : "");
	    pLine.modify(field+"_success_color", color);
	}
    
	pLine.fillFromDB(db);
	
	final String sDetectors = db.gets("detectors_list").toLowerCase();
	
	final StringTokenizer st = new StringTokenizer(sDetectors, ",");
	
	final Set<String> shuttle = new HashSet<String>(32);
	
	while (st.hasMoreTokens()){
	    shuttle.add(st.nextToken());
	}
	
	p.append(pLine);
    }
    
    for (Map.Entry<String, TreeMap<Integer, AtomicInteger>> me: totals.entrySet()){
	String sDet = me.getKey();
	TreeMap<Integer, AtomicInteger> tm = me.getValue();
	
	final StatusDictionary sd = StatusDictionary.getInstance(sDet);
	
	int iTotal = 0;
	
	String sStats = "<table border=1 cellspacing=2 cellpadding=0><tr><td>State</td><td>Explanation</td><td>Count</td></tr>";
	
	for (Map.Entry<Integer, AtomicInteger> state : tm.entrySet()){
	    StatusDictionaryEntry sde = sd.get(state.getKey());
	
	    String sColor = sde!=null ? sde.getHTMLColor() : "";
	    
	    if (sColor.length()>0)
		sColor=" bgcolor='"+sColor+"'";
		
	    String sExplanation = "";
	    
	    if (sde!=null){
		sExplanation = sde.getShortText();
		
		if (sExplanation==null || sExplanation.trim().length()==0)
		    sExplanation = sde.getLongText();
	    }
	
	    sStats += "<tr "+sColor+"><td>"+state.getKey()+"</td><td>"+Format.escHtml(sExplanation)+"</td><td>"+state.getValue()+"</td></tr>";
	    
	    iTotal += state.getValue().get();
	}
	
	sStats += "</table>";
	
	p.modify(sDet+"_stats", sStats);
	p.modify(sDet+"_count", iTotal);
    }

    p.modify("runcount", iRunsCount);    
    p.modify("runlist", runlist);
    p.modify("runlist2", Format.replace(runlist.toString(), " ", ""));
    p.modify("raw_run_count", iRunsCount);
    p.modify("events_count", lEvents);
    p.modify("reco_events_count", lRecoEvents);
    p.modify("chunks_count", lChunks);
    p.modify("processed_chunks_count", lRecoChunks);
    p.modify("processed_percentage_total", lChunks>0 ? ( lRecoChunks * 100d/ lChunks ) : "");

    for (Map.Entry<String, AtomicLong> me: hmSums.entrySet()){
	p.modify("sum_"+me.getKey(), me.getValue());
    }
    
    AtomicLong pass1 = hmSums.get("pass1_events");
    
    if (pass1.longValue()>0){
	p.modify("qa_events_fraction", Format.point(hmSums.get("qa_events").longValue()*100d / pass1.longValue())+"%");
    }
    
    AtomicLong ph_events = hmSums.get("event_count_physics");
    
    if (ph_events.longValue()>0){
	p.modify("pass1_events_fraction", Format.point(pass1.longValue()*100d / ph_events.longValue())+"%");
    }

    // ------------------------ final bits and pieces

    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    out.flush();

    lia.web.servlets.web.Utils.logRequest("/configuration/pot.jsp", baos.size(), request);
%>