<%@ page import="alien.taskQueue.Job,lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.jobs.*,java.util.regex.*,alien.pool.*,lazyj.commands.*,lia.Monitor.Store.Cache,lia.Monitor.monitor.*,alien.utils.*,java.util.concurrent.atomic.*,alien.catalogue.*"%><%!
    // 004 Fri Dec 11 03:08:25 2009 [state ]: Job state transition from STARTED to RUNNING |=| procinfotime: 1260497305 site: ALICE::CERN::LCG started: 1260497305 spyurl: lxbsq1245.cern.ch:8089 node: lxbsq1245.cern.ch 
    private static final Pattern pToRunning = Pattern.compile(".*Job state transition from.*STARTED.*to.*RUNNING.+procinfotime:\\s+(\\d+)\\s+site:\\s+([^\\s]+)\\s+.*node:\\s+([^\\s]+).*");

    // 006 Fri Dec 11 05:56:43 2009 [state ]: Job state transition from RUNNING to SAVING |=| procinfotime: 1260507403 site: ALICE::CERN::LCG error: 
    private static final Pattern pToSaving = Pattern.compile(".*Job state transition from.*RUNNING.*to.*SAVING.+procinfotime:\\s+(\\d+)\\s+.*");

    // 011 Fri Dec 11 03:17:40 2009 [state ]: Job state transition to SAVED |=| procinfotime: 1260497860 site: ALICE::CERN::LCG     
    // 054 Tue Apr 13 12:43:05 2010 [state ]: Job state transition to ERROR_E |=| procinfotime: 1271155385 site: ALICE::LUNARC::PBS spyurl: finished: 1271155385 
    private static final Pattern pFinalState = Pattern.compile(".*Job state transition to.+(SAV|ERR).+procinfotime:\\s+(\\d+)\\s+.*");
    
    // 006 Fri Dec 11 06:46:30 2009 [trace     ]: Adding the requirement to 'ALICE::CERN::ALICEDISK ALICE::CNAF::SE ALICE::FZK::SE' due to /alice/data/2009/LHC09d/000104321/ESDs/pass1_special/09000104321018.50/AliESDs.root
    private static final Pattern pSites = Pattern.compile(".*Adding the requirement to \\'([^\\']+)\\' due to .*");
    
    // 016 Sun Dec 13 07:09:38 2009 [state ]: The job finished on the worker node with status ERROR_V
    // 009 Sat Dec 12 22:42:45 2009 [state     ]: The job finished on the worker node with status SAVED_WARN
    private static final Pattern pDate = Pattern.compile("^\\s*\\d+\\s+(.+)\\s+\\[state.*");
    
    private static final String[] SIGNALS = {"HUP", "INT", "QUIT", "ILL", "TRAP", "ABRT", "BUS", "FPE", "KILL", "USR1", "SEGV", "USR2", "PIPE", "ALRM", "TERM", "STKFLT", "CHLD", "CONT", "STOP", "TSTP", "TTIN", "TTOU", "URG", "XCPU", "XFSZ", "VTALRM", "PROF", "WINCH", "IO", "PWR", "SYS"};
    
    private static final class SiteStats {
	
	public List<Double> rss = new LinkedList<Double>();
	public List<Double> vms = new LinkedList<Double>();
	public List<Long> running_time = new LinkedList<Long>();
	public List<Long> saving_time = new LinkedList<Long>();

	public void fill(final Page p){
	    long lTotal = 0;
	    long lMin = 0;
	    long lMax = 0;
	
	    for (final Double m: rss){
		final long i = (long) (m.doubleValue()*1024);
	    
		lTotal += i;
		
		if (lMin==0 || lMin>i) lMin = i;
		if (lMax<i) lMax = i;
	    }
	    
	    if (rss.size()>0){
		p.modify("rss_min", lMin);
		p.modify("rss_max", lMax);
		p.modify("rss_avg", lTotal / rss.size());
	    }

	    lTotal = lMin = lMax = 0;

	    for (final Double m: vms){
		final long i = (long) (m.doubleValue() * 1024);
	    
		lTotal += i;
		
		if (lMin==0 || lMin>i) lMin = i;
		if (lMax<i) lMax = i;
	    }
	    
	    if (vms.size()>0){
		p.modify("vms_min", lMin);
		p.modify("vms_max", lMax);
		p.modify("vms_avg", lTotal / vms.size());
	    }
	    
	    if (running_time.size()>0){
		lTotal = 0;
		
		for (Long l: running_time)
		    lTotal += l.longValue();
		
		p.modify("avg_running", lTotal / running_time.size());
	    }

	    if (saving_time.size()>0){
		lTotal = 0;
		
		for (Long l: saving_time)
		    lTotal += l.longValue();
		
		p.modify("avg_saving", lTotal / saving_time.size());
	    }
	}	
	
    }
