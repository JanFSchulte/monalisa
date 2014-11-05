<%@ page import="lia.web.servlets.web.display,lia.web.utils.ServletExtension,lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*, java.awt.*, org.jfree.chart.*, org.jfree.chart.plot.*, org.jfree.chart.entity.*, org.jfree.data.xy.*, org.jfree.chart.renderer.xy.XYLineAndShapeRenderer, org.jfree.chart.axis.*, org.jfree.chart.labels.*, java.text.DecimalFormat" %><%!

      private static final void addConfigs(Page p, int train_id, String wagon_name, boolean unprivileged){
	  DB db = new DB("SELECT config, subwagon_name, activated from train_subwagon WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"';");
	  int list_id=1;
	  
 	  p.comment("com_has_subwagons", db.count()>0);
 
 	  Page psubwagon = new Page("trains/admin/train_edit_wagon_subwagon.res", false);
 
 	  psubwagon.append("list_id", "0");
 	  psubwagon.append("subwagon_name", "XXX");
 	  psubwagon.append("config", "");
 	  psubwagon.comment("com_edit", true);
 	  psubwagon.comment("com_activated" , true);
 
 	  p.append("wagon_configurations_copy", psubwagon);
	  
	  
	  while(db.moveNext()){
 	      psubwagon.comment("com_edit" ,!unprivileged);
 	      psubwagon.comment("com_activated" , db.getb("activated"));
 	      psubwagon.append("list_id", list_id);
 	      psubwagon.append("subwagon_name", db.gets("subwagon_name"));
		  psubwagon.append("config", db.gets("config"));
		  list_id++;
		  p.append("wagon_configurations", psubwagon);
	

	  }
	  p.append("highest_subwagon", list_id-1);
      }

%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_edit_wagon.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page p = new Page(baos, "trains/admin/train_edit_wagon.res", false);
    
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    final String wagon_name = rw.gets("wagon_name");
    final String period_name = rw.gets("period_name");//for activating this wagon for a certain dataset
    final String group_name = rw.gets("group_name");
     
    final String previous_name = rw.gets("old_name");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    boolean admin = true; //principal.hasRole("admin");
    
    String wagonowner = principal.getName();

    boolean unprivileged = false;

    db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
    final boolean train_operator = db.moveNext();

    if (!admin)
	admin = train_operator;

    if (wagon_name.length()>0){
	if (previous_name.length()>0){
	    db.query("SELECT username FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(previous_name)+"';");
	    
	    if (!db.moveNext())
		admin=true;
	    else
	    if (db.gets(1).equals(principal.getName()))
		admin = true;
	}
	else{
	    db.query("SELECT username FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
	    
	    if (!db.moveNext())
		admin=true;
	    else
	    if (db.gets(1).equals(principal.getName()))
		admin = true;	    
	}
	wagonowner = db.gets(1);
    }
    else{
	admin = true;
    }

    if (!admin && rw.geti("op")==0){
	admin = true;
	unprivileged = true;
    }

    if (!admin){
	out.println("You are not allowed here");
	return;
    }

    boolean copyAnotherWagon = false;
    int showWagons = 2;

    Set<String> depsSet = new LinkedHashSet<String>();
    
    String selectedOutputFile = "";

  if (rw.gets("submit").startsWith("Copy")){
	String ref = rw.gets("copywagon");
	
	if (ref.equals("showallwagons")) {
	  showWagons = 1;
	}
	if (ref.equals("showmywagons")) {
	  showWagons = 2;
	}
	else if (ref.indexOf("/")>0){
	    int copy_train_id = Integer.parseInt(ref.substring(0, ref.indexOf("/")));
	    String copy_wagon_name = ref.substring(ref.indexOf("/")+1);
	    db.query("SELECT * FROM train_wagon WHERE train_id="+copy_train_id+" AND wagon_name='"+Format.escSQL(copy_wagon_name)+"';");
	
	    if (db.moveNext()){
		p.modify("train_id", train_id);
		p.modify("old_name", wagon_name);
		p.fillFromDB(db);
	    
	    	StringTokenizer st = new StringTokenizer(db.gets("dependencies"), ";,");
	
		while (st.hasMoreTokens()){
		    depsSet.add(st.nextToken().trim());
		}
		
		selectedOutputFile = db.gets("outputfile");
		p.comment("com_wagon_no_skip_processing", db.getb("wagon_no_skip_processing"));
		p.comment("com_addtask_needs_alien", db.getb("addtask_needs_alien"));
	    
		copyAnotherWagon = true;
	    }
	    addConfigs(p, copy_train_id, copy_wagon_name, unprivileged);
	}
  }
  else{
      if (rw.geti("op") != 0 && wagon_name.length()>0){
        lia.web.servlets.web.Utils.logRequest("/trains/admin/train_edit_wagon.jsp?train_id="+train_id+"&username="+principal.getName()+"&wagon_name="+wagon_name+"&op="+rw.geti("op"), baos.size(), request);

	if (rw.geti("op") == 7|| rw.geti("op") == 8){
	    db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
	    if (rw.geti("op") == 8){
		db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT "+train_id+", '"+Format.escSQL(wagon_name)+"', period_name FROM train_period WHERE train_id="+train_id+" AND enabled=1;");
		db.query("SELECT period_name FROM train_period WHERE train_id="+train_id+" AND enabled=1;");
		while(db.moveNext())
		    trains.UpdateTestStatus.activateDependentWagons(train_id, wagon_name, db.gets("period_name"));
	    }

	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
	else
	if (rw.geti("op") == 3){
	    db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"' AND period_name='"+Format.escSQL(period_name)+"';");

	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
	else
	if (rw.geti("op") == 4){
	    db.syncUpdateQuery("INSERT INTO train_wagon_period VALUES ("+train_id+", '"+Format.escSQL(wagon_name)+"', '"+Format.escSQL(period_name)+"');");
	    trains.UpdateTestStatus.activateDependentWagons(train_id, wagon_name, period_name);

	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
	if (rw.geti("op") == 2){
	    // delete
	    db.syncUpdateQuery("DELETE FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
	    
	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
	else
	if (rw.geti("op") == 1){
	    // insert/update
	    
	    String deps = "";
	    
	    for (String s: rw.getValues("dependencies")){
		deps += (deps.length()>0 ? "," : "") + s;
	    }
	    
	    if (previous_name.length()==0){
		// insert
		
		db.query("SELECT 1 FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
		if (db.moveNext()){
		    out.println("Wagon name conflicts with an existing entry, please go back and choose another name.");
		    return;
		}
		String parameters = rw.gets("parameters");
		parameters.replaceAll("\n", " ");
		out.println("<script type=text/javascript>alert('TEST');</script>");
		out.println("<script type=text/javascript>alert('INSERT INTO train_wagon (train_id, wagon_name, macro_path, macro_body, parameters, libraries, dependencies, username, outputfile, terminatefile, addtask_needs_alien, wagon_no_skip_processing, group_name) VALUES ("+train_id+", "+Format.escSQL(wagon_name)+", "+Format.escSQL(rw.gets("macro_path"))+", "+Format.escSQL(rw.gets("macro_body"))+", "+Format.escSQL(parameters)+", "+Format.escSQL(rw.gets("libraries"))+", "+Format.escSQL(deps)+", "+Format.escSQL((rw.gets("wagonowner").length() > 0) ? rw.gets("wagonowner") : "Name")+", "+Format.escSQL(rw.gets("outputfile"))+", "+Format.escSQL(rw.gets("terminatefile"))+", "+rw.geti("addtask_needs_alien", 0)+", "+rw.geti("wagon_no_skip_processing", 0)+", "+Format.escSQL(rw.gets("wagongroup"))+");');</script>");
		//~ out.println("<script type=text/javascript>alert('INSERT INTO train_wagon (train_id, wagon_name, macro_path, macro_body, parameters, libraries, dependencies, username, outputfile, terminatefile, addtask_needs_alien, wagon_no_skip_processing, group_name) VALUES ("+train_id+", \'"+Format.escSQL(wagon_name)+"\', \'"+Format.escSQL(rw.gets("macro_path"))+"\', \'"+Format.escSQL(rw.gets("macro_body"))+"\', \'"+Format.escSQL(parameters)+"\', \'"+Format.escSQL(rw.gets("libraries"))+"\', \'"+Format.escSQL(deps)+");');</script>");
		out.println("<script type=text/javascript>alert('INSERT INTO train_wagon (train_id, wagon_name, macro_p)');</script>");
		db.syncUpdateQuery("INSERT INTO train_wagon (train_id, wagon_name, macro_path, macro_body, parameters, libraries, dependencies, username, outputfile, terminatefile, addtask_needs_alien, wagon_no_skip_processing, group_name) VALUES ("+train_id+", '"+Format.escSQL(wagon_name)+"', '"+Format.escSQL(rw.gets("macro_path"))+"', '"+Format.escSQL(rw.gets("macro_body"))+"', '"+Format.escSQL(parameters)+"', '"+Format.escSQL(rw.gets("libraries"))+"', '"+Format.escSQL(deps)+"', '"+Format.escSQL((rw.gets("wagonowner").length() > 0) ? rw.gets("wagonowner") : "Name")+"', '"+Format.escSQL(rw.gets("outputfile"))+"', '"+Format.escSQL(rw.gets("terminatefile"))+"', '"+rw.geti("addtask_needs_alien", 0)+"', '"+rw.geti("wagon_no_skip_processing", 0)+"', '"+Format.escSQL(rw.gets("wagongroup"))+"');");

		for(int i=1;i<=rw.geti("highest_subwagon");i++){		    
		    db.syncUpdateQuery("INSERT INTO train_subwagon (train_id, wagon_name, config, subwagon_name, activated) VALUES ("+train_id+", '"+Format.escSQL(wagon_name)+"', '"+Format.escSQL(rw.gets("subwagon_"+i))+"', '"+Format.escSQL(rw.gets("subwagon_"+i+"_name"))+"', '"+rw.geti("subwagon_"+i+"_checkbox", 0)+"');");
		}

	    }
	    else{
		// update
		
		if (!wagon_name.equals(previous_name)){
		    db.query("SELECT 1 FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
		    if (db.moveNext()){
			out.println("Wagon name conflicts with an existing entry, please go back and choose another name.");
			return;
	    	    }
		}
		String parameters = rw.gets("parameters");
		parameters = parameters.replaceAll("(\\r|\\n)", " ");

		String q = "UPDATE train_wagon SET wagon_name='"+Format.escSQL(wagon_name)+"', macro_path='"+Format.escSQL(rw.gets("macro_path"))+"', macro_body='"+Format.escSQL(rw.gets("macro_body"))+"', parameters='"+Format.escSQL(parameters)+"', "+
		    "libraries='"+Format.escSQL(rw.gets("libraries"))+"', dependencies='"+Format.escSQL(deps)+"', outputfile='"+Format.escSQL(rw.gets("outputfile"))+"', terminatefile='"+Format.escSQL(rw.gets("terminatefile"))+"'"+", addtask_needs_alien='"+rw.geti("addtask_needs_alien", 0)+"', wagon_no_skip_processing='"+rw.geti("wagon_no_skip_processing", 0)+"'";
		    
		if (train_operator){
		  q += ", username = '"+rw.gets("wagonowner")+"'";
		}
		   
		q += ", group_name = '"+rw.gets("wagongroup")+"'";
		q += " WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(previous_name)+"';";
		    
		db.syncUpdateQuery(q);

		db.syncUpdateQuery("DELETE FROM train_subwagon WHERE train_id = "+train_id+" AND wagon_name = '"+Format.escSQL(previous_name)+"';");
		for(int i=1;i<=rw.geti("highest_subwagon");i++){	    
		    db.syncUpdateQuery("INSERT INTO train_subwagon (train_id, wagon_name, config, subwagon_name, activated) VALUES ("+train_id+", '"+Format.escSQL(wagon_name)+"', '"+Format.escSQL(rw.gets("subwagon_"+i))+"', '"+Format.escSQL(rw.gets("subwagon_"+i+"_name"))+"', '"+rw.geti("subwagon_"+i+"_checkbox", 0)+"');"); 
		}

		//update dependencies
		if (!wagon_name.equals(previous_name)){
		    db.query("SELECT wagon_name, dependencies from train_wagon where dependencies like '%"+previous_name+"%' and train_id="+train_id+";");

		    StringTokenizer st = new StringTokenizer(db.gets("dependencies"), ",");
		    String newDependencies="";
		    Boolean change = false;
		    while (st.hasMoreTokens()){
			if(!newDependencies.equals("")) newDependencies+=",";
			String dep = st.nextToken();
			if(dep.equals(previous_name)) {
			    dep=wagon_name;
			    change = true;
			}
			newDependencies+=dep;
		    }
		    if(change)
			db.syncUpdateQuery("UPDATE train_wagon SET dependencies='"+newDependencies+"' where train_id="+train_id+" and wagon_name='"+db.gets("wagon_name")+"';");
		}
	    }

	    out.println("<script type=text/javascript>parent.setBookmark('wagons');</script>");
	    out.println("<script type=text/javascript>parent.modify()</script>");
	    return;
	}
      }else if(rw.geti("op") != 0 && group_name.length()>0 && period_name.length()>0){

	if (rw.geti("op") == 5){
	    db.syncUpdateQuery("DELETE FROM train_wagon_period WHERE train_id="+train_id+" AND period_name='"+period_name+"' AND wagon_name IN (SELECT wagon_name FROM train_wagon WHERE train_id="+train_id+" and group_name='"+group_name+"');");

	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
	else
	if (rw.geti("op") == 6){
	    db.query("SELECT wagon_name FROM train_wagon WHERE train_id="+train_id+" AND group_name='"+group_name+"' AND wagon_name NOT IN (SELECT wagon_name FROM train_wagon_period WHERE train_id="+train_id+" AND period_name='"+period_name+"');");
	    while(db.moveNext())
		trains.UpdateTestStatus.activateDependentWagons(train_id, db.gets("wagon_name"), period_name);

	    db.syncUpdateQuery("INSERT INTO train_wagon_period (train_id, wagon_name, period_name) SELECT train_id, wagon_name, '"+period_name+"' FROM train_wagon WHERE train_id="+train_id+" AND group_name='"+group_name+"' AND wagon_name NOT IN (SELECT wagon_name FROM train_wagon_period WHERE train_id="+train_id+" AND period_name='"+period_name+"');");

	    response.sendRedirect("/trains/train.jsp?train_id="+train_id+"#wagons");
	    return;
	}
    }
  }
    
    // ------------------------ content
    
    
    
    if (!copyAnotherWagon){
    
	boolean modifyId = true;

	if (wagon_name.length()>0){
	    db.query("SELECT * FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escSQL(wagon_name)+"';");
	    if(db.moveNext()){
		modifyId=false;
		p.fillFromDB(db);
	    
		p.modify("old_name", db.gets("wagon_name"));
		p.comment("com_wagon_no_skip_processing", db.getb("wagon_no_skip_processing"));
		p.comment("com_addtask_needs_alien", db.getb("addtask_needs_alien"));
		
		StringTokenizer st = new StringTokenizer(db.gets("dependencies"), ";,");
		
		while (st.hasMoreTokens()){
		    depsSet.add(st.nextToken().trim());
		}
		
		selectedOutputFile = db.gets("outputfile");

		//scale parameters box
		int parameters_length = db.gets("parameters").length();
		p.append("number_rows_parameters", ((parameters_length/85+1 < 5) ? (parameters_length/85+1) : 5));
	    }
	    addConfigs(p, train_id, wagon_name, unprivileged);
	    
	}
	if(modifyId){
	    p.modify("train_id", train_id);
	    p.comment("com_wagon_no_skip_processing", false);
	    p.comment("com_addtask_needs_alien", false);
	}
    }
    
    if (train_operator) {
      db.query("SELECT DISTINCT(username) FROM train_wagon ORDER BY username");
      boolean foundMyself = false;
      while (db.moveNext()){
	p.append("wagonowner_list", "<option value='"+Format.escHtml(db.gets(1))+"' "+((wagonowner.equals(db.gets(1))) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
	if (db.gets(1).equals(principal.getName()))
	  foundMyself = true;
      }
      if (!foundMyself)
	p.append("wagonowner_list", "<option value='"+Format.escHtml(principal.getName())+"' "+((wagonowner.equals(principal.getName())) ? "selected" : "")+">"+Format.escHtml(principal.getName())+"</option>");
    }

    db.query("SELECT group_name FROM train_group WHERE train_id="+train_id+" ORDER BY (CASE when group_name='Attic' THEN 1 ELSE 0 END),lower(group_name);");
 
    final DB db2 = new DB();
    db2.query("SELECT group_name FROM train_wagon WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"';");
    while (db.moveNext()){
	String this_group_name = db2.gets(1);
	if(this_group_name.equals(""))
	    this_group_name="Default";
	p.append("wagongroup_list", "<option value='"+Format.escHtml(db.gets(1))+"' "+((this_group_name.equals(db.gets(1))) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }

    db.query("SELECT outputfiles FROM train_def WHERE train_id="+train_id);
    String[] fileList = db.gets(1).replaceAll(" ", "").split(",");

    // for new wagons, selected the first output file
    if (selectedOutputFile.length() == 0)
      selectedOutputFile = fileList[0];

    for (int i=0; i<fileList.length; i++){
      p.append("outputfile_opt", "<option value='"+Format.escHtml(fileList[i])+"' "+((selectedOutputFile.equals(fileList[i])) ? "selected" : "")+">"+Format.escHtml(fileList[i])+"</option>");
    }

    db.query("SELECT wagon_name FROM train_wagon WHERE train_id="+train_id+" AND wagon_name!='"+Format.escSQL(wagon_name)+"' ORDER BY LENGTH(dependencies) ASC, wagon_name ASC;");
	
    while (db.moveNext()){
        p.append("dependencies_opt", "<option value='"+Format.escHtml(db.gets(1))+"' "+(depsSet.contains(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }

    String q = "SELECT wg_no,train_name,wagon_name,train_id FROM train_wagon INNER JOIN train_def USING(train_id) WHERE (train_id!="+train_id+" OR wagon_name!='"+Format.escSQL(wagon_name)+"')";
    if (showWagons == 2)
      q += " AND (username='"+Format.escSQL(principal.getName())+"')";
    q += " ORDER BY 1,2,3;";
    db.query(q);

    while (db.moveNext()){
	String k = db.gets(4)+"/"+db.gets(3);
    
	String s = db.gets(1)+"/"+db.gets(2)+"/"+db.gets(3);
	
	p.append("copy_list", "<option value='"+Format.escHtml(k)+"'>"+Format.escHtml(s)+"</option>");
    }


    p.comment("com_edit", !unprivileged);
    p.comment("com_train_operator", train_operator);

    //for the wagon statistics
    p.modify("field_train_id", train_id);
    p.modify("field_wagon_name",wagon_name);

    // ------------------------ final bits and pieces

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_edit_wagon.jsp?train_id="+train_id+"&username="+principal.getName()+"&wagon_name="+wagon_name, baos.size(), request);
%>
