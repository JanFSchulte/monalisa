<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,java.util.concurrent.atomic.*,utils.IntervalQuery,java.sql.*"%><%!

    static Page getCell(){
	return new Page("runview/index_el.res");
    }

    private static class TreeEntry extends LinkedList<TreeEntry> {

	int pid = 0;
	
	int maxjobs = -1;
	
	long maxsize = -1;
	
	long maxevents = -1;
	
	int totaljobs = 0;
	
	int donejobs = 0;
	
	int activejobs = 0;
	
	long outputsize;
	
	long events = -1;
	
	int type = 0;
	
	String comment = null;

	private Map<String, String> attributes = new HashMap<String, String>();

	TreeEntry parent = null;

	public TreeEntry(){
	    // root entry
	}
	
	public TreeEntry(final int pid){
	    this.pid = pid;
	    
	    try{
	        fetchDetails();
	    }
	    catch (SQLException e){
		System.err.println("Exception in runview/index.jsp : "+e);
	    }
	    
	    addAllSubjobs();
	}
	
	private void fetchDetails() throws SQLException {
	    DB db = new DB();
	    
	    db.query("SELECT * from job_runs_details where pid="+pid);
	    
	    if (db.moveNext()){
		for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
		    String column = db.getMetaData().getColumnLabel(i);
		    
		    attributes.put(column, db.gets(column));
	        }
	        
	        events = Math.max(events, db.getl("events", -1));
	        
	        outputsize = Math.max(outputsize, db.getl("outputsize", -1));
	        
	        int prodid = db.geti("job_types_id");
	        
	        if (prodid>0){
	    	    db.query("SELECT * FROM job_types WHERE jt_id="+prodid);
	    	    
	    	    if (db.moveNext()){
			for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
			    String column = db.getMetaData().getColumnLabel(i);
		    
			    attributes.put("job_types."+column, db.gets(column));
	    		}
	    	    }
	    	    
	    	    String sType = db.gets("jt_type");
	    	    String sComment = db.gets("jt_field3");
	    	    String sIssues = db.gets("jt_known_issues");
	    	    
	    	    if (!sComment.equals(sType)){
	    		comment = "<i>"+Format.escHtml(sComment)+"</i>";
	    	    }
	    	    
	    	    if (sIssues.length()>0){
	    		if (comment==null)
	    		    comment = "";
	    		else
	    		    comment += "<BR>";
	    		
	    		comment += "<font color=red>"+Format.escHtml(sIssues)+"</font>";
	    	    }
	        }
	    }
	    
	    db.query("SELECT * FROM job_stats WHERE pid="+pid);
	    
	    if (db.moveNext()){
		for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
		    String column = db.getMetaData().getColumnLabel(i);
		    attributes.put("job_stats."+column, db.gets(column));
	        }
	    }
	    
	    db.query("SELECT * FROM rawdata_processing_requests where masterjob_id="+pid);
	    
	    if (db.moveNext()){
		for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
		    String column = db.getMetaData().getColumnLabel(i);
		    attributes.put("rawdata_processing_requests."+column, db.gets(column));
	        }
	        
	        outputsize = db.getl("total_size");
	        events = Math.max(events, db.getl("events_count", -1));
	        
	        type = 1;
	    }
	    
	    db.query("select state,cnt from job_stats_details where pid="+pid);
	    
	    while (db.moveNext()){
		String state = db.gets(1);
		int count = db.geti(2);
		attributes.put("job_stats_details."+state, ""+count);
		
		if (state.equals("TOTAL"))
		    totaljobs = count;
		else
		if (state.startsWith("DONE"))
		    donejobs += count;
		else
		if (state.startsWith("RUN") || state.startsWith("WAIT") || state.startsWith("SAV") || state.startsWith("INSERT") || state.startsWith("START"))
		    activejobs += count;
	    }
	    
	    if (donejobs>totaljobs)
		totaljobs = donejobs;
		
	    if (totaljobs==0){
		System.err.println("No TOTAL jobs for pid = "+pid);
		totaljobs = 1;
	    }
		
	    maxjobs = totaljobs;
	    
	    db.query("SELECT * FROM lpm_history WHERE pid="+pid);
	    
	    if (db.moveNext()){
		for (int i=1; i<=db.getMetaData().getColumnCount(); i++){
		    String column = db.getMetaData().getColumnLabel(i);
		    attributes.put("lpm_history."+column, db.gets(column));
	        }
	    }
	}

	public Page getPage(){
	    // TODO

	    Page p = getCell();
	    
	    if (pid==0){
		
	    }
	    else{
		p.modify(attributes);
	    }
	    
	    double ratio = (double) totaljobs / getMaxJobs();
	    
	    int size = 20 + (int) (100 * Math.sqrt(ratio));
	    
	    int jobsgreen = (100 * donejobs) / totaljobs;
	    
	    int jobsyellow = (100 * activejobs) / totaljobs;
	    
	    p.modify("prod_comment", comment);
	    
	    p.modify("colspan", getWidth());
	    
	    p.modify("jobssize", size);
	    
	    p.modify("jobsgreen", jobsgreen);
	    p.modify("jobsyellow", jobsyellow);
	    p.modify("jobsred", 100-jobsgreen-jobsyellow);

	    if (size()>0){
		p.comment("com_children", true);
		
		for (TreeEntry sub: this){
		    p.append(sub.getPage());
		}
	    }	    
	    else{
		p.comment("com_children", false);
	    }
	    
	    switch(type){
		case 1:
		    p.modify("jobtype_style_start", "<b>");
		    p.modify("jobtype_style_end", "</b>");
		    break;
		
		case 2:
		    p.modify("jobtype_style_start", "<i>");
		    p.modify("jobtype_style_end", "</i>");
	    }
	    
	    if (outputsize>0){
		p.comment("com_hassize", true);
		
		size = 20 + (int) (100 * outputsize / getMaxSize());
		
		p.modify("width_size", size);
		
		p.modify("outputsize_explicit", outputsize);
	    }
	    else{
		p.comment("com_hassize", false);
	    }

	    if (events>0){
		p.comment("com_hasevents", true);

		size = 20 + (int) (100 * events / getMaxEvents());
		
		p.modify("width_events", size);
		
		p.modify("noevents", events);
	    }
	    else{
		p.comment("com_hasevents", false);
	    }
	    
	    if (attributes.containsKey("lpm_history.pid")){
		p.comment("com_jdl", true);
	    }
	    else{
		p.comment("com_jdl", false);
	    }
	    
	    return p;
	}

	public void addAllSubjobs(){
	    if (pid>0){
		DB db = new DB();
		
		db.query("SELECT pid FROM lpm_history WHERE parentpid="+pid+" ORDER BY pid ASC;");
		
		while (db.moveNext()){
	    	    TreeEntry te = new TreeEntry(db.geti(1));
		
		    maxjobs = Math.max(maxjobs, te.maxjobs);
		
		    te.parent = this;
		
		    add(te);
		}
	    }
	}

	public int getWidth(){
	    if (size()==0)
		return 1;
	
	    int sum = 0;
	    
	    for (TreeEntry sub: this){
		sum += sub.getWidth();
	    }
	    
	    return sum;
	}
	
	public int getHeight(){
	    if (size()==0)
		return 1;
		
	    int max = 0;
	    
	    for (TreeEntry sub: this){
		max = Math.max(max, sub.getHeight());
	    }
	    
	    return 1+max;
	}
	
	public int getMaxJobs(){
	    return parent != null ? parent.getMaxJobs() : getMaxJobsSub();
	}
	
	private int getMaxJobsSub(){
	    if (maxjobs<0){
		maxjobs = totaljobs;
		
	        for (TreeEntry sub: this){
	    	    maxjobs = Math.max(maxjobs, sub.getMaxJobsSub());
	        }
	    }
	    
	    return maxjobs;
	}
	
	public long getMaxSize(){
	    return parent != null ? parent.getMaxSize() : getMaxSizeSub();
	}
	
	private long getMaxSizeSub(){
	    if (maxsize<0){
		maxsize = outputsize;
		
		for (TreeEntry sub: this){
		    maxsize = Math.max(maxsize, sub.getMaxSizeSub());
		}
	    }
	    
	    return maxsize;
	}

	public long getMaxEvents(){
	    return parent != null ? parent.getMaxEvents() : getMaxEventsSub();
	}
	
	private long getMaxEventsSub(){
	    if (maxevents<0){
		maxevents = events;
		
		for (TreeEntry sub: this){
		    maxevents = Math.max(maxevents, sub.getMaxEventsSub());
		}
	    }
	    
	    return maxevents;
	}
	
	public boolean containsPid(final int opid){
	    if (pid == opid)
		return true;
	
	    for (TreeEntry sub: this){
		if (sub.containsPid(opid))
		    return true;
	    }
	    
	    return false;
	}
	
	@Override
	public String toString(){
	    return pid+" "+super.toString();
	}
    }
    
