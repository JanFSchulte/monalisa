<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
    
    //get runlist as sum of all runlists for this dataset, but each run is only listed once
    private static final String getRunlist(int trainId, String period_name){
	DB db = new DB();
	db.query("SELECT runlist FROM train_period_runlist WHERE train_id="+trainId+" AND period_name='"+period_name+"';");
	String runlist = "";
	while(db.moveNext()){
	    String this_runlist = db.gets("runlist");
	    if(this_runlist.equals("")) return "";//this means merge all runno

	    if(runlist.equals("")){
		runlist += this_runlist.replaceAll(" ", "");
		continue;
	    }
	    StringTokenizer st = new StringTokenizer(this_runlist, ",");
	    String tok = "";

	    while(st.hasMoreTokens()){
		tok = st.nextToken().replaceAll(" ", "");
		if(!runlist.contains(tok)){
		    runlist += ","+tok;
		}
	    }
	}
	return runlist;
    }

      private static final void addRunlists(Page p, int train_id, String period_name, boolean unprivileged){
	  DB db = new DB("SELECT list_id, runlist, runlist_name, activated from train_period_runlist WHERE train_id="+train_id+" AND period_name='"+period_name+"' order by list_id;");
	  int highest_runlist = 0;
	  boolean newDataset = true;
	  while(db.moveNext()){
	      newDataset = false;
	      String runlist_text = "";
	      if(highest_runlist>0){ //if not first runlist
		  runlist_text += "<br> <br>";
	      }
	      if(!unprivileged){//this means the user can edit the runlist information
		  int list_id = db.geti("list_id");
		  runlist_text += "runlist name <input type=text size=20 name=\"runlist_"+list_id+"_name\" id=\"runlist_"+list_id+"_name\" value=\""+Format.escHtml(db.gets("runlist_name"))+"\" class=input_text> ";

		  runlist_text += "<input type=\"checkbox\" name=\"runlist_"+list_id+"_checkbox\" value=\"1\" "+(db.getb("activated") ? "checked" : "")+">  runlist activated <br>";

		  runlist_text += "<textarea rows=3 style=\"width: 450px;\" class=input_textarea name=runlist_"+list_id+" id=runlist_"+list_id+" >"+Format.escHtml(db.gets("runlist"))+"</textarea> ";

	      }else{
		  runlist_text += "Runlist " + (db.gets("runlist_name").length()>0 ? Format.escHtml(db.gets("runlist_name")) : db.gets("list_id"));
		  runlist_text += "<input type=\"checkbox\" name=\"runlist_"+db.geti("list_id")+"_checkbox\" value=\"1\" "+(db.getb("activated") ? "checked" : "")+" disabled>  runlist activated <br>";
		  runlist_text += Format.escHtml(db.gets("runlist"));
	      }

	      highest_runlist = db.geti("list_id");//because of the order of the database query in the last while loop this will be the highest list_id
	      
	      p.append("runlist_shown", runlist_text);

	  }
	  if(newDataset && !unprivileged){//new Dataset
	      String runlist_text = "";
	      runlist_text += "runlist name <input type=text size=20 name=\"runlist_1_name\" id=\"runlist_1_name\" value=\""+Format.escHtml(db.gets("runlist_name"))+"\" class=input_text> ";
	      runlist_text += "<input type=\"checkbox\" name=\"runlist_1_checkbox\" value=\"1\" checked>  runlist activated <br>";
	      runlist_text += "<textarea rows=3 style=\"width: 450px;\" class=input_textarea name=runlist_1 id=runlist_1></textarea> ";
	      p.append("runlist_shown", runlist_text);
	      highest_runlist = 1;
	  }
	  p.append("highest_runlist", highest_runlist);
	  
      }

