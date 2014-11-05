<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.*,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*,lazyj.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/packagemanager.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Package Management");
    pMaster.modify("class_packagemanager", "_active");

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");
    
    Page p = new Page(BASE_PATH+"/admin/packagemanager.res");
    Page pPackage = new Page(BASE_PATH+"/admin/packagemanager_package.res");

    int iColorIndex = 1;
    BufferedReader br;
    String sLine;
    
    /* --------- */
    
    URL urlServerList = new URL("http://alirootbuild3.cern.ch:8889/BitServers.notcached");
    
    URLConnection conn = urlServerList.openConnection();
    
    br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    
    ArrayList<String> alPlatformNames = new ArrayList<String>();
    ArrayList<String> alPlatformURLs = new ArrayList<String>();
    
    String sPlatformList = "";
    
    while ( (sLine=br.readLine()) != null ){
	//if (sLine.indexOf("Darwin")>0)
	//    continue;
	
	StringTokenizer st = new StringTokenizer(sLine, "|");
	
	if (st.countTokens()>=2){
	    if (st.countTokens()>=3)
		st.nextToken();
	    
	    String sPlatformName = st.nextToken().trim();
	    String sURL = st.nextToken().trim();
	    
	    alPlatformNames.add(sPlatformName);
	    alPlatformURLs.add(sURL);
	    
	    sPlatformList += sPlatformName + " ";
	    
	    p.append("platforms", "<td class=\"table_header\" width=90><a class=link target=_blank href="+sURL+"><b>"+sPlatformName+"</b></td>");
	}
    }
    
    br.close();
    
    /* list already installed packages */

    Set<String> installedByVo = new HashSet<String>();
    Set<String> installedByUsers = new HashSet<String>();
    
    Page pInstalled = new Page(BASE_PATH+"/admin/packagemanager_installed.res");
    
    String sOldOwner = "";
    
    try{
        Process child = lia.util.MLProcess.exec(new String[]{"/home/monalisa/MLrepository/bin/packages/list.sh"}, 1000*60*1);
    
	br = new BufferedReader(new InputStreamReader(child.getInputStream()));
	
	while ( (sLine=br.readLine())!=null ){
	    if (sLine.indexOf("@")>0){
		sLine = sLine.trim();
		
		String sOwner = sLine.substring(0, sLine.indexOf("@"));
		
		String sPackage = sLine.substring(sLine.indexOf("@")+1).replace("::", " ");
		
		if (sOwner.equals("VO_ALICE")){
		    installedByVo.add(sPackage);
		    pInstalled.comment("com_uninstall", true);
		}
		else{
		    installedByUsers.add(sPackage);
		    //pInstalled.comment("com_uninstall", false);
		    pInstalled.comment("com_uninstall", false);
		}
		
		if (!sOwner.equals(sOldOwner)){
		    iColorIndex = (iColorIndex + 1)%2;
		    sOldOwner = sOwner;
		}
	    
		pInstalled.modify("packagename", sLine);
		pInstalled.modify("package", sPackage+" "+sPlatformList);
		
		if (sOwner.equals("VO_ALICE")){
		    pInstalled.modify("bgcolor", "#EEEEEE");
		    
		    p.append("installedvo", pInstalled);
		}
		else{
		    pInstalled.modify("bgcolor", iColorIndex==0 ? "#FFFFFF" : "#EEEEEE");
		
		    p.append("installed", pInstalled);
		}
	    }
	}
	
	br.close();
    }
    catch (Exception e){
	p.append("installed", "<tr><td colspan=2 align=center><font color=red>Error querying AliEn for the package list</font></td></tr>");
    }

    /* --------- */
    
    iColorIndex = 0;
    
    p.modify("platforms_count", alPlatformNames.size());
    
    TreeMap<String, Set<String>> tmPackages = new TreeMap<String, Set<String>>();
    TreeMap<String, String> tmAliceNames = new TreeMap<String, String>();
    TreeMap<String, String> tmDependencies = new TreeMap<String, String>();
    
    for (int i=0; i<alPlatformNames.size(); i++){
	String sPlatformName = alPlatformNames.get(i);
	String sPlatformURL  = alPlatformURLs.get(i);
	
	try{
	    conn = new URL(sPlatformURL+"/tarballs/Packages").openConnection();
	    br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
	    
	    //System.err.println("admin/packagemanager.jsp : "+sPlatformURL+" <starting>");
	    
	    while ( (sLine=br.readLine()) != null ){
		//System.err.println("admin/packagemanager.jsp : "+sPlatformURL+" : "+sLine);
	    
		StringTokenizer st = new StringTokenizer(sLine);
		
		if (st.countTokens() >= 5){
		    String sTGZ = st.nextToken();
		    String sName = st.nextToken();
		    String sVersion = st.nextToken();
		    String sARCH = st.nextToken();
		    String sAliceName = st.nextToken();
		    String sDeps = st.hasMoreTokens() ? st.nextToken() : null;
		                    
		    String s = sName+" "+sVersion;
		    
		    Set<String> ssPlatforms = tmPackages.get(s);
		    
		    if (ssPlatforms == null){
			ssPlatforms = new HashSet<String>();
			tmPackages.put(s, ssPlatforms);
		    }
		    
		    ssPlatforms.add(sARCH);
		    
		    tmAliceNames.put(s, sAliceName);
		    tmDependencies.put(s, sDeps);
		}
	    }

	    //System.err.println("admin/packagemanager.jsp : "+sPlatformURL+" <ending>");
	}
	catch (Exception e){
	    System.err.println("admin/packagemanager.jsp : Cannot talk to "+sPlatformURL+" : "+e);
	}
    }

    String sOldPackage = "";
    
    for (Map.Entry<String, Set<String>> me: tmPackages.entrySet()){
	String sPackageName = me.getKey();
	
	String sStyle="color:black";
	String sTitle="Depends on";
	
	if (installedByVo.contains(sPackageName)){
	    sStyle="color:blue;font-weight:bold";
	    sTitle="Package installed for VO_ALICE";
	}
	else
	if (installedByUsers.contains(sPackageName)){
	    sStyle="color:green";
	    sTitle="Package installed by users";
	}
	
	pPackage.modify("style", sStyle);
	pPackage.modify("title", sTitle);
	
	String sAppName = sPackageName.substring(0, sPackageName.indexOf(" "));
	
	if (!sOldPackage.equals(sAppName)){
	    sOldPackage = sAppName;
	    iColorIndex = (iColorIndex+1)%2;
	}
	
	pPackage.modify("bgcolor", iColorIndex==0 ? "#FFFFFF" : "#EEEEEE");
	
	Set<String> sPlatforms = me.getValue();
	
	pPackage.modify("package", sPackageName);

	String sDeps = tmDependencies.get(sPackageName);
	
	pPackage.modify("deps", sDeps !=null ? sDeps : "Independent package");
	pPackage.modify("package_email", sPackageName.replace(" ", "_"));
	
	for (String sPlatform: alPlatformNames){
	    if (sPlatforms.contains(sPlatform)){
	    //if(true){
		pPackage.append(
		    "<td align=center bgcolor=#AAFFAA>"+
			"<input type=checkbox onChange=\"checkDeps(this);\" name=install id=\""+sPackageName+"\" value=\""+sPackageName+" "+sPlatform+"\">"+
		    "</td>\n");
	    }
	    else{
		pPackage.append("<td bgcolor=#FFAAAA>&nbsp;</td>");
	    }
	}
	
	p.append(pPackage);
	
	if (sDeps!=null){
	    StringTokenizer st = new StringTokenizer(sDeps, ",");
	    
	    String sDef = "alsoCheck['"+sPackageName+"'] = [";
	    
	    while (st.hasMoreTokens()){
		String s = st.nextToken();
		
		s = s.substring(s.indexOf("@") + 1).replace("::", " ");
		
		sDef += "'"+s+"',";
	    }
	    
	    sDef = sDef.substring(0, sDef.length()-1) + "];\n";
	    
	    p.append("alsocheck", sDef);
	}
    }
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    alien.managers.InstalledPackagesUpdater.asyncUpdate();
    
    lia.web.servlets.web.Utils.logRequest("/admin/packagemanager.jsp", baos.size(), request);
%>