%><%
    lia.web.servlets.web.Utils.logRequest("START /runview/index.jsp", 0, request);
    
    final AlicePrincipal user = Users.get(request);
    
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Run processing tree");

    final Page p = new Page("runview/index.res");
    
    final DB db = new DB();
    
    final boolean bAuthOk = user!=null;
    
    p.comment("com_authenticated", bAuthOk);
    
    if (bAuthOk)
	p.modify("account", user.getName());
    
    // ------------------------ parameters

    int iRun = rw.geti("run");
    
    String sBookmark = "run="+iRun;

    if (iRun == 0){
	db.query("SELECT run FROM configuration ORDER BY run DESC LIMIT 1;");

	iRun = db.geti(1);
    }

    TreeEntry jobs = new TreeEntry();

    db.query("SELECT masterjob_id FROM rawdata_processing_requests where run="+iRun+" order by masterjob_id asc;");
    
    while (db.moveNext()){
	final int pid = db.geti(1);
    
	if (jobs.containsPid(pid))
	    continue;
    
	TreeEntry reco = new TreeEntry(pid);
	
	reco.type = 1;
	
	jobs.add(reco);
	
	reco.parent = jobs;
    }

    db.query("select pid from job_runs_details inner join lpm_history using(pid) where lpm_history.runno="+iRun+" and outputdir like '/alice/sim/%' and parentpid=0 ORDER BY pid ASC;");
    
    while (db.moveNext()){
	final int pid = db.geti(1);
    
	if (jobs.containsPid(pid))
	    continue;
    
	TreeEntry mc = new TreeEntry(pid);
	
	mc.type = 2;
	
	jobs.add(mc);
	
	mc.parent = jobs;
    }
    
    p.modify("run", iRun);
    
    for (TreeEntry job: jobs){
	p.append(job.getPage());
    }

    // ------------------------ final bits and pieces

    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    out.flush();

    lia.web.servlets.web.Utils.logRequest("/runview/index.jsp", baos.size(), request);
%>