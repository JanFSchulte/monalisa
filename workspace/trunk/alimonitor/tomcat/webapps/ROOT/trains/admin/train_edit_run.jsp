<%@ page import="lia.web.servlets.web.display,lazyj.*,lia.web.utils.ServletExtension,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,java.text.SimpleDateFormat,utils.IntervalQuery,lazyj.mail.*,lia.Monitor.monitor.AppConfig" %><%!
 
    //~ private final static String basePath = System.getProperty("user.home")+"/train-workdir/";
    private final static String basePath ="/opt/home/train-workdir/";
    
    private final static SimpleDateFormat dirFormat = new SimpleDateFormat("yyyyMMdd-HHmm");
    
    private static final String getDirName(){
	return getDirName(new Date());
    }
    
    private static final void sendMail(final String subject, final String body, final String cc, final String... accounts){
	final Mail m = new Mail();
	
	m.sFrom = "alitrain@alimonitor.cern.ch";
	
	final Sendmail s = new Sendmail(m.sFrom, AppConfig.getProperty("lia.util.mail.MailServer", "127.0.0.1"));
	
	for (final String account: accounts){
	    m.sSubject = subject;
	    m.sBody = body;
	    
	    final Set<String> emails = LDAPHelper.checkLdapInformation("uid="+account, "ou=People,", "email");
	    
	    m.sTo = "";
	    
	    if (emails!=null){
	        for (final String email: emails){
		    if (m.sTo.length()>0)
			m.sTo += ", ";
		
		    m.sTo += email;
		}
	    }
	    
	    final Set<String> ccs = LDAPHelper.checkLdapInformation("uid="+cc, "ou=People,", "email");
	    if (ccs!=null){
	        for (final String ccemail: ccs){
		    if (m.sCC.length()>0)
			m.sCC += ", ";
		
		    m.sCC += ccemail;
		}
	    }
	    
	    if (m.sTo.length()>0)
	        s.send(m);
	}
    }
    
    private static final String getDirName(final Date d){
	synchronized (dirFormat){
	    return dirFormat.format(d);
	}
    }

    //get runlist as sum of all runlists for this dataset, but each run is only listed once
    private static final String getRunlist(int trainId, String period_name, int id, boolean onlyMentionedRuns){
	DB db = new DB();
	String q = "SELECT runlist FROM ";
	if(id>0){
	    q += "train_run_final_merge WHERE train_id="+trainId+" AND id="+id+";";
	}else if(period_name.length()>0){
	    q += "train_period_runlist WHERE train_id="+trainId+" AND period_name='"+period_name+"' AND activated = true;";
	}else{return "ERROR in getRunlist";}//should never happen

	db.query(q);
	String runlist = "";
	while(db.moveNext()){
	    String this_runlist = db.gets("runlist");
	    if(this_runlist.equals("")) 
		if(onlyMentionedRuns)
		    continue;
		else
		    return "";//this means merge all runno

	    if(runlist.equals("")){
		runlist += this_runlist.replaceAll("\\s", "");
		continue;
	    }
	    StringTokenizer st = new StringTokenizer(this_runlist, ",");
	    String tok = "";

	    while(st.hasMoreTokens()){
		tok = st.nextToken().replaceAll("\\s", "");
		if(!runlist.matches("(^|.*,)" + tok + "($|,.*)")){
		    runlist += ","+tok;
		}
	    }
	}
	return runlist;
    }

    //get runlists sorted in chunks according to their appearance in different runlists
    private static final String getRunlistChunk(int trainId, String period_name, String runlist){
	DB db = new DB("SELECT runlist FROM train_period_runlist WHERE train_id="+trainId+" AND period_name='"+period_name+"'  AND activated = true;");
	int number = db.count();

	//get these runlists
	String lists[] = new String[number];

	int index = 0;
	while(db.moveNext()){
	    lists[index++] = db.gets("runlist").replaceAll("\\s", "");
	}
	
	String return_runlist = "";

	runlist = runlist.replaceAll("\\s", "");

	StringTokenizer st = new StringTokenizer(runlist, ",");
	String tok = "";

	boolean first = true;

	//run over all run numbers and check if runs from later positions in the runlist are always in the same runlists
	while(st.hasMoreTokens()){
	    tok = st.nextToken();

	    //check if this token is already in the return list
	    if(return_runlist.matches("(^|.*,|.*\")" + tok + "($|,.*|\".*)"))
		continue;

	    if(first){
		return_runlist += "\""+tok;
		first = false;
	    }else
		return_runlist += ",\""+tok;

	    boolean contains[] = new boolean[number];
	    for(int i=0; i<number; i++){
		if(lists[i].matches("(^|.*,)" + tok + "($|,.*)"))
		    contains[i]=true;
		else
		    contains[i]=false;
	    }

	    StringTokenizer st2 = new StringTokenizer(runlist, ",");
	    String tok2 = "";

	    while(st2.hasMoreTokens()){
		tok2 = st2.nextToken();
		//tests if this token is already in the return runlist, this is also the case for tok
		if(return_runlist.matches("(^|.*,|.*\")" + tok2 + "($|,.*|\".*)"))
		    continue;

		boolean add = true;

		for(int i=0; i<number; i++){
		    boolean tok2_contained = lists[i].matches("(^|.*,)" + tok2 + "($|,.*)");
		    
		    //exclusive or: one of the two is true the other one false: so they are different
		    if(tok2_contained^contains[i]){
			add = false;
			break;
		    }
		}
		if(add)
		    return_runlist += ","+tok2;
	    }
	    return_runlist += "\"";
	}

	return return_runlist;
    }

    private static final boolean checkDerivedDataSet(int train_id, String period, JspWriter out) throws IOException {
      //if the dataset is a derived dataset, check if the data is still there
      DB db = new DB("SELECT aod, refprod from train_period where train_id="+train_id+" and period_name='"+Format.escSQL(period)+"';");
      if(db.geti("aod")==200){
	  String refprod = db.gets("refprod");
	  int idx_1 = refprod.lastIndexOf("(")+1;
	  int idx_2 = refprod.lastIndexOf(")");
	  String chain_id = refprod.substring(idx_1, idx_2);

	  db.query("select output_deleted from train_run where lpm_id="+chain_id+" limit 1;");
	  if(db.geti("output_deleted")>0){
	      out.println("<script type=text/javascript>alert('The data of this derived dataset has already been deleted. Please chose another dataset.');</script>");
	      return false;
	  }
      }
      return true;
    }
    
    private static final synchronized void startRun(final int trainId, final int runId) throws IOException {
	FileWriter w;

	DB db = new DB("SELECT test_path,run_start,derived_data FROM train_run WHERE train_id="+trainId+" AND id="+runId);
	
	if (!db.moveNext() || db.geti(2)>0){
	    return;
	}
	
	final String sTestDir=db.gets(1);
	final int derived_data = db.geti("derived_data");
	
	// trigger test of remaining wagons if fast test was ran
	db.query("SELECT COUNT(*) FROM train_run_wagon WHERE train_id="+trainId+" AND id="+runId+" AND test_exitcode=2");
	if (db.geti(1) > 0)
	{
	  db.syncUpdateQuery("UPDATE train_run_wagon SET test_exitcode=NULL WHERE train_id="+trainId+" AND id="+runId+" AND test_exitcode=2");
	  w = new FileWriter(basePath+"train-queue/tests/"+System.currentTimeMillis());
	  w.write(sTestDir+"\n");
	  w.flush();
	  w.close();  
	}

	w = new FileWriter(basePath+"train-queue/generator/"+System.currentTimeMillis());
	w.write(sTestDir+"\n");
	w.flush();
	w.close();
	
	String q = "UPDATE train_run SET run_start=extract(epoch from now())::int WHERE train_id="+trainId+" AND id="+runId;
	
	db.syncUpdateQuery(q);
	
	db.query("select wg_no,refprod,aod,period_name from train_def natural inner join train_run natural inner join train_run_period natural inner join train_period where train_id="+trainId+" and id="+runId+" limit 1;");
					   
	final String wg_no = db.gets(1);
	String refprod = db.gets(2);
	final int aod = db.geti(3);
	final String period_name = db.gets(4);

	String runlist = getRunlist(trainId, "", runId, false);//get the runlist from train_run_final_merge
	if (aod == 100)
	   runlist = "1";

	db.syncUpdateQuery("DELETE from train_wagon_period WHERE train_id="+trainId+" AND period_name='"+period_name+"'AND wagon_name IN (SELECT DISTINCT wagon_name FROM train_run_wagon WHERE train_id="+trainId+" AND id="+runId+");");
	
	// now let's insert the lpm entry
	db.query("SELECT max(id) FROM lpm_chain;");
	
	final int lpm_id = db.geti(1)+1;
	
	db.query("select owner,count(1) as cnt from job_types inner join job_runs_details on job_types_id=jt_id inner join job_stats using(pid) where jt_field1='LHC10h(2)' and owner in ('aliprod', 'alidaq') group by owner order by cnt desc;");
	
	String owner = db.gets(1);
	
	int weight = 90;
	if (aod == 0 || aod == 4 || aod == 5 || aod == 6)
	  weight = 45;
	
	String alienUser = "alitrain";
	//if (wg_no.equals("ZZ"))
	//  alienUser = "pwg_cf";
	
	if(aod==200){
	    int idx_1 = refprod.lastIndexOf("(")+1;
	    int idx_2 = refprod.lastIndexOf(")");
	    refprod = "__LPM_"+refprod.substring(idx_1, idx_2)+"__";
	}

	db.syncUpdateQuery("INSERT INTO lpm_chain (id, parentid, jdl, parameters, alienuser, weight, lastrun, maxrun, completion, submitcount, parent_completion_min, constraints, enabled) VALUES ("+
	    lpm_id+", 0, "+
	    "'#.alien.lpm.PWG "+Format.escSQL(wg_no)+" "+Format.escSQL(sTestDir)+" "+Format.escSQL(refprod)+"',"+
	    "'/alice/cern.ch/user/a/alitrain/"+Format.escSQL(sTestDir)+"/lego_train.jdl"+(runlist.length()>0? " "+Format.escSQL(runlist) : "")+"',"+
//	    "'"+Format.escSQL(owner)+"',"+
	    "'"+alienUser+"',"+weight+
	    ", -1, -1, 100, 0, null, null, 0);"
	);
	if(derived_data==1){
	    int new_lpm_id = lpm_id+1;
	    db.syncUpdateQuery("INSERT INTO lpm_chain (id, parentid, jdl, parameters, alienuser, weight, lastrun, maxrun, completion, submitcount, parent_completion_min, constraints, enabled) VALUES ("+
			       new_lpm_id+", "+lpm_id+", "+
			       "'#0', '',"+
			       "'"+alienUser+"',"+weight+
			       ", -1, -1, 100, 0, null, null, 0);"
			       );
	}
	
	db.syncUpdateQuery("UPDATE train_run SET lpm_id="+lpm_id+" WHERE train_id="+trainId+" AND id="+runId);
    }
    
