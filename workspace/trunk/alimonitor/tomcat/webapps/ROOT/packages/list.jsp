<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.concurrent.atomic.*" %><%!
    private static Set<String> getSites(){
	File f = new File("/home/monalisa/MLrepository/bin/packages/sites");
	
	String[] files = f.list();
	
	TreeSet<String> ret = new TreeSet<String>();
	
	for (String s: files)
	    if (!s.startsWith("ALL"))
		ret.add(s);
	    
	return ret;
    }
    
    private static Set<String> getPackages(final String site, final String sFilter){
	TreeSet<String> ret = new TreeSet<String>();
    
	try{
	    BufferedReader br = new BufferedReader(new FileReader("/home/monalisa/MLrepository/bin/packages/sites/"+site));
	    
	    String sLine;
	    
	    while ( (sLine=br.readLine())!=null ){
		if (sLine.length()>0 && (sFilter.length()==0 || sLine.startsWith(sFilter)))
		    ret.add(sLine);
	    }
	}
	catch (Exception e){
	}
	
	return ret;
    }
    
    private static String getColor(final int value, final int max){
    
	return lia.web.servlets.web.Utils.toHex(255 - (value*128 / max)) +
	       lia.web.servlets.web.Utils.toHex(255 - (value*128 / max)) +
	       lia.web.servlets.web.Utils.toHex(255);
    
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /packages/list.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);
    
    String sFilter = rw.gets("filter");
    int restrict = rw.geti("restrict");

    String sBookmark = "/packages/list.jsp?filter="+Format.encode(sFilter);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("title", "ALICE packages on sites");
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("bookmark", sBookmark);

    Page p = new Page("packages/list.res");
    Page pHead = new Page("packages/list_header.res");
    Page pFoot = new Page("packages/list_footer.res");
    Page pLine = new Page("packages/list_line.res");
    Page pCell = new Page("packages/list_cell.res");
    
    p.comment("com_restrict1", restrict==1);
    p.comment("com_restrict2", restrict==2);
    
    // -------------------
    
    Set<String> sites = getSites();

    TreeMap<String, Set<String>> sitesForPackages = new TreeMap<String, Set<String>>();
    TreeMap<String, Set<String>> packagesOnSites = new TreeMap<String, Set<String>>();

    Set<String> sInstalledPackages = getPackages("ALL.packman", sFilter);

    String sOld = null;
    int iCount = 0;
    
    for (String site: sites){
	Set<String> packages = getPackages(site, sFilter);
	
	if (restrict==1){
	    // only installed packages
	    packages.retainAll(sInstalledPackages);
	}
	else
	if (restrict==2){
	    // only uninstalled packages
	    packages.removeAll(sInstalledPackages);
	}
	
	packagesOnSites.put(site, packages);
	
	for (String pkg: packages){
	    Set<String> s = sitesForPackages.get(pkg);
	    
	    if (s==null){
		s = new HashSet<String>();
		sitesForPackages.put(pkg, s);
	    }
	
	    s.add(site);
	}
    }

    for (String pkg: sitesForPackages.keySet()){
	String sUser = pkg.substring(0, pkg.indexOf("@"));
    
	if (!sUser.equals(sOld)){
	    if (iCount>0){
		pHead.modify("site", sOld);
		pHead.modify("package", sOld);
		pHead.modify("packagedescr", sOld);
		pHead.modify("colspan", iCount);
		pHead.modify("color", "000000");
		p.append("users", pHead);
	    }
	
	    sOld = sUser;
	    iCount = 1;
	}
	else
	    iCount++;
    }
    
    if (iCount>0){
	pHead.modify("site", sOld);
	pHead.modify("package", sOld);
	pHead.modify("packagedescr", sOld);
	pHead.modify("colspan", iCount);
	pHead.modify("color", "000000");
	p.append("users", pHead);
    }	
    
    iCount = 0;
    
    for (String pkg: sitesForPackages.keySet()){
	String sName = pkg.substring(0, pkg.indexOf("::"));
    
	if (!sName.equals(sOld)){
	    if (iCount>0){
		pHead.modify("site", sOld.substring(sOld.indexOf("@")+1));
		pHead.modify("package", sOld);
		pHead.modify("packagedescr", sOld);
		pHead.modify("colspan", iCount);
		pHead.modify("color", "000000");
		p.append("packagenames", pHead);
	    }
	
	    sOld = sName;
	    iCount = 1;
	}
	else
	    iCount++;
    }
    
    if (iCount>0){
	pHead.modify("site", sOld.substring(sOld.indexOf("@")+1));
	pHead.modify("package", sOld);
	pHead.modify("packagedescr", sOld);
	pHead.modify("colspan", iCount);
	pHead.modify("color", "000000");
	p.append("packagenames", pHead);
    }

    
    for (String pkg: sitesForPackages.keySet()){
    	boolean bIsDefined = sInstalledPackages.contains(pkg);
	pHead.modify("color", bIsDefined ? "009900" : "FF0000");
	pHead.modify("site", pkg.substring(pkg.indexOf("::")+2));
	pHead.modify("package", pkg);
	pHead.modify("packagedescr", pkg+(bIsDefined ? "" : "<br><b><font color=red>Was removed centrally, should be deleted on sites</font></b>"));
	pHead.modify("colspan", 1);
	p.append("versions", pHead);
    }
    
    int max = 0;
    
    for (Set<String> s: packagesOnSites.values()){
	max = Math.max(max, s.size());
    }
    
    // site -> count
    HashMap<String, AtomicInteger> counters = new HashMap<String, AtomicInteger>();
    
    for (Map.Entry<String, Set<String>> me: packagesOnSites.entrySet()){
	String site = me.getKey();
	Set<String> pkgs = me.getValue();
    
	pLine.modify("site", site);
	pLine.modify("count", pkgs.size());
	pLine.modify("countcolor", pkgs.size() > 0 ? getColor(pkgs.size(), max) : "FF9999");
	
	for (String pkg: sitesForPackages.keySet()){
	    boolean bIsDefined = sInstalledPackages.contains(pkg);

	    boolean bInstalled = pkgs.contains(pkg);
	    
	    pCell.modify("color", bInstalled ? "00FF00": (bIsDefined ? "FF9900" : "FFFFFF") );
	    pCell.modify("status", bInstalled ? (bIsDefined ? "Installed" : "Undefined, should be REMOVED!") : (bIsDefined ? "Available on demand" : "-"));
	    pCell.modify("site", site);
	    pCell.modify("package", pkg);
	    
	    pLine.append("content", pCell);
	    
	    if (bInstalled){
		AtomicInteger ai = counters.get(pkg);
		
		if (ai==null){
		    ai = new AtomicInteger(1);
		    counters.put(pkg, ai);
		}
		else{
		    ai.incrementAndGet();
		}
	    }

	}
	
	p.append("content", pLine);
    }

    for (String pkg : sitesForPackages.keySet()){
	pFoot.modify("site", pkg);
	
	AtomicInteger ai = counters.get(pkg);
	
	pFoot.modify("count", ai==null ? 0 : ai.get());
	p.append("footer", pFoot);
    }
    
    // -------------------

    pMaster.append(p);

    response.setContentType("text/html");
    pMaster.write();   
    
    String s = new String(baos.toByteArray());
    out.println(s);
	    
    lia.web.servlets.web.Utils.logRequest("/packages/list.jsp", baos.size(), request);		
%>