<%@ page import="alimonitor.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.util.*,java.io.*,lia.web.servlets.web.*,auth.*,java.security.cert.*" %><%
    Utils.logRequest("START /pledged_future.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");

    pMaster.modify("title", "Pledged Future");
    
    //menu
    pMaster.modify("class_pledged_future", "_active");

    String JSP = "pledged_future.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    DB db = new DB();
    
    final int Y_START = 2009;
    final int Y_END   = 2013;
    
    final int QUARTERS = (Y_END-Y_START+1)*4;
    
    String sParam = request.getParameter("field");
    String sValue = request.getParameter("value");

    if (sParam!=null && sValue!=null){
	int iRet = -1;
    
	try{
	    final int i1 = sParam.indexOf("_");
	    final int i2 = sParam.lastIndexOf("_");
	    
	    final int iResource = Integer.parseInt(sParam.substring(1,2));
	    final int iQuarterY = Integer.parseInt(sParam.substring(i2+1));
	    final String sSite  = sParam.substring(i1+1, i2);
	    
	    final int iYear = Y_START+iQuarterY/4;
	    final int iQuarter  = iQuarterY%4;
	    
	    try{
	        int iValue    = Integer.parseInt(sValue);
	    
		if (iValue>0){
		    //db.query("DELETE FROM pledged_future WHERE resource="+iResource+" AND site='"+sSite+"' AND (year>"+iYear+" OR (year="+iYear+" AND quarter>="+iQuarter+"));");
		    db.syncUpdateQuery("DELETE FROM pledged_future WHERE resource="+iResource+" AND site='"+sSite+"' AND (year="+iYear+" AND quarter>="+iQuarter+");");
		
		    //for (int i=iQuarterY; i<QUARTERS; i++){
		    for (int i=iQuarterY; i<((iQuarterY/4)+1)*4; i++){
			int year = Y_START+i/4;
			int quarter  = i%4;
		    
			db.syncUpdateQuery("INSERT INTO pledged_future (site, resource, year, quarter, val) VALUES ('"+sSite+"', "+iResource+", "+year+", "+quarter+", "+iValue+");");
		    }
		
		    iRet = iValue;
		}
	    }
	    catch (Exception ex2){
		// exception parsing the value part, try to get the old one from DB
		
		db.query("SELECT val FROM pledged_future WHERE site='"+sSite+"' AND resource="+iResource+" AND year="+iYear+" AND quarter="+iQuarter+";");
		
		if (db.moveNext())
		    iRet = db.geti(1);
	    }
	}
	catch (Exception ex){
	    // exception parsing the parameter name => invalid cell ?!
	}
	
	out.print(iRet < 0 ? "-" : ""+iRet);
	    
	out.flush();
	    
	return;
    }
    
    Page pPledged = new Page("pledged_future.res");
    
    db.query("SELECT name FROM abping_aliases WHERE name IN (SELECT name FROM alien_sites) ORDER BY lower(name) ASC;");
    
    final ArrayList<String> alSites = new ArrayList<String>(100);
    
    boolean bFirst = true;
    
    while (db.moveNext()){
	alSites.add(db.gets(1));
	
	if (!bFirst)
	    pPledged.append("sitenames", ",");
	
	pPledged.append("sitenames", "'"+db.gets(1)+"'");
	
	bFirst = false;
    }
    
    final Date dNow = new Date();
    
    final int QNOW = (dNow.getYear()+1900-Y_START)*4 + dNow.getMonth()/3;
    
    pPledged.modify("quarters", QUARTERS);
    
    Page pResourceTable = new Page("pledged_future_resource_table.res");
    Page pResourceHeader = new Page("pledged_future_resource_header.res");
    Page pResourceFooter = new Page("pledged_future_resource_footer.res");
    Page pResourceLine   = new Page("pledged_future_resource_line.res");
    Page pResourceCell;
    
    //if the users is logged he can edit the cells
    
    boolean bAuthOK = false;
    
    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
	
	if (cert!=null && cert.length>0){
	    AlicePrincipal principal = new AlicePrincipal(cert[0].getSubjectDN().getName());
	    
	    String sName = principal.getName();
	    
	    if (sName!=null && sName.length()>0){
		Set<String> sRoles = LDAPHelper.checkLdapInformation("users="+sName, "ou=Roles,", "uid");
		
		bAuthOK = sRoles.contains("webadmin");
	    }
	}
    }
    
    if(bAuthOK){
	pResourceCell   = new Page("pledged_future_resource_cell.res");
	pPledged.comment("com_explanation", false);
    }
    else
    	pResourceCell   = new Page("pledged_future_resource_cell_nologin.res");
    
    db.query("SELECT * FROM pledged_future;");
    
    TreeMap<Integer, TreeMap<String, TreeMap<Integer, Integer>>> tmResources = new TreeMap<Integer, TreeMap<String, TreeMap<Integer, Integer>>>();
    
    TreeMap<Integer, TreeMap<Integer, Integer>> tmSums = new TreeMap<Integer, TreeMap<Integer, Integer>>();
    
    while (db.moveNext()){
	final String sSite = db.gets("site");
	final int iResource = db.geti("resource");
	final int iValue = db.geti("val");
	final int iYear = db.geti("year");
	final int iQuarter = db.geti("quarter");
	
	final int iPos = (iYear - Y_START)*4 + iQuarter;
	
	TreeMap<String, TreeMap<Integer, Integer>> tmSites = tmResources.get(iResource);
	
	if (tmSites==null){
	    tmSites = new TreeMap<String, TreeMap<Integer, Integer>>();
	    tmResources.put(iResource, tmSites);
	}
	
	TreeMap<Integer, Integer> tmValues = tmSites.get(sSite);
	
	if (tmValues==null){
	    tmValues = new TreeMap<Integer, Integer>();
	    tmSites.put(sSite, tmValues);
	}
	
	tmValues.put(iPos, iValue);
	
	TreeMap<Integer, Integer> tmSum = tmSums.get(iResource);
	
	if (tmSum==null){
	    tmSum = new TreeMap<Integer, Integer>();
	    tmSums.put(iResource, tmSum);
	}
	
	Integer iOldSum = tmSum.get(iPos);
	
	tmSum.put(iPos, iOldSum != null ? iOldSum.intValue() + iValue : iValue);
    }

    for (int i=2; i<=5; i++){
	pResourceTable.modify("resource", i);
    
	switch (i){
	    case 1:
		    pResourceTable.modify("title", "CPUs");
		    pResourceTable.modify("description", "Pledged number of CPUs");
		    break;
	    case 2:
		    pResourceTable.modify("title", "kSI2K");
		    pResourceTable.modify("description", "Pledged kSI2K units");
		    break;
	    case 3:
		    pResourceTable.modify("title", "Bandwidth");
		    pResourceTable.modify("description", "Pledged available bandwidth (Mbps)");
		    break;
	    case 4:
		    pResourceTable.modify("title", "Disk Storage");
		    pResourceTable.modify("description", "Pledged disk storage (TB)");
		    break;
	    case 5:
		    pResourceTable.modify("title", "Mass Storage");
		    pResourceTable.modify("description", "Pledged mass storage (TB)");
		    break;
	}
    
	TreeMap<Integer, Integer> tmSum = tmSums.get(i);
    
	for (int y=Y_START; y<=Y_END; y++){
	    for (int q=0; q<=3; q++){
		pResourceHeader.modify("year", y);
		pResourceHeader.modify("quarter", q+1);
		
		int yq = (y-Y_START)*4+q;
		
		String sColor =  yq==QNOW ? "FFDDCC" : (y%2==0 ? "FFFFE2" : "EAEACF");
		
		pResourceHeader.modify("color", sColor);
		
		pResourceTable.append("header", pResourceHeader);
		
		
		// footer
		pResourceFooter.modify("table", i);
		pResourceFooter.modify("quarter", yq);
		pResourceFooter.modify("text", tmSum!=null && tmSum.containsKey(yq) ? ""+tmSum.get(yq) : "-");
		pResourceFooter.modify("color", sColor);
		
		pResourceTable.append("footer", pResourceFooter);
	    }
	}
	
	TreeMap<String, TreeMap<Integer, Integer>> tmSites = tmResources.get(i);
	
	for (int j=0; j<alSites.size(); j++){
	    String sSite = alSites.get(j);
	    
	    pResourceLine.modify("resource", i);
	    pResourceLine.modify("number", j+1);    
	    pResourceLine.modify("name", sSite);

	    for (int k=0; k<QUARTERS; k++){
		TreeMap<Integer, Integer> tm;
		
		if (tmSites!=null && (tm=tmSites.get(sSite))!=null && tm.containsKey(k)){
		    pResourceCell.modify("value", tm.get(k));
		}
		else{
		    pResourceCell.modify("value", "-");
		}
		
		pResourceCell.modify("table", i);
		pResourceCell.modify("name", sSite);
		pResourceCell.modify("quarter", k);
		
		String sColor;
		
		if (j%2==0){
		    sColor = k==QNOW ? "FFEEDD" : ((k/4)%2!=0 ? "FFFFEF" : "F6F6E5");
	        }
		else{
		    sColor = k==QNOW ? "FFDDCC" : ((k/4)%2!=0 ? "FFFFE2" : "EAEACF");
	        }
		
		pResourceCell.modify("color", sColor);
		
		pResourceLine.append(pResourceCell);
	    }
	    
	    pResourceLine.modify("color", j%2==0 ? "#FFFFFF" : "#F0F0F0");
	    
	    pResourceTable.append(pResourceLine);
	}
	
	pResourceTable.modify("name", "Tab "+i);
	pResourceTable.modify("id", "tab"+i);
	
	pPledged.append(pResourceTable);
    }
    
    pPledged.modify("jsp", JSP);
    
    pMaster.append(pPledged);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
    
    Utils.logRequest("/pledged_future.jsp", baos.size(), request);
%>