private static final synchronized String startTest(final int trainId, final int runId, final int test_only_full_train, final int splitAll, final int derived_data, final int no_clean_up, final int slow_train_run, JspWriter out) throws IOException {
	StringBuilder sb = new StringBuilder(1024);

	DB db = new DB();

	db.query("SELECT wg_no,train_name,train_debuglevel,excludefiles,additionalpackages,globalvariables,outputfiles FROM train_def WHERE train_id="+trainId);
	DB db2 = new DB("SELECT globalvariables_dataset from train_period where train_id="+trainId+" and period_name=(SELECT period_name from train_run_period where train_id="+trainId+" and id="+runId+");");

	final String train_name = db.gets("train_name");
	String sTestDir = "PWG"+db.gets(1)+"/"+db.gets(2)+"/"+runId+"_"+getDirName();
	final int debuglevel = db.geti(3, 0);
	//~ final String excludefiles = db.gets(4);
	final String additionalpackages = db.gets(5);
	final String outputfiles = db.gets("outputfiles");



	sb.append("class trainconfig:\n");
	
	sb.append("	class mainConfig:\n");
	
	sb.append("		id = "+trainId+"\n");
	sb.append("		debugLevel = "+debuglevel+"\n");	
	sb.append("		name = '"+db.gets("train_name")+"'\n");
	db.query("SELECT outputfiles FROM train_def WHERE train_id="+trainId);
	String outputFiles = "['";
	while (db.moveNext()){
		outputFiles += db.gets(1)+"','";
		
	}	
	outputFiles +="']";
	sb.append("		outputFiles = "+outputFiles+"\n");	
	db.query("SELECT excludefiles FROM train_def WHERE train_id="+trainId);
	String excludefiles = "['";
	while (db.moveNext()){
		excludefiles += db.gets(1)+"','";
		
	}	
	excludefiles +="']";
	sb.append("		excludefiles = "+excludefiles+"\n");	
	sb.append("	class runConfig:\n");
	
	db.query("SELECT ver_aliroot FROM train_run WHERE train_id="+trainId+" and id="+runId);	
	String cmssw_version = db.gets(1);
	db.query("SELECT architecture FROM cmssw_releases WHERE release='"+cmssw_version+"'");
	String arch = db.gets(1);	
	db.query("SELECT path FROM cmssw_releases WHERE release='"+cmssw_version+"'");
	String release_path = db.gets(1);	
	sb.append("		release = '"+cmssw_version+"'\n");
	sb.append("		scramArchitcture = '"+arch+"'\n");
	sb.append("		releasePath = '"+release_path+"'\n");	
	sb.append("		runID = '"+runId+"'\n");	


	db.query("select train_period.* from train_run_period natural inner join train_period where train_id="+trainId+" and id="+runId+";");
	
	String period_name = db.gets("period_name");
	sb.append("		dataSetName = '"+period_name+"'\n");
	
	
	db.query("select train_wagon.*, train_run_wagon.*, train_subwagon.config, train_subwagon.activated from train_run_wagon natural inner join train_wagon left join train_subwagon ON (train_run_wagon.train_id=train_subwagon.train_id AND train_run_wagon.wagon_name=train_subwagon.wagon_name AND train_run_wagon.subwagon_name=train_subwagon.subwagon_name) where train_run_wagon.train_id="+trainId+" and id="+runId+" and (activated=true or activated is NULL) order by length(dependencies), dependencies;");

	
	sb.append("	class wagons:\n");
	while (db.moveNext()){
	    sb.append("		class "+db.gets("wagon_name")+":\n");
	    sb.append("			wagonName = '"+db.gets("wagon_name")+"'\n");
		sb.append("			userName = '"+db.gets("username")+"'\n");
		sb.append("			macroPath = '"+db.gets("macro_path")+"'\n");
		sb.append("			parameters = '"+"--conditions=MCRUN2_72_V0A:All --fast  -n 10 --eventcontent FEVTDEBUGHLT -s GEN,SIM,RECO,EI,HLT:@relval --datatier GEN-SIM-DIGI-RECO --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --magField 38T_PostLS1 --no_exec"+"'\n");		
	    sb.append("			outputFile = '"+db.gets("outputfile")+"'\n");
	    sb.append("			cmsCommand = 'cmsDriver.py'\n");

	}
 
	String dirName = basePath+sTestDir;
	
	File f = new File(dirName+"/config");
	f.mkdirs();
	
	FileWriter w = new FileWriter(dirName+"/config/train_cfg.py");
	w.write(sb.toString());
	w.flush();
	w.close();

	

	
	sb = new StringBuilder(1024);

	//~ out.println("<script type=text/javascript>alert('SELECT architecture FROM cmssw_releases WHERE release="+cmssw_version+"');</script>");

	

	String gen_macro_body = db.gets("gen_macro_body");

	int analyzed_dataset = db.geti("aod");




	
	w = new FileWriter(basePath+"train-queue/tests/"+System.currentTimeMillis());
	w.write(sTestDir+"\n");
	w.flush();
	w.close();
	
	if (train_name.contains("MC"))
	    analyzed_dataset += 256;

	//check if this train is a MC train and set the analyzed_dataset in train_run
	db.query("SELECT count(*) FROM train_handler WHERE train_id="+trainId+" AND enabled=1 AND macro_path LIKE '%AddMCHandler%';");
	if (db.geti(1) > 0)
	    analyzed_dataset += 512;
	
	//get all the used output files
	db.query("select distinct outputfile from train_wagon natural inner join train_run_wagon where train_id="+trainId+" and id="+runId+";");
	String output_file = "";
	while(db.moveNext()){
	   StringTokenizer tokenizer = new StringTokenizer(db.gets("outputfile"),","); 

	   while (tokenizer.hasMoreTokens()) {
	       String token = tokenizer.nextToken();
	       token.replaceAll("\\s", "");

	       if(output_file.matches("(^|.*,)" + token + "($|,.*)"))
		   continue;
	       excludefiles.replaceAll("\\s", "");
	       if(excludefiles.matches("(^|.*,)" + token + "($|,.*)"))
		   continue;

	       if(!output_file.equals(""))
		   output_file +=",";
	       output_file += token;
	   }
	}
	
	String q = "UPDATE train_run SET test_path='"+Format.escSQL(sTestDir)+"',test_start=extract(epoch from now())::int,test_end=null,split_all="+splitAll+",derived_data="+derived_data+",slow_train_run="+slow_train_run+",no_clean_up="+no_clean_up+",analyzed_dataset="+analyzed_dataset+",output_files='"+output_file+"' WHERE train_id="+trainId+" AND id="+runId;
	
	db.syncUpdateQuery(q);

	//if there had been a test before, the entry in train_run_period needs to be deleted
	db.syncUpdateQuery("DELETE FROM train_run_final_merge WHERE train_id="+trainId+" AND id="+runId+";");

	db.query("SELECT list_id, runlist, runlist_name FROM train_period_runlist WHERE train_id="+trainId+" AND period_name='"+period_name+"' AND activated = true ORDER BY list_id;");

	while(db.moveNext()){
	    db2.syncUpdateQuery("INSERT INTO train_run_final_merge(train_id, id, list_id, runlist, runlist_name) VALUES("+trainId+","+runId+","+db.geti("list_id")+",'"+db.gets("runlist")+"', '"+db.gets("runlist_name")+"');");
	}
	
	return sb.toString();
    }

    private static final void getJobStats(final int job_types_id, final String path, final String htmlTag, final Page p, final boolean brief)
    {
      DB db2 = new DB();
      
      db2.query("SELECT sum(cnt),state FROM job_runs_details INNER JOIN job_stats_details USING(pid) WHERE job_types_id="+job_types_id+" AND (outputdir ilike '%"+Format.escSQL(path)+"') GROUP BY state;");
			    
      int done = 0;
      int total = 0;
      int error = 0;
      int active = 0;
      int waiting = 0;
      
      while (db2.moveNext()){
	  int cnt = db2.geti(1);
	  String state = db2.gets(2);
	  
	  if (state.startsWith("DONE"))
	      done += cnt;
	  else
	  if (state.equals("TOTAL"))
	      total = cnt;
	  else
	  if (state.startsWith("E") || state.startsWith("Z") || state.startsWith("FAILED"))
	      error += cnt;
	  else
	  if (state.startsWith("R") || state.startsWith("A") || state.startsWith("S"))
	      active += cnt;
	  else
	      waiting += cnt;
      }
  
      p.modify(htmlTag, "<b>" + total + ((brief) ? "/" : " total, ") +
		    "<font color='green'>" + done + ((brief) ? "</font>/" : " done</font>, ") +
		    "<font color='red'>" + error + ((brief) ? "</font>/" : " error</font>, ") +
		    "<font color='blue'>" + active + ((brief) ? "</font>/" : " active</font>, ") +
		    "<font color='orange'>" + waiting + ((brief) ? "</font></b>" : " waiting</font></b>"));
    }

