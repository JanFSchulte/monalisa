<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
    %><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/admin_page.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
            
    final Page p = new Page(baos, "trains/admin/admin_page.res", false);
    
    final DB db = new DB();
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    pMaster.modify("title", "Analysis trains");


    if (!(principal.getName().equals("mazimmer")|principal.getName().equals("jgrosseo")|principal.getName().equals("costing"))){
	out.println("You are not allowed here");
	return;
    }


    if (submit.startsWith("Insert")){
	String train_name = Format.escHtml(rw.gets("train_name"));
	if (train_name.length()>0){
	    db.query("SELECT Count(*) FROM train_def WHERE train_name='"+train_name+"';");
	    if(db.geti(1)==0){
		//get highest id
		db.query("SELECT max(train_id) FROM train_def;");
		int train_id=db.geti(1)+1;
		String outputfiles = Format.escHtml(rw.gets("outputfiles"));
		if(outputfiles.equals("")) outputfiles = "AnalysisResults.root";

		db.syncUpdateQuery("INSERT INTO train_def (train_id, train_name, train_type, train_debuglevel, excludefiles, additionalpackages, outputfiles, wg_no) VALUES ("+train_id+", '"+Format.escHtml(train_name)+"', "+rw.geti("train_type")+", "+rw.geti("train_debuglevel")+", '"+Format.escHtml(rw.gets("excludefiles"))+"', '"+Format.escHtml(rw.gets("additionalpackages"))+"', '"+outputfiles+"', '"+Format.escHtml(rw.gets("wg_no"))+"');");

		String train_operator = Format.escHtml(rw.gets("train_operator"));
		String toTokenizer = train_operator.replaceAll(" ","");
		StringTokenizer tokenizer = new StringTokenizer(toTokenizer, ",");
		while(tokenizer.hasMoreTokens()) {
		    String operator = tokenizer.nextToken();
		    db.query("Select Count(*) from train_operator where username='"+operator+"';");
		    if(db.geti(1)==0)
			db.syncUpdateQuery("INSERT INTO train_operator (username, wg_no) VALUES('"+operator+"', '"+Format.escHtml(rw.gets("wg_no"))+"');");			
		    db.syncUpdateQuery("INSERT INTO train_operator_permission (train_id, username) VALUES("+train_id+", '"+operator+"');");
		}
		//add Default and Attic group
		db.syncUpdateQuery("INSERT INTO train_group (train_id, group_name) VALUES ("+train_id+", 'Default');");
		db.syncUpdateQuery("INSERT INTO train_group (train_id, group_name) VALUES ("+train_id+", 'Attic');");
	    }else{
		out.println("<script type=text/javascript>alert('This train_name already exists, please chose another one.');</script>");
	    }
	}else{
	    out.println("<script type=text/javascript>alert('Please enter a train name.');</script>");
	}
    }
    else
    if (submit.startsWith("Change")){
	String oldName = Format.escHtml(rw.getValues("trains")[0]);
	db.query("SELECT train_id FROM train_def WHERE train_name='"+oldName+"';");
	int train_id=db.geti(1);
	if(train_id==rw.geti("train_id")){
	    String train_name=Format.escHtml(rw.gets("train_name"));
	    if(train_name.length()>0 && !oldName.equals(train_name)){
		db.query("SELECT Count(*) FROM train_def WHERE train_name='"+train_name+"';");
		if(db.geti(1)==0){
		    db.syncUpdateQuery("Update train_def SET train_name='"+Format.escHtml(rw.gets("train_name"))+"' WHERE train_id="+train_id+";");
		}else{
		    out.println("<script type=text/javascript>alert('This train_name already exists, please chose another one.');</script>");
		}
	    }
	    db.syncUpdateQuery("Update train_def SET train_type="+rw.geti("train_type")+" WHERE train_id="+train_id+";");
	    db.syncUpdateQuery("Update train_def SET train_debuglevel='"+rw.geti("train_debuglevel")+"' WHERE train_id="+train_id+";");
	    db.syncUpdateQuery("Update train_def SET excludefiles='"+Format.escHtml(rw.gets("excludefiles"))+"' WHERE train_id="+train_id+";");
	    db.syncUpdateQuery("Update train_def SET additionalpackages='"+Format.escHtml(rw.gets("additionalpackages"))+"' WHERE train_id="+train_id+";");
	    String outputfiles = Format.escHtml(rw.gets("outputfiles"));
	    if(outputfiles.equals("")) outputfiles = "AnalysisResults.root";
	    db.syncUpdateQuery("Update train_def SET outputfiles='"+outputfiles+"' WHERE train_id="+train_id+";");
	    db.syncUpdateQuery("Update train_def SET wg_no='"+Format.escHtml(rw.gets("wg_no"))+"' WHERE train_id="+train_id+";");
	    db.syncUpdateQuery("DELETE FROM train_operator_permission WHERE train_id="+train_id+";");
	    String train_operator = Format.escHtml(rw.gets("train_operator"));
	    String toTokenizer = train_operator.replaceAll(" ","");
	    StringTokenizer tokenizer = new StringTokenizer(toTokenizer, ",");
	    while(tokenizer.hasMoreTokens()) {
		String operator = tokenizer.nextToken();
		db.query("SELECT Count(*) FROM train_operator where username='"+operator+"';");
		if(db.geti(1)==0)
		    db.syncUpdateQuery("INSERT INTO train_operator (username, wg_no) VALUES('"+operator+"', '"+Format.escHtml(rw.gets("wg_no"))+"');");
		db.syncUpdateQuery("INSERT INTO train_operator_permission (train_id, username) VALUES("+train_id+", '"+operator+"');");
	    }
	}else{
	    db.query("SELECT count(*) FROM train_def WHERE train_id="+rw.geti("train_id")+";");
	    if(db.geti(1)==0){
		db.syncUpdateQuery("Update train_def SET train_id="+rw.geti("train_id")+" WHERE train_id="+train_id+";");
	    }else{
		out.println("<script type=text/javascript>alert('There is already a train with this train_id');</script>");
	    }
	}
    }else
    if (submit.startsWith("Delete")){
	String oldName = Format.escHtml(rw.getValues("trains")[0]);
	db.query("SELECT train_id FROM train_def WHERE train_name='"+oldName+"';");
	int train_id=db.geti(1);
	db.syncUpdateQuery("DELETE FROM train_operator_permission WHERE train_id="+train_id+";");
	db.syncUpdateQuery("DELETE FROM train_def WHERE train_id="+train_id+";");
	db.syncUpdateQuery("DELETE FROM train_wagon WHERE train_id="+train_id+";");
    }else
    if (submit.startsWith("Remove")){
	String oldOperator = Format.escHtml(rw.getValues("operators2")[0]);
	db.syncUpdateQuery("DELETE FROM train_operator WHERE username='"+oldOperator+"';");
    }

    db.query("SELECT * FROM train_def ORDER BY lower(train_name);");
    String submitStr ="";
	
    while (db.moveNext()){
	p.append("opt_trains", "<option value='"+Format.escHtml(db.gets("train_name"))+"'>"+Format.escHtml(db.gets("train_name"))+"</option>");
	submitStr += db.geti("train_id") + "|";
	submitStr += db.gets("train_name") + "|";
	submitStr += db.gets("train_type") + "|";
	submitStr += db.geti("train_debuglevel") + "|";
	submitStr += db.gets("excludefiles") + "|";
	submitStr += db.gets("additionalpackages") + "|";
	submitStr += db.gets("outputfiles") + "|";
	
	DB db2 = new DB("SELECT username from train_operator_permission where train_id="+db.geti("train_id")+";");
	boolean first = true;
	while (db2.moveNext()){
	    if(first){first=false;}else{submitStr += ", ";}
	    submitStr += db2.gets("username");
	}
	submitStr += "|";
	submitStr += db.gets("wg_no") + ";";
    }

    db.query("SELECT DISTINCT username FROM train_operator_permission ORDER BY username;");
    int first = 0;
    while (db.moveNext()){
	if(first==0){
	    p.append("opt_operators", Format.escHtml(db.gets("username")));
	}else{
	    p.append("opt_operators", ", "+Format.escHtml(db.gets("username")));
	}
	first++;
    }

    db.query("SELECT DISTINCT username FROM train_operator where username not in (SELECT DISTINCT username FROM train_operator_permission ORDER BY username) ORDER BY username;");
    while (db.moveNext()){
	p.append("opt_operators2", "<option value='"+Format.escHtml(db.gets("username"))+"'>"+Format.escHtml(db.gets("username"))+"</option>");
    }

    db.query("SELECT distinct wg_no FROM train_operator ORDER BY wg_no");
    while (db.moveNext()){
	p.append("wg_no", "<option value='"+Format.escHtml(db.gets(1))+"'>"+Format.escHtml(db.gets(1))+"</option>");
    }

    p.append("train_info", submitStr);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);



    lia.web.servlets.web.Utils.logRequest("/trains/admin_page.jsp?username="+principal.getName(), baos.size(), request);
%>