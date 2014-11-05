<%@ page import="alimonitor.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*,alien.catalogue.*" %><%!

private static String getColor(int rowParity, boolean bEnabled){
    if (bEnabled){
	return rowParity%2 == 0 ? "#BBFFBB" : "#99FF99";
    }
    
    return rowParity%2 == 0 ? "#FFEEEE" : "#FFDDDD";
}

%><%
    lia.web.servlets.web.Utils.logRequest("START /lpm/lpm_manager.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");

    pMaster.modify("title", "LPM Management");
    
    //menu
    pMaster.modify("class_lpm", "_active");

    final Page p = new Page("lpm/lpm_manager.res");
    final Page pLine = new Page("lpm/lpm_manager_line.res", false);
    final Page pEdit = new Page("lpm/lpm_manager_edit.res");

    final String JSP = "lpm/lpm_manager.jsp";

    rw.setNotCache(response);
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    String URL="/"+JSP;
    boolean bQM = false;

    boolean bAuthOK = false;

    final AlicePrincipal principal = Users.get(request);
    
    if (principal!=null){
	bAuthOK = principal.hasRole("webadmin");
    }
        
    final Enumeration en = request.getParameterNames();
    
    while (en.hasMoreElements()){
	String sParam = (String) en.nextElement();
	
	String[] values = request.getParameterValues(sParam);
	
	for (int i=0; values!=null && i<values.length; i++){
	    URL = URL + (bQM ? "&" : "?") + URLEncoder.encode(sParam)+"="+URLEncoder.encode(values[i]);
	    bQM = true;
	}
    }
    
    final int iAdd = rw.geti("add", -1);
    
    final int iEdit = rw.geti("edit", -1);
    
    final int iDel = rw.geti("delete", -1);

    final int iEnable = rw.geti("enable", -1);

    int iID = rw.geti("id", -1);
    
    final int iSettings = rw.geti("submit_trigger", -1);

    final int iLTMSettings = rw.geti("ltm_submit_trigger", -1);
    
    if (iAdd > 0 || iEdit > 0 || iDel > 0 || iID >= 0 || iEnable > 0 || iSettings > 0 || iLTMSettings > 0){
	if(!bAuthOK){
	    response.sendRedirect("/dologin.jsp?page="+URLEncoder.encode(URL));
	    return;
	}
    }
    
    final String sAccount = rw.gets("account");

    final DB db = new DB();

    if (iDel > 0){
	db.syncUpdateQuery("DELETE FROM lpm_chain WHERE id="+iDel+";");
	response.sendRedirect("/"+JSP+"?account="+Format.encode(sAccount));
	return;
    }
    
    if (iEnable > 0){
	db.syncUpdateQuery("UPDATE lpm_chain SET enabled=(enabled + 1)%2 WHERE id="+iEnable);
	response.sendRedirect("/"+JSP+"?account="+Format.encode(sAccount)+"#"+iEnable);
	return;
    }
    
    if (iID >= 0){
	try{
	    String jdl = rw.gets("jdl");
	    String parameters = rw.gets("parameters");
	    String alienuser = rw.gets("alienuser");
	    int iWeight = rw.geti("weight", 50);
	    int iLastRun = rw.geti("lastrun", 1);
	    int iMaxRun = rw.geti("maxrun", -1);
	    int iCompletion = rw.geti("completion", 95);
	    String parentCompletionMin = rw.gets("parent_completion_min");
	    int iSubmitCount = rw.geti("submitcount", 0);
	    String constraints = rw.gets("constraints");
	    
	    if (iMaxRun > 0 && iMaxRun < iLastRun)
		iMaxRun = iLastRun;
	    
	    if (iID>0){
		db.syncUpdateQuery("UPDATE lpm_chain SET jdl='"+Formatare.mySQLEscape(jdl)+"', parameters='"+Formatare.mySQLEscape(parameters)+"', weight="+iWeight+", lastrun="+iLastRun+", maxrun="+iMaxRun+", completion="+iCompletion+", alienuser='"+Formatare.mySQLEscape(alienuser)+"', submitcount="+iSubmitCount+", parent_completion_min='"+Formatare.mySQLEscape(parentCompletionMin)+"', constraints='"+Formatare.mySQLEscape(constraints)+"' WHERE id="+iID+";");
	    }
	    else{
		int iParentID = rw.geti("parentid", 0);
		
		db.query("SELECT max(id) FROM lpm_chain WHERE hidden=0;");
		
		iID = db.geti(1)+1;
		
		db.syncUpdateQuery("INSERT INTO lpm_chain (id, parentid, jdl, parameters, alienuser, weight, lastrun, maxrun, completion, submitcount, parent_completion_min, constraints) VALUES ("+iID+", "+iParentID+", '"+Formatare.mySQLEscape(jdl)+"', '"+Formatare.mySQLEscape(parameters)+"', '"+Formatare.mySQLEscape(alienuser)+"', "+iWeight+", "+iLastRun+", "+iMaxRun+", "+iCompletion+", "+iSubmitCount+", '"+Formatare.mySQLEscape(parentCompletionMin)+"', '"+Formatare.mySQLEscape(constraints)+"');");
	    }
	    
	    response.sendRedirect("/"+JSP+"?account="+Format.encode(sAccount)+"#"+iID);
	    return;
	}
	catch (Exception e){
	}
    }
    else{
	
    }
    
    if (iSettings > 0 || iLTMSettings > 0){
	db.query("SELECT s_key FROM lpm_settings;");
	
	while (db.moveNext()){
	    String sKey = db.gets(1);
	
	    String sParam = rw.gets(sKey);
	
	    if (sParam.length()>0 || (iSettings>0 && sKey.equals("lpm_active")) || (iLTMSettings>0 && sKey.equals("ltm_active"))){
	        new DB("UPDATE lpm_settings SET s_value='"+Formatare.mySQLEscape(sParam)+"' WHERE s_key='"+Formatare.mySQLEscape(db.gets(1))+"';");
	    }
	}
	
	// Update lines on the taskqueue charts
	int iLimit = rw.geti("submit_trigger");
	    
	if (iLimit > 0){
	    new DB("UPDATE annotations SET a_from="+iLimit+", a_to="+iLimit+" WHERE a_id=20;");
	    
	    int iTarget = Integer.parseInt(request.getParameter("submit_target"));
	
	    new DB("UPDATE annotations SET a_from="+iTarget+", a_to="+iTarget+" WHERE a_id=24;");
	}
	
	iLimit = rw.geti("ltm_submit_trigger");
	
	if (iLimit > 0){
	    new DB("UPDATE annotations SET a_from="+iLimit+", a_to="+iLimit+" WHERE a_id=75;");
	}
    }


    db.query("SELECT distinct alienuser FROM lpm_chain WHERE hidden=0 ORDER BY 1;");
    
    while (db.moveNext()){
	String s = db.gets(1);
	
	p.append("opt_account", "<option value='"+s+"' "+(s.equals(sAccount) ? "selected":"")+">"+s+"</option>");
    }
    
    p.modify("account", sAccount);

    String sQuery = "SELECT id,enabled FROM lpm_chain WHERE parentid=0 AND hidden=0";

    if (sAccount.length()>0){
	sQuery += " AND alienuser='"+Format.escSQL(sAccount)+"' ";
    }
    
