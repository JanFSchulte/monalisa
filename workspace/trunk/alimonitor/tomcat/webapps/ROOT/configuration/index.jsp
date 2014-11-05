<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,java.util.concurrent.atomic.*,utils.IntervalQuery"%><%!
    private static final String[] DETECTORS = new String[] {"aco", "emc", "fmd", "hlt", "hmp", "mch", "mtr", "phs",
	"pmd", "spd", "sdd", "ssd", "tof", "tpc", "trd", "t00", "v00", "zdc", "hlt_mode"};

    private static final String[] DETECTORS_MAG = new String[] {"field", "aco", "emc", "fmd", "hlt", "hmp", "mch", "mtr", "phs",
	"pmd", "spd", "sdd", "ssd", "tof", "tpc", "trd", "t00", "v00", "zdc", "hlt_mode"};

    private static final String[] DICTIONARY_FIELDS = new String[] {
	"filling_scheme", "quality", "muon_quality",
	"field", "aco", "emc", "fmd", "hlt", "hmp", "mch", "mtr", "phs",
	"pmd", "spd", "sdd", "ssd", "tof", "tpc", "trd", "t00", "v00", "zdc",
	"hlt_mode"
    };
	
    private static final String[] NUMERIC_FIELDS = new String[]{"det_aco", "det_emc", "det_fmd", "det_hlt", "det_hmp", "det_mch", "det_mtr", "det_phs",
	"det_pmd", "det_spd", "det_sdd", "det_ssd", "det_tof", "det_tpc", "det_trd", "det_t00", "det_v00", "det_zdc", "field", "filling_scheme", "quality", "muon_quality",
	"fillno", "energy", "intensity_per_bunch",
	"cbeamb_abce_nopf_all", "cint1b_abce_nopf_all", "rate", "cint1_e_nopf_all", "cint1a_abce_nopf_all", "cint1c_abce_nopf_all", 
	"mean_vertex_xyz", "vertex_quality", "raw_run",
	"interaction_trigger", "beam_empty_trigger", "empty_empty_trigger", "muon_trigger", "high_multiplicity_trigger", "calibration_trigger", "emcal_trigger",
	"mu",
	"hlt_mode",
	"interacting_bunches", "noninteracting_bunches_beam_1", "noninteracting_bunches_beam_2"
	};

    private static final String[] SUM_FIELDS = new String[]{
	"interaction_trigger", "beam_empty_trigger", "empty_empty_trigger", "muon_trigger", "high_multiplicity_trigger", "calibration_trigger", "emcal_trigger", "runduration"
    };
	
    private static final String[] STRING_FIELDS = new String[]{"comment", "filling_config"};
    
%><%
    lia.web.servlets.web.Utils.logRequest("START /configuration/index.jsp", 0, request);
    
    final AlicePrincipal user = Users.get(request);
    
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Run Condition Table");

    final Page p = new Page("configuration/index.res", false);
    final Page pLine = new Page("configuration/index_line.res", false);
    
    final DB db = new DB();
    
    final boolean bAuthOk = user!=null;
    
    p.comment("com_authenticated", bAuthOk);
    
    if (bAuthOk)
	p.modify("account", user.getName());
    
    // ------------------------ parameters

    int pass = rw.geti("pass", 1);
    
    if (pass<1 || pass>4)
	pass=1;
	
    p.modify("pass_"+pass, "selected");
    p.modify("pass", pass);
    
    String q = "SELECT * FROM configuration_view2 ";
    
    String sPartition = rw.gets("partition");
    
    db.query("select distinct partition from raw_details_lpm where partition not like '%\\\\_%' order by 1 desc;");
    
    while (db.moveNext()){
	String s = db.gets(1);
    
	if (sPartition.length()==0)
	    sPartition = s;
	
	p.append("opt_partitions", "<option value='"+Format.escHtml(s)+"' "+(s.equals(sPartition) ? "selected" : "")+">"+Format.escHtml(s)+"</option>");
    }
    
    String sWhere;

    if (sPartition.indexOf('%')>=0)
	sWhere = " WHERE partition LIKE '"+Format.escSQL(sPartition)+"'";
    else
	sWhere = " WHERE partition='"+Format.escSQL(sPartition)+"'";
    
    //sWhere += " AND (coalesce(interaction_trigger,0)+coalesce(beam_empty_trigger,0)+coalesce(empty_empty_trigger,0)+coalesce(muon_trigger,0)+coalesce(high_multiplicity_trigger,0)>0) ";
    
    sWhere += " AND sum_trigger>0 AND pass="+pass;
    
    db.syncUpdateQuery("INSERT INTO configuration_perpass (run,pass) SELECT run,"+pass+" FROM configuration WHERE run NOT IN (SELECT run FROM configuration_perpass WHERE pass="+pass+");");
    
    String sBookmark = "/configuration/?partition="+Format.encode(sPartition);
    
    int iRunsCount = 0;
    
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
   
    System.err.println(q);
    
    db.query(q);
    
    long lEvents = 0;
    long lRecoEvents = 0;
    long lChunks = 0;
    long lRecoChunks = 0;
    
    final HashMap<String, TreeMap<Integer, AtomicInteger>> totals = new HashMap<String, TreeMap<Integer, AtomicInteger>>();
    
    final StringBuilder runlist = new StringBuilder();
    
    final HashMap<String, AtomicLong> hmSums = new HashMap<String, AtomicLong>(SUM_FIELDS.length);
    
    //for (String field: DICTIONARY_FIELDS){ 
