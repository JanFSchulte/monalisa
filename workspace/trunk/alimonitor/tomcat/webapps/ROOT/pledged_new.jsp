<%@ page import="alimonitor.*,lazyj.Format,lia.Monitor.Store.Fast.DB,lia.web.utils.Formatare,java.util.*,java.io.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.Monitor.monitor.*"%><%
    Utils.logRequest("START /pledged_new.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");

    pMaster.modify("title", "Sites grouping");
    
    //menu
    pMaster.modify("class_pledged", "_active");

    String JSP = "pledged_new.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");
    
    final String ROLE="admin";
    
    String URL="/"+JSP;
    boolean bQM = false;
    
    Enumeration en = request.getParameterNames();
    
    while (en.hasMoreElements()){
	String sParam = (String) en.nextElement();
	
	String[] values = request.getParameterValues(sParam);
	
	for (int i=0; values!=null && i<values.length; i++){
	    URL = URL + (bQM ? "&" : "?") + URLEncoder.encode(sParam)+"="+URLEncoder.encode(values[i]);
	    bQM = true;
	}
    }

    en = request.getParameterNames();
    
    while (en.hasMoreElements()){
	String sName = (String) en.nextElement();
	
	if (sName.startsWith("cpus_") || sName.startsWith("ksi2k_")){
	    if(!request.isUserInRole(ROLE)){
		response.sendRedirect("/dologin.jsp?page="+URLEncoder.encode(URL));
		return;
	    }
	
	    String sParam = sName.substring(0, sName.indexOf("_"));
	    String sFarm = sName.substring(sName.indexOf("_")+1);
	    
	    int value;
	    
	    try{
		value = Integer.parseInt(request.getParameter(sName));
	    }
	    catch (Exception e){
		continue;
	    }
	    
	    DB db = new DB();
	    
	    db.query("UPDATE pledged_dynamic SET "+sParam+"="+value+" WHERE site='"+sFarm+"';");
	}
    }
    
    String sNewGroup = request.getParameter("group");
    String[] vs = request.getParameterValues("group_members");
    
    if (sNewGroup != null && (sNewGroup=sNewGroup.trim()).length()>0 && vs!=null && vs.length>0){
        if(!request.isUserInRole(ROLE)){
	    response.sendRedirect("/dologin.jsp?page="+URLEncoder.encode(URL));
	    return;
	}
    
	DB db = new DB();
	
	db.syncUpdateQuery("UPDATE pledged_dynamic SET groupname='' WHERE groupname='"+Format.escSQL(sNewGroup)+"';");
	
	for (int i=0; i<vs.length; i++)
	    db.syncUpdateQuery("UPDATE pledged_dynamic SET groupname='"+Format.escSQL(sNewGroup)+"' WHERE site='"+Format.escSQL(vs[i])+"';");

	//System.err.println("Calling reload() for ServiceGroups");
	    
	lia.Monitor.JiniClient.Store.ServiceGroups.getInstance().reload();
    }
    
    String sEditGroup = request.getParameter("edit_group");
    
    if (sEditGroup==null)
	sEditGroup = "";
	

    Page pPledged = new Page("pledged.res");
    Page pPledgedEl = new Page("pledged_el.res");

    DB db = new DB();
    
    db.query("SELECT fill_pledged_dynamic();");
	    
    db.query("SELECT name,version,cpus,ksi2k,groupname FROM abping_aliases LEFT OUTER JOIN pledged_dynamic ON name=site WHERE name IN (SELECT name FROM alien_sites) ORDER BY name ASC;");
	    
    int i = 1;
	    
    while (db.moveNext()){
	monPredicate pred = new monPredicate(db.gets("name"), "*", "*", -1, -1, new String[]{"*"}, null);
		
	String sGroup = db.gets("groupname");
	    
	pPledgedEl.modify("color", i%2 == 0 ? "#FFFFFF" : "#F0F0F0");
	pPledgedEl.modify("i", i);
	pPledgedEl.modify("name", db.gets("name"));
	pPledgedEl.modify("version", db.gets("version"));
	
	pPledgedEl.modify("ksi2k", db.geti("ksi2k"));
	
	pPledgedEl.modify("jsp", JSP);
	
	if (sGroup.length()==0 || sGroup.equals(sEditGroup)) {
	    pPledgedEl.comment("com_input", true);
	    pPledgedEl.comment("com_link", false);
	    
	    if (sGroup.length()>0)
		pPledgedEl.modify("group_checked", "checked");
	}
	else{
	    pPledgedEl.modify("group", sGroup);	
	    pPledgedEl.comment("com_link", true);
	    pPledgedEl.comment("com_input", false);
	}
	
	pPledged.append(pPledgedEl);
	
	i++;
    }	
    
    pPledged.modify("jsp", JSP);
    pPledged.modify("edit_group", sEditGroup);
    
    pMaster.append(pPledged);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
                    
    Utils.logRequest("/pledged_new.jsp", baos.size(), request);
%>