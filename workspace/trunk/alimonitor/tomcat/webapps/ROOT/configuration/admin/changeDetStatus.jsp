<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,utils.IntervalQuery"%><%!
%><%
    final AlicePrincipal user = Users.get(request);

    if (user==null){
	out.println("You first have to login");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/changeDetStatus.jsp?not_authenticated", 0, request);
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);
    
    final int iRun = rw.geti("run");
    
    final String sDet = rw.gets("det");

    final int pass = rw.geti("pass");
    
    if (iRun<=0 || sDet.length()<0){
	out.println("Invalid parameters");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/changeDetStatus.jsp?u="+user+"&invalid_parameters", 0, request);
	return;
    }
    
    final StatusDictionary d = StatusDictionary.getInstance(sDet);
    
    final String sRunRange = rw.gets("runrange");
    final int iStatus = rw.geti("newstatus", -1000);
    
    final DB db = new DB();
    
    final String sField = sDet.length()>3 ? sDet : "det_"+Format.escSQL(sDet);
    
    if (sRunRange.length()>0 && iStatus!=-1000){
	final String sCond = IntervalQuery.numberInterval(sRunRange, "raw_run");
	
	if (sCond.length()>0){
	    String q = "SELECT distinct raw_run,detectors_list FROM configuration_view2 WHERE "+sCond+" AND ("+sField+" IS NULL OR "+sField+"!= "+iStatus+")";
	    
	    if (sDet.length()==3){
		q+= " AND exists (SELECT 1 FROM shuttle WHERE run=configuration_view2.raw_run and instance='PROD' and lower(detector)='"+Format.escSQL(sDet)+"')";
	    }
	    
	    db.query(q);
	    
	    int count = db.count();
	    
	    if (db.count()>10){
		out.println("Your update would apply to "+count+" runs, which is probably not what you have intented. Please use narrower intervals (10 runs or less at a time).");
		return;
	    }
	    
	    final DB db2 = new DB();
	    
	    while (db.moveNext()){
		if (pass>0){
	    	    db2.syncUpdateQuery("UPDATE configuration SET changedby='"+Format.escSQL(user.getName())+"', changedon=extract(epoch from now())::int WHERE run="+db.geti("raw_run"));
		
	    	    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration (run,detectors,changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(db.gets("detectors_list"))+"', '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		    }
		    
		    db2.syncUpdateQuery("UPDATE configuration_perpass SET "+sField+"="+iStatus+" WHERE run="+db.geti("raw_run")+" AND pass="+pass);
		    
		    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration_perpass (run,pass,"+sField+") VALUES ("+db.geti("raw_run")+", "+pass+", "+iStatus+");");
		    }
		
		    db2.syncUpdateQuery("INSERT INTO configuration_history (run,"+sField+",pass,changedby,changedon) VALUES ("+db.geti("raw_run")+", "+iStatus+", "+pass+",'"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		}
		else{
	    	    db2.syncUpdateQuery("UPDATE configuration SET "+sField+"="+iStatus+", changedby='"+Format.escSQL(user.getName())+"', changedon=extract(epoch from now())::int WHERE run="+db.geti("raw_run"));
		
	    	    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration (run,detectors,"+sField+",changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(db.gets("detectors_list"))+"', "+iStatus+", '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		    }
		
		    db2.syncUpdateQuery("INSERT INTO configuration_history (run,"+sField+",changedby,changedon) VALUES ("+db.geti("raw_run")+", "+iStatus+", '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		}
	    }
	}
    }

    if (pass==0)
	db.query("SELECT "+sField+" FROM configuration WHERE run<="+iRun+" AND "+sField+" IS NOT NULL ORDER BY run DESC LIMIT 1;");
    else
	db.query("SELECT "+sField+" FROM configuration_view2 WHERE pass="+pass+" AND run<="+iRun+" AND "+sField+" IS NOT NULL ORDER BY run DESC LIMIT 1;");
    
    final int iDefaultStatus = db.geti(1);
    
    if (rw.gets("short_text").length()>0){
	int iEditStatus = rw.geti("status");
	
	StatusDictionaryEntry sde = d.get(iEditStatus);
	
	if (sde==null){
	    sde = new StatusDictionaryEntry(rw.gets("det"), rw.gets("short_text"), rw.gets("long_text"), rw.gets("html_color"), user.getName());
	}
	else{
	    sde.setShortText(rw.gets("short_text"));
	    sde.setLongText(rw.gets("long_text"));
	    sde.setHTMLColor(rw.gets("html_color"));
	    sde.save(user.getName());
	}
    }
    
    final Page p = new Page("configuration/admin/changeDetStatus.res");

    for (StatusDictionaryEntry sde: d.values()){
	p.append("short_text["+sde.getStatus()+"] = '"+Format.escJS(sde.getShortText())+"';");
	p.append("long_text["+sde.getStatus()+"] = '"+Format.escJS(sde.getLongText())+"';");
	p.append("html_color["+sde.getStatus()+"] = '"+Format.escJS(sde.getHTMLColor())+"';");
	
	p.append("opt_values", "<option value="+sde.getStatus()+(sde.getStatus()==iDefaultStatus ? " selected" :"")+">"+sde.getStatus()+" ("+sde.getShortText()+")");
    }
    
    p.modify("run", iRun);
    p.modify("det", sDet);
    p.modify("pass", pass);
    
    out.println(p);
    lia.web.servlets.web.Utils.logRequest("/configuration/admin/changeDetStatus.jsp?u="+user+"&run="+iRun+"&det="+sDet+"&pass="+pass, 0, request);
%>