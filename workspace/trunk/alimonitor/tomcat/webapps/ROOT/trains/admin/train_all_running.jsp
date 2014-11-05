<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alien.taskQueue.*,alien.jobs.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,java.text.SimpleDateFormat,utils.IntervalQuery,lazyj.mail.*,lia.Monitor.monitor.AppConfig" %><%!

    private final static String basePath = "/home/monalisa/train-workdir/";

    public class JobStatus {
      public int done = 0;
      public int total = 0;
      public int error = 0;
      public int active = 0;
      public int waiting = 0;
      public int masterjobs = 0;
      public int error_split = 0;
      
      public void add(JobStatus jobStatus)
      {
	done += jobStatus.done;
	total += jobStatus.total;
	error += jobStatus.error;
	active += jobStatus.active;
	waiting += jobStatus.waiting;
	masterjobs += jobStatus.masterjobs;
	error_split += jobStatus.error_split;
      }
      
      public int finalstate()
      {
	return done + error;
      }
      
      public int activestate()
      {
	return waiting + active;
      }
    }

    private final JobStatus getJobStats(final int job_types_id, final String path, final String htmlTag, final Page p, final boolean brief)
    {
      DB db2 = new DB();
      
      db2.query("SELECT sum(cnt),state FROM job_runs_details INNER JOIN job_stats_details USING(pid) WHERE job_types_id="+job_types_id+" AND (outputdir ilike '%"+Format.escSQL(path)+"') GROUP BY state;");
		
      JobStatus j = new JobStatus();
      
      while (db2.moveNext()){
	  int cnt = db2.geti(1);
	  String state = db2.gets(2);
	  
	  if (state.startsWith("DONE"))
	      j.done += cnt;
	  else
	  if (state.equals("TOTAL"))
	      j.total = cnt;
	  else
	  if (state.startsWith("E") || state.startsWith("Z") || state.startsWith("FAILED"))
	      j.error += cnt;
	  else
	  if (state.startsWith("R") || state.startsWith("A"))
	      j.active += cnt;
	  else
	      j.waiting += cnt;
	  if (state.equals("ERROR_SPLT"))
	    j.error_split += cnt;
      }
      
      db2.query("SELECT count(distinct pid) as no_masterjobs FROM job_runs_details WHERE job_types_id="+job_types_id+" AND (outputdir ilike '%"+Format.escSQL(path)+"%');");
      j.masterjobs = db2.geti(1);
  
      p.modify(htmlTag, "<b>" + j.total + ((brief) ? "/" : " total, ") +
		  "<font color='green'>" + j.done + ((brief) ? "</font>/" : " done</font>, ") +
		  "<font color='red'>" + j.error + ((brief) ? "</font>/" : " error</font>, ") +
		  "<font color='blue'>" + j.active + ((brief) ? "</font>/" : " active</font>, ") +
		  "<font color='orange'>" + j.waiting + ((brief) ? "</font></b>" : " waiting</font></b>"));
      
      return j;
    }

    private final int checkJobsWaiting(final int job_types_id, final String path)
    {
      DB db = new DB();
      
      db.query("SELECT distinct pid as no_masterjobs FROM job_runs_details WHERE job_types_id="+job_types_id+" AND (outputdir ilike '%"+Format.escSQL(path)+"%');");
      
      int jobsOverWaiting = 0;
      
      while (db.moveNext())
      {
	Masterjob j = new Masterjob(db.geti(1), "alitrain", true);
        if (j == null || j.getMasterJob() == null)
		continue;

	int waitingLimit = 0;

	try{
	      final alien.taskQueue.JDL jdl = new alien.taskQueue.JDL(j.getMasterJob().getJDL());

	      String value = jdl.gets("LPMActivity");

	      if (value!=null)
		    waitingLimit = Integer.parseInt(value);
	}
	catch (NumberFormatException nfe){
	    System.err.println("LPMActivity was specified but could not be parsed "+nfe.getMessage());
	}
	catch (IOException ioe){
	    // ignore
	}
	
	final boolean activityTimeReached = waitingLimit>0 && j.getMasterJob().received + (waitingLimit+1800) < (System.currentTimeMillis()/1000);

	if (activityTimeReached){
	    Set<Integer> waiting = j.getSubjobIDs("WAITING");

	    if (waiting!=null && waiting.size()>0){
		jobsOverWaiting += waiting.size();
	    }
	}
      }

      return jobsOverWaiting;
    }
    
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_all_running.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("title", "Analysis trains overview");
    
    final Page p = new Page(baos, "trains/admin/train_all_running.res", false);
    
    final DB db = new DB();
    final DB db2 = new DB();
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    boolean admin = true; //principal.hasRole("admin");

    JobStatus totalJobs = new JobStatus();
    
    // ------------------------ content
    
    String sAliroot = null;
    
    db.query("SELECT train_run.train_id, train_run.id, operator_created, split_all, wg_no, train_type, train_name, lpm_id, test_path, run_start, train_finished_timestamp, outputfiles,  to_char(to_timestamp(run_start), 'DD Mon YY') as run_date, extract(epoch from now())-run_start as run_date_ago FROM train_run LEFT JOIN train_def ON train_run.train_id = train_def.train_id WHERE (extract(epoch from now())-run_start) < 60 * 60 * 24 * 7 ORDER BY wg_no, train_name, train_run.id");

    Page pLine = new Page("trains/admin/train_all_running_line.res", false);

    String copyingFailures = "";
  
    int traincount = 0;
    while (db.moveNext())
    {
	pLine.reset();
      
	final int lpm_id = db.geti("lpm_id");
	final int train_id = db.geti("train_id");
	final int id = db.geti("id");
	final int train_finished_timestamp = db.geti("train_finished_timestamp");
	final boolean mc_gen = (db.geti("train_type") == 1);
	String issues = new String();

	// exclude runs not yet submitted or where final merging was already executed
	if (lpm_id <= 0 || train_finished_timestamp > 0)
	  continue;

        // skip killed trains	
	if (new File(basePath+db.gets("test_path")+"/train_killed").exists())
	  continue;
	
	String outputfiles = db.gets("outputfiles");
	pLine.modify("no_outputfiles", outputfiles.split(",", 0).length);
	
	db2.query("select * from lpm_chain where id="+lpm_id);
	
	final int submitcount = db2.geti("submitcount");
	final int lpm_enabled = db2.geti("enabled");

	// check for file copying failure
	if (new File(basePath+db.gets("test_path")+"/files_copying_failure").exists()) {
	  issues += "Copying of files to the Grid failed<br>";
	  copyingFailures += db.gets("test_path") + " ";
        }
	    
	db2.query("select job_types_id,jt_field1 from lpm_history natural inner join job_runs_details inner join job_types on jt_id=job_types_id where chain_id="+lpm_id+" limit 1;");

	if (db2.geti(1) > 0)
	{
	  final int job_types_id = db2.geti(1);
	  final String job_type = db2.gets(2);
	      
	  JobStatus procJobs = getJobStats(job_types_id, db.gets("test_path") + ((mc_gen) ? "%" : ""), "processing_jobstats", pLine, false);
	  
	  db2.query("select jt_id,jt_field1 from job_types where jt_field1='"+job_type+"_Stage1_Merging';");
	  final int job_types_id_stage1 = db2.geti(1);
	  JobStatus merge1Jobs = getJobStats(job_types_id_stage1, db.gets("test_path") + ((mc_gen) ? "%" : "/Stage_1"), "merging1_jobstats", pLine, true);

	  db2.query("select jt_id,jt_field1 from job_types where jt_field1='"+job_type+"_Stage5_FinalMerging';");
	  final int job_types_id_stage5 = db2.geti(1);
	  JobStatus merge5Jobs = getJobStats(job_types_id_stage5, db.gets("test_path") + ((mc_gen) ? "%" : ""), "merging5_jobstats", pLine, true);

	  if (procJobs.activestate() == 0)
	  {
	    //if (merge1Jobs.masterjobs < submitcount)
	    //  issues += "Only " + merge1Jobs.masterjobs + "/" + submitcount + " in stage1<br>";
	    if (merge1Jobs.activestate() == 0)
	    {
	      if (merge5Jobs.total < submitcount)
		issues += "Only " + merge5Jobs.total + "/" + submitcount + " in final merging<br>";
	    }
	  }
	  
	  if (merge5Jobs.error > 0)
	    issues += "Failures in stage5<br>";
	  
	  JobStatus allJobs = new JobStatus();
	  allJobs.add(procJobs);
	  allJobs.add(merge1Jobs);
	  allJobs.add(merge5Jobs);
	  
	  //if (allJobs.activestate() <= 0 && lpm_enabled != 1)
	  //  continue;
	  
	  if (allJobs.error_split > 0)
	    issues += allJobs.error_split + " jobs in ERROR_SPLT<br>";
	  
	  // 95% done, check for jobs which should have been moved to E_W
	  if (false && procJobs.finalstate() > 0.9 * procJobs.total)
	  {
	    int jobs_over_waiting = checkJobsWaiting(job_types_id, db.gets("test_path"));
	    jobs_over_waiting += checkJobsWaiting(job_types_id_stage1, db.gets("test_path"));
	    jobs_over_waiting += checkJobsWaiting(job_types_id_stage5, db.gets("test_path"));
	    
	    if (jobs_over_waiting > 0)
	      issues += jobs_over_waiting + " jobs should have been moved to E_W<br>";
	  }
	  
	  totalJobs.add(procJobs);
	}
//	else if (lpm_enabled != 1)
//	  continue;

	// final merge
	db2.query("SELECT count(*) FROM train_run_final_merge WHERE train_id = "+train_id+" AND id = "+id+" AND final_merge_job_id = -1");
	if (db2.geti(1) > 0)
	  issues += "Final merge submission failed<br>";
	
	// vmem
	db2.query("SELECT test_mem_virt_max FROM train_run_wagon WHERE train_id = "+train_id+" AND id = "+id+" AND wagon_name = '__ALL__'");
	pLine.fillFromDB(db2);
	
	pLine.modify("issues", issues);
	pLine.modify("lpm_submitted", submitcount);
	pLine.modify("lpm_enabled", (lpm_enabled == 0) ? "<font color='blue'>DONE</font>" : "<font color='green'>ACTIVE</font>");

	db2.query("SELECT period_name FROM train_run_period WHERE train_id = "+train_id+" AND id = "+id);
	db2.query("SELECT aod FROM train_period WHERE train_id = "+train_id+" AND period_name='"+db2.gets(1)+"'");
	pLine.modify("esd_aod", (db2.geti(1) == 0) ? "ESD" : "AOD");

	
	db2.query("SELECT COUNT(*) FROM train_run_wagon WHERE train_id="+train_id+" AND id = "+id);
	pLine.modify("no_wagons", db2.geti(1)-2);
	
	pLine.fillFromDB(db);
	
	p.append(pLine);
	
	traincount++;
    }
    
    final boolean brief = false;

    p.modify("totaljob_stat", "<b>" + totalJobs.total + ((brief) ? "/" : " total, ") +
		"<font color='green'>" + totalJobs.done + ((brief) ? "</font>/" : " done</font>, ") +
		"<font color='red'>" + totalJobs.error + ((brief) ? "</font>/" : " error</font>, ") +
		"<font color='blue'>" + totalJobs.active + ((brief) ? "</font>/" : " active</font>, ") +
		"<font color='orange'>" + totalJobs.waiting + ((brief) ? "</font></b>" : " waiting</font></b>"));
		
    p.modify("train_count", traincount);
    p.modify("copyingFailures", copyingFailures);
    
    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_all_running.jsp", baos.size(), request);
%>