//    sQuery +=" AND id in (949, 973, 948, 947, 946, 945, 944, 1040, 1039, 531, 532, 533, 534, 535, 536, 665, 662, 252, 253) ";

    sQuery += " ORDER BY id DESC;";

    db.query(sQuery);

    LinkedList<Integer> lIDs = new LinkedList<Integer>();
    HashMap<Integer, Integer> hmLevel = new HashMap<Integer, Integer>();
    HashMap<Integer, Boolean> hmEnabled = new HashMap<Integer, Boolean>();

    LinkedList<Integer> lTempIDs = new LinkedList<Integer>();

    while (db.moveNext()){
	Integer id = Integer.valueOf(db.geti(1));
    
	lTempIDs.add(id);
	hmLevel.put(id, 0);
	hmEnabled.put(id, Boolean.valueOf(db.geti(2)==1));
    }
    
    while (lTempIDs.size()>0){
	Integer id = lTempIDs.remove(0);
	
	lIDs.add(id);
	
	db.query("SELECT id,enabled FROM lpm_chain WHERE parentid="+id+" AND hidden=0 ORDER BY id ASC;");
	
	Integer iNextLevel = Integer.valueOf( hmLevel.get(id).intValue() + 1 );
	
	boolean bEnabled = hmEnabled.get(id).booleanValue();
	
	while (db.moveNext()){
	    id = Integer.valueOf(db.geti(1));
	    
	    lTempIDs.add(0, id);
	    hmLevel.put(id, iNextLevel);
	    
	    hmEnabled.put(id, Boolean.valueOf(db.geti(2)==1 && bEnabled));
	}
    }

    String vsColors[] = new String[] { "#EEEEEE", "#FFFFFF" };
    
    int iColor = -1;
    
    db.query("select max(length(jdl)) from lpm_chain WHERE hidden=0;");
    
    int maxlength = db.geti(1);
    
    for (Integer id: lIDs){
	db.query("SELECT *,(SELECT submitdate FROM lpm_history WHERE (id=chain_id OR jdl=lpm_chain.jdl) AND runno=lastrun ORDER BY runno DESC LIMIT 1) AS submitdate FROM lpm_chain WHERE id="+id+" AND hidden=0;");
	
	final boolean bEdit = iEdit == id.intValue();
	
	Page pTemp = bEdit ? pEdit : pLine;
	
	pTemp.modify("account", sAccount);
	
	boolean bEnabled = hmEnabled.get(id).booleanValue();

	if (db.geti("enabled")==0){
	    pTemp.modify("enabletext", "Enable");
	}
	else{
	    pTemp.modify("enabletext", "Disable");
	}
	
	pTemp.modify("id", db.geti("id"));
	pTemp.modify("jdl", db.gets("jdl"));
	//pTemp.modify("parameters", bEdit ? db.gets("parameters") : utils.CatalogueHighlight.highlight(db.gets("parameters")));
	pTemp.modify("parameters", db.gets("parameters"));
	pTemp.modify("parameters_cut", lazyj.page.tags.Cut.cut(db.gets("parameters"), 30 + maxlength-db.gets("jdl").length()));
	pTemp.modify("completion", db.geti("completion"));
	pTemp.modify("parent_completion_min", db.gets("parent_completion_min"));
	pTemp.modify("constraints", db.gets("constraints"));
	
	final String sAliEnUser = db.gets("alienuser");
	
	pTemp.modify("alienuser", sAliEnUser);
	
	if (!sAliEnUser.equals("aliprod")){
	    final String sCode = (sAliEnUser.startsWith("pwg_") || sAliEnUser.equals("alitrain")) ? "B" : "I";
	
	    pTemp.modify("extra_start", "<"+sCode+">");
	    pTemp.modify("extra_end", "</"+sCode+">");
	}
	
	pTemp.comment("com_edit", false);
	
	try{
	
	    String jdl = db.gets("jdl");

	    if (!jdl.startsWith("#")){
		if (!jdl.startsWith("/")){
		    jdl = alien.users.UsersHelper.getHomeDir(sAliEnUser)+jdl;
		}
	    
	        final AliEnFile f = FileCache.getFile(jdl);
	    
		if (f.exists() && f.isFile()){
		    pTemp.comment("com_edit", true);
		
		    pTemp.modify("jdl_long", jdl);
		}	
	    }
	    else{
		if (jdl.matches("^#\\d+$")){
		    pTemp.append("extra_start", "<a class=link href='"+jdl+"' onClick='highlightRow("+jdl.substring(1)+")'>");
		    pTemp.append("extra_end", "</a>", true);
		}
	    }
	}
	catch (Exception e){
	    // ignore
	}
	
	int iLevel = hmLevel.get(id).intValue();

	int iLastRun = db.geti("lastrun", -1);
	
	if (iLastRun>0){
	    pTemp.modify("lastrun", db.gets("lastrun"));
	}
	
	if (db.gets("submitdate").length()>0){
	    pTemp.modify("submitdate", " ("+db.gets("submitdate")+")");
	}
	
	if (db.geti("submitcount")>0){
	    pTemp.modify("submitcount", db.geti("submitcount"));
	}

	int iMaxRun = db.geti("maxrun");
	    
	pTemp.modify("maxrun", iMaxRun>0 ? ""+iMaxRun : "");
	
	if (iLevel==0){
	    pTemp.modify("weight", db.geti("weight"));
	    
	    pTemp.comment("com_level0", true);
	    pTemp.comment("com_sublevel", false);
	}
	else{
	    pTemp.comment("com_level0", false);
	    pTemp.comment("com_sublevel", true);
	}
	
	pTemp.modify("parentid", db.geti("parentid"));

	if (iLevel==0)
	    iColor = (iColor + 1) % 2;
	
	pTemp.modify("padding", iLevel * 10 + 2);
	
	pTemp.modify("bgcolor", getColor(iColor, bEnabled));
	
	p.append(pTemp);
	
	if (iAdd==id.intValue()){
	    pEdit.modify("id", "0");
	    pEdit.modify("parentid", iAdd);
	    pEdit.modify("jdl", "");
	    pEdit.modify("parameters", "#RUN#");
	    pEdit.modify("weight", "50");
	    pEdit.modify("completion", "100");
	    pEdit.modify("alienuser", sAliEnUser);
	    pEdit.modify("parent_completion_min", "90%");
	    pEdit.modify("account", sAccount);
	    
	    db.query("SELECT max(lastrun) FROM lpm_chain WHERE hidden=0;");
	    
	    pEdit.modify("lastrun", "-1");
	    
	    pEdit.modify("padding", iLevel * 10 + 12);
	    
	    pEdit.modify("bgcolor", getColor(iColor, bEnabled));
	    
	    pEdit.comment("com_level0", false);
	    pEdit.comment("com_sublevel", true);
	    
	    p.append(pEdit);
	}
	
    }

    if (iAdd==0){
	pEdit.modify("id", "0");
	pEdit.modify("parentid", iAdd);
	pEdit.modify("jdl", "");
	pEdit.modify("parameters", "#RUN#");
	pEdit.modify("weight", "50");
	pEdit.modify("completion", "95");
	pEdit.modify("submitcount", "0");
	pEdit.modify("alienuser", sAccount.length()>0 ? sAccount : "aliprod");
	pEdit.modify("account", sAccount);
	
	db.query("SELECT max(lastrun) FROM lpm_chain WHERE hidden=0;");
	
	int newRun = (db.geti(1)/1000 + 1) * 1000 - 1;
	
	pEdit.modify("lastrun", newRun);
	pEdit.modify("maxrun", newRun+1000);
	
	pEdit.modify("padding", 2);
	
	pEdit.modify("bgcolor", getColor(iColor+1, true));

        pEdit.comment("com_level0", true);
        pEdit.comment("com_sublevel", false);
	    
	p.append(pEdit);
    }
    
    db.query("SELECT s_key,s_value FROM lpm_settings;");
    
    while (db.moveNext()){
	String sKey = db.gets(1);
	
	if (sKey.equals("lpm_active")){
	    boolean bActive = db.geti(2)==1;
	    
	    p.modify("lpm_status", bActive ? "checked" : "");
	    p.modify("lpm_status_text", bActive? "<font color=#009900><B>ACTIVE</B></font>" : "<font color=#990000><B>DISABLED</B></font>");
	}
	else
	if (sKey.equals("ltm_active")){
	    boolean bActive = db.geti(2)==1;
	    
	    p.modify("ltm_status", bActive ? "checked" : "");
	    p.modify("ltm_status_text", bActive? "<font color=#009900><B>ACTIVE</B></font>" : "<font color=#990000><B>DISABLED</B></font>");
	}
	else{
	    p.modify(sKey, db.gets(2));
	}
    }

    pMaster.append(p);
    
    pMaster.write();
        
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/lpm/lpm_manager.jsp", baos.size(), request);
%>