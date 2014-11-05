<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.*,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*,lazyj.*" %><%!

    private static boolean updateDependencies(final String sPackage, final String sDependencies){
	final DB db = new DB("SELECT dependencies FROM packages_dependencies WHERE name='"+Format.escSQL(sPackage)+"';");
	
	if (db.moveNext()){
	    if (!sDependencies.equals(db.gets(1))){
		db.query("UPDATE packages_dependencies SET dependencies='"+Format.escSQL(sDependencies)+"', update=extract(epoch from now())::int WHERE name='"+Format.escSQL(sPackage)+"';");
		
		return true;
	    }
	}
	else{
	    db.query("INSERT INTO packages_dependencies (name, dependencies) VALUES ('"+Format.escSQL(sPackage)+"', '"+Format.escSQL(sDependencies)+"');");
	    
	    return true;
	}
	
	return false;
    }

%><%
    lia.web.servlets.web.Utils.logRequest("START /work/updatePackages.jsp", 0, request);

    URL urlServerList = new URL("http://alienbuild.cern.ch:8889/BitServers");
    
    URLConnection conn = urlServerList.openConnection();

    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    
    ArrayList<String> alPlatformURLs = new ArrayList<String>();
    
    String sPlatformList = "";
    
    String sLine;
    
    while ( (sLine=br.readLine()) != null ){
	StringTokenizer st = new StringTokenizer(sLine, "|");
	
	if (st.countTokens()>=2){
	    if (st.countTokens()>=3)
		st.nextToken();
	    
	    String sPlatformName = st.nextToken().trim();
	    String sURL = st.nextToken().trim();
	    
	    alPlatformURLs.add(sURL);
	}
    }
    
    br.close();
    
    Set<String> installedByVo = new HashSet<String>();
    
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
		}
	    }
	}
	
	br.close();
    }
    catch (Exception e){
	return;
    }

    TreeMap<String, String> tmInstalledPackages = new TreeMap<String, String>();
    
    for (int i=0; i<alPlatformURLs.size(); i++){
	String sPlatformURL  = alPlatformURLs.get(i);
	
	try{
	    conn = new URL(sPlatformURL+"/tarballs/Packages").openConnection();
	
	    br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
	    
	    while ( (sLine=br.readLine()) != null ){
		StringTokenizer st = new StringTokenizer(sLine);
		
		if (st.countTokens() >= 5){
		    String sTGZ = st.nextToken();
		    String sName = st.nextToken();
		    String sVersion = st.nextToken();
		    String sARCH = st.nextToken();
		    String sAliceName = st.nextToken();
		    String sDeps = st.hasMoreTokens() ? st.nextToken() : null;
		    
		    String s = sName+" "+sVersion;
		    
		    if (installedByVo.contains(s))
			tmInstalledPackages.put(sAliceName, sDeps);
		}
	    }
	}
	catch (Exception e){
	}
    }

    if (tmInstalledPackages.size()==0)
	return;
	
    DB db = new DB();
    // easy way out :)
    db.syncUpdateQuery("TRUNCATE packages_dependencies;");
    
    for (final Map.Entry<String, String> me: tmInstalledPackages.entrySet()){
	updateDependencies(me.getKey(), me.getValue());
    }
    
    lia.web.servlets.web.Utils.logRequest("/work/updatePackages.jsp", 0, request);
%>