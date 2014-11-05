<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
    %><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_edit_group.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page(baos, "trains/admin/train_edit_group.res", false);
    
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    boolean admin = true; //principal.hasRole("admin");

    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);

	admin = db.moveNext();
    }

    if (!admin){
	out.println("You are not allowed here");
	return;
    }

    if (submit.startsWith("Insert")){
	if (rw.gets("group_name_new").length()>0){
	    String group_name_new = rw.gets("group_name_new");
	    p.append("marked_group", group_name_new);
	    db.syncUpdateQuery("SELECT Count(*) FROM train_group WHERE train_id="+train_id+" AND group_name='"+Format.escHtml(group_name_new)+"';");
	    if(db.geti(1)==0){
		db.syncUpdateQuery("INSERT INTO train_group VALUES ("+train_id+", '"+Format.escHtml(group_name_new)+"');");
		out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
	    }
	    else if(db.geti(1)==1){
		out.println("<script type=text/javascript>alert('The group "+Format.escHtml(group_name_new)+" already exists.');</script>");
	    } 
	}else{
	    out.println("<script type=text/javascript>alert('Please enter a group name.');</script>");
	}
    }
    else
    if (submit.startsWith("Rename")){
	if (rw.gets("group_name_renamed").length()>0){
	    String group_name_renamed = rw.gets("group_name_renamed");
	    p.append("marked_group", group_name_renamed);
	    String oldName = rw.getValues("groups")[0];
	    db.syncUpdateQuery("SELECT COUNT(*) from train_group WHERE train_id="+train_id+" AND group_name='"+Format.escHtml(group_name_renamed)+"';");
	    if(db.geti(1)>0){
	    out.println("<script type=text/javascript>alert('"+group_name_renamed+" already exists.');</script>");
	    }else if(oldName.equals("Default")||oldName.equals("Attic")){
		db.syncUpdateQuery("INSERT INTO train_group VALUES ("+train_id+", '"+Format.escHtml(group_name_renamed)+"');");
		db.syncUpdateQuery("UPDATE train_wagon SET group_name='"+Format.escHtml(group_name_renamed)+"' WHERE train_id="+train_id+" AND group_name='"+oldName+"';");
	    }else{
		db.syncUpdateQuery("Update train_group SET group_name='"+Format.escHtml(group_name_renamed)+"' WHERE train_id="+train_id+" AND group_name='"+Format.escHtml(oldName)+"';");
	    }
	    out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
	}else{
	    out.println("<script type=text/javascript>alert('Please enter a new group name.');</script>");
	}
    }
    else
    if (submit.startsWith("Save")){
	String name = rw.getValues("groups")[0];
	p.append("marked_group", name);
	db.syncUpdateQuery("Update train_group SET auto_activate_wagons='"+rw.geti("allow_auto_activate_wagons", 0)+"' WHERE train_id="+train_id+" AND group_name='"+Format.escHtml(name)+"';");
    }
    else
    if (submit.startsWith("Delete Group")){
	String delete = rw.getValues("groups")[0];
	db.syncUpdateQuery("DELETE from train_group WHERE train_id="+train_id+" AND group_name='"+Format.escHtml(delete)+"';");
	out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
    }
    else
    if (submit.startsWith("Delete Wagons")){
	p.append("marked_group", rw.getValues("groups")[0]);
	for (String wagon: rw.getValues("wagons")){
	    db.syncUpdateQuery("DELETE from train_wagon WHERE train_id="+train_id+" AND wagon_name='"+Format.escHtml(wagon)+"';");
	}
	out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
    }
    else
    if (submit.startsWith("Move Wagons")){
	p.append("marked_group", rw.getValues("groups")[0]);
	for (String wagon: rw.getValues("wagons")){
	    db.syncUpdateQuery("UPDATE train_wagon SET group_name = '"+Format.escSQL(rw.gets("wagon_destination"))+"' WHERE train_id="+train_id+" AND wagon_name='"+Format.escHtml(wagon)+"';");
	}
	out.println("<script type=text/javascript>parent.Windows.addObserver(parent.obs);</script>");
    }

    
    // ------------------------ content

    db.query("SELECT group_name, auto_activate_wagons FROM train_group WHERE train_id="+train_id+" ORDER BY group_name;");

    String allow_auto_activate_wagons = "";

    while (db.moveNext()){
	String group_name = db.gets("group_name");
	p.append("opt_groups", "<option value='"+Format.escHtml(group_name)+"'>"+Format.escHtml(db.gets(1))+"</option>");
	if(!allow_auto_activate_wagons.equals("")) allow_auto_activate_wagons+=";";
	allow_auto_activate_wagons += group_name + "," + db.getb("auto_activate_wagons");

	DB db2 = new DB("SELECT wagon_name from train_wagon where train_id="+train_id+" and group_name='"+group_name+"' order by wagon_name;");
	while (db2.moveNext()){
	    allow_auto_activate_wagons += "," + db2.gets("wagon_name");
	}

    }
    p.append("auto_activate_wagons", allow_auto_activate_wagons);


    // ------------------------ final bits and pieces


    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);



    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_edit_group.jsp?train_id="+train_id+"&username="+principal.getName(), baos.size(), request);
%>