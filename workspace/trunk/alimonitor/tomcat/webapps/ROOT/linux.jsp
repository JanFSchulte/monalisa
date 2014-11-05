<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.Result,lia.Monitor.monitor.eResult,lia.Monitor.JiniClient.Store.Main" %><%
    lia.web.servlets.web.Utils.logRequest("START /linux.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Site Administration - Linux Flavour");
    pMaster.modify("class_administration", "_active");

    Page pLinux = new Page(BASE_PATH+"/admin/linux.res");
    Page pLinuxEl = new Page(BASE_PATH+"/admin/linux_el.res");
    Page pLinuxCount = new Page(BASE_PATH+"/admin/linux_count.res");

    DB db = new DB();

    String sQuery = "SELECT vobox_stats.*,abping_aliases.libc_ver FROM vobox_stats INNER JOIN abping_aliases ON vobox_stats.name=abping_aliases.name ORDER BY lower(vobox_stats.name) ASC";

    db.query(sQuery);
    
    while(db.moveNext()){
	String sVer = db.gets("libc_ver");
	
	sVer = sVer.replaceAll("^libc-", "");
	sVer = sVer.replaceAll("\\.so$", "");
	
	pLinuxEl.modify("libc_ver", sVer);
	pLinuxEl.fillFromDB(db);
	
	pLinux.append(pLinuxEl)	;
    }
    
    sQuery = "SELECT linuxflavor, count(1) as cnt FROM vobox_stats GROUP BY linuxflavor ORDER BY cnt DESC;";
    db.query(sQuery);
    
    while(db.moveNext()){
	pLinuxCount.fillFromDB(db);
	pLinux.append("count", pLinuxCount);
    }
    
    sQuery = "SELECT trim(libc_ver), count(1) as cnt FROM vobox_stats INNER JOIN abping_aliases ON vobox_stats.name=abping_aliases.name GROUP BY 1 ORDER BY 2 DESC, 1 ASC;";
    db.query(sQuery);
    
    while (db.moveNext()){
    	String sVer = db.gets(1);
	
	sVer = sVer.replaceAll("^libc-", "");
	sVer = sVer.replaceAll("\\.so$", "");

	pLinuxCount.modify("linuxflavor", sVer);
	pLinuxCount.fillFromDB(db);
	
	pLinux.append("libc_count", pLinuxCount);
    }
    
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    pMaster.append(pLinux);

    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
            
    lia.web.servlets.web.Utils.logRequest("/linux.jsp", s.length(), request);
%>