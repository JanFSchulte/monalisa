<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.io.ByteArrayOutputStream" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/ltm.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);

    ServletContext sc = getServletContext();
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");

    pMaster.modify("title", "LTM Management");
    
    // ----------
    // menu
    pMaster.modify("class_ltm", "_active");

    Page p = new Page("admin/ltm.res");
    Page pLine = new Page("admin/ltm_line.res");
    Page pEdit = new Page("admin/ltm_edit.res");
    
    String JSP = "admin/ltm.jsp";

    rw.setNotCache(response);
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    DB db = new DB();
    
    final String vsColors[] = new String[] { "#EEEEEE", "#FFFFFF" };
    
    // -----------
    // enable / disable
    String s = rw.gets("enable");
    
    if (s.length()>0){
	db.syncUpdateQuery("UPDATE rawdata_replication_ses SET active=1 WHERE sename='"+Format.escSQL(s)+"';");
    }
    
    s = rw.gets("disable");

    if (s.length()>0){
	db.syncUpdateQuery("UPDATE rawdata_replication_ses SET active=0 WHERE sename='"+Format.escSQL(s)+"';");
    }
    
    String sEdit = rw.gets("edit");
    
    // ----------
    // settings
    
    if (rw.geti("settings")==1){
	db.query("SELECT s_key FROM lpm_settings WHERE s_key LIKE 'ltm%';");
	
	DB db2 = new DB();
	
	while (db.moveNext()){
	    String sKey = db.gets(1);
	    
	    String sValue = rw.gets(sKey);
	    
	    if (sKey.equals("ltm_active"))
		sValue = sValue.length()>0 ? "1" : "0";
	    
	    db2.syncUpdateQuery("UPDATE lpm_settings SET s_value='"+Format.escSQL(sValue)+"' WHERE s_key='"+Format.escSQL(sKey)+"';");
	}
    }
    
    // -----------
    // Edit / add / remove
    
    s = rw.gets("add").trim().toUpperCase();
    
    if (s.length()>0){
	db.syncUpdateQuery("INSERT INTO rawdata_replication_ses (sename) VALUES ('"+Format.escSQL(s)+"');");
    }
    
    s = rw.gets("oldsename");
    
    if (s.length()>0){
	String sNew = rw.gets("sename").trim().toUpperCase();
	double dRatio = rw.getd("ratio", 5);
	
	if (sNew.length()==0)
	    db.syncUpdateQuery("DELETE FROM rawdata_replication_ses WHERE sename='"+Format.escSQL(s)+"';");
	else
	    db.syncUpdateQuery("UPDATE rawdata_replication_ses SET sename='"+Format.escSQL(sNew)+"',ratio="+dRatio+" WHERE sename='"+Format.escSQL(s)+"';");
    }
    
    // -----------
    // listing
    db.query("SELECT * FROM rawdata_replication_ses ORDER BY sename ASC;");
    
    int iColor = -1;
    
    long lTotalRuns = 0;
    long lTotalFiles = 0;
    long lTotalSize = 0;
    
    int iActiveCount = 0;
    int iDisabledCount = 0;
    
    while (db.moveNext()){
	Page pg = sEdit.equals(db.gets("sename")) ? pEdit : pLine;
    
	pg.fillFromDB(db);
	
	boolean active = false;
	
	try{
	    active = db.geti("active", 0)==1;
	}
	catch (Exception e){
	    // ignore
	}
	
	//System.err.println("active: "+active);
	
	if (!active){
	    pg.modify("strike_start", "<strike>");
	    pg.modify("strike_end", "</strike>");
	    pg.comment("com_active", false);
	    iDisabledCount++;
	}
	else{
	    pg.comment("com_notactive", false);
	    iActiveCount++;
	}
	
	pg.modify("bgcolor", vsColors[++iColor%2]);
	
	p.append("content", pg);
	
	lTotalRuns += db.getl("runcount");
	lTotalFiles += db.getl("files");
	lTotalSize += db.getl("totalsize");
    }

    // LTM settings
    db.query("SELECT s_key,s_value FROM lpm_settings WHERE s_key LIKE 'ltm%';");
    
    while (db.moveNext()){
	String sKey = db.gets(1);
	
	if (sKey.equals("ltm_active")){
	    boolean bActive = db.geti(2)==1;
	    
	    p.modify("ltm_status", bActive ? "checked" : "");
	    p.modify("ltm_status_text", bActive? "<font color=#009900><B>ACTIVE</B></font>" : "<font color=#990000><B>DISABLED</B></font>");
	}
	else{
	    p.modify(sKey, db.gets(2));
	}
    }

    // -----------
    // final
    
    p.modify("runs", lTotalRuns);
    p.modify("files", lTotalFiles);
    p.modify("size", lTotalSize);
    p.modify("active", iActiveCount);
    p.modify("disabled", iDisabledCount);
    
    pMaster.append(p);
    
    pMaster.write();
        
    s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/ltm.jsp", baos.size(), request);
%>
