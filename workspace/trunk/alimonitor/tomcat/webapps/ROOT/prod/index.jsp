<%@ page import="alimonitor.*,java.util.regex.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lazyj.*,utils.IntervalQuery,java.util.concurrent.atomic.*"%><%!

private static final Pattern pProduction = Pattern.compile("^(FILTER(pass\\d)?|QA)\\D*(\\d{1,3})\\D+.*$");

private static final int geti(final Map<String, Object> values, final String columnName){
    Object o = values.get(columnName);
    
    if (o==null)
	return 0;

    if (o instanceof Number)
	return ((Number)o).intValue();

    try{
	return Integer.parseInt(o.toString());
    }
    catch (Exception e){
    }
    
    return 0;
}

private static final long getl(final Map<String, Object> values, final String columnName){
    Object o = values.get(columnName);
    
    if (o==null)
	return 0;

    if (o instanceof Number)
	return ((Number)o).longValue();

    try{
	return Long.parseLong(o.toString());
    }
    catch (Exception e){
    }
    
    return 0;
}

private static final String gets(final Map<String, Object> values, final String columnName){
    Object o = values.get(columnName);
    
    if (o==null)
	return "";
    
    if (o instanceof String)
	return (String) o;
	
    return o.toString();
}

private static final void fillLine(final Map<String, Object> entry, final Page p, final Page pLine, final int iCnt, final HashMap<String, AtomicLong> hmTotals, final int indent){
	final Map<String, Object> values = (Map<String, Object>) entry.get("values");
	
	String sType = gets(values, "jt_field2");

	final int iRealRunning = geti(values, "running_jobs") + geti(values, "waiting_jobs");

	final int jt_id = geti(values, "jt_id");
	
	if(("Running".equals(sType) && iRealRunning==0) || ("Completed".equals(sType) && iRealRunning>0)){
	    //System.err.println("Double checking job type : "+db.geti("jt_id"));
	    
	    DB db2 = new DB("select state,count(1) from job_runs_details inner join job_stats using(pid) where job_types_id="+jt_id+" group by state;");
	    
	    int iState2 = 0;
	    int iStateNot2 = 0;
	    
	    while (db2.moveNext()){
		if (db2.geti(1)==2)
		    iState2 = db2.geti(2);
		else
		    iStateNot2 += db2.geti(2);
	    }                                                                                           
	    
	    if (iStateNot2==0 && iState2>0){
		// all jobs in a final state
		db2.syncUpdateQuery("UPDATE job_types SET jt_field2='Completed' WHERE jt_id="+jt_id+" AND jt_field2='Running';");
		sType = "Completed";
	    }
	    else
	    if (iStateNot2>0){
		// we have some running jobs
		db2.syncUpdateQuery("UPDATE job_types SET jt_field2='Running' WHERE jt_id="+jt_id+" AND jt_field2='Completed';");
		sType = "Running";
	    }
	}
	
	pLine.modify("jt_field2_new", sType);
	
	if ("Running".equals(sType)){
	    pLine.modify("bgcolor", "#54E715");
	    pLine.modify("status_code", 1);
	}
	else
	if("Pending".equals(sType) || sType.startsWith("Quality") || sType.startsWith("Macros") || sType.startsWith("Software") || sType.startsWith("Technical") ){
	    pLine.modify("bgcolor", "yellow");
	    pLine.modify("status_code", 2);
	}
	else
	if("Completed".equals(sType)){
	    pLine.modify("bgcolor", "#A1EBFF");
	    pLine.modify("status_code", 3);
	}
	else
	if ("Scheduled".equals(sType)){
	    pLine.modify("bgcolor", "pink");
	    pLine.modify("status_code", 0);
	}
	    
        pLine.modify("bgcolor", "#FFFFFF");
	    
	pLine.modify("tr_bgcolor", iCnt % 2 == 0 ? "#FFFFFF" : "#F0F0F0");    
    
	final String sBaseDir = "/home/monalisa/MLrepository/tomcat/webapps/ROOT/productions/train/train_"+gets(values,"jt_field1");
	
	final File f = new File(sBaseDir);
	
	if (f.exists() && f.isDirectory()){
	    pLine.comment("com_files", true);
	    pLine.comment("com_catalogue", false);
	}
	else{
	    pLine.comment("com_files", false);
	    
	    final String sProd = gets(values,"jt_field1");
	    
	    // maybe it is a standard production where we know where the files are?
	    final Matcher m = pProduction.matcher(sProd);
	    if (m.matches()){
		final String trainNo = m.group(3);
		
		String sPath = "/alice/cern.ch/user/a/alidaq/";
		
		if (sProd.startsWith("FILTER"))
		    sPath += "AOD/AOD"+trainNo;
		else
		if (sProd.startsWith("QA"))
		    sPath += "QA/QA"+trainNo;
		
		pLine.modify("catalogue_path", sPath);
		
		pLine.comment("com_catalogue", true);
	    }
	    else
		pLine.comment("com_catalogue", false);
	}
	
	final File fDownload = new File(sBaseDir+"_download");
	
	if (fDownload.exists() && fDownload.isDirectory()){
	    pLine.comment("com_download", true);
	}
	else{
	    pLine.comment("com_download", false);
	}

	pLine.modify(values);
	
	final int iDone = geti(values, "done_jobs");
	final int iTotal = geti(values, "total_jobs");

	hmTotals.get("total").addAndGet(iTotal);
	hmTotals.get("done").addAndGet(iDone);
	
	hmTotals.get("running").addAndGet(geti(values, "running_jobs"));
	hmTotals.get("waiting").addAndGet(geti(values, "waiting_jobs"));
	
	hmTotals.get("ttrain_output").addAndGet(geti(values, "train_output"));
	hmTotals.get("ttrain_passed").addAndGet(geti(values, "train_passed"));
	
	hmTotals.get("outputsize").addAndGet(getl(values, "outputsize"));
	
	final int iPercentage = iDone*100 / (iTotal>0? iTotal : 1);
	
	if (iTotal > 0){
	    pLine.modify("success_rate", iPercentage+"%");
	}
	
	if (! "Running".equals(sType)){
	
	if (iPercentage>=95)
	    pLine.modify("rate_bgcolor", "#54E715");
	else
	if (iPercentage>=90)
	    pLine.modify("rate_bgcolor", "yellow");
	else
	if (iPercentage>=80)
	    pLine.modify("rate_bgcolor", "orange");
	else
	    pLine.modify("rate_bgcolor", "red");
	    
	}
	else{
	    pLine.modify("rate_bgcolor", "pink");
	    //pLine.modify("extra_rate", "onMouseOver=\"overlib('If you don\\'t like the color talk to Mihaela');\" onMouseOut=\"nd()\"");
	}

	pLine.comment("com_run", geti(values, "maxrun")>0);

	if (gets(values,"comment").length()==0)
	    p.comment("com_comment", false);	

	if (indent>0){
	    pLine.modify("indent", "<span style='padding-left:"+((indent-1)*12)+"px'><img border=0 src='/img/joinbottom.gif' align=absmiddle></span> ");
	}
	
	if (indent==0)
	    pLine.modify("jt_type_x", gets(values, "jt_type"));

	final DB db2 = new DB();

	db2.query("SELECT count(1) FROM job_types_links WHERE jt_id="+geti(values, "jt_id"));
	
	pLine.comment("com_links", db2.geti(1)>0);
	
	p.append(pLine);
	
	final List<Map<String, Object>> children = (List<Map<String,Object>>) entry.get("children");
	
	for (final Map<String, Object> subentry: children){
	    while (db2.moveNext()){
		fillLine(subentry, p, pLine, iCnt, hmTotals, indent+1);
	    }
	}
}

