<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,utils.IntervalQuery"%><%!
%><%
    final AlicePrincipal user = Users.get(request);

    if (user==null){
	out.println("You first have to login");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/changeField.jsp?not_authenticated", 0, request);
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);
    
    final int iRun = rw.geti("run");
    
    final String sField = rw.gets("field");
    
    final int pass = rw.geti("pass");
    
//    if (iRun<=0 || sField.length()<0 || !(sField.equals("luminosity") || sField.equals("energy") || sField.equals("events") || sField.equals("comment"))){
//	out.println("Invalid parameters");
//	return;
//  }
    
    final String sRunRange = rw.gets("runrange");
    final String sValue = rw.gets("value");
    
    final DB db = new DB();
    
    if (sRunRange.length()>0 && sValue.length()>0){
	final String sCond = IntervalQuery.numberInterval(sRunRange, "raw_run");
	
	if (sCond.length()>0){
	    String q = "SELECT * FROM configuration_view2 WHERE "+sCond+" AND ("+sField+" IS NULL OR "+sField+"!='"+Format.escSQL(sValue)+"');";
	
	    //System.err.println(q);
	
	    db.query(q);
	    
	    int count = db.count();
	    
	    if (db.count()>10){
		out.println("Your update would apply to "+count+" runs, which is probably not what you have intented. Please use narrower intervals.");
		return;
	    }
	    
	    final DB db2 = new DB();
	    
	    System.err.println("pass="+pass);
	    
	    while (db.moveNext()){
		if (pass==0){
	    	    db2.syncUpdateQuery("UPDATE configuration SET "+sField+"='"+Format.escSQL(sValue)+"', changedby='"+Format.escSQL(user.getName())+"', changedon=extract(epoch from now())::int WHERE run="+db.geti("raw_run"));
		
		    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration (run,detectors,"+sField+",changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(db.gets("detectors_list"))+"', '"+Format.escSQL(sValue)+"', '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		    }
		
		    db2.syncUpdateQuery("INSERT INTO configuration_history (run,"+sField+",changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(sValue)+"', '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		}
		else{
	    	    db2.syncUpdateQuery("UPDATE configuration SET changedby='"+Format.escSQL(user.getName())+"', changedon=extract(epoch from now())::int WHERE run="+db.geti("raw_run"));
		
		    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration (run,detectors,changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(db.gets("detectors_list"))+"', '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		    }
		    
		    db2.syncUpdateQuery("UPDATE configuration_perpass SET "+sField+"='"+Format.escSQL(sValue)+"' WHERE run="+db.geti("raw_run")+" AND pass="+pass);
		    
		    if (db2.getUpdateCount()==0){
			db2.syncUpdateQuery("INSERT INTO configuration_perpass (run,pass,"+sField+") VALUES ("+db.geti("raw_run")+", "+pass+", '"+Format.escSQL(sValue)+"');");
		    }
		
		    db2.syncUpdateQuery("INSERT INTO configuration_history (run,"+sField+",pass,changedby,changedon) VALUES ("+db.geti("raw_run")+", '"+Format.escSQL(sValue)+"', "+pass+", '"+Format.escSQL(user.getName())+"', extract(epoch from now())::int);");
		}
	    }
	}
    }

    if (pass==0)
	db.query("SELECT "+sField+" FROM configuration WHERE run<="+iRun+" AND "+sField+" IS NOT NULL ORDER BY run DESC LIMIT 1;");
    else
	db.query("SELECT "+sField+" FROM configuration_view2 WHERE run<="+iRun+" AND pass="+pass+" AND "+sField+" IS NOT NULL ORDER BY run DESC LIMIT 1;");
    
    final String sDefaultValue = db.gets(1);
    
    final Page p = new Page("configuration/admin/changeField.res");
    
    p.modify("run", iRun);
    p.modify("field", sField);
    p.modify("value", sDefaultValue);
    p.modify("pass", pass);
    
    lia.web.servlets.web.Utils.logRequest("/configuration/admin/changeField.jsp?u="+user+"&run="+iRun+"&field="+sField+"&value="+sDefaultValue+"&pass="+pass, 0, request);
    
    out.println(p);
%>