//	StatusDictionary.getInstance(field).refresh();
  //  }
    
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
    
    while (db.moveNext()){
	iRunsCount++;
    
	final int iRun = db.geti("raw_run");
	
	if (iRunsCount>1){
	    runlist.append(", ");
	}
	
	runlist.append(iRun);
	
	pLine.modify("tr_bgcolor", iRunsCount % 2 == 0 ? "#FFFFFF" : "#F0F0F0");
	
	lEvents += db.getl("events");
	lRecoEvents += db.getl("pass1_events");
	lChunks += db.getl("chunks");
	lRecoChunks += db.getl("processed_chunks");
	
	for (String sField: SUM_FIELDS){
	    final int i = db.geti(sField);
	    
	    if (i>0){
		AtomicLong al = hmSums.get(sField);
		
		if (al==null){
		    al = new AtomicLong(i);
		    hmSums.put(sField, al);
		}
		else
		    al.addAndGet(i);
	    }
	}
    
	pLine.fillFromDB(db);
	
	final String sDetectors = db.gets("detectors_list").toLowerCase();
	
	final StringTokenizer st = new StringTokenizer(sDetectors, ",");
	
	final Set<String> shuttle = new HashSet<String>(32);
	
	while (st.hasMoreTokens()){
	    shuttle.add(st.nextToken());
	}
	
	for (String field: DICTIONARY_FIELDS){
	    if (shuttle.contains(field) || field.length()>3){
		int iValue = db.geti( field.length()>3 ? field : "det_"+field, -1000);
		
		if (iValue!=-1000){
		    TreeMap<Integer, AtomicInteger> tm = totals.get(field);
		    
		    if (tm==null){
			tm = new TreeMap<Integer, AtomicInteger>();
			totals.put(field, tm);
		    }
		    
		    AtomicInteger ai = tm.get(iValue);
		    
		    if (ai==null){
			ai = new AtomicInteger(1);
			tm.put(iValue, ai);
		    }
		    else{
			ai.incrementAndGet();
		    }
		}
		
		StatusDictionaryEntry sde = StatusDictionary.getInstance(field).get(iValue);
		
		String sStatus = "";
		
		if (sde!=null){
		    if (sde.getHTMLColor().length()>0)
			pLine.modify(field+"_bgcolor", "bgcolor='"+Format.escHtml(sde.getHTMLColor())+"'");

		    sStatus = sde.getLongText();
		    
		    if (sStatus==null || sStatus.trim().length()==0)
			sStatus = sde.getShortText();
		}
		
		pLine.modify(field+"_longtext", sStatus);
	    }
	}
	
	for (String det: DETECTORS_MAG){
	    String sLine = "<td nowrap align=center class='table_row'";
	    
	    if (shuttle.contains(det) || det.length()>3){
		int iValue = db.geti( det.length()>3 ? det : "det_"+det, -1000);
		
		StatusDictionaryEntry sde = StatusDictionary.getInstance(det).get(iValue);
		
		String sStatus = "";
		
		if (sde!=null){
		    if (sde.getHTMLColor().length()>0)
			sLine += "bgcolor='"+Format.escHtml(sde.getHTMLColor())+"' ";
			
		    sStatus = sde.getLongText();
		    
		    if (sStatus==null || sStatus.trim().length()==0)
			sStatus = sde.getShortText();
		}
		
		sLine += "onMouseOver=\"overlibnz('"+Format.escHtml(Format.escJS(sStatus))+"', CAPTION, '"+Format.escHtml(Format.escJS(det.toUpperCase()))+" / "+iRun+"');\" onMouseOut='nd()' onClick=\"editStatusPerPass("+iRun+", '"+det+"');\">"+(iValue!=-1000 ? ""+iValue : "");
	    }
	    else{
		sLine += "bgcolor=#EEEEEE onMouseOver=\"overlibnz('Detector off')\" onMouseOut='nd()'>x";
	    }
	    
	    sLine += "</td>";
	    
	    pLine.append(sLine);
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
    
    p.modify("runlist", runlist);
    p.modify("runlist2", Format.replace(runlist.toString(), " ", ""));
    p.modify("raw_run_count", iRunsCount);
    p.modify("events_count", lEvents);
    p.modify("reco_events_count", lRecoEvents);
    p.modify("chunks_count", lChunks);
    p.modify("processed_chunks_count", lRecoChunks);
    p.modify("processed_percentage_total", lChunks>0 ? ( lRecoChunks * 100d/ lChunks ) : "");

    AtomicLong al = hmSums.get("runduration");

    for (Map.Entry<String, AtomicLong> me: hmSums.entrySet()){
	p.modify("sum_"+me.getKey(), me.getValue());
	
	if (me.getKey().equals("interaction_trigger")){
	    if (al!=null){
		p.modify("sum_rate", me.getValue().doubleValue() / al.longValue());
	    }
	}
    }

    // ------------------------ final bits and pieces

    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    out.flush();

    lia.web.servlets.web.Utils.logRequest("/configuration/index.jsp?u="+(user!=null ? user.getName() : "guest"), baos.size(), request);
%>