%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_edit_run.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page(baos, "trains/admin/train_edit_run.res", false);
    p.modify("backend_url", lia.Monitor.monitor.AppConfig.getProperty("trains.admin.backend.url", "http://alitrain.cern.ch"));

    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    int id = rw.geti("id");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    boolean admin = true; //principal.hasRole("admin");

    boolean unprivileged = false;

    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
	
	admin = db.moveNext();
    }

    p.comment("com_admin", admin);

    if (!admin){
	if (submit.length()==0){
	    unprivileged = true;
	    admin = true;
	}
    }

    if (!admin){
	out.println("You are not allowed here");
	return;
    }
    
    if (submit.equals("Delete")){
	// Do not allow to delete runs which have already been submitted
	db.query("SELECT run_start FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
	if (db.geti(1) > 0) {
	  out.println("You are not allowed here");
	  return;
	}

	db.syncUpdateQuery("DELETE FROM train_run_wagon WHERE train_id="+train_id+" AND id="+id);
	db.syncUpdateQuery("DELETE FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
    
	response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#runs");
	return;
    }

    boolean cont = true;

    //change the status of the no_clean_up bin
    if (admin && rw.geti("op")==1){
	db.query("SELECT no_clean_up FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
	int no_clean_up = db.geti("no_clean_up");
	if(no_clean_up==0) no_clean_up=1;
	else no_clean_up=0;
	db.syncUpdateQuery("UPDATE train_run SET no_clean_up="+no_clean_up+" WHERE train_id="+train_id+" AND id="+id+";");
    }

    // do some checks before saving
    if (submit.startsWith("Start test")||submit.startsWith("Start fast test")) {
	
	// check if wagons which are not enabled are selected

	String tmp = "";
	String period= rw.getValues("periods")[0];
	for (String s: rw.getValues("wagons")){

	    db.query("SELECT Count(*) FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(s)+"' AND period_name='"+Format.escSQL(period)+"';");
	    if (db.geti(1) != 1)
		tmp += Format.escSQL(s) + "\\n";
	}
	
	if (tmp.length() > 0)
	{
	  out.println("<script type=text/javascript>alert('You have selected wagon(s) which are not enabled by the user. Testing cannot be started. The wagon(s) in question are:\\n"+tmp+"');</script>");
	  cont = false;
	}
	
	// check if skip processing per run is activated and if it is is allowed for all wagons
	int skip_processing_per_run = rw.geti("splitAll", 0);
	tmp = "";
	if(skip_processing_per_run==1){
	    for (String s: rw.getValues("wagons")){
		db.query("SELECT wagon_no_skip_processing FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(s)+"';");
		if(db.getb("wagon_no_skip_processing"))
		    tmp += Format.escSQL(s) + "\\n";
	    }
	    if(tmp.length() > 0){
		out.println("<script type=text/javascript>alert('You have selected wagon(s) which cannot run with the \"skip processing per run\" option. The wagon(s) in question are:\\n"+tmp+"');</script>");
		cont = false;
	    }


	    db.query("SELECT period_no_skip_processing from train_period where train_id="+train_id+" and period_name='"+period+"';");
	    if(db.getb("period_no_skip_processing")){
		cont = false;
		out.println("<script type=text/javascript>alert('The dataset "+period+" cannot run with the \"skip processing per run\" option.');</script>");
	    }
	}

	// check if one of the wagon_name + subwagon_name combinations exists in the same train run
	String wagon_subwagon_names = "";
	ArrayList<String> subwagon_list = new ArrayList<String>();
	// check for not enabled dependencies
	tmp = "";
	for (String s: rw.getValues("wagons")){
	    db.query("SELECT dependencies FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(s)+"'");
	    StringTokenizer st = new StringTokenizer(db.gets(1),",");
	    while (st.hasMoreTokens()) {
	      String token = st.nextToken();
	      
	      boolean found = false;
	      for (String s2: rw.getValues("wagons")) {
		if (s2.equals(token))
		  found = true;
	      }
	      
	      if (!found)
		tmp += Format.escSQL(s) + " -> " + token + "\\n";
	    }

	    //check if there is a wagon with subwagons which has a combined name which is equal to the name of another wagon
	    db.query("SELECT subwagon_name, activated FROM train_subwagon where train_id="+train_id+" AND wagon_name='"+Format.escSQL(s)+"';");
	    if(db.count()>0)
		while(db.moveNext()){
		    if(db.getb("activated")){
			if(subwagon_list.contains(s+"_"+db.gets("subwagon_name"))){
			    cont = false;
			    out.println("<script type=text/javascript>alert('The wagon "+s+" with configuration "+db.gets("subwagon_name")+" has the same name as another wagon.');</script>");
			}
			subwagon_list.add(s+"_"+db.gets("subwagon_name"));
		    }
		}
	    else{
		if(subwagon_list.contains(s)){
		    cont = false;
		    out.println("<script type=text/javascript>alert('The wagon "+s+" has the same name as another wagon with its configuration.');</script>");
		}
		subwagon_list.add(s);
	    }
	}

	if (tmp.length() > 0)
	{
	  out.println("<script type=text/javascript>alert('The selected wagons have dependencies which are not selected. Testing cannot be started. The wagon(s) in question are:\\n"+tmp+"');</script>");
	  cont = false;
	}

	//check if there is at least one activated handler
	db.query("SELECT Count(*) FROM train_handler WHERE train_id="+train_id+" and enabled=1;");
	if (db.geti(1) == 0)
	{
	  out.println("<script type=text/javascript>alert('There is no handler activated.');</script>");
	  cont = false;
	}

	//check if there is at least one activated period runlist
	db.query("SELECT train_type FROM train_def WHERE train_id="+train_id+";");
	if(db.geti("train_type")==0){
	    db.query("SELECT Count(*) FROM train_period_runlist WHERE train_id="+train_id+" AND period_name='"+period+"' AND activated = true;");
	    if (db.geti(1) == 0){
		out.println("<script type=text/javascript>alert('There is no activated runlist in the dataset.');</script>");
		cont = false;
	    }
	}

	if (!checkDerivedDataSet(train_id, period, out))
	  cont = false;
    }

    if (submit.startsWith("Save") || submit.startsWith("Start test") || submit.startsWith("Start fast test") || submit.startsWith("Clone")){
	boolean clone = submit.startsWith("Clone");
	boolean newEntryCreated = false;

	out.println("<script type=text/javascript>parent.setBookmark('runs');</script>");

	if (id==0 || clone){
	    if (clone && submit.startsWith("Clone & enable wagons")){
		final DB db2 = new DB();
		db.syncUpdateQuery("UPDATE train_period SET enabled=1 WHERE train_id="+train_id+" AND period_name=(SELECT period_name FROM train_run_period WHERE train_id="+train_id+" AND id="+id+");");
		db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT DISTINCT train_id, wagon_name, period_name FROM train_run_wagon as trw NATURAL JOIN train_run_period as trp WHERE train_id="+train_id+" AND id="+id+" AND trw.wagon_name!='__ALL__' AND trw.wagon_name!='__BASELINE__' AND trp.period_name NOT IN (SELECT period_name FROM train_wagon_period where train_id="+train_id+" AND wagon_name=trw.wagon_name);");
	    }
	    db.query("SELECT max(id) FROM train_run WHERE train_id="+train_id);
	    
	    id = db.geti(1)+1;
	    
	    db.syncUpdateQuery("INSERT INTO train_run (train_id, id, ver_aliroot, comment) VALUES ("+train_id+", "+id+", '"+Format.escSQL(rw.gets("ver_aliroot"))+"','"+Format.escSQL(rw.gets("comment"))+"');");
	    newEntryCreated = true;
	}
	else{
	    db.syncUpdateQuery("UPDATE train_run SET ver_aliroot='"+Format.escSQL(rw.gets("ver_aliroot"))+"', comment='"+Format.escSQL(rw.gets("comment"))+"' WHERE train_id="+train_id+" AND id="+id);
	}
	
	db.syncUpdateQuery("DELETE FROM train_run_period WHERE train_id="+train_id+" AND id="+id);
	db.syncUpdateQuery("DELETE FROM train_run_wagon WHERE train_id="+train_id+" AND id="+id);
    
	for (String s: rw.getValues("wagons")){
	    final DB db2 = new DB();
	    String test_exitcode = "NULL";
	    if(submit.startsWith("Start fast test"))
		test_exitcode = "2";
	    db2.query("SELECT subwagon_name, activated FROM train_subwagon where train_id="+train_id+" AND wagon_name='"+Format.escSQL(s)+"';");
	    if(db2.count()>0)
		while(db2.moveNext()){
		    if(db2.getb("activated"))
			db.syncUpdateQuery("INSERT INTO train_run_wagon (train_id, id, wagon_name, subwagon_name, test_exitcode) VALUES ("+train_id+", "+id+", '"+Format.escSQL(s)+"', '"+db2.gets("subwagon_name")+"', "+test_exitcode+");");
		}
	    else
		db.syncUpdateQuery("INSERT INTO train_run_wagon (train_id, id, wagon_name, subwagon_name, test_exitcode) VALUES ("+train_id+", "+id+", '"+Format.escSQL(s)+"', '', "+test_exitcode+");");//sets subwagon_name to an empty string which will result in no difference to the old wagons without subwagon_names
	}
	
	db.syncUpdateQuery("INSERT INTO train_run_wagon (train_id, id, wagon_name) VALUES ("+train_id+", "+id+", '__ALL__');");
	db.syncUpdateQuery("INSERT INTO train_run_wagon (train_id, id, wagon_name) VALUES ("+train_id+", "+id+", '__BASELINE__');");

	db.syncUpdateQuery("INSERT INTO train_run_period (train_id, id, period_name) VALUES ("+train_id+", "+id+", '"+rw.getValues("periods")[0]+"');");
	    
	String q = "UPDATE train_run SET test_path=null,test_start=null,test_end=null,operator_created='"+principal.getName()+"',split_all="+rw.geti("splitAll", 0)+",derived_data="+rw.geti("derived_data", 0)+",no_clean_up="+rw.geti("no_clean_up", 0)+" WHERE train_id="+train_id+" AND id="+id;
	db.syncUpdateQuery(q);
	
	if (cont) {
	    if (submit.startsWith("Start test")||submit.startsWith("Start fast test")){
		int start_fast_test = 0;
		if(submit.startsWith("Start fast test"))
		    start_fast_test = 1;

		startTest(train_id, id, start_fast_test, rw.geti("splitAll", 0), rw.geti("derived_data", 0), rw.geti("no_clean_up", 0), rw.geti("slow_run", 0),out);

		if (newEntryCreated)
		  out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
	    }
	    else{
		out.println("<script type=text/javascript>parent.modify()</script>");
		return;
	    }
	}
    }
    else if (submit.startsWith("Stop test"))
    {
      db.query("SELECT test_path FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
      
      final String sTestDir = db.gets(1);
      
      FileWriter w;
      w = new FileWriter(basePath+sTestDir+"/abort_test");
      w.write("\n");
      w.flush();
      w.close();
    }
    else if (submit.startsWith("Update only comment field"))
    {
      db.syncUpdateQuery("UPDATE train_run SET comment='"+Format.escSQL(rw.gets("comment"))+"' WHERE train_id="+train_id+" AND id="+id);
      out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
    }
    else
    if (submit.startsWith("Start running")){
    
	boolean canStart = checkDerivedDataSet(train_id, rw.getValues("periods")[0], out);

	//check if the dataset is still existing (could have been deleted or renamend in the meantime)
	db.query("SELECT Count(*) FROM train_run_period NATURAL INNER JOIN train_period WHERE train_id="+train_id+" AND id="+id+";");
	if(db.geti(1)==0){
	    out.println("<script type=text/javascript>alert('The dataset does not exist anymore.');</script>");
	    canStart = false;
	}

	if (id>0 && canStart){
	    startRun(train_id, id);
	    db.syncUpdateQuery("UPDATE train_run SET operator_created='"+principal.getName()+"' WHERE train_id="+train_id+" AND id="+id);
	}
    }
    else
    if (submit.startsWith("Mail test results")){
	db.query("SELECT DISTINCT username, test_path FROM train_run_wagon NATURAL INNER JOIN train_wagon NATURAL INNER JOIN train_run WHERE train_id = "+train_id+" AND id = "+id+" AND test_exitcode = 1;");
    
	String users = "";
	while (db.moveNext()){
	  String username = db.gets(1);

	  sendMail("Train test failed", "Dear train user,\n\nYour wagon has been tested for running in the train and unfortunately failed. Please have a look at the log file output on https://alimonitor.cern.ch/trains/train.jsp?train_id="+train_id+", train run "+id+".\n\nYou can find the test output at "+lia.Monitor.monitor.AppConfig.getProperty("trains.admin.backend.url", "http://alitrain.cern.ch")+"/train-workdir/"+db.gets("test_path")+"/test.\n\nPlease fix the wagon configuration or commit needed changes to the code. If needed inform the train operator.\n\nTwiki: https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains\n\nBest regards,\nThe LEGO framework\n", principal.getName(), username);

	  users += username + ",";
	}

	out.println("<script type=text/javascript>alert('A mail has been sent to the users whose wagons failed ("+users+"). You are in CC.')</script>");
    }
    else
    if (submit.startsWith("Mail train status")){
	db.query("SELECT test_path FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
	String sTestPath = db.gets(1);

	db.query("SELECT DISTINCT username FROM train_run_wagon NATURAL INNER JOIN train_wagon WHERE train_id = "+train_id+" AND id = "+id+";");

	String users = "";
	while (db.moveNext()){
	  String username = db.gets(1);
	  
	  sendMail("Train is on the way", "Dear train user,\n\nYour wagon has been included in the train. You can check the status on https://alimonitor.cern.ch/trains/train.jsp?train_id="+train_id+", train run "+id+".\n\nYou can check the progress of the train by clicking 'processing status'; the merging status by clicking 'merging status'. The output files merged per run appear in:\n<RUNDIR>/"+sTestPath+"\n\nOnce the final merge job is on the way you can see the link 'merged files in FC' where the merged output will appear:\n/alice/cern.ch/user/a/alitrain/"+sTestPath+"/merge\n\nTwiki: https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains\n\nBest regards,\nThe LEGO framework\n", principal.getName(), username);
	  users += username + ",";
	}

	out.println("<script type=text/javascript>alert('A mail has been sent to the users who participate in the train ("+users+"). You are in CC.')</script>");
    }
    
    // ------------------------ content
    
    String sAliroot = null;

    p.comment("com_run_status", false);
    p.comment("com_test_status", false);
    p.comment("com_results", false);
    p.comment("com_show_clone", false);
    p.comment("com_run", false);
    p.comment("com_kill", false);
    p.comment("com_email_test", false);
    p.comment("com_email_run", false);
    p.comment("com_stoptest", false);
    p.comment("com_show_no_clean_up", false);
    p.comment("com_show_slow_run", false);

    if (id > 0){
	trains.UpdateTestStatus.update(train_id, id);
    
	db.query("SELECT wg_no, train_type FROM train_def WHERE train_id="+train_id);
	p.fillFromDB(db);
	final boolean mc_gen = (db.geti("train_type") == 1);
	p.comment("com_mc_gen", mc_gen);
  
 	db.query("SELECT * FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
    
	sAliroot = db.gets("ver_aliroot");
    
	p.fillFromDB(db);

	final int final_merge_job_id = db.geti("final_merge_job_id");

	if (db.geti("test_start")==0){
	    p.comment("com_edit", true);
	    p.comment("com_kill", false);
	    p.comment("com_results", false);
	    
	    p.modify("status", "Testing was not started yet");
	}
	else{
	    p.comment("com_results", true);
	    p.comment("com_test_status", true);
	
	    p.comment("com_edit", db.geti("test_end")>0 && db.geti("run_start")==0);
	    
	    p.modify("gogconfirm_condition", "true");
	    
	    p.comment("com_show_clone", true);

	    String sTestPath = db.gets("test_path");
	    
	    if (db.geti("test_end")==0){
		// test is still running, nothing to do
		p.comment("com_stoptest", true);
	    }
	    else
    	    if (db.geti("run_start")==0){
		p.comment("com_email_test", true);
    		// some test was generated, we can start running now
		p.comment("com_run", true);
	    }
	    else{
		// running has started, to pause or stop we'll have to look in the respective LPM entry
		p.modify("reload", "var autoReloadTimeout = setTimeout('reload()', 600000);");

		if (db.geti("output_deleted")>0){
		    p.comment("com_deleted", true);
		}
		else{
		    p.comment("com_deleted", false);
		}

		p.comment("com_run_status", true);
		p.comment("com_email_run", true);
		if (new File(basePath+sTestPath+"/train_killed").exists())
		    p.comment("com_kill", false);
		else
		    p.comment("com_kill", true);

		//show only information about the final merging if there is any final merge job
		DB db2 = new DB("SELECT Count(final_merge_job_id) FROM train_run_final_merge WHERE train_id="+train_id+" AND id="+id+" AND final_merge_job_id IS NOT NULL");
		int number_final_merge = db2.geti(1);
		p.comment("com_final_merge", (number_final_merge == 0) ? true : false);
		p.comment("com_final_merge_job", (number_final_merge > 0) ? true : false);

		db2.query("SELECT run_start, output_deleted, derived_data, slow_train_run from train_run WHERE train_id="+train_id+" AND train_run.id="+id+";");
		//check if run is started and data isn't already deleted
		p.comment("com_show_no_clean_up", db2.geti("run_start")>0 && db2.geti("output_deleted")==0 && db2.geti("derived_data")==1);

		db2.query("SELECT run_start, train_finished_timestamp FROM train_run WHERE train_id="+train_id+" AND id="+id);
		p.modify("run_start_ago", Format.toInterval(System.currentTimeMillis() - db2.geti(1)*1000L));
		p.comment("com_train_finished", (db2.geti(2) > 0));
		p.modify("train_finished_timestamp_ago", Format.toInterval(db2.geti(2)*1000L - db2.geti(1)*1000L));

		db2.query("SELECT lpm_id FROM train_run WHERE train_id="+train_id+" AND id="+id);
		
		if (new File(basePath+sTestPath+"/files_generated").exists())
		  p.modify("copying_stats", "<font color=green>Files copied to the Grid successfully</font>");
		else if (new File(basePath+sTestPath+"/files_copying_failure").exists())
		  p.modify("copying_stats", "<font color=red>Copying of files to the Grid failed</font>");
		else
		  p.modify("copying_stats", "<font color=orange>Files not yet copied</font>");
		
		int lpm_id = db2.geti(1);
		if (lpm_id > 0)
		{
		    db2.query("SELECT * FROM lpm_chain WHERE id="+lpm_id);
		    
		    p.modify("lpm_submitted", db2.geti("submitcount"));
		    if (db2.geti("submitcount") <= 1) // no final merge button if less than 2 masterjobs
		      p.comment("com_final_merge", false);
		      
		    p.modify("lpm_lastrun", db2.geti("lastrun"));
		    
		    if (db2.geti("enabled")==1){
			p.modify("lpm_status", "<font color=green>Submitting enabled</font>");
		    }
		    else{
			String status = "<font color=blue>All jobs submitted</font>";
			db2.query("SELECT Count(*) FROM train_run WHERE train_finished_timestamp IS NOT NULL AND train_id="+train_id+" AND id="+id+";");
			if (db2.geti(1)>0)
			    status = "<font color=green>Train finished</font>";
			else if (!(new File(basePath+sTestPath+"/files_generated").exists()))
			    status = "<font color=orange>Waiting for files to be copied</font>";
			else if (new File(basePath+sTestPath+"/train_killed").exists())
			    status = "<font color=red>Train killed by operator</font>";

			p.modify("lpm_status", status);
		    }
		
		    db2.query("SELECT job_types_id,jt_field1 FROM lpm_history NATURAL INNER JOIN job_runs_details INNER JOIN job_types ON jt_id=job_types_id WHERE chain_id="+lpm_id+" LIMIT 1;");

		    if (db2.geti(1) > 0)
		    {
			int job_types_id = db2.geti(1);
		    
			p.comment("com_run_links", true);
			p.modify("job_types_id", job_types_id);
			p.modify("jt_field1", db2.gets(2));
			
			String job_type = db2.gets(2);
			
			db2.query("SELECT jt_id,jt_field1 FROM job_types WHERE jt_field1='"+job_type+"_Stage5_FinalMerging';");
			getJobStats(db2.geti(1), sTestPath + ((mc_gen) ? "%" : ""), "merging5_jobstats", p, false);
			p.modify("final_merging_job_types_id", db2.geti(1));
			
			db2.query("SELECT jt_id,jt_field1 from job_types WHERE jt_field1='"+job_type+"_Stage1_Merging';");
			getJobStats(db2.geti(1), sTestPath + ((mc_gen) ? "%" : "/Stage_1"), "merging1_jobstats", p, true);
			p.modify("merging1_job_types_id", db2.geti(1));

			db2.query("SELECT jt_id,jt_field1 from job_types WHERE jt_field1='"+job_type+"_Stage2_Merging';");
			getJobStats(db2.geti(1), sTestPath + ((mc_gen) ? "%" : "/Stage_2"), "merging2_jobstats", p, true);
			p.modify("merging2_job_types_id", db2.geti(1));

			db2.query("SELECT jt_id,jt_field1 from job_types WHERE jt_field1='"+job_type+"_Stage3_Merging';");
			getJobStats(db2.geti(1), sTestPath + ((mc_gen) ? "%" : "/Stage_3"), "merging3_jobstats", p, true);
			p.modify("merging3_job_types_id", db2.geti(1));

			db2.query("SELECT jt_id,jt_field1 from job_types WHERE jt_field1='"+job_type+"_Stage4_Merging';");
			getJobStats(db2.geti(1), sTestPath + ((mc_gen) ? "%" : "/Stage_4"), "merging4_jobstats", p, true);
			p.modify("merging4_job_types_id", db2.geti(1));
			
			//db2.query("SELECT * FROM job_runs_details INNER JOIN job_stats USING(pid) LEFT OUTER JOIN job_events USING(pid) WHERE job_types_id="+job_types_id+" AND (outputdir ilike '%"+Format.escSQL(sTestPath)+"%') ORDER BY runno DESC, pid DESC;");
			getJobStats(job_types_id, sTestPath + ((mc_gen) ? "%" : ""), "processing_jobstats", p, false);
		    }
		    else
			p.comment("com_run_links", false);
		}
		else
		    p.comment("com_run_links", false);
	    }
	    
	    
	    final boolean bReallyStarted = new File(basePath+sTestPath+"/test_started").exists() || db.geti("test_end")>0;
	    
	    if (!bReallyStarted){
		p.modify("test_status", "Queued");
		
		p.modify("reload", "var autoReloadTimeout = setTimeout('reload()', 10000);");
	    }
	    else{
		if (db.geti("test_end")>0){
		    String statusText = "Finished";
		    if (new File(basePath+sTestPath+"/abort_test").exists())
		      statusText = "Aborted";
		    
		    statusText += " ("+Format.toInterval((db.geti("test_end") - db.geti("test_start"))*1000L)+" total time)";
		    
		    p.modify("test_status", statusText);
		}
		else{
		    String statusText = "Started "+Format.toInterval(System.currentTimeMillis() - db.geti("test_start")*1000L)+" ago";
		    if (new File(basePath+sTestPath+"/downloading_input_files").exists())
		      statusText += ". Downloading input files...";
		      
		    if (new File(basePath+sTestPath+"/abort_test").exists())
		    {
		      statusText = statusText + ". Aborting...";
		      p.comment("com_email_test", false);
		    }
		      
		    p.modify("test_status", statusText);
		    
		    p.modify("reload", "var autoReloadTimeout = setTimeout('reload()', 10000);");
		}
	    }
	    
	    db.query("SELECT *,test_cpu_time*1000 AS cpu_per_event,test_wall_time*1000 AS wall_per_event FROM train_run_wagon LEFT OUTER JOIN train_wagon USING(train_id, wagon_name) WHERE train_id="+train_id+" AND id="+id+" ORDER BY wagon_name='__ALL__',wagon_name!='__BASELINE__',dependencies IS NOT NULL,length(dependencies) asc, lower(dependencies) asc,lower(wagon_name) asc;");

	    Page pLine = new Page("trains/admin/train_edit_run_line.res", false);	

	    Map<String, Map<String, Double>> memoryMap = new HashMap<String, Map<String, Double>>();

	    final String[] deltas = new String[]{"test_mem_rss", "test_mem_virt", "test_mem_rss_max", "test_mem_virt_max", "test_cpu_time", "test_wall_time", "cpu_per_event", "wall_per_event", "test_mem_rss_slope", "test_mem_virt_slope"};

	    boolean allOk = true;

	    while (db.moveNext()){
		pLine.comment("com_show_trainfiles", false);
		pLine.comment("com_std_toBig", false);//stdout + stderr are smaller than 1MB
		pLine.comment("com_mem_virt_toBig", false);//maximum virtual memory is smaller than 2.0 GB or not Full Train Test
		pLine.comment("com_mem_rss_toBig", false);//maximum resident memory is smaller than 2.0 GB or not Full Train Test
		pLine.comment("com_mem_virt_slope_toBig", false);//virtual slope is smaller than 0.01MB 
		pLine.comment("com_mem_rss_slope_toBig", false);//resident slope is smaller than 0.01MB 
		pLine.modify("backend_url", lia.Monitor.monitor.AppConfig.getProperty("trains.admin.backend.url", "http://alitrain.cern.ch"));

		pLine.fillFromDB(db);
		pLine.modify("test_path", sTestPath);
		
		String sNiceName = db.gets("wagon_name");
		if(db.gets("subwagon_name").length()>0)
		    sNiceName += "_"+db.gets("subwagon_name");
		pLine.append("nice_wagon_name", sNiceName);

		final Map<String, Double> testMemory = new HashMap<String, Double>();
		
		for (final String delta: deltas){
		    testMemory.put(delta, db.getd(delta));
		    
		    if (delta.endsWith("_slope") && db.getd(delta)>0)
			pLine.modify(delta+"_sign", "+");
		}
		
		final StringTokenizer st = new StringTokenizer("__BASELINE__,"+db.gets("dependencies"), ",; \t\r\n");

		final Map<String, Double> deltaMemory = new HashMap<String, Double>(testMemory);
		
		while (st.hasMoreTokens()){
		    final String tok = st.nextToken();
		
		    final Map<String, Double> ref = memoryMap.get(tok);
		    
		    if (ref!=null){
			for (final String delta: deltas){
			    double d = Math.min(testMemory.get(delta).doubleValue() - ref.get(delta).doubleValue(), deltaMemory.get(delta).doubleValue());
			    
			    deltaMemory.put(delta, d);
			}
		    }
		}

		memoryMap.put(sNiceName, testMemory);
		String sNiceName_config = sNiceName;

		File mergeNoFile = new File(basePath+sTestPath+"/test/"+sNiceName+"/mergeNoFile");
		File mergeFile = new File(basePath+sTestPath+"/test/"+sNiceName+"/merge_test/lego_train_merge.sh");
		File mergefinished = new File(basePath+sTestPath+"/test/"+sNiceName+"/merge_test/validated");
		File testfinished = new File(basePath+sTestPath+"/test/"+sNiceName+"/syswatch.stats");

		if(mergeNoFile.isFile()){
		    pLine.comment("com_show_merge_link", false);

		    if(sNiceName.equals("__ALL__")){
			pLine.modify("merging", "<font color=red>No<br>output</font>");
			allOk = false;
		    }else
			pLine.modify("merging", "<font color=blue>No<br>output</font>");

		}else if(!mergeFile.isFile()){
		    pLine.modify("merging", "<font color=blue>Not<br>tested</font>");
		    pLine.comment("com_show_merge_link", false);
		}else if(mergefinished.isFile()){
		    pLine.modify("merging", "<font color=green>OK</font>");
		    pLine.comment("com_show_merge_link", true);
		}else if(testfinished.isFile()){
		    pLine.modify("merging", "<font color=red>Failed</font>");
		    pLine.comment("com_show_merge_link", true);
		    allOk = false;
		}else{
		    pLine.modify("merging", "Queued");
		    pLine.comment("com_show_merge_link", false);
		    allOk = false;
		}
		
		if (sNiceName.equals("__ALL__"))
		    sNiceName = "Full train";
		else
		    if (sNiceName.equals("__BASELINE__")){
			sNiceName = "Base line";
			pLine.comment("com_hide_delta", false);
		    }
		
		pLine.modify("wagon_name_nice", sNiceName);
		
		int defaultStatus = -2;	// queued;
		
		if (bReallyStarted){
		    File fWagonDir = new File(basePath+sTestPath+"/test/"+sNiceName_config);
		    
		    if (fWagonDir.exists() && fWagonDir.isDirectory())
			defaultStatus = -1;
		}
		
		final int code = db.geti("test_exitcode", defaultStatus);

		if (code==0 && deltaMemory.size()>0){
	    	    for (final String delta: deltas){
			pLine.modify(delta+"_delta", deltaMemory.get(delta));
			
			if (delta.endsWith("_slope") && deltaMemory.get(delta).doubleValue()>0)
			    pLine.modify(delta+"_delta_sign", "+");
		    }
		}

		if(deltaMemory.get("test_mem_virt_slope")>0.05){
		    pLine.comment("com_mem_virt_slope_toBig", true);
		    pLine.modify("color_mem_virt_slope_toBig","red");
		}else if(deltaMemory.get("test_mem_virt_slope")>0.01){
		    pLine.comment("com_mem_virt_slope_toBig", true);
		    pLine.modify("color_mem_virt_slope_toBig","orange");
		}
		if(deltaMemory.get("test_mem_rss_slope")>0.05){
		    pLine.comment("com_mem_rss_slope_toBig", true);
		    pLine.modify("color_mem_rss_slope_toBig","red");
		}else if(deltaMemory.get("test_mem_rss_slope")>0.01){
		    pLine.comment("com_mem_rss_slope_toBig", true);
		    pLine.modify("color_mem_rss_slope_toBig","orange");
		}
		
		if (code==0 && db.getd("test_wall_time")>0){
		    double eff = 100 * db.getd("test_cpu_time") / db.getd("test_wall_time");
		    
		    pLine.modify("cpu_eff", Format.point(eff)+"%");
		}
		
		switch (code){
		    case -2: pLine.modify("status", "Queued"); allOk = false; break;
		    case -1: pLine.modify("status", "<font color=blue>Running</font>"); allOk = false; break;
		    case  0: pLine.modify("status", "<font color=green>OK</font>"); break;
		    case  1: pLine.modify("status", "<font color=red>Failed</font>"); allOk = false; break;
		    case  2: pLine.modify("status", "<font color=blue>Skipped</font>"); break;
		}
		
		pLine.comment("com_show_status", code>=0 && code!=2);
		pLine.comment("com_show_logfiles", code>=-1 && code!=2);
		
		//output file size
		
		DB db2 = new DB();

		if(!db.gets("wagon_name").equals("__ALL__")){
		    db2.query("SELECT outputfile from train_wagon where train_id="+train_id+" and wagon_name='"+db.gets("wagon_name")+"';");
		}else{
		    int test_mem_virt_max = db.geti("test_mem_rss_max");
		    if(test_mem_virt_max>2.5*1024){
			pLine.comment("com_mem_virt_toBig", true);//maximum virtual memory are smaller than 2.5 GB
			pLine.modify("color_mem_virt_toBig","red");
		    }else if(test_mem_virt_max>2.0*1024){
			pLine.comment("com_mem_virt_toBig", true);//maximum virtual memory are smaller than 2.5 GB
			pLine.modify("color_mem_virt_toBig","orange");
		    }
		    int test_mem_rss_max = db.geti("test_mem_rss_max");
		    if(test_mem_rss_max>2.5*1024){
			pLine.comment("com_mem_rss_toBig", true);//maximum virtual memory are smaller than 2.5 GB
			pLine.modify("color_mem_rss_toBig","red");
		    }else if(test_mem_rss_max>2.0*1024){
			pLine.comment("com_mem_rss_toBig", true);//maximum virtual memory are smaller than 2.5 GB
			pLine.modify("color_mem_rss_toBig","orange");
		    }

		    db2.query("SELECT outputfiles from train_def where train_id="+train_id+";");   
		}
		
		final StringTokenizer output_st = new StringTokenizer(db2.gets(1),",");
		long outputsize=0;
		
		while (output_st.hasMoreTokens()){
		    final String tok = output_st.nextToken();
		    File file = new File(basePath+sTestPath+"/test/"+sNiceName_config+"/"+tok);
		    outputsize+=file.length();
		}
		pLine.append("output_file_size",outputsize);
		long outputsize_std=0;
		File file_stdout = new File(basePath+sTestPath+"/test/"+sNiceName_config+"/stdout");
		File file_stderr = new File(basePath+sTestPath+"/test/"+sNiceName_config+"/stderr");
		outputsize_std+=file_stdout.length()+file_stderr.length();
		if(outputsize_std>Math.pow(1024,2))//checkk if stdout + sterr are bigger than 1 MB
		    pLine.comment("com_std_toBig", true);
		pLine.append("output_std_size",outputsize_std);
		
		p.append(pLine); 
	    }

	    //check if the Train Files are generated
	    pLine.modify("backend_url", lia.Monitor.monitor.AppConfig.getProperty("trains.admin.backend.url", "http://alitrain.cern.ch"));

	    pLine.modify("wagon_name_nice", "Train file generation");
	    pLine.modify("test_path", sTestPath);

	    File file = new File(basePath+sTestPath+"/__TRAIN__/");
	    File finished = new File(basePath+sTestPath+"/test_finished");

	    if(!finished.isFile()){
		pLine.modify("status", "Queued");
		pLine.comment("com_show_trainfiles", false);
		allOk = false;
	    }else if(file.isDirectory()){
		pLine.modify("status", "<font color=green>OK</font>");
		pLine.modify("generation_dir", "__TRAIN__");
		pLine.comment("com_show_trainfiles", true);
		pLine.comment("com_show_trainfiles_output", true);
	    }else{
		allOk = false;
		File aborted = new File(basePath+sTestPath+"/aborted.test");
		if(aborted.isFile()){
		    pLine.modify("status", "Queued");
		    pLine.comment("com_show_trainfiles", false);
		}else{
		    pLine.modify("status", "<font color=red>Failed</font>");
		    pLine.modify("generation_dir", "config");
		    pLine.comment("com_show_trainfiles", true);
		    pLine.comment("com_show_trainfiles_output", false);
		}
	    }

	    pLine.comment("com_show_status", false);
	    pLine.comment("com_show_logfiles", false);
	    p.append(pLine);

	    //information about the number of test files
	    db.query("SELECT test_events, test_exitcode FROM train_run_wagon WHERE train_id="+train_id+" AND id="+id+" and wagon_name='__ALL__';");
	    int test_exitcode = db.geti("test_exitcode");

	    int test_events = db.geti("test_events");
	    db.query("SELECT pp, exists(SELECT 1 FROM train_period WHERE train_id=tp.train_id AND period_name=tp.period_name), exists(SELECT 1 FROM train_run WHERE train_id=tp.train_id AND id="+id+" and test_end>0) FROM train_period as tp NATURAL JOIN train_run_period WHERE train_id="+train_id+" AND id="+id+";");
	    if(db.getb(2) && db.getb(3) && test_exitcode==0){
		boolean isPP = db.getb("pp");
		int test_minEvents = 500;
		if(isPP) test_minEvents *= 10;
		
		if(test_events<test_minEvents) {
	            if (test_events < 100)
		        p.append("numberTestEvents", "<font color='red'> Used less than 100 test events. Please use at least "+test_minEvents+" test events. <br> You can increase the number of events by increasing <i>the number of files to test</i> in the dataset.</font>");		    
		    else
		        p.append("numberTestEvents", "<font color='red'> Used about "+test_events+" test events. Please use at least "+test_minEvents+" test events. <br> You can increase the number of events by increasing <i>the number of files to test</i> in the dataset.</font>");

		} else
		    p.append("numberTestEvents", " Used "+test_events+" test events. ");
		p.comment("com_show_test_events", true);
	    }else
		p.comment("com_show_test_events", false);

	    if (!allOk){
		p.comment("com_run", false);
	    }

	    db.query("SELECT max(list_id) FROM train_run_final_merge WHERE train_id="+train_id+" AND id="+id+";");
	    int max_list_id = db.geti(1);
	    if(max_list_id==1) p.append("merge_dir", "/merge");

	    db.query("SELECT final_merge_job_id, list_id, runlist, test_path, runlist_name FROM train_run_final_merge natural join train_run WHERE train_id="+train_id+" AND id="+id+" ORDER BY list_id;");
	    while(db.moveNext()){
		Page pFinalMerge = new Page("trains/admin/train_edit_run_finalMerging.res", false);
		pFinalMerge.fillFromDB(db);
		pFinalMerge.append("name_runlist", db.gets("runlist_name").length() > 0 ? db.gets("runlist_name") : db.gets("list_id"));
		if(max_list_id>1) pFinalMerge.append("merge_dir", "_runlist_"+db.geti("list_id"));

		pFinalMerge.comment("com_error_submitting", true);
		if (db.geti("final_merge_job_id") > 0) {
		    DB db2 = new DB("SELECT pid,jobtype,status FROM lpm_history INNER JOIN job_runs_details USING(pid) WHERE pid="+db.geti("final_merge_job_id")+";");
		    
		    int childpid = 0;
		    String subjobcomment = null;
		    int subjobstatus = -1;
		
		    while (db2.moveNext()){
			childpid = db2.geti(1);
			subjobcomment = db2.gets(2);
			subjobstatus = db2.geti(3);
		    
			db2.query("SELECT pid,jobtype,status FROM lpm_history INNER JOIN job_runs_details USING(pid) WHERE parentpid="+childpid);
		    }
		
		    if (subjobcomment != null){
			System.err.println("Comment: "+subjobcomment);
			int idx = subjobcomment.indexOf("_Stage");
			    
			pFinalMerge.modify("final_merge_stage", subjobcomment.substring(idx+6, idx+7));
			pFinalMerge.modify("final_merge_stage_status", subjobstatus==2 ? "green" : "blue");
			pFinalMerge.modify("final_merge_last_id", childpid);
			pFinalMerge.comment("com_error_submitting", false);
		    }		
		} 
		p.append("final_merging_runlists", pFinalMerge);
	    }
	}
    }
    else {
	p.modify("train_id", train_id);
	
	p.comment("com_edit", true);
	p.comment("com_show_no_clean_up", false);
	p.comment("com_show_slow_run", false);
	p.comment("com_run", false);
	p.comment("com_kill", false);
	p.comment("com_results", false);	
	p.comment("com_test_status", false);
	p.comment("com_run_status", false);

	//if start new train put the operator who clicked here as the created operator
	p.modify("operator_created", principal.getName());
    }

    if (unprivileged){
	p.comment("com_edit", false);
	p.comment("com_run", false);
	p.comment("com_kill", false);
	p.comment("com_show_clone", false);
	p.comment("com_final_merge", false);
	p.comment("com_email_run", false);
	p.comment("com_email_test", false);
	p.comment("com_show_update_comment", false);
	p.comment("com_improvements", false);
    }

    p.modify("confirm_condition", "false");


    db.query("SELECT release FROM cmssw_releases WHERE release LIKE 'CMSSW_%' ORDER BY 1 DESC;");
    while (db.moveNext()){
	final String s = db.gets(1);
	p.append("opt_aliroot_ver", "<option value='"+Format.escHtml(s)+"' "+(s.equals(sAliroot) ? "selected" : "")+">"+Format.escHtml(s)+"</option>");
    }
    //~ p.append("opt_aliroot_ver", "<option>CMSSW_5_3_8_patch3"+"</option>");
    //~ p.append("opt_aliroot_ver", "<option>CMSSW_5_3_8_patch3"+"</option>");

/*
    final List<String> packageList = new ArrayList<String>(alien.catalogue.PackageUtils.getPackageNames());
    
    Collections.sort(packageList);
    Collections.reverse(packageList);
    
    for (final String packageName: packageList){
	if (packageName.startsWith("VO_ALICE@AliRoot::")){
	    p.append("opt_aliroot_ver", "<option value='"+Format.escHtml(packageName)+"' "+(packageName.equals(sAliroot) ? "selected" : "")+">"+Format.escHtml(packageName)+"</option>");
        }
    }
*/
    String selected_period_name="";
    if(id>0){
	//get period_name which was used the last time
	db.query("SELECT period_name, exists(select 1 FROM train_period WHERE train_id=trp.train_id AND period_name=trp.period_name AND enabled=1) FROM train_run_period trp WHERE train_id="+train_id+" AND id="+id+";");
	selected_period_name = db.gets(1);
	if(db.getb(2)==false)
	    p.append("opt_periods", "<option value='"+Format.escHtml(db.gets(1))+"' "+(db.gets(1).equals(selected_period_name) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
	p.append("periods_not_edit", "<input type=hidden name=periods value='"+Format.escHtml(db.gets(1))+"'>"+Format.escHtml(db.gets(1))+"<br>");
    }

    db.query("SELECT period_name, aod FROM train_period WHERE train_id="+train_id+" AND enabled=1 ORDER BY lower(period_name);");

    // in submitStr the period_names with their correspondent activated wagons and wagons which were used before in this train run are saved
    // also the wagons of the chosen period are displayed
    String submitStr ="";
    while (db.moveNext()){
        if (selected_period_name == "")
	    selected_period_name = db.gets(1);
	p.append("opt_periods", "<option value='"+Format.escHtml(db.gets(1))+"' "+(db.gets(1).equals(selected_period_name) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
	submitStr += db.gets(1)+","+db.geti("aod");
	DB db2 = new DB();
	db2.query("SELECT wagon_name, exists(select 1 FROM train_run_wagon WHERE train_id=t.train_id AND wagon_name=t.wagon_name AND id="+id+") FROM train_wagon_period t WHERE train_id="+train_id+" AND period_name='"+db.gets(1)+"';");
	while (db2.moveNext()){
	    submitStr += ",";
	    submitStr += db2.gets(1);
	    if(db.gets("period_name").equals(selected_period_name)){
		p.append("opt_wagons", "<option value='"+Format.escHtml(db2.gets(1))+"' "+((id==0||db2.getb(2,false)) ? "selected" : "")+">"+Format.escHtml(db2.gets(1))+"</option>");
	    }
	}
	submitStr += ";";
	if(id>0){
	    db2.query("SELECT distinct wagon_name FROM train_run_wagon WHERE train_id="+train_id+" AND id="+id+" AND wagon_name != '__ALL__' AND wagon_name != '__BASELINE__' AND wagon_name NOT IN (SELECT wagon_name FROM train_wagon_period WHERE train_id="+train_id+" AND period_name='"+db.gets(1)+"');");
	    while (db2.moveNext()){
		if(db.gets("period_name").equals(selected_period_name))
		    p.append("opt_wagons", "<option value='"+Format.escHtml(db2.gets(1))+"' selected>"+Format.escHtml(db2.gets(1))+"</option>");
	    }
	}
    }
    p.append("period_wagon", submitStr);

    db.query("SELECT distinct wagon_name FROM train_run_wagon WHERE train_run_wagon.train_id = "+train_id+" AND id = "+id+" AND train_run_wagon.wagon_name != '__ALL__' AND train_run_wagon.wagon_name != '__BASELINE__';");

    while (db.moveNext()){
	String wagon_not_edit = db.gets("wagon_name");
	p.append("wagons_not_edit", "<input type=hidden name=wagons value='"+Format.escHtml(wagon_not_edit)+"'>"+Format.escHtml(wagon_not_edit)+", ");
    }

    if (id == 0)
 	p.comment("com_show_update_comment", false);

    //set different checkboxes
    if(id>0){
	db.query("SELECT split_all, derived_data, no_clean_up, slow_train_run FROM train_run WHERE train_id="+train_id+" AND id="+id+";");

	p.comment("com_splitAll", db.geti("split_all")==1);
	p.comment("com_derived_data", db.geti("derived_data")==1);
	p.comment("com_no_clean_up", db.geti("no_clean_up")==1);
	p.comment("com_slow_run", db.geti("slow_train_run")==1);

	p.comment("com_show_slow_run", db.geti("derived_data")==1);
    }else if(id == 0){
	p.comment("com_splitAll", true);
	p.comment("com_derived_data", false);
	p.comment("com_no_clean_up", false);
	p.comment("com_slow_run", false);
    }

    //show slow_run box if dataset is a derived dataset production
    db.query("SELECT aod from train_period where train_id="+train_id+" AND period_name='"+selected_period_name+"';");
    if(db.geti("aod")==200){
	p.comment("com_show_slow_run", true);
	p.append("show_slow_run_because_dataset", "1");
    }else{
	p.append("show_slow_run_because_dataset", "0");
    }

    //Statistics
    db.query("SELECT Count(*) FROM train_run_statistics WHERE train_id="+train_id+" AND id="+id+";");
    boolean haveStats = db.geti(1)>0;

    if(haveStats){
	p.comment("com_statistics", true);
	db.query("SELECT lpm_id FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
	int lpm_id=db.geti(1);
	p.append("train_lpm_id",lpm_id);

	String[] jobState = new String[]{"DONE", "ERROR_V", "ERROR_E (TTL)", "ERROR_E (mem)", "ERROR_E (disk)", "ERROR_EW", "Other"};//for these states the files histogram is computed
	int jobs = 0;

	//fill statistics table
	for(int jobStates=0;jobStates<jobState.length;++jobStates){
	    db.query("SELECT * FROM train_run_statistics WHERE train_id="+train_id+" AND id="+id+" AND state='"+jobState[jobStates]+"';");
	    final Page train_statistics = new Page("trains/admin/train_edit_run_statistics.res", false);
	    train_statistics.fillFromDB(db);
	    p.append("statistics_table", train_statistics);

	    jobs += db.geti("jobs");//used for advice later
	}
	    
	db.query("SELECT * FROM train_run_statistics WHERE train_id="+train_id+" AND id="+id+" AND state='DONE';");
	//add information to the statistics box
	p.append("files_job_min", db.geti("files_job_min"));
	p.append("files_job_max", db.geti("files_job_max"));
	p.append("files_job_avg", db.getd("files_job_avg"));
	p.append("files_job_standDev", db.getd("files_job_standDev"));
		
	//time of the jobs
	p.append("running_time_min", Format.toInterval((long)db.geti("running_time_job_min")));
	p.append("running_time_max", Format.toInterval((long)db.geti("running_time_job_max")));
	p.append("running_time_95", Format.toInterval((long)db.geti("running_time_job_95")));
	p.append("running_time_avg", Format.toInterval((long)db.geti("running_time_job_avg")));
	p.append("running_time_standDev", Format.toInterval((long)db.geti("running_time_job_standDev")));
	
	
	db.query("SELECT total_wall, output_size FROM train_run WHERE train_id="+train_id+" AND id="+id+";");
	p.append("wall_time",  Format.toInterval(db.getl("total_wall")));
	long size_output = db.getl("output_size");
	p.append("size_output", size_output);

	//give advice how to improve the train
	String advice = "";

	double jobs_error = 0;
	//give advice if there are more than 5% of the jobs in an error state
	for(int jobStates=1;jobStates<jobState.length-1;++jobStates){//do not give this advice for other
	    db.query("SELECT * FROM train_run_statistics WHERE train_id="+train_id+" AND id="+id+" AND state='"+jobState[jobStates]+"';");
	    double jobs_state = Math.round(100*(double)db.geti("jobs")/jobs);
	    if(jobs_state>5){
		advice += "<li>" + jobs_state+"% of the jobs are in "+jobState[jobStates]+".";
		if(jobState[jobStates].equals("ERROR_E (TTL)"))
		    advice += " Increase the time to live (TTL) in the dataset configuration.";
		if(jobState[jobStates].equals("ERROR_E (mem)"))
		    advice += " Check the wagons for memory leaks.";
		if(jobState[jobStates].equals("ERROR_E (disk)"))
		    advice += " Check the output in particular text output of the wagons.";
	    }
	    jobs_error += db.geti("jobs");
	}
	jobs_error /= jobs;
	//give advice if 10% of all the jobs are in an error state
	if(jobs_error>0.1){
	    double jobs_error_rel = Math.round(100*jobs_error);
	    advice += "<li>" + jobs_error_rel+"% of the jobs are in an error state. Such inefficient trains should not be submitted.";
	}

	db.query("SELECT * FROM train_run_statistics WHERE train_id="+train_id+" AND id="+id+" and state='DONE';");
	int running_time_95 = db.geti("running_time_job_95");
	double files_avg = db.getd("files_job_avg");

	db.query("select max(array_length(files_histogram, 1)) as files_max from train_run left join lpm_history on train_run.lpm_id=lpm_history.chain_id natural join job_stats_details where train_id="+train_id+" and id="+id+";");
	int files_max = db.geti("files_max")-1;//first bin in the list is for 0 input files

 
	if(files_avg>(double)files_max/2){
	    if(running_time_95<1000*60*60){
		advice += "<li>95% of the jobs are finished after "+Format.toInterval((long) running_time_95)+", the number of files per job (SplitMaxInputFileNumber) can be increased.";
	    }
	}else{
	    //double files_avg_round = Math.round(10*files_avg);
	    //advice += "<li>The average used files are "+files_avg_round/10+" per job, which is below half of the value given as SplitMaxInputFileNumber("+files_max+"), maybe the number of files per job (SplitMaxInputFileNumber) can be reduced.";

	    //if(running_time_95<1000*60*60){//running_time_95 < 1 hour
	    //advice += "<li>95% of the jobs are finished after "+Format.toInterval((long) running_time_95)+", this can usually be improved by increasing the number of files per job, but the splitting is already quite bad.";
	    //}

	}

	if(advice.length()>0){
	    p.comment("com_improvements", true);
	    p.append("train_improvements", "<ul>" + advice + "</ul>");
	}else{
	    p.comment("com_improvements", false);
	}
	
    }else if(!haveStats){
	p.comment("com_statistics", false);
    }

    // ------------------------ final bits and pieces
    
    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_edit_period.jsp?train_id="+train_id+"&username="+principal.getName()+"&id="+id, baos.size(), request);
%>