private static final Comparator<Map<String,Object>> comparatorJtID = new Comparator<Map<String,Object>>(){
    public int compare(final Map<String, Object> m1, final Map<String, Object> m2){
	final Map<String, Object> v1 = (Map<String, Object>) m1.get("values");
	final Map<String, Object> v2 = (Map<String, Object>) m2.get("values");
		
	return geti(v2, "jt_id") - geti(v1, "jt_id");
    }
};

%><%
    lia.web.servlets.web.Utils.logRequest("START /prod/index.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    final RequestWrapper rw = new RequestWrapper(request);
    
    int iType = rw.geti("t");
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    String sProductions = "Analysis trains";
    String jtField = "TRAIN";
    
    if (iType == 1){
	sProductions = "Raw data productions";
	jtField = "RAW";
    }
    else
    if (iType == 2){
	sProductions = "MonteCarlo";
	jtField = "MC";
    }
    else
    if (iType == 3){
	sProductions = "Other RAW data production tasks";
	jtField = "RAW_OTHER";
    }

    String sDefaultTypeFilter = rw.getCookie("prod_type");
    
    if (sDefaultTypeFilter.length()==0 && iType!=3)
	sDefaultTypeFilter = "QA";
    
    String sTypeFilter = rw.gets("prod_type", iType==0 ? sDefaultTypeFilter  : "");
    
    pMaster.modify("title", "Productions - "+sProductions);
    
    final Page p = new Page("prod/index.res", false);

    p.comment("com_analysis", iType==0);
    
    final Page pLine = new Page("prod/index_el.res", false);
    
    final DB db = new DB();

    String sStatus = request.getParameter("status") == null ? "" : request.getParameter("status");

    db.query("select distinct jt_field2 from job_types order by 1;");
    
    final String sJtField2 = rw.gets("jt_field2");
    
    while (db.moveNext()){
	final String sType = db.gets(1);
	
	p.append("opt_jt_field2", "<option value='"+sType+"'"+(sType.equals(sJtField2) ? " selected" : "")+">"+sType+"</option>");
    }
    
    String sQuery = "SELECT * FROM job_types_view_prod ";
    
    String sWhere = "WHERE jt_field4='"+jtField+"'";		    

    if (!sTypeFilter.equals("ALL"))
	sWhere += " AND (jt_field1 LIKE '"+Format.escSQL(sTypeFilter)+"%'";
	
    if (sTypeFilter.equals("FILTER")){
	sWhere += " OR jt_field1 LIKE 'AODmerge_%'";
    }
    
    sWhere += ")";
	
    p.modify("prod_type_"+sTypeFilter, "selected");
    
    String sBookmark = "/prod/";
    
    if (iType>0){
	sBookmark = IntervalQuery.addToURL(sBookmark, "t", ""+iType);
	p.modify("t", ""+iType);
    }
    else{
	// analysis trains
	sBookmark = IntervalQuery.addToURL(sBookmark, "prod_type", sTypeFilter);
	
	Cookie c = new Cookie("prod_type", sTypeFilter);
	
	c.setMaxAge(60*60*24*30);
	c.setPath("/");
	c.setSecure(false);
	response.addCookie(c);
    }
    
    for (String sField : Arrays.asList("jt_id", "completion", "total_jobs", "done_jobs", "running_jobs", "waiting_jobs", "nr_runs", "train_output", "train_passed")){
	String sValue = rw.gets(sField);
    
	String sCond = IntervalQuery.numberInterval(sValue, sField);
	
	if (sCond.length() > 0){
	    sWhere = IntervalQuery.cond(sWhere, sCond);
	    
	    p.modify(sField, sValue);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sField, sValue);
	}
    }
    
    for (String sField : Arrays.asList("jt_field1", "jt_type", "comment")){
	String sValue = rw.gets(sField);
	
	if (sValue.length()>0){
	    String sCond = sField+" ilike '%"+sValue+"%'";
	    
	    p.modify(sField, sValue);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sField, sValue);
	    
	    sWhere = IntervalQuery.cond(sWhere, sCond);
	}
    }
    
    sQuery += sWhere+" ORDER BY jt_field1 desc;"; // jt_field1 DESC, jt_id DESC
    
    long lStart = System.currentTimeMillis();
    
    db.query(sQuery);

    System.err.println((System.currentTimeMillis( )- lStart) + " : "+sQuery);
    
    int iCnt = 0;    
    
    final HashMap<String, AtomicLong> hmTotals = new HashMap<String, AtomicLong>();
    
    hmTotals.put("total", new AtomicLong());
    hmTotals.put("done", new AtomicLong());
    hmTotals.put("running", new AtomicLong());
    hmTotals.put("waiting", new AtomicLong());
    hmTotals.put("ttrain_output", new AtomicLong());
    hmTotals.put("ttrain_passed", new AtomicLong());
    hmTotals.put("outputsize", new AtomicLong());
    
    final List<Map<String, Object>> list = new ArrayList<Map<String, Object>>(1);
    
    while(db.moveNext()){
	final Map<String, Object> entry = new HashMap<String, Object>(2);
	
	entry.put("values", db.getValuesMap());
	entry.put("children", new LinkedList());
	
	list.add(entry);
    }

    for (int i=0; i<list.size()-1; i++){
	final Map<String, Object> entry = list.get(i);
    
	final Map<String, Object> values = (Map<String, Object>) entry.get("values");
	
	final String key = gets(values, "jt_field1");

	int idx = key.indexOf("_Stage");
	
	if (idx>0){
	    // the parent is the next entry, if any
	    
	    try{
		final int stage = Integer.parseInt(key.substring(idx+6, idx+7));
	    
	        final Map<String, Object> next = list.get(i+1);
	    
		final Map<String, Object> nextValues = (Map<String, Object>) next.get("values");
	    
	        final String nextKey = gets(nextValues, "jt_field1");
	    
		if (nextKey.equals(key.substring(0, idx)) || nextKey.startsWith(key.substring(0, idx+6))){
		    final List<Map<String, Object>> children = (List<Map<String, Object>>) next.get("children");
		
	    	    children.add(entry);
		    list.remove(i);
		    i--;
		}
	    }
	    catch (Exception e){
		// just move forward
	    }
	}	
	else
	if (key.endsWith("_Merging")){
	    final Map<String, Object> next = list.get(i+1);
	    
	    final Map<String, Object> nextValues = (Map<String, Object>) next.get("values");
	    
	    final String nextKey = gets(nextValues, "jt_field1");
	    
	    if (key.equals(nextKey+"_Merging")){
		final List<Map<String, Object>> children = (List<Map<String, Object>>) next.get("children");
		
	    	children.add(entry);
		list.remove(i);
		i--;
	    }
	    else{
		System.err.println("Didn't match : "+key+" / "+nextKey);
	    }
	}
    }
    
    // should sort again by jt_id
    Collections.sort(list, comparatorJtID);
    
    for (final Map<String, Object> entry: list){
	fillLine(entry, p, pLine, iCnt, hmTotals, 0);
	iCnt ++;
    }
    
    final long iTTotal = hmTotals.get("total").longValue();
    final long iTDone = hmTotals.get("done").longValue();
    final long iTRunning = hmTotals.get("running").longValue();
    final long iTWaiting = hmTotals.get("waiting").longValue();
    final long iOutputSize = hmTotals.get("outputsize").longValue();
    
    p.modify("cnt", iCnt);
    p.modify("ttotal_jobs", iTTotal);
    p.modify("tdone_jobs", iTDone);
    p.modify("trunning_jobs", iTRunning);
    p.modify("twaiting_jobs", iTWaiting);
    p.modify("ttrain_output", Long.valueOf(hmTotals.get("ttrain_output").longValue()));
    p.modify("ttrain_passed", Long.valueOf(hmTotals.get("ttrain_passed").longValue()));
    p.modify("outputsize", iOutputSize);

    long iPercentage = iTDone * 100 / (iTTotal > 0 ? iTTotal : 1);
    
    if (iPercentage>=95)
        p.modify("rate_bgcolor", "#54E715");
    else
    if (iPercentage>=90)
        p.modify("rate_bgcolor", "yellow");
    else
    if (iPercentage>=80)
        p.modify("rate_bgcolor", "orange");
    else 
        p.modify("rate_bgcolor", "red");
    
    p.modify("tcompletion", iPercentage+"%");
    
    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/prod/index.jsp", baos.size(), request);
%>