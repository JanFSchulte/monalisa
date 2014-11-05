<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!

       private final static String basePath = System.getProperty("user.home")+"/train-workdir/";
     
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/train.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    RequestWrapper rw2 = new lazyj.RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    final Page p = new Page("trains/train.res", false);

    final AlicePrincipal principal = new AlicePrincipal("");//Users.get(request);
    
    final String submit = rw.gets("submit");

    final DB db = new DB();
    final DB db_period = new DB();
    
    final int train_id = rw.geti("train_id");
    
    String sBookmark = "/trains/train.jsp";

    p.modify("backend_url", lia.Monitor.monitor.AppConfig.getProperty("trains.admin.backend.url", "http://alitrain.cern.ch"));
    
    sBookmark = utils.IntervalQuery.addToURL(sBookmark, "train_id", ""+train_id);
    
    //~ boolean admin = principal.hasRole("admin");
    boolean admin = true;
    
    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
	
	admin = db.moveNext();
    }

     //check this button already here because users should also be able to use this
     if (submit.length()>0 && submit.startsWith("Update wagon status")) {
	 db.query("SELECT tw.wagon_name, tw.username, tp.period_name, (twp.wagon_name IS NOT NULL) AS exists FROM train_wagon AS tw NATURAL JOIN train_period AS tp left join train_wagon_period AS twp ON tw.wagon_name = twp.wagon_name AND tp.period_name = twp.period_name AND tw.train_id = twp.train_id WHERE tw.train_id="+train_id+" ORDER BY wagon_name, period_name;");

	 while (db.moveNext()){
	     String wagon_name = db.gets("wagon_name");
	     String period_name = db.gets("period_name");
	     int activate = rw.geti("wagon_enabled_"+wagon_name+"_"+period_name);
	     if(rw.geti("wagon_enabled_"+wagon_name+"_"+period_name+"_hidden")!=activate){
		 //check if this user is allowed to do the change (user could have hacked the page)
		 if(admin || db.gets("username").equals(principal.getName())){
		     if(activate==1 && !db.getb("exists")){
			 final DB db2 = new DB();		     
			 db2.syncUpdateQuery("INSERT INTO train_wagon_period VALUES ("+train_id+", '"+db.gets("wagon_name")+"', '"+db.gets("period_name")+"');");
			 trains.UpdateTestStatus.activateDependentWagons(train_id, db.gets("wagon_name"), db.gets("period_name"));
			 
		     } else if (activate==0 && db.getb("exists")){
			 final DB db2 = new DB();
			 db2.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name= '"+db.gets("wagon_name")+"' AND period_name = '"+db.gets("period_name")+"';");   
		     }
		 }
	     }
	 }
	 response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");

     }
    
    if (admin && submit.length()>0){
     if (submit.startsWith("Save")) {
	 String globallibraries = rw.gets("globallibraries");
	 globallibraries = globallibraries.replaceAll("(\\r|\\n)", "");

	 db.syncUpdateQuery("UPDATE train_def SET description='"+Format.escSQL(rw.gets("description"))+"', train_debuglevel='"+Format.escSQL(rw.gets("train_debuglevel"))+"', excludefiles='"+Format.escSQL(rw.gets("excludefiles"))+"', additionalpackages='"+Format.escSQL(rw.gets("additionalpackages"))+"', globalvariables='"+Format.escSQL(rw.gets("globalvariables"))+"', globallibraries='"+Format.escSQL(globallibraries)+"', outputfiles='"+Format.escSQL(rw.gets("outputfiles"))+"' WHERE train_id="+train_id);
	 response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#Configuration");
     }
      if (submit.startsWith("Enable all")||submit.startsWith("Disable all")) {
	  String period_request = " AND period_name='"+Format.escSQL(rw.gets("period_enable"))+"'";
	  if(rw.gets("period_enable").equals("all datasets"))
	      period_request = "";
	 db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+period_request+";");
	 if(submit.startsWith("Enable all")){
	     if(!rw.gets("period_enable").equals("all datasets"))
		 db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT train_id, wagon_name, '"+Format.escSQL(rw.gets("period_enable"))+"' FROM train_wagon WHERE train_id="+train_id+";");
	     else
		 db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT train_id, wagon_name, period_name FROM train_wagon natural inner join train_period WHERE train_id="+train_id+" and enabled=1;");
	 }
             //don't need to do an activation for dependent wagons because already all wagons are activated
      }else if (submit.startsWith("Enable")||submit.startsWith("Disable")) {
	 
	 String activate = Format.escSQL(rw.gets("wagonNames"));
	 String period_enable = rw.gets("period_enable");
	 
	 String toTokenizer = activate.replaceAll(" ","");
	 StringTokenizer tokenizer = new StringTokenizer(toTokenizer, ",");
	 boolean change = true;
	 
	 while(tokenizer.hasMoreTokens()) {
	     String toSearch = tokenizer.nextToken();
	     db.query("SELECT wagon_name FROM train_wagon WHERE wagon_name='"+toSearch+"' AND train_id="+train_id);
	     if(db.count()!=1){
		 if(submit.startsWith("Enable")){
		     out.println("<script type=text/javascript>alert('The list contains an unknown wagon: "+toSearch+". No wagon has been enabled.');</script>");
		 }else if(submit.startsWith("Disable")){
		     out.println("<script type=text/javascript>alert('The list contains an unknown wagon: "+toSearch+". No wagon has been disabled.');</script>");
		 }
		 p.modify("wagonNames", activate);
		 change=false;
	     }
	 }

	 if(change){
	     String toActivate = toTokenizer.replaceAll(",","','");
	     if(submit.startsWith("Enable")){
		 if(!period_enable.equals("all datasets"))
		     db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT train_id, wagon_name, '"+Format.escSQL(period_enable)+"' FROM train_wagon as tw WHERE train_id="+train_id+" AND tw.wagon_name IN ('"+toActivate+"') AND wagon_name NOT IN (SELECT wagon_name FROM train_wagon_period where train_id="+train_id+" AND wagon_name=tw.wagon_name AND period_name='"+Format.escSQL(period_enable)+"');");
		 else
		     db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT train_id, wagon_name, period_name FROM train_wagon as tw natural inner join train_period WHERE train_id="+train_id+" AND tw.wagon_name IN ('"+toActivate+"') AND wagon_name NOT IN (SELECT wagon_name FROM train_wagon_period natural join train_period where train_id="+train_id+" AND wagon_name=tw.wagon_name AND enabled=1) and enabled=1;");
		 StringTokenizer wagon_tokenizer = new StringTokenizer(toActivate, "','");

		 while(wagon_tokenizer.hasMoreTokens()){
		     String wname = wagon_tokenizer.nextToken();
		     trains.UpdateTestStatus.activateDependentWagons(train_id, wname, period_enable);
		 }
		 
	     }else if(submit.startsWith("Disable")){
		 db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name IN ('"+toActivate+"') AND period_name='"+Format.escSQL(period_enable)+"';");
	     }
	     response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	 }
      }
      if (submit.startsWith("Copy")) {
	  String period_enable = rw.gets("period_enable");
	  if (rw.gets("period_copy_to").length() > 0 && !rw.gets("period_copy_to").equals(period_enable)){
	      db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(rw.gets("period_copy_to"))+"';");
	      db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, period_name, wagon_name) SELECT "+train_id+", '"+Format.escSQL(rw.gets("period_copy_to"))+"', wagon_name FROM train_wagon_period where train_id="+train_id+" and period_name='"+Format.escSQL(period_enable)+"';");
	      db.query("SELECT wagon_name FROM train_wagon_period where train_id="+train_id+" and period_name='"+Format.escSQL(period_enable)+"';");
	      while(db.moveNext())
		  trains.UpdateTestStatus.activateDependentWagons(train_id, db.gets("wagon_name"), rw.gets("period_copy_to"));
	      
	      response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	  }
      }
    }
    
    p.comment("com_admin", admin);
    
    db.query("SELECT * FROM train_def WHERE train_id="+train_id);
    
    if (!db.moveNext())
	return;
    
    pMaster.modify("title", "Analysis trains - "+Format.escHtml(db.gets("train_name")));

    p.modify("account", principal.getName());
    p.comment("com_mc_gen", db.geti("train_type") == 1);
    
    p.fillFromDB(db);    
    //scale globalvariables box
    String globalVariables = db.gets("globalvariables");
    int lines_globalVariables = globalVariables.length()/25;
    if(lines_globalVariables<5) lines_globalVariables = 5;
    else if(lines_globalVariables>50) lines_globalVariables = 50;
    p.modify("rows_globalVariables", lines_globalVariables);


    // ------------------------ content

    db.query("SELECT * FROM train_handler WHERE train_id="+train_id+" ORDER BY handler_name ASC;");
    
    final Page pHandler = new Page("trains/train_handler.res", false);
    
    while (db.moveNext()){
	pHandler.fillFromDB(db);
	pHandler.comment("com_enabled", false);
	if(db.geti("enabled")==1)
	    pHandler.comment("com_enabled", true);

	pHandler.comment("com_admin", admin);	
	p.append("handlers", pHandler);
    }
    
    //header of the train wagons (dynamical part of the periods)
    db_period.query("SELECT period_name FROM train_period WHERE train_id = "+train_id+" AND enabled = 1 ORDER BY period_name;");
    
    while (db_period.moveNext()){
	final Page pWagonPeriod_header = new Page("trains/train_wagon_periods.res", false);
	pWagonPeriod_header.comment("com_header", true);
	pWagonPeriod_header.fillFromDB(db_period);
	p.append("wagonHeader", pWagonPeriod_header);
    }
    
    //add checkDivs
    //please notice if you add another one that for div_check they need a ',' at the beginning and the second one isn't allowed to have '' at the beginning and the end
    p.append("div_check","'div_lego_train_"+train_id+"_owner'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_macro_path'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_dependencies'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_refprod_dataset'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_runlist_dataset'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_global_variables_dataset'");
    p.append("div_check",", 'div_lego_train_"+train_id+"_desc_dataset'");
    p.append("div_owner","div_lego_train_"+train_id+"_owner");
    p.append("div_macro_path","div_lego_train_"+train_id+"_macro_path");
    p.append("div_dependencies","div_lego_train_"+train_id+"_dependencies");
    p.append("div_refprod_dataset","div_lego_train_"+train_id+"_refprod_dataset");
    p.append("div_runlist_dataset","div_lego_train_"+train_id+"_runlist_dataset");
    p.append("div_global_variables_dataset", "div_lego_train_"+train_id+"_global_variables_dataset");
    p.append("div_desc_dataset","div_lego_train_"+train_id+"_desc_dataset");
    p.append("div_showOnlyMyWagons","div_lego_train_"+train_id+"_showOnlyMyWagons");
    p.append("div_showOnlyActiveWagons","div_lego_train_"+train_id+"_showOnlyActiveWagons");
    p.append("div_showOnlyActivatedWagons","div_lego_train_"+train_id+"_showOnlyActivatedWagons");
    p.append("div_showOnlyActivatedDatasets","div_lego_train_"+train_id+"_showOnlyActivatedDatasets");

    //check cookies 
    String cookie_owner =rw2.getCookie("lastval_div_lego_train_"+train_id+"_owner");
    if(cookie_owner==""){
	cookie_owner="1";
	p.append("no_cookie_owner", true);
    }else{
	p.append("no_cookie_owner", false);
    }
    String cookie_dependencies =rw2.getCookie("lastval_div_lego_train_"+train_id+"_dependencies");
    if(cookie_dependencies==""){
	cookie_dependencies="1";
	p.append("no_cookie_dependencies", true);
    }else{
	p.append("no_cookie_dependencies", false);
    }
    String cookie_macro_path =rw2.getCookie("lastval_div_lego_train_"+train_id+"_macro_path");
    if(cookie_macro_path==""){
	cookie_macro_path="0";
    }
    String cookie_refprod_dataset =rw2.getCookie("lastval_div_lego_train_"+train_id+"_refprod_dataset");
    if(cookie_refprod_dataset==""){
	cookie_refprod_dataset="1";
	p.append("no_cookie_refprod_dataset", true);
    }else{
	p.append("no_cookie_refprod_dataset", false);
    }
    String cookie_runlist_dataset =rw2.getCookie("lastval_div_lego_train_"+train_id+"_runlist_dataset");
    if(cookie_runlist_dataset==""){
	cookie_runlist_dataset="1";
	p.append("no_cookie_runlist_dataset", true);
    }else{
	p.append("no_cookie_runlist_dataset", false);
    }
    String cookie_global_variables_dataset =rw2.getCookie("lastval_div_lego_train_"+train_id+"_global_variables_dataset");
    if(cookie_global_variables_dataset==""){
	cookie_global_variables_dataset="0";
    }
    String cookie_desc_dataset =rw2.getCookie("lastval_div_lego_train_"+train_id+"_desc_dataset");
    if(cookie_desc_dataset==""){
	cookie_desc_dataset="1";
	p.append("no_cookie_desc_dataset", true);
    }else{
	p.append("no_cookie_desc_dataset", false);
    }

    String cookie_showOnlyMyWagons =rw2.getCookie("lastval_div_lego_train_"+train_id+"_showOnlyMyWagons");
    if(cookie_showOnlyMyWagons==""){
	cookie_showOnlyMyWagons="0";
    }
    String opposite = "0";
	p.comment("com_check_box_myWagon_ok", true);
    if(cookie_showOnlyMyWagons.equals("0")){
	opposite="1";
	p.comment("com_check_box_myWagon_ok", false);
    }
    p.append("div_showOnlyMyWagons_value", opposite);

    String cookie_showOnlyActiveWagons =rw2.getCookie("lastval_div_lego_train_"+train_id+"_showOnlyActiveWagons");
    if(cookie_showOnlyActiveWagons==""){
	cookie_showOnlyActiveWagons="0";
    }
    String opposite_activeWagons = "0";
    p.comment("com_check_box_activeWagon_ok", true);
    if(cookie_showOnlyActiveWagons.equals("0")){
	opposite_activeWagons="1";
	p.comment("com_check_box_activeWagon_ok", false);
    }
    p.append("div_showOnlyActiveWagons_value", opposite_activeWagons);

    String cookie_showOnlyActivatedWagons =rw2.getCookie("lastval_div_lego_train_"+train_id+"_showOnlyActivatedWagons");
    if(cookie_showOnlyActivatedWagons==""){
	cookie_showOnlyActivatedWagons="0";
    }
    String opposite_activatedWagons = "0";
    p.comment("com_check_box_activatedWagon_ok", true);
    if(cookie_showOnlyActivatedWagons.equals("0")){
	opposite_activatedWagons="1";
	p.comment("com_check_box_activatedWagon_ok", false);
    }
    p.append("div_showOnlyActivatedWagons_value", opposite_activatedWagons);

    if(cookie_showOnlyMyWagons.equals("1")||cookie_showOnlyActiveWagons.equals("1")||cookie_showOnlyActivatedWagons.equals("1"))
	p.comment("com_show_warning", true);
    else
	p.comment("com_show_warning", false);

    String cookie_showOnlyActivatedDatasets =rw2.getCookie("lastval_div_lego_train_"+train_id+"_showOnlyActivatedDatasets");
    if(cookie_showOnlyActivatedDatasets==""){
	cookie_showOnlyActivatedDatasets="0";
    }
    String opposite_activatedDatasets = "0";
    p.comment("com_check_box_activatedDataset_ok", true);
    if(cookie_showOnlyActivatedDatasets.equals("0")){
	opposite_activatedDatasets="1";
	p.comment("com_check_box_activatedDataset_ok", false);
    }
    p.append("div_showOnlyActivatedDatasets_value", opposite_activatedDatasets);

    final Page pGroup = new Page("trains/train_group.res", false);

    db.query("SELECT train_id, group_name FROM train_group WHERE train_id="+train_id+" ORDER BY (CASE when group_name='Attic' THEN 1 ELSE 0 END),lower(group_name);");
    
    int first=0;
    
    //put the wagons on the page
    while(db.moveNext()){
	first++;
	String group_name = db.gets("group_name");
	pGroup.fillFromDB(db);
	pGroup.append("div_group","div_lego_train_"+train_id+"_group_"+group_name);
	
	p.append("div_check",", 'div_lego_train_"+train_id+"_group_"+group_name+"'");
    
    db_period.query("SELECT period_name FROM train_period WHERE train_id = "+train_id+" AND enabled = 1 ORDER BY period_name;");
    
    final Page pWagonPeriod = new Page("trains/train_wagon_periods.res", false);
    
    while(db_period.moveNext()){
	pWagonPeriod.comment("com_header", false);
	pWagonPeriod.comment("com_wagon", false);
	
	pWagonPeriod.comment("com_admin", admin);
	pWagonPeriod.fillFromDB(db);
	pWagonPeriod.fillFromDB(db_period);
	pGroup.append("datasets_group", pWagonPeriod);

	//puts activated datasets into the dropdown menu
	if (first==1){
	    p.append("opt_period", "<option value='"+Format.escHtml(db_period.gets(1))+"' >"+Format.escHtml(db_period.gets(1))+"</option>\n");
	    p.append("opt_period_copy_to", "<option value='"+Format.escHtml(db_period.gets(1))+"' >"+Format.escHtml(db_period.gets(1))+"</option>\n");
	}
    }
    //use Attic as group so that 'all datasets' is the last in the group overview; could also put it below the group loop
    if(db.gets("group_name").equals("Attic"))
	p.append("opt_period", "<option value='all datasets' >all datasets</option>\n");
    
    String ownerRestriction = "";
    if(Integer.parseInt(cookie_showOnlyMyWagons)==1)
	ownerRestriction = "AND username='"+principal.getName()+"'";

   
    final DB db2 = new DB();
    db2.query("SELECT *, (select train_run.id from train_run left join train_run_wagon on train_run_wagon.train_id = train_run.train_id and  train_run_wagon.id = train_run.id AND train_run_wagon.wagon_name = tw.wagon_name where train_run.train_id = "+train_id+" AND train_run_wagon.wagon_name IS NOT NULL AND run_start IS NOT NULL ORDER BY run_start DESC LIMIT 1) AS run_id, (select train_run.id from train_run left join train_run_wagon on train_run_wagon.train_id = train_run.train_id and  train_run_wagon.id = train_run.id AND train_run_wagon.wagon_name = tw.wagon_name where train_run.train_id = "+train_id+" AND train_run_wagon.wagon_name IS NOT NULL AND test_start IS NOT NULL ORDER BY test_start DESC LIMIT 1) AS test_id FROM train_wagon tw WHERE train_id="+train_id+" AND group_name='"+group_name+"' "+ownerRestriction+" ORDER BY group_name, lower(wagon_name);");
    
    final Page pWagon = new Page("trains/train_wagon.res", false);
    int last_test=0;
    int last_run=0;
    
    //put the wagons in the group
    while(db2.moveNext()){
	//check if only the last runs should be displayed or all the runs and if only the last runs should be shown filter out the others
	if(Integer.parseInt(cookie_showOnlyActiveWagons)==1){
	    final long interval = 3600*24*30;
	    int stat_begin =  (int) (System.currentTimeMillis()/1000-interval);
	    
	    final DB db3 = new DB();
	    String wagon_name = db2.gets("wagon_name");
	    db3.query("SELECT max(run_start), exists(SELECT 1 FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"') FROM train_run NATURAL JOIN train_run_wagon WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"';");
	    if(db3.geti(1)<stat_begin && !db3.getb(2))
		continue;
	}
	if(Integer.parseInt(cookie_showOnlyActivatedWagons)==1){
	    final DB db3 = new DB();
	    String wagon_name = db2.gets("wagon_name");
	    db3.query("SELECT Count(*) FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"';");
	    if(db3.geti(1)==0)
		continue;
	}
	
	pWagon.modify("dependencies", db2.gets("dependencies").replace(",", ", "));
	pWagon.modify("parameters", db2.gets("parameters").replace(",", ", "));
	pWagon.fillFromDB(db2);

	if(db2.geti("test_id")>last_test)
	    last_test=db2.geti("test_id");
	if(db2.geti("run_id")>last_run)
	    last_run=db2.geti("run_id");
	
	db_period.query("SELECT period_name,exists(SELECT 1 FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+db2.gets("wagon_name")+"' AND period_name=t.period_name) FROM train_period t WHERE train_id = "+train_id+" AND enabled = 1 ORDER BY period_name;");
	
	while(db_period.moveNext()){
	    pWagonPeriod.comment("com_header", false);
	    pWagonPeriod.comment("com_canedit", admin || db2.gets("username").equals(principal.getName()));
	    pWagonPeriod.comment("com_enabled", db_period.getb(2));
	    if(db_period.getb(2)){
		DB db3 = new DB("SELECT to_char(to_timestamp(activated), 'DD Mon YYYY') as run_date FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+db2.gets("wagon_name")+"' AND period_name='"+db_period.gets("period_name")+"';");
		pWagonPeriod.fillFromDB(db3);
	    }

	    pWagonPeriod.fillFromDB(db2);
	    pWagonPeriod.fillFromDB(db_period);
	    pWagonPeriod.comment("com_admin", admin);
	    pWagonPeriod.comment("com_wagon", true);
	    pWagon.append("datasets", pWagonPeriod);
	}
	pWagon.comment("com_canedit", admin || db2.gets("username").equals(principal.getName()));
	pWagon.comment("com_admin", admin);

	pWagon.comment("com_macro_path", Integer.parseInt(cookie_macro_path)==1);
	pWagon.comment("com_owner", Integer.parseInt(cookie_owner)==1);
	pWagon.comment("com_dependencies", Integer.parseInt(cookie_dependencies)==1);

	pGroup.append("group_wagons", pWagon);
    }
    if(last_test>0)
	pGroup.append("last_test", last_test);
    if(last_run>0)
	pGroup.append("last_run", last_run);
    p.append("wagons", pGroup);
}    

    db.query("SELECT *, (select max(id) FROM train_run_period WHERE train_id=tp.train_id AND period_name=tp.period_name) AS id FROM train_period tp WHERE train_id="+train_id+" ORDER BY lower(period_name);");
    
    final Page pPeriod = new Page("trains/train_period.res", false);
    
    while (db.moveNext()){
	if(Integer.parseInt(cookie_showOnlyActivatedDatasets)==1 && db.geti("enabled")==0){
	    continue;
	}

	String refprod = db.gets("refprod");
	if (refprod.equals("__MC__"))
		pPeriod.modify("refprod", "On the fly MC generation");
	else if(refprod.startsWith("Derived Data:")){
	    refprod = refprod.substring(0, refprod.indexOf("(")-1) + refprod.substring(refprod.indexOf(")")+1, refprod.lastIndexOf("("));
	    pPeriod.modify("refprod", refprod);
	}

	pPeriod.fillFromDB(db);
	pPeriod.comment("com_admin", admin);
	pPeriod.comment("com_enabled_data", db.geti("enabled")>0);

	pPeriod.comment("com_refprod_dataset", Integer.parseInt(cookie_refprod_dataset)==1);
	pPeriod.comment("com_runlist_dataset", Integer.parseInt(cookie_runlist_dataset)==1);
	pPeriod.comment("com_global_variables_dataset", Integer.parseInt(cookie_global_variables_dataset)==1);
	pPeriod.comment("com_desc_dataset", Integer.parseInt(cookie_desc_dataset)==1);

	//need to fill runlist separate
	DB db2 = new DB("SELECT Count(*) FROM train_period_runlist WHERE train_id="+train_id+" AND period_name='"+db.gets("period_name")+"';");
	int count_runlists = db2.geti(1);
	db2.query("SELECT * FROM train_period_runlist WHERE train_id="+train_id+" AND period_name='"+db.gets("period_name")+"' ORDER BY list_id asc;");
	while (db2.moveNext()){
	    String list_id = "";
	    if(count_runlists>1)list_id = "Runlist "+(db2.gets("runlist_name").length()>0 ? Format.escHtml(db2.gets("runlist_name")) : db2.geti("list_id"))+": ";
	    if(db2.geti("list_id")!=1) list_id = "<br> "+list_id;
	    
	    pPeriod.append("runlists", list_id+Format.escHtml(db2.gets("runlist")));
	}
	p.append("periods", pPeriod);
    }
    
    db.query("SELECT id FROM train_run WHERE train_id="+train_id+" AND ((test_start>0 and test_end is null) OR (run_start>0 and run_end is null));");
    
    while (db.moveNext()){
	trains.UpdateTestStatus.update(train_id, db.geti(1));
    }

    int limit = 50;
    
    int offset = rw.geti("offset");
    
    if (offset<0)
	offset = 0;

    String q = "SELECT train_run.*,to_char(to_timestamp(test_start), 'YYYY Mon DD, ') AS test_date, to_char(to_timestamp(run_start), 'YYYY Mon DD, ') as run_date, (SELECT period_name FROM train_run_period WHERE train_run.train_id = train_run_period.train_id AND train_run.id = train_run_period.id LIMIT 1) AS dataset FROM train_run WHERE train_id="+train_id;
    
    db.query(q);
    
    int count = db.count();
 
    db.query(q+" ORDER BY id DESC LIMIT "+limit+" OFFSET "+offset);
    
    final Page pRun = new Page("trains/train_run.res", false);
    
    final Set<String> alienPackages = alien.catalogue.PackageUtils.getPackageNames();
    final Set<String> cvmfsPackages = alien.catalogue.PackageUtils.getCvmfsPackages();
    
    while (db.moveNext()){
	pRun.fillFromDB(db);
	pRun.comment("com_admin", admin);
	pRun.comment("com_run_started", false);//put the test information in the train status field
	
	if (alienPackages!=null && alienPackages.contains(db.gets("ver_aliroot"))){
	    if (cvmfsPackages!=null && cvmfsPackages.contains(db.gets("ver_aliroot"))){
		pRun.modify("aliroot_available_color", "green");
		pRun.modify("aliroot_available_tooltip", "Package ready to be used in Grid");
	    }
	    else{	
		pRun.modify("aliroot_available_color", "orange");
		pRun.modify("aliroot_available_tooltip", "Package not (yet) available in CVMFS");
	    }
	}
	else{
	    pRun.modify("aliroot_available_color", "red");
	    pRun.modify("aliroot_available_tooltip", "Package not defined");
	}
	
	pRun.modify("ver_aliroot_short", db.gets("ver_aliroot").replaceAll("VO_ALICE@AliRoot::", ""));

	String sTestPath = db.gets("test_path");
	
	if (db.geti("test_start")>0){
	    final boolean bReallyStarted = new File(basePath+sTestPath+"/test_started").exists() || db.geti("test_end")>0;
	
	    if (!bReallyStarted){
		pRun.modify("test_status", "Test queued");
		
		pRun.modify("reload", "setTimeout('reload()', 10000);");
	    }
	    else{
		if (db.geti("test_end")>0){
	    	    pRun.modify("test_status", "Test finished ("+Format.toInterval((db.geti("test_end") - db.geti("test_start"))*1000L)+" total time)");
		}  
		else{
	    	    pRun.modify("test_status", "Test started "+Format.toInterval(System.currentTimeMillis() - db.geti("test_start")*1000L)+" ago");
	    	    pRun.modify("reload", "setTimeout('reload()', 10000);");
		}   	
	    }
	}

	// TODO part of this is a code duplication
	if (db.geti("run_start")>0){
	  pRun.comment("com_run_started", true);  
	  final DB db2 = new DB();
	  db2.query("select wagon_name from train_run_wagon where train_id="+train_id+" and id="+db.geti("id")+" AND wagon_name not in ('__ALL__', '__BASELINE__')");	  
	  String wagon_name_list = "";
	  while (db2.moveNext()){
	      if(wagon_name_list.length()>0) wagon_name_list+=", ";
	      wagon_name_list += db2.gets("wagon_name");
	  }
	  pRun.append("wagon_name_list", wagon_name_list);

	  db2.query("select lpm_id from train_run where train_id="+train_id+" and id="+db.geti("id"));
	  
	  int lpm_id = db2.geti(1);
	  if (lpm_id > 0)
	  {
	    db2.query("select job_types_id from lpm_history natural inner join job_runs_details where chain_id="+lpm_id+" limit 1;");
	    
	    p.modify("job_types_id", db2.geti(1));
	    
	    db2.query("select * from lpm_chain where id="+lpm_id);
	    
	    if (db2.geti("enabled")==1){
		pRun.modify("lpm_status", "<font color=green>Train run: Submitting enabled</font>");
	    }
	    else{
		String status = "<font color=blue>Train run: All jobs submitted</font>";
		db2.query("SELECT Count(*) FROM train_run WHERE train_finished_timestamp IS NOT NULL AND train_id="+train_id+" AND id="+db.geti("id")+";");
		if(db2.geti(1)>0){
		    status = "<font color=green>Train run finished</font>";
		} else if (!(new File(basePath+sTestPath+"/files_generated").exists())) {
		    status = "<font color=orange>Waiting for files to be copied</font>";
		} else if (new File(basePath+sTestPath+"/train_killed").exists())
   	     	    status = "<font color=red>Train killed by operator</font>";

		pRun.modify("lpm_status", status);
	    }
	  }
	  pRun.comment("allow_delete", false);
	}
	else
	{
	  pRun.comment("allow_delete", true);
	}
	
	p.append("runs", pRun);
    }
    
    if (count>limit + offset){
	p.comment("com_nextpage", true);
	p.modify("nextoffset", limit+offset);
    }
    else{
	p.comment("com_nextpage", false);
    }
    
    if (offset>0){
	p.comment("com_prevpage", true);
	p.modify("prevoffset", offset-limit);
    }
    else{
	p.comment("com_prevpage", false);
    }

    p.modify("bookmark", sBookmark);
    pMaster.modify("bookmark", sBookmark);
    
    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/train.jsp", baos.size(), request);
%>