%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_edit_period.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page(baos, "trains/admin/train_edit_period.res", false);
    
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    final String period_name = rw.gets("period_name");
    
    final String previous_name = rw.gets("old_name");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    boolean mc_gen = (rw.geti("mc") == 1);

    boolean admin = true; //principal.hasRole("admin");
    
    boolean unprivileged = false;
    
    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
	
	admin = db.moveNext();
    }

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
    
    final String[] fields = new String[]{"train_id", "period_name", "old_name", "period_desc", "globalvariables_dataset", "test_files_no", "splitmaxinputfilenumber", "maxmergefiles", "ttl", "period_filter", "friendchainnames", "friendchain_libraries", "subselection", "gen_macro_path", "gen_parameters", "gen_libraries", "gen_macro_body", "gen_total_events" };
    
    final String[] copy_fields = new String[]{"period_desc", "globalvariables_dataset", "test_files_no", "splitmaxinputfilenumber", "maxmergefiles", "ttl", "friendchainnames", "friendchain_libraries", "subselection", "gen_macro_path", "gen_parameters", "gen_libraries", "gen_macro_body", "gen_total_events" };
    
    boolean copyOtherPeriod = false;
    boolean searching = false;
    
    String copyRefProd = null;
    String copyMainFileName = null;

    if (submit.startsWith("Copy")){
	if (rw.gets("copyperiod").length()>0){
	    String periodToCopy = rw.gets("copyperiod");
		
	    int idx = periodToCopy.indexOf('/');
	
	    int copy_train_id = Integer.parseInt(periodToCopy.substring(0, idx));
	
	    String copy_period_name = periodToCopy.substring(idx+1);
	
    	    String q = "SELECT * FROM train_period WHERE train_id="+copy_train_id+" AND period_name='"+Format.escSQL(copy_period_name)+"';";
	        
    	    db.query(q);

	    if (db.moveNext()){
		for (String field: copy_fields){
		    p.modify(field, db.gets(field));
		}
		p.comment("com_pp", db.getb("pp"));
		p.modify("aod_" + db.geti("aod"), "selected");
	    
		copyRefProd = db.gets("refprod");
		copyMainFileName = db.gets("main_file_name");

		p.comment("com_period_no_skip_processing", db.getb("period_no_skip_processing"));
	    
		copyOtherPeriod = true;
	    }
	    //copy runlists
	    addRunlists(p, copy_train_id, copy_period_name, unprivileged);
	}
    }
    else
    if (rw.geti("op") != 0){
	out.println("<script type=text/javascript>parent.setBookmark('datasets');</script>");
	if (rw.geti("op") == 3 && period_name.length()>0){
	    // deactivate
	    db.syncUpdateQuery("UPDATE train_period SET enabled=0 WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#datasets");
	    return;
	}
	else
	if (rw.geti("op") == 4 && period_name.length()>0){
	    // activate
	    db.syncUpdateQuery("UPDATE train_period SET enabled=1 WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#datasets");
	    return;
	}
	else
	if (rw.geti("op") == 2 && period_name.length()>0){
	    // delete
	    db.syncUpdateQuery("DELETE FROM train_period WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
	    
	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#datasets");
	    return;
	}
	else
	if (rw.geti("op") == 1){
	    if (rw.gets("submit").startsWith("Search")){
		for (String field: fields){
		    p.modify(field, rw.gets(field));
		}
		for(int i=1;i<=rw.geti("highest_runlist");i++){	

		    String runlist_text = "";
		    if(i>1){ //if not first runlist
			runlist_text += "<br> <br>";
		    }
		    runlist_text += "runlist name <input type=text size=20 name=\"runlist_"+i+"_name\" id=\"runlist_"+i+"_name\" value=\""+rw.gets("runlist_"+i+"_name")+"\" class=input_text> ";
		    runlist_text += "<input type=\"checkbox\" name=\"runlist_"+i+"_checkbox\" value=\"1\" "+(rw.geti("runlist_"+i+"_checkbox", 0)==1 ? "checked" : "")+">  runlist activated <br>";
		    runlist_text += "<textarea rows=3 style=\"width: 450px;\" class=input_textarea name=runlist_"+i+" id=runlist_"+i+" >"+rw.gets("runlist_"+i)+"</textarea> ";
		    if(i==1){
			p.modify("runlist_shown", runlist_text);
		    }else{
			p.append("runlist_shown", runlist_text);
		    }
		}
		p.modify("highest_runlist", rw.geti("highest_runlist"));

		p.comment("com_period_no_skip_processing", rw.geti("period_no_skip_processing", 0)!=0);
		p.comment("com_pp", (rw.geti("pp", 0) == 1) ? true : false);
		p.modify("aod_" + rw.geti("aod"), "selected");

		searching = true;
		copyRefProd = rw.gets("refprod");
	    }
	    else{
	    if (previous_name.length()==0 && period_name.length()>0){
		// insert
		
		db.query("SELECT 1 FROM train_period WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
		if (db.moveNext()){
		    out.println("Period name conflicts with an existing entry, please go back and choose another name.");
		    return;
		}

		String refprod = rw.gets("refprod");
		int aod_number = rw.geti("aod");
		
		String main_file_name = "";
		if(refprod.startsWith("Derived Data")) {
		    aod_number = 200;
		    main_file_name = Format.escSQL(rw.gets("refprod_main_file"));
		}

		db.syncUpdateQuery("INSERT INTO train_period (train_id, period_name, period_desc, globalvariables_dataset, refprod, test_files_no, splitmaxinputfilenumber, maxmergefiles, ttl, debuglevel, friendchainnames, friendchain_libraries, subselection, pp, aod, gen_macro_path, gen_parameters, gen_libraries, gen_macro_body, gen_total_events, main_file_name, period_no_skip_processing) VALUES ("+train_id+", '"+Format.escSQL(period_name)+"', '"+Format.escSQL(rw.gets("period_desc"))+"', '"+Format.escSQL(rw.gets("globalvariables_dataset"))+"', '"+Format.escSQL(refprod)+"', "+
		    rw.geti("test_files_no", 2)+", "+
		    rw.geti("splitmaxinputfilenumber", 20)+", "+
		    rw.geti("maxmergefiles", 20)+", "+
		    rw.geti("ttl", 70000)+", "+
		    rw.geti("debuglevel", 0)+", '"+
		    Format.escSQL(rw.gets("friendchainnames"))+"', '"+
		    Format.escSQL(rw.gets("friendchain_libraries"))+"', '"+
		    Format.escSQL(rw.gets("subselection"))+"', '"+
		    rw.geti("pp", 0) +"', '"+
		    aod_number+"', '"+
		    Format.escSQL(rw.gets("gen_macro_path"))+"', '"+
		    Format.escSQL(rw.gets("gen_parameters"))+"', '"+
		    Format.escSQL(rw.gets("gen_libraries"))+"', '"+
		    Format.escSQL(rw.gets("gen_macro_body"))+"', '"+
		    rw.geti("gen_total_events", 0)+"', '"+
		    main_file_name+"', '"+
		    rw.geti("period_no_skip_processing", 0)+"'"+
		    ");");

		for(int i=1;i<=rw.geti("highest_runlist");i++){		    
		    db.syncUpdateQuery("INSERT INTO train_period_runlist (train_id, period_name, list_id, runlist, runlist_name, activated) VALUES ("+train_id+", '"+Format.escSQL(period_name)+"', "+i+", '"+Format.escSQL(rw.gets("runlist_"+i))+"', '"+Format.escSQL(rw.gets("runlist_"+i+"_name"))+"', '"+rw.geti("runlist_"+i+"_checkbox", 1)+"');"); 
		}

		out.println("<script type=text/javascript>parent.modify()</script>");
		return;
	    }
	    else if (period_name.length()>0) {
		// update
		
		if (!period_name.equals(previous_name)){
		    db.query("SELECT 1 FROM train_period WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
		    if (db.moveNext()){
			out.println("Period name conflicts with an existing entry, please go back and choose another name.");
			return;
	    	    }
		}
		
		String refprod = rw.gets("refprod");
		int aod_number = rw.geti("aod");

		String main_file_name = "";
		if(refprod.startsWith("Derived Data:")){
		    aod_number = 200;
		    main_file_name = Format.escSQL(rw.gets("refprod_main_file"));
		}

		db.syncUpdateQuery("UPDATE train_period SET period_name='"+Format.escSQL(period_name)+"', period_desc='"+Format.escSQL(rw.gets("period_desc"))+"', globalvariables_dataset='"+Format.escSQL(rw.gets("globalvariables_dataset"))+"', refprod='"+Format.escSQL(refprod)+"', "+
		    "test_files_no="+rw.geti("test_files_no", 2)+","+
		    "splitmaxinputfilenumber="+rw.geti("splitmaxinputfilenumber", 20)+", "+
		    "maxmergefiles="+rw.geti("maxmergefiles", 10)+","+
		    "ttl="+rw.geti("ttl", 70000)+","+
		    "debuglevel="+rw.geti("debuglevel", 0)+","+
		    "friendchainnames='"+Format.escSQL(rw.gets("friendchainnames"))+"',"+
		    "friendchain_libraries='"+Format.escSQL(rw.gets("friendchain_libraries"))+"',"+
		    "subselection='"+Format.escSQL(rw.gets("subselection"))+"',"+
		    "pp='"+rw.geti("pp", 0)+"',"+
		    "aod='"+aod_number+"',"+
		    "gen_macro_path='"+Format.escSQL(rw.gets("gen_macro_path"))+"',"+
		    "gen_parameters='"+Format.escSQL(rw.gets("gen_parameters"))+"',"+
		    "gen_libraries='"+Format.escSQL(rw.gets("gen_libraries"))+"',"+
		    "gen_macro_body='"+Format.escSQL(rw.gets("gen_macro_body"))+"',"+
		    "gen_total_events='"+rw.geti("gen_total_events", 0)+"',"+
		    "main_file_name='"+main_file_name+"',"+
		    "period_no_skip_processing='"+rw.geti("period_no_skip_processing", 0)+"'"+
		    " WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(previous_name)+"';");

		db.syncUpdateQuery("DELETE FROM train_period_runlist WHERE train_id = "+train_id+" AND period_name = '"+Format.escSQL(period_name)+"';");
		for(int i=1;i<=rw.geti("highest_runlist");i++){		    
		    db.syncUpdateQuery("INSERT INTO train_period_runlist (train_id, period_name, list_id, runlist, runlist_name, activated) VALUES ("+train_id+", '"+Format.escSQL(period_name)+"', "+i+", '"+Format.escSQL(rw.gets("runlist_"+i))+"', '"+Format.escSQL(rw.gets("runlist_"+i+"_name"))+"', '"+rw.geti("runlist_"+i+"_checkbox", 0)+"')");  
		}
	    }
	    
	    out.println("<script type=text/javascript>parent.modify()</script>");
	    return;
	    }
	}
    }
    
    // ------------------------ content
    
    String period = null;
    String period_main_file_name = null;//if this is a derived data dataset put here the main file name
    
    Set<String> runList = new HashSet<String>();
    
    if (period_name.length()>0){
	db.query("SELECT *,period_name as old_name FROM train_period WHERE train_id="+train_id+" AND period_name='"+Format.escSQL(period_name)+"';");
	if(db.moveNext()){
		
	    if (copyOtherPeriod){
		//System.err.println("Copy!");
		
		for (String field: new String[]{"train_id", "period_name", "old_name"})
		    p.modify(field, db.gets(field));
	    }
	    else
		{
		    p.fillFromDB(db);
		    if(!db.gets("refprod").startsWith("Derived Data:"))
			p.append("refprod_no_edit", db.gets("refprod"));

		    if (!searching)
			{
			    p.comment("com_period_no_skip_processing", db.getb("period_no_skip_processing"));
			    p.comment("com_pp", db.getb("pp"));
			    p.modify("aod_" + db.geti("aod"), "selected");
			}
		}
	    
	    period = db.gets("refprod");
	    period_main_file_name = db.gets("main_file_name");
	    if (db.geti("aod") == 100)
	    	    mc_gen = true;
	    
	    final StringTokenizer st = new StringTokenizer(getRunlist(train_id, period_name), " ,;\t\r\n");
	    
	    while (st.hasMoreTokens()){
		runList.add(st.nextToken());
	    }
	}else{
	    p.modify("train_id", train_id);//see also if period_name=0 and last else statement
	}
    }
    else if (!copyOtherPeriod && !searching) {
	p.modify("train_id", train_id);
	p.modify("maxmergefiles", 20);
	p.modify("test_files_no", (mc_gen) ? 600 : 2);
	p.modify("splitmaxinputfilenumber", (mc_gen) ? 10000 : 20);
	p.modify("ttl", 70000);
	p.modify("debuglevel", 0);
	p.modify("gen_total_events", 1000000);
	p.comment("com_pp", false);
	p.comment("com_period_no_skip_processing", false);
    }
    else
    {	
	p.modify("train_id", train_id);// see also first if statement if there is no result from the database
    }
    
    String q = "select jt_field1,jt_field4,jt_type,jt_id from job_types where ((jt_field4 in ('MC', 'RAW')) or (jt_field4='TRAIN' and jt_field1 like 'FILTER%')) ";
    
    String sPeriodFilter = rw.gets("period_filter").trim();
    
    if (sPeriodFilter.length()>0){
	q += "AND (jt_field1 ILIKE '%"+Format.escSQL(sPeriodFilter)+"%' OR jt_type ILIKE '%"+Format.escSQL(sPeriodFilter)+"%') ";
    }
    
    q += "order by jt_field4, lower(jt_field1) desc;";
    
    db.query(q);
    
    int jt_id=0;
    
    if (copyRefProd!=null)
	period = copyRefProd;

    if (copyMainFileName!=null)
	period_main_file_name = copyMainFileName;
    
    while (db.moveNext()){
	final String s = db.gets(1);
    
	String sDesc = s;
	
	String longDesc = db.gets(3);

	if (longDesc.contains("_Stage"))
	    continue;
	
	if (!longDesc.equals(sDesc)){
	    if (longDesc.startsWith(sDesc))
		longDesc = longDesc.substring(sDesc.length()).trim();
	
	    if (longDesc.startsWith(":"))
		longDesc = longDesc.substring(1).trim();
	
	    if (longDesc.length()>0)
		sDesc += " ("+lazyj.page.tags.Cut.cut(longDesc, 200)+")";
	}

	sDesc = lazyj.page.tags.Cut.cut(sDesc, 65);
	
	if (s.equals(period))
	    jt_id=db.geti("jt_id");
    
	p.append("opt_refprod", "<option value='"+Format.escHtml(s)+"' "+(s.equals(period) ? "selected" : "")+">"+Format.escHtml(sDesc)+"</option>\n");
    }

    //add derived data
    db.query("SELECT wg_no FROM train_def WHERE train_id="+train_id);
    final String wg_no = db.gets(1);
    
    db.query("SELECT train_name, train_id, id, lpm_id, output_files FROM train_run inner join train_def using(train_id) WHERE output_deleted=0 AND derived_data=1 AND train_finished_timestamp>0 AND wg_no = '"+wg_no+"' ORDER BY train_id, id;");

    String submitStr_derived_data = "";

    if(period==null||!period.startsWith("Derived Data:")){
	p.comment("com_hide_main_file_name", true);
	p.comment("com_hide_aod", false);
    }else{
	p.comment("com_hide_main_file_name", false);
	p.comment("com_hide_aod", true);
    }

    while (db.moveNext()){
	String derived_data_period_name = "Derived Data: " + db.gets("train_name") + " (" + db.geti("train_id") +"), run "+db.geti("id") +" ("+db.geti("lpm_id")+")";
	String derived_data_period_name_show = "Derived Data: " + db.gets("train_name") + ", run "+db.geti("id");	

	p.append("opt_refprod", "<option value='"+Format.escHtml(derived_data_period_name)+"' "+(derived_data_period_name.equals(period) ? "selected" : "")+">"+Format.escHtml(derived_data_period_name_show)+"</option>\n");
	if(derived_data_period_name.equals(period))
	    p.modify("refprod_no_edit", derived_data_period_name_show);


	submitStr_derived_data += "||" + derived_data_period_name + "|" + db.gets("output_files").replaceAll(",","|");

	if(derived_data_period_name.equals(period)){
	    final StringTokenizer st_derived_data = new StringTokenizer(db.gets("output_files"), ",");
	    while (st_derived_data.hasMoreTokens()){
		String tok = st_derived_data.nextToken();

		p.append("opt_refprod_main_file", "<option value='"+Format.escHtml(tok)+"' "+(tok.equals(period_main_file_name) ? "selected" : "")+">"+Format.escHtml(tok)+"</option>\n"); 
	    }
	}
    }
    p.append("all_main_file_names", submitStr_derived_data);
    p.append("refprod_main_file_no_edit", period_main_file_name);

    if(!copyOtherPeriod && !searching)
	addRunlists(p, train_id, period_name, unprivileged);

    if (jt_id>0){
	db.query("select distinct runno from job_runs_details where job_types_id="+jt_id+" and runno>0 order by 1;");
	
	StringBuilder sb = new StringBuilder();
	
	while (db.moveNext()){
	    if (sb.length()>0)
		sb.append(", ");
	
	    String run = db.gets(1);
	    
	    if (runList.size()==0 || runList.contains(run))
		sb.append("<font color=green>");
	    else
		sb.append("<font color=red>");
		
	    sb.append(db.gets(1));
	    
	    sb.append("</font>");
	}
	
	p.modify("runlist_all", sb.toString());
    }
    
    q = "select wg_no,train_name,period_name,train_id,aod from train_period natural inner join train_def WHERE (train_id!="+train_id+" OR period_name!='"+Format.escSQL(period_name)+"')";
    if (mc_gen)
        q += " AND aod = 100";
    else
        q += " AND aod != 100";
    q += " order by wg_no,train_name,period_name;";
    
    db.query(q);
    
    while (db.moveNext()){
	// skip derived data not from this PWG
	if (db.geti("aod") == 200 && !db.gets("wg_no").equals(wg_no))
	  continue;
	p.append("opt_copyperiod", "<option value='"+db.geti("train_id")+"/"+Format.escHtml(db.gets("period_name"))+"'>PWG"+db.gets("wg_no")+"/"+Format.escHtml(db.gets("train_name")+"/"+db.gets("period_name"))+"</option>");
    }

    p.comment("com_edit", !unprivileged);
    p.comment("com_mc_gen", mc_gen);
    
    // ------------------------ final bits and pieces

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_edit_period.jsp?train_id="+train_id+"&username="+principal.getName()+"&period_name="+period_name, baos.size(), request);
%>
