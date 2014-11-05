<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.Result,lia.Monitor.monitor.eResult,lia.Monitor.JiniClient.Store.Main" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/services.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Site services admin");
    pMaster.modify("class_siteservices", "_active");

    Page pServices = new Page(BASE_PATH+"/admin/services.res");

    Page pRestart = new Page(BASE_PATH+"/admin/services_restart.res");
    
    Page pRestartLine = new Page(BASE_PATH+"/admin/services_restart_line.res");
    
    /** Parameters parsing*/
    
    Enumeration e = request.getParameterNames();
    
    boolean bFirst = true;
    
    DB db = new DB();
    
    while (e.hasMoreElements()){
	String sParam = (String) e.nextElement();
	
	if (sParam.indexOf("|")<=0)
	    continue;
	    
	String sSite = sParam.substring(0, sParam.indexOf("|"));
	String sService = sParam.substring(sParam.indexOf("|")+1);
	
	if (bFirst){
	    db.query("DELETE FROM site_services;");
	    bFirst = false;
	}
	
	if (sService.equals("email")){
	    String sEmail = request.getParameter(sParam);
	    
	    String sEnabled = request.getParameter(sSite+"|notif");
	    
	    int iEnabled = sEnabled==null || sEnabled.equals("0") ? 0 : 1;
	    
	    db.query("UPDATE sites_info SET notif_enabled="+iEnabled+", notif_suppemail='"+Formatare.mySQLEscape(sEmail)+"' WHERE name='"+Formatare.mySQLEscape(sSite)+"';");
	    
	    if (db.getUpdateCount()==0)
		db.query("INSERT INTO sites_info (name, notif_enabled, notif_suppemail) VALUES ('"+Formatare.mySQLEscape(sSite)+"', "+iEnabled+", '"+Formatare.mySQLEscape(sEmail)+"');");
	}
	else
	if (sService.equals("notif")){
	    // ignore, processed above
	}
	else{
	    // disable a site service
	    db.query("INSERT INTO site_services (name, service, restart_enabled) VALUES ('"+Formatare.mySQLEscape(sSite)+"', '"+Formatare.mySQLEscape(sService)+"', 0);");
	}
    }
    
    db.query("VACUUM ANALYZE site_services;");
    db.query("VACUUM ANALYZE sites_info;");
    
    /** Services restart checkboxes */
    
    db = new DB("select abping_aliases.name,service,restart_enabled from abping_aliases left outer join site_services on abping_aliases.name=site_services.name where abping_aliases.name in (select name from alien_sites) order by lower(abping_aliases.name) asc;");
    
    String sPrevSite = "";
    
    int iCnt = 0;
    
    while (db.moveNext()){
	String sSite = db.gets(1);
	
	if (!sSite.equals(sPrevSite)){
	    if (sPrevSite.length()>0)
		pRestart.append(pRestartLine);
		
	    sPrevSite = sSite;
	    
	    pRestartLine.modify("site", sSite);
	    
	    iCnt++;
	    
	    pRestartLine.modify("bgcolor", iCnt%2==0 ? "#FFFFFF" : "#F0F0F0");
	}
	
	pRestartLine.modify(db.gets(2)+"_checked", db.geti(3)==0 ? "checked" : "");

	if (db.geti(3)==0){
	    pRestartLine.modify("extra_"+db.gets(2), "bgcolor=#FFCCCC");
	}
    }
    
    pRestart.append(pRestartLine);
    
    /** Resources notifications section */
    
    db.query("select abping_aliases.name,sites_info.notif_enabled,sites_info.notif_suppemail,abping_aliases.contact_email from abping_aliases left outer join sites_info on abping_aliases.name=sites_info.name where abping_aliases.name in (select name from alien_sites) order by lower(abping_aliases.name) asc;;");

    Page pNotif = new Page(BASE_PATH+"/admin/services_notif.res");
    
    Page pNotifLine = new Page(BASE_PATH+"/admin/services_notif_line.res");
    
    iCnt = 0;
    
    while (db.moveNext()){
	pNotifLine.modify("site", db.gets(1));
	pNotifLine.modify("notif_enabled", db.geti(2, 1) == 1 ? "checked" : "");
	pNotifLine.modify("notif_suppemail", db.gets(3));
	pNotifLine.modify("contact_email", db.gets(4));
	
	iCnt++;
	
	pNotifLine.modify("bgcolor", iCnt%2==0 ? "#FFFFFF" : "#F0F0F0");
	
	pNotif.append(pNotifLine);
    }
    
    /** */
    
    pServices.modify("table_restart", pRestart);
    pServices.modify("table_notif", pNotif);
    
    /** */
    
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    pMaster.append(pServices);

    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
            
    lia.web.servlets.web.Utils.logRequest("/admin/services.jsp", s.length(), request);
%>