%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /jobs/details.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();
    
    int pid = rw.geti("pid");
    
    if (pid==0){
	pid = rw.geti("id");
	
	if (pid==0){
	    out.println("No ID given");
	    return;
	}
    }
    
    final int details = rw.geti("details");
    final int inputData = rw.geti("input");

    final Page p = new Page("jobs/details.res");
    p.setWriter(out);
    
    p.modify("pid", pid);
    p.modify("details", details);
    p.modify("input", inputData);
    
    p.modify("details_text", details==0 ? "more" : "less");
    p.modify("input_text", inputData==0 ? "show" : "hide");
    p.modify("not_details", 1-details);
    p.modify("not_input", 1-inputData);
    p.comment("com_input_data", inputData==1);

    final String returnURL = "/jobs/details.jsp?pid="+pid+"&details="+details+"&input="+inputData;
    
    p.modify("returnurl", returnURL);

    db.query("SELECT run, pass FROM rawdata_processing_requests WHERE masterjob_id="+pid+";");
    
    if (db.moveNext()){
	p.modify("run", db.geti(1));
	p.modify("pass", db.geti(2));
	p.comment("com_updateprocessing", true);
    }
    else{
	p.comment("com_updateprocessing", false);
    }
        
    db.query("select subjobid, resubmissions from lpm_resubmissions where masterjobid="+pid+";");
    
    final Map<Integer, Integer> resubmissions = new HashMap<Integer, Integer>(db.count() + 2);
    
    while (db.moveNext()){
	resubmissions.put(db.geti(1), db.geti(2));
    }
    
    db.query("select pid,jobtype from lpm_history left outer join job_runs_details using(pid) where parentpid="+pid+" order by 1;");
    
    final boolean bHasChildren = db.moveNext();
    
    String sChildren = "";
    
    do{
	if (sChildren.length()>0)
	    sChildren += ", ";
	
	sChildren += "<a href='details.jsp?pid="+db.geti(1)+"&input="+inputData+"&details="+details+"' title='"+Format.escHtml(db.gets(2))+"'>"+db.geti(1)+"</a>";
    }
    while (db.moveNext());
    
    p.comment("com_children", bHasChildren);
    p.modify("children", sChildren);
    if (sChildren.indexOf(',')>0)
	p.modify("children_s", "es");
	
    db.query("SELECT parentpid,jobtype FROM lpm_history LEFT OUTER JOIN job_runs_details ON lpm_history.parentpid=job_runs_details.pid WHERE lpm_history.pid="+pid);
    
    if (db.moveNext() && db.geti(1)>0){
	p.modify("parentpid", db.geti(1));
	p.modify("parentcomment", db.gets(2));
	p.comment("com_parent", true);
    }
    else{
	p.comment("com_parent", false);
    }
    
    db.query("select * from job_runs_details where pid="+pid);
    
    if (db.moveNext()){
	String s = "";
	
	final String sJobType = db.gets("jobtype");
	
	if (sJobType.length()>0){
	    String sHREF = alien.repository.LPM.getProductionHREF(sJobType, pid);
	    
	    if (sHREF!=null)
		s = "<a target=_blank href='"+Format.escHtml(sHREF)+"'><i>"+Format.escHtml(sJobType)+"</i></a>";
	    else
		s = "<i>"+Format.escHtml(sJobType)+"</i>";
	}

	if (db.gets("outputdir").length()>0){
	    if (s.length()>0) s+=", ";
	    
	    s += "<a target=_blank href='/catalogue/?path="+Format.encode(db.gets("outputdir"))+"'>"+Format.escHtml(db.gets("outputdir"))+"</a>";
	}

	if (db.gets("app_root").length()>0){
	    if (s.length()>0) s+=", ";

	    s += "ROOT "+db.gets("app_root");	    
	}

	if (db.gets("app_aliroot").length()>0){
	    if (s.length()>0) s+=", ";

	    s += "AliROOT "+db.gets("app_aliroot");	    
	}
	
	p.comment("com_jobtype", true);
	p.modify("jobtype", s);
    }
    else{
	p.comment("com_jobtype", false);
    }
	
    try{
	final Masterjob job = new Masterjob(pid, null, inputData==1);
	
	String sStatus = job.getStatus();

	p.comment("com_refresh", !job.isFinalStatus());

	p.modify("owner", job.getUsername());
	
	if (sStatus==null){
	    p.modify("masterjob_status", "n/a");
	    p.write();
	    return;
	}
	
	alien.repository.Masterjob.updateStatus(job, true);
	
	Map<Integer, Trace> traces = null;
	
	Map<String, Map<String, AtomicLong>> perSiteSummaries = null;
	
	Map<String, SiteStats> siteStatsMap = null;
	
	if (details==1){
	    traces = job.getTraces(null);
	    
	    perSiteSummaries = new TreeMap<String, Map<String, AtomicLong>>();
	    
	    siteStatsMap = new HashMap<String, SiteStats>();
	}
	
	p.modify("masterjob_status", sStatus);
	
	p.modify("subjobs", job.getSubjobsCount());
	
	final monPredicate predRSS = new monPredicate("*", "%::%::%_Jobs", "*", -1000000000, -1, new String[]{"rss", "virtualmem"}, null);

	HashMap<Integer, Double> hmRSS = null;
	HashMap<Integer, Double> hmVirtualMem = null;

	for (final String sState : new String[]{"ERROR_SPLT", "ERROR_VER", "ERROR_V", "ERROR_S", "ERROR_M", "ERROR_SV", "ERROR_E", "ERROR_IB", "ERROR_VN", "ERROR_VT", "ERROR_I", "ERROR_A", "ERROR_RE", "ERROR_EW", "ERROR_W", 
					 "FAILED", "EXPIRED", "ZOMBIE", "ASSIGNED", "INTERACTIV", "IDLE", "RUNNING", "STARTING", "QUEUED", "STAGING", 
					 "STARTED", "SAVING", "SAVED", "SAVED_WARN", "WAITING", "DONE", "DONE_WARN", "OVER_WAITI", "OVER_WAITING", "INSERTING", "KILLED", "SPLIT", "A_STAGED", "UPDATING"}){
	    final Set<Integer> subjobs = job.getSubjobIDs(sState);
	    
	    if (subjobs!=null && subjobs.size()>0){
		final StringBuilder sb = new StringBuilder("<dt style='padding-top:10px'><a name='").append(Format.escHtml(sState)).append("'><font color=");
		
		if (sState.startsWith("ERR") || sState.startsWith("EXPIRED"))
		    sb.append("red");
		else
		if (sState.startsWith("DONE"))
		    sb.append("green");
		else
		if (sState.startsWith("RUN"))
		    sb.append("blue");
		else
		    sb.append("black");
		
		sb.append(">").append(sState).append("</font></a>").append(" (").append(subjobs.size()).append(")");
		
		if (!bHasChildren){
		    if (sState.startsWith("ERR") || sState.startsWith("EXPIRED") || sState.startsWith("OVER_WAIT") || sState.startsWith("Z")){
			sb.append(" : <a href='/users/resubmit.jsp?pid=").append(pid).append("&state=").append(Format.encode(sState)).append("&return_path=").append(Format.encode(returnURL)).append("'>resubmit all</a>");
		    }
		}
		
		sb.append("</dt>");
		
		Map<String, Set<Integer>> splitErrors = new TreeMap<String, Set<Integer>>();
		
		if (details==1 && sState.equals("ERROR_E")){
		    for (final Integer i: subjobs){
			String substate = "";
			
			final Trace t = traces.get(i);
			
			if (t!=null){
			    final StringBuilder lastTrace = t.getLastExecutionTrace();
			    
			    if (lastTrace!=null){
				if (lastTrace.indexOf("Killing the job (using more than ")>=0){
				    if (lastTrace.indexOf("MB of diskspace (right now we were using")>=0)
					substate = "Too much local disk space used";
				    else
				    if (lastTrace.indexOf(" memory (right now")>=0)
					substate = "Too much allocated memory";
				}
				else
				if (lastTrace.indexOf("Killing the job (due to zero CPU consumption in the last")>=0)
				    substate = "Process idle for too long";
				else
				if (lastTrace.indexOf("Killing the job (it was running for longer than its TTL)")>=0){
				    final Job j = job.getSubjob(i);
				    
				    final JDL jdl = new JDL(j.getJDL());
				
				    substate = "Running longer than the TTL ("+jdl.gets("TTL")+"s = "+Format.toInterval(Long.parseLong(jdl.gets("TTL")) * 1000)+")"; 
				}
			    }
			}
			
			Set<Integer> splitsubjobs = splitErrors.get(substate);
			
			if (splitsubjobs==null){
			    splitsubjobs = new TreeSet<Integer>();
			    splitErrors.put(substate, splitsubjobs);
			}
			
			splitsubjobs.add(i);
		    }
		    
		    //System.err.println(splitErrors);
		}
		else{
		    splitErrors.put("", subjobs);
		}
		
		int iWaiting = 0;
		
		boolean firstError = true;
		
		for (final Map.Entry<String, Set<Integer>> entry: splitErrors.entrySet()){
		  String substate = entry.getKey();

		  if (firstError)
		    firstError = false;
		  else
		    sb.append("<dd>&nbsp;</dd>");

		  if (substate.length()>0){
		    int nojobs = entry.getValue().size();
		  
		    sb.append("<dd><b>").append(substate).append("</b>").append(": ").append(nojobs);
		    
		    if (nojobs>1)
			sb.append(" jobs");
		    else
			sb.append(" job");
		
		    sb.append("</dd>");
		  }
		  
		  final Map<String, Set<Integer>> byExitcode = new TreeMap<String, Set<Integer>>();
		  
		  if (sState.equals("ERROR_V") || sState.startsWith("ERROR_E")){
		    for (final Integer i: entry.getValue()){
			Job j = job.getSubjob(i);
		                      
		        String sCode = "";
		                      
			if (j!=null){
			    sCode = "Exit code: <b>" + j.error+"</b>";
			    
			    if (sState.equals("ERROR_V")){
				if (j.error > 128 && j.error < 160){
				    sCode += " ("+SIGNALS[j.error-129]+" ?)";
				}
				else
				if (j.error == 1)
				    sCode += " ( Snapshot ?)";
				else
				if (j.error == 5)
				    sCode += " ( sim.C ?)";
				else
				if (j.error == 10)
				    sCode += " ( rec.C ?)";
				else
				if (j.error == 11)
				    sCode += " ( FPE or recOuter.C ?)";
				else
				if (j.error == 40)
				    sCode += " ( calibTrain.C ?)";
				else
				if (j.error == 50)
				    sCode += " ( tag.C ?)";
				else
				if (j.error == 60)
				    sCode += " ( check.C ?)";
				else
				if (j.error == 100)
				    sCode += " ( QA.C ?)";
				else
				if (j.error == 101)
				    sCode += " ( QAOuter.C ?)";
				else
				if (j.error == 200)
				    sCode += " ( AOD.C ?)";
			    }
			}
			
			Set<Integer> jobsByExitcode = byExitcode.get(sCode);
			
			if (jobsByExitcode==null){
			    jobsByExitcode = new TreeSet<Integer>();
			    byExitcode.put(sCode, jobsByExitcode);
			}
			
			jobsByExitcode.add(i);
		    }
		  }
		  else{
		    byExitcode.put("", entry.getValue());
		  }

		  for (final Map.Entry<String, Set<Integer>> entryByCode: byExitcode.entrySet()){
		   String stateByCode = entryByCode.getKey();

		   if (stateByCode.length()>0){
		    int nojobs = entryByCode.getValue().size();
		  
		    sb.append("<dd><i>").append(stateByCode).append("</i>").append(": ").append(nojobs);
		    
		    if (nojobs>1)
			sb.append(" jobs");
		    else
			sb.append(" job");
		
		    sb.append("</dd>");
		   }
		  
		   for (final Integer i : entryByCode.getValue()){
		    sb.append("<dd>");
		    
		    if (sState.equals("ERROR_V"))
			sb.append("&nbsp;&nbsp;");
		    else
		    if (sState.startsWith("ERROR_E")){
	                sb.append("&nbsp;&nbsp;");
	                
	                if (details==1)
	            	    sb.append("&nbsp;&nbsp;");
		    }

    		    double rss = -1;
		    double virtualmem = -1;
		    
		    if (!sState.startsWith("WAIT") && !sState.startsWith("INSERT")){
			if (hmRSS == null){
			    final Vector<?> v = Cache.getLastValues(predRSS);
			    
			    hmRSS = new HashMap<Integer, Double>(v.size()/2);
			    hmVirtualMem = new HashMap<Integer, Double>(v.size()/2);

			    for (final Object o: v){
				if (o instanceof Result){
				    final Result r = (Result) o;
				    
				    if (r.param_name[0].equals("rss"))
					hmRSS.put(Integer.valueOf(r.NodeName), Double.valueOf(r.param[0]));
				    else
					hmVirtualMem.put(Integer.valueOf(r.NodeName), Double.valueOf(r.param[0]));
				}
			    }
			}

			final Double dRSS = hmRSS.get(i);
			
			if (dRSS!=null)
			    rss = dRSS.doubleValue();
			    
			final Double dVirt = hmVirtualMem.get(i);
			
			if (dVirt!=null)
			    virtualmem = dVirt.doubleValue();
		    }

		    sb.append("<a ");
		    if (rss>=0 || virtualmem>=0)
			sb.append("onMouseOver=\"overlib('<img src=/display?page=memory/img&amp;Nodes=").append(i).append("&amp;dont_cache=true>')\" onMouseOut=\"nd();\" ");
		
		    sb.append("id='").append(i).append("' name='").append(i).append("' target=_blank href='jdl.jsp?pid=").append(i).append("'>").append(i).append("</a>");
		    
		    sb.append(" : <a target=_blank href='trace.jsp?pid=").append(i).append("'>trace</a>");

		    if (sState.startsWith("ERR") && !sState.equals("ERROR_E")){
			sb.append(" | <a target=_blank href='output.jsp?pid=").append(pid).append("&id=").append(i).append("'>log files</a>");
		    }
		    
		    if (sState.startsWith("DONE")){
			sb.append(" | <a target=_blank href='output.jsp?pid=").append(pid).append("&id=").append(i).append("'>output dir</a>");
		    }
		    
		    
		    if (!bHasChildren){
		        if (sState.startsWith("ERR") || sState.startsWith("EXPIRED") || sState.startsWith("OVER_WAIT") || sState.startsWith("Z")){
			    sb.append(" | <a href='/users/resubmit.jsp?pid=").append(pid).append("&id=").append(i).append("&return_path=").append(Format.encode(returnURL)).append("'>resubmit</a>");
			}
		    }

		    if (rss>=0 || virtualmem>=0){
		        sb.append(", <a href='javascript:void(0);' onClick=\"overlib('<img src=/display?page=memory/img&amp;Nodes=").append(i).append("&amp;dont_cache=true>', STICKY, CAPTION, 'Memory profile');\">");
		    
		        if (rss>=0)
			    sb.append(Format.size(rss, "K")).append(" RSS");

			if (virtualmem>=0)
			    sb.append(", ").append(Format.size(virtualmem, "K")).append(" VMS");
			
			sb.append("</a>");
		    }
		    
		    long inputDataSize = 0;
		    
		    if (inputData==1){
    			Job j = job.getSubjob(i);
			
			if (j!=null){
			    final String jdlContent = j.getOriginalJDL(false);
			    
			    if (jdlContent!=null && jdlContent.length()>0){
				final alien.taskQueue.JDL jdl;
				
				try{
				    jdl = new alien.taskQueue.JDL(Job.sanitizeJDL(jdlContent));
			    
    				List<String> data = jdl.getInputData();
    				
    				if (data==null || data.size()==0){
    				    final List<String> dataFiles = jdl.getInputFiles(true);
    				    
    				    for (final String file: dataFiles){
    					if (file.endsWith(".xml")){
    					    final XmlCollection x = new XmlCollection(LFNUtils.getLFN(file));
    					    
    					    for (final LFN l: x){
    						if (data == null)
    						    data = new LinkedList<String>();
    					    
    						data.add(l.getCanonicalName());
    					    }
    					    
    					    break;
    					}
    				    }
    				}
    				
    				if (data!=null && data.size()>0){
    				    sb.append(", ").append(data.size()).append(" input file");
    				    if (data.size()>1)
    					sb.append('s');
    				
    				    for (final String file: data){
    					final LFN inputFile = LFNUtils.getLFN(file);
    				    
    					if (inputFile!=null)
    					    inputDataSize += inputFile.size;
    				    }
    				}
    				else{
    				    sb.append(", no input files");
    				}
    				
    				if (inputDataSize>0)
    				    sb.append(" of ").append(Format.size(inputDataSize));
    				}
    				catch (IOException ioe){
    				    System.err.println("JDL parsing exception for job "+i+": "+ioe.getMessage()+"\n"+jdlContent);
    				    ioe.printStackTrace();
    				}
			    }
			    else{
				System.err.println("Null JDL for "+i);
			    }
			}
		    }
		    
		    if (details==1 && !sState.startsWith("INSERT")){
			    final Trace t = traces.get(i);
			    
			    if (t==null){
				System.err.println("Trace is null for "+i);
			    
				continue;
			    }
			    
			    if (t.getLastStatusChangeTimestamp()<0){
				System.err.println("Last change timestamp not found for "+i);
			    
				continue;
			    }
				
			    final long lNow = System.currentTimeMillis();
			    
			    if (sState.startsWith("OVER_WAIT")){
				sb.append(" (is in the queue for ").append(Format.toInterval(lNow - t.getLastStatusChangeTimestamp())).append(")");
				continue;
			    }
			    
			    if (sState.startsWith("WAIT")){
				String sSites = "";
			    
				if (iWaiting < 0){	// disable this feature, it doesn't seem to be used and it takes too long to execute
				    iWaiting ++;	
			    
				    CommandOutput co = AliEnPool.executeCommand("jobListMatch "+i, true);

				    if (co!=null){
					BufferedReader br = co.reader();
				    
					String sLine;
				    
					try{
					    while ( (sLine=br.readLine())!=null ){
						// Comparing the jdl of the job with ALICE::NSC::ARC... MATCHED
						//System.err.println(sLine);
					    
						if (sLine.indexOf("MATCHED")>0){
						    String sSite = sLine.substring(sLine.indexOf("::")+2, sLine.indexOf("..."));
						
						    //System.err.println(sSite);
						
						    sSites += (sSites.length()>0 ? ", " : "") + sSite;
						}
					    }
					}
					catch (Exception e){
					    System.err.println("jobs/details.jsp : "+e);
					}
				    }
				    else{
					System.err.println("jobs/details.jsp : null output");
				    }
			    
				    if (sSites.length()>0)
					sSites = "Sites that could run this job: "+sSites;
				    else
					sSites = "No sites match the requirements of this job !";
				}
			    
				sb.append(" (<A title='").append(Format.escHtml(sSites)).append("'>waiting for ").append(Format.toInterval(lNow - t.getLastStatusChangeTimestamp())).append("</A>)");
				continue;
			    }
			    
			    String sSitePart = "";
			    
			    SiteStats ss = null;
			    boolean siteRSSAdded = false;
			    boolean siteVirtAdded = false;
			    
			    if (t.getSite()!=null){
				sSitePart = t.getSite();
				
				ss = siteStatsMap.get(sSitePart);
				
				if (ss==null){
				    ss = new SiteStats();
				    siteStatsMap.put(sSitePart, ss);
				}
				
				if (rss>0){
				    ss.rss.add(rss);
				    siteRSSAdded = true;
				}
				
				if (virtualmem>0){
				    ss.vms.add(virtualmem);
				    siteVirtAdded = true;
				}
				
				Map<String, AtomicLong> siteStats = perSiteSummaries.get(sSitePart);
				
				if (siteStats==null){
				    siteStats = new HashMap<String, AtomicLong>();
				    
				    perSiteSummaries.put(sSitePart, siteStats);
				}
				
				String sKeyState;
				
				if (sState.startsWith("ERR") || sState.startsWith("EXPI") || sState.startsWith("KILL") || sState.startsWith("OVER") || sState.startsWith("ZOMB"))
				    sKeyState = "ERROR";
				else
				if (sState.startsWith("RUN") || sState.equals("START"))
				    sKeyState = "RUNNING";
				else
				if (sState.startsWith("DONE"))
				    sKeyState = "DONE";
				else
				if (sState.startsWith("WAIT"))
				    sKeyState = "WAITING";
				else
				if (sState.startsWith("INSERT"))
				    sKeyState = "INSERTING";
				else
				if (sState.startsWith("SAV"))
				    sKeyState = "SAVING";
				else
				    sKeyState = "OTHER";
				    
				AtomicLong ai = siteStats.get(sKeyState);
				if (ai==null){
				    ai = new AtomicLong(1);
				    siteStats.put(sKeyState, ai);
				}
				else
				    ai.incrementAndGet();

				final int wallTime = t.getWallTime();
				final int cpuTime = t.getCpuTime();
				
				if (wallTime>0){
				    ai = siteStats.get("wallTime");
				    if (ai==null){
					ai = new AtomicLong(wallTime);
					siteStats.put("wallTime", ai);
				    }
				    else
					ai.addAndGet(wallTime);

				    ai = siteStats.get("cpuTime");
				    if (ai==null){
					ai = new AtomicLong(cpuTime);
					siteStats.put("cpuTime", ai);
				    }
				    else
					ai.addAndGet(cpuTime);
				}
				
				if (t.getHost()!=null){
				    sSitePart = "<a title='"+t.getHost()+"'>"+sSitePart+"</a>";
				}
				
				if (inputDataSize>0){
				    AtomicLong al = siteStats.get("inputDataSize");
				    
				    if (al==null){
					al = new AtomicLong(inputDataSize);
					siteStats.put("inputDataSize", al);
				    }
				    else
					al.addAndGet(inputDataSize);
				}
			    }
			    
			    if (sSitePart.length()>0)
				sSitePart = " @ " + sSitePart;
	
			    final Date d = new Date(t.getLastStatusChangeTimestamp());		
	
			    String sDate = Format.showNiceDate(d)+ " " +Format.showTime(d);
			    
			    sb.append(" (<a title='Last change: ").append(Format.escHtml(sDate)).append("'>");
			
			    if (sState.equals("STARTED")){
				sb.append("started "+Format.toInterval(lNow - t.getLastStatusChangeTimestamp())+" ago</a>"+sSitePart+")");
				continue;
			    }
			
			    if (t.getFinalTimestamp() > 0){
				    if (t.getRunningTimestamp() > 0 && t.getSavingTimestamp()>0){
					final long lRunning = t.getSavingTimestamp() - t.getRunningTimestamp();
					final long lSaving = t.getFinalTimestamp() - t.getSavingTimestamp();
					
					if (ss!=null){
					    ss.running_time.add(lRunning);
					    ss.saving_time.add(lSaving);
					}
				    
			    		sb.append(Format.toInterval(lRunning)+" running, "+Format.toInterval(lSaving)+" saving");
			    	    }
			    	    else
			    	    if (t.getRunningTimestamp() > 0){
			    		final long lRunning = t.getFinalTimestamp() - t.getRunningTimestamp();
			    		
			    		if (ss!=null){
			    		    ss.running_time.add(lRunning);
			    		}
			    	    
			    		sb.append(Format.toInterval(lRunning)+" running, didn't save");
			    	    }
			    	    else
			    	    if (t.getSavingTimestamp()>0){
			    		final long lSaving = t.getFinalTimestamp() - t.getSavingTimestamp();
			    		
			    		if (ss!=null){
			    		    ss.saving_time.add(lSaving);
			    		}
			    		
			    		sb.append("did not run, "+Format.toInterval(lSaving)+" saving");
			    	    }
			    	    else{
			    		sb.append("did not run");
			    	    }
			    }
			    else
			    if (t.getSavingTimestamp() > 0){
				final long lRunning = t.getSavingTimestamp() - t.getRunningTimestamp();
				final long lSaving = lNow - t.getSavingTimestamp();
				
				if (ss!=null){
				    ss.running_time.add(lRunning);
				    ss.saving_time.add(lSaving);
				}
			    
				sb.append(Format.toInterval(lRunning)+" running, now saving for "+Format.toInterval(lSaving));
			    }
			    else
			    if (t.getRunningTimestamp()>0){
				final long lRunning = lNow - t.getRunningTimestamp();
				
				if (ss!=null)
				    ss.running_time.add(lRunning);
				
				sb.append("running for "+Format.toInterval(lRunning));
			    }
			    else
				sb.append("did not run");
				
			    String eff = t.getCpuEfficiency();
			    
			    if (eff!=null)
				sb.append(", ").append(eff).append(" CPU");
			    
			    sb.append("</a>").append(sSitePart);

			    long lRSS = t.getMaxRSS();
			    long lVirt = t.getMaxVirt();

			    Double dm = hmRSS.get(i);
			    
			    if (dm!=null)
				lRSS = Math.max(lRSS, dm.longValue()*1024);
				
			    dm = hmVirtualMem.get(i);
			    
			    if (dm!=null)
				lVirt = Math.max(lVirt, dm.longValue()*1024);			    
			    
			    if (lRSS>0 || lVirt>0){
				sb.append(", max ");
				
				if (lRSS>0){
				    sb.append("RSS: ").append(Format.size(lRSS));

	    			    if (hmRSS.get(Integer.valueOf(i))==null)
					hmRSS.put(Integer.valueOf(i), Double.valueOf(lRSS));
				
				    if (ss!=null && !siteRSSAdded)
					ss.rss.add(Double.valueOf(lRSS/1024));
				}
				
				if (lVirt>0){
				    if (lRSS>0)
					sb.append(", ");
					
				    sb.append("Virt: ").append(Format.size(lVirt));
				    
				    if (hmVirtualMem.get(Integer.valueOf(i))==null)
					hmVirtualMem.put(Integer.valueOf(i), Double.valueOf(lVirt));
				
				    if (ss!=null && !siteVirtAdded)
					ss.vms.add(Double.valueOf(lVirt/1024));
				}
			    }

			    sb.append(")");
		    }
		    
		    Integer iResubmissions = resubmissions.get(i);
		    
		    if (iResubmissions!=null && iResubmissions > 0){
			sb.append(" (resubmitted "+iResubmissions+" time"+(iResubmissions.intValue()>1 ? "s" : "")+")");
		    }
		    
		    sb.append("</dd>\n");
                  }
                 }
		}
		
		p.append(sb);
	    }
	}
	
	if (details==1 && perSiteSummaries.size()>0){
	    final Page pLine = new Page("jobs/details_summary_line.res");
	
	    p.comment("com_summary", true);
	    
	    final Map<String, AtomicLong> totals = new HashMap<String, AtomicLong>();
	    
	    SiteStats global = new SiteStats();
	    
	    for (final Map.Entry<String, Map<String, AtomicLong>> me: perSiteSummaries.entrySet()){
		pLine.modify("site", me.getKey());
		
		pLine.comment("com_input_data", inputData==1);
		
		long wallTime = -1;
		long cpuTime = -1;
		long inputDataSize = -1;
		
		for (final Map.Entry<String, AtomicLong> me2: me.getValue().entrySet()){
		    final String sState = me2.getKey();
		    final AtomicLong ai = me2.getValue();
		    
		    pLine.modify(sState, ai);
		    
		    AtomicLong sum = totals.get(sState);
		    
		    if (sum==null){
			sum = new AtomicLong(ai.longValue());
			totals.put(sState, sum);
		    }
		    else
			sum.addAndGet(ai.longValue());
		
		    if (sState.equals("wallTime"))
			wallTime = ai.longValue();
		    else
		    if (sState.equals("cpuTime"))
			cpuTime = ai.longValue();
		    else
		    if (sState.equals("inputDataSize")){
			inputDataSize = ai.longValue();
			pLine.modify("inputDataSize", Format.size(inputDataSize));
		    }
		}
		
		if (wallTime>0){
		    pLine.modify("cpu_efficiency", Format.point(cpuTime*100d/wallTime)+"%");
		    
		    if (inputDataSize>0)
			pLine.modify("inputDataRate", Format.size(inputDataSize/wallTime)+"/s");
		}
				
		SiteStats ss = siteStatsMap.get(me.getKey());
		if (ss!=null){
		    ss.fill(pLine);
		    
		    global.rss.addAll(ss.rss);
		    global.vms.addAll(ss.vms);
		    global.running_time.addAll(ss.running_time);
		    global.saving_time.addAll(ss.saving_time);
		}

		p.append("summary", pLine);
	    }
	    
	    global.fill(p);
	    
	    int iTotal = 0;
	    
	    long wallTime = -1;
	    long cpuTime = -1;
	    long inputDataSize = -1;
	    
	    for (final Map.Entry<String, AtomicLong> me: totals.entrySet()){
		final AtomicLong ai = me.getValue();
	    
		
		if (me.getKey().equals("wallTime")){
		    wallTime = ai.longValue();
		}
		else
		if (me.getKey().equals("cpuTime")){
		    cpuTime = ai.longValue();
		}
		else
		if (me.getKey().equals("inputDataSize")){
		    inputDataSize = ai.longValue();
		    
		    p.modify("inputDataSize", Format.size(inputDataSize));
		}
		else{
		    p.modify(me.getKey(), ai);

		    iTotal += ai.longValue();
		}
	    }
	    
	    p.modify("summary_jobs", iTotal);
	    p.modify("summary_sites", perSiteSummaries.size());
	    
	    if (wallTime>0){
		p.modify("cpu_efficiency", Format.point(cpuTime*100d/wallTime)+"%");
		
		if (inputDataSize>0)
		    p.modify("inputDataRate", Format.size(inputDataSize/wallTime)+"/s");
	    }
	}
	else{
	    p.comment("com_summary", false);
	}
    }
    catch (Exception e){
	p.modify("masterjob_status", "Process is no longer active");
	System.err.println("jobs/details.jsp : "+e);
	e.printStackTrace();
    }
    
    p.write();
    
    lia.web.servlets.web.Utils.logRequest("/jobs/details.jsp", 0, request);
%>
