<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.security.cert.*" %><%!

public String addToURL(final String sURL, final String sKey, final String sValue){
    String s = sURL;

    if (s.indexOf("?")<0)
	s += "?";
    else
	s += "&";

    return s+Format.encode(sKey)+"="+Format.encode(sValue);
}

%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /production/requests.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "RAW data production requests");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    final Page p = new Page("production/requests.res");
    final Page pLine = new Page("production/requests_line.res");
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    final DB db = new DB();
    
    // ----- page parameters ------
    
    String sCond = "";

    String sBookmark = "/production/requests.jsp";
    
    String sRunFilter = rw.gets("filter_runno");
    String sPartitionFilter = rw.gets("filter_partition");
    int iPassFilter = rw.geti("filter_pass", -1);
    int iStatusFilter = rw.geti("filter_status", -1);

    if (sRunFilter.length()>0){
	StringTokenizer st = new StringTokenizer(sRunFilter, ",");
	
	String sRunCond = "";
	
	while (st.hasMoreTokens()){
	    String sTok = st.nextToken().trim();
	    
	    String sEl = "";
	    
	    if (sTok.indexOf("-")<0){
		try{
		    int i = Integer.parseInt(sTok);
		    
		    sEl = "r.run="+i;
		}
		catch (Exception e){
		}
	    }
	    else{
		try{
		    int i1 = Integer.parseInt(sTok.substring(0, sTok.indexOf("-")));
		    int i2 = Integer.parseInt(sTok.substring(sTok.indexOf("-")+1));
		    
		    sEl = "(r.run>="+i1+" AND r.run<="+i2+")";
		}
		catch (Exception e){
		}
	    }
	    
	    if (sEl.length()>0){
		if (sRunCond.length()>0)
		    sRunCond += " OR ";
		    
		sRunCond += sEl;
	    }
	}
	
	if (sRunCond.length()>0){
	    if (sCond.length()>0)
		sCond += " AND ";
	
	    sCond += "("+sRunCond+")";
	    
	    sBookmark = addToURL(sBookmark, "filter_runno", sRunFilter);
	}
    }
    
    if (sPartitionFilter.length()>0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "partition='"+Format.escSQL(sPartitionFilter)+"'";
	
	sBookmark = addToURL(sBookmark, "filter_partition", sPartitionFilter);
    }
    
    if (iPassFilter>=0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "pass="+iPassFilter;
	
	sBookmark = addToURL(sBookmark, "filter_pass", ""+iPassFilter);
    }
    
    if (iStatusFilter>=0){
	if (sCond.length()>0)
	    sCond += " AND ";
	
	sCond += "status="+iStatusFilter;
	
	sBookmark = addToURL(sBookmark, "filter_statuts", ""+iStatusFilter);
    }
    
    if (sCond.length()>0)
	sCond = " WHERE "+sCond;
	
    String sOrderBy = "run";
    String sOrder = "DESC";
    
    // check if the user is authenticated (SSL) and if it has the admin priviledges
    
    final boolean bSecure = request.isSecure();
    
    final boolean bIsAdmin;
    
    if (bSecure){
    	final X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

    	if (cert!=null && cert.length>0){
	    final String sDN = cert[0].getSubjectDN().getName();
	
	    final auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);

	    final auth.LdapCertificateRealm realm = new auth.LdapCertificateRealm();
	    
	    p.modify("username", principal.getName());
	    
	    bIsAdmin = realm.hasRole(principal, "pwgadmin");
	}
	else{
	    bIsAdmin = false;
	}
    }
    else{
	bIsAdmin = false;
    }
    
    p.comment("com_secure", bSecure);
    p.comment("com_insecure", !bSecure);
    p.comment("com_auth", bIsAdmin);
    p.comment("com_noauth", !bIsAdmin);
    
    p.modify("secure", bSecure);
    
    // ----- display lines ------

    db.query("SELECT r.*, chunks, partition from rawdata_processing_requests as r inner join rawdata_runs on r.run=rawdata_runs.run and partition!='TDSMtest' "+sCond+" ORDER BY "+sOrderBy+" "+sOrder+";");
    
    int iCnt = 0;
    int iCnt0 = 0;
    int iCnt1 = 0;
    int iCnt2 = 0;
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	pLine.comment("com_auth", bIsAdmin);
	
	int iStatus = db.geti("status");
	
	switch (iStatus){
	    case 0:
		pLine.modify("status_text", "Requested");
		pLine.modify("status_color", "#FFFFFF");
		pLine.comment("com_link", false);
		iCnt0++;
		break;
	
	    case 1:
		pLine.modify("status_text", "Started");
		pLine.modify("status_color", "#FFFF00");
		pLine.comment("com_link", true);
		iCnt1++;
		break;
	
	    case 2:
		pLine.modify("status_text", "Completed");
		pLine.modify("status_color", "#00FF00");
		pLine.comment("com_link", true);
		iCnt2++;
		break;
	}
	
	iCnt ++;
	
	p.append(pLine);
    }
    
    // ----- Totals ------------
    
    p.modify("totalcnt", iCnt);
    p.modify("requested", iCnt0);
    p.modify("started", iCnt1);
    p.modify("completed", iCnt2);
    
    // ----- fill options ------
    p.modify("filter_runno", sRunFilter);
    
    for (int pass=0; pass<=100; pass++){
	p.append("pass_options", "<option value="+pass+(pass==iPassFilter ? " selected" : "")+">"+pass+"</option>");
    }
    
    p.modify("status_"+iStatusFilter, "selected");

    db.query("SELECT partition, count(1) as cnt from rawdata_runs WHERE partition!='TDSMtest' GROUP BY partition ORDER BY partition DESC;");
    
    while (db.moveNext()){
	String sp = db.gets(1);
    
	p.append("opt_partition", "<option value='"+sp+"'"+(sp.equals(sPartitionFilter) ? " selected" : "")+">"+sp+" ("+db.gets(2)+")</option>");
    }
    
    // Create the bookmarks
    
    pMaster.modify("bookmark", sBookmark);

    // ----- closing -----
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/production/requests.jsp", baos.size(), request);
%>