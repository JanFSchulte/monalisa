<%@ page import="alimonitor.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /bits/bits_benchmark.jsp", 0, request);
    
    RequestWrapper rw = new RequestWrapper(request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "AliRoot benchmarking");
    
    Page p = new Page("bits/bits_benchmark.res");
    Page pTest = new Page("bits/bits_benchmark_table.res");
    Page pLine = new Page("bits/bits_benchmark_line.res");

    String JSP = "bits/bits_benchmark.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    String URL="/"+JSP;

    String sTestFilter = rw.gets("test");
    
    String sOldTest = "";
    String sOldKey  = "";
    
    DB db = new DB();
        
    String q = "select testname,testkey,parameter,result,testtime from bits_benchmark  WHERE testkey LIKE '%.%.%.%' ";
    
    final boolean bTestFilter = sTestFilter!=null && sTestFilter.length()>0;
    
    if (bTestFilter){
	q += " and testname='"+Formatare.mySQLEscape(sTestFilter)+"'";
    }
    
    q+=" order by testname asc, split_part(testkey,'.',4) desc, parameter like '%test' desc, testtime desc";

    db.query(q);
    
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd.MM.yyyy HH:mm");
    
    TreeSet<String> tsOS = new TreeSet<String>();
    TreeSet<String> tsARCH = new TreeSet<String>();
    TreeSet<String> tsRELEASE = new TreeSet<String>();
    
    int iCount = 0;
    
    final int iMaxUnfilteredCount = 10;
    
    // ---------- filters -----------
    
    final int iStateFilter = rw.geti("filter_state", -1);
    final int iTimeFilter = rw.geti("filter_date");
    
    final String sOSFilter = rw.gets("filter_os");
    final String sARCHFilter = rw.gets("filter_arch");
    final String sRELEASEFilter = rw.gets("filter_release");
    
    // ------------------------------
    
    boolean bSkip = false;
    
    boolean bOk = false;
    
    while (db.moveNext()){
	String sTest = db.gets(1);
	String sKey  = db.gets(2);

	if (!sTest.equals(sOldTest)){
	    if (sOldTest.length()>0){
		for (String s: tsOS){
		    pTest.append("options_filter_os", "<option value=\""+s+"\">"+s+"</option>");
		}

		for (String s: tsARCH){
		    pTest.append("options_filter_arch", "<option value=\""+s+"\">"+s+"</option>");
		}
		
		for (String s: tsRELEASE){
		    pTest.append("options_filter_release", "<option value=\""+s+"\">"+s+"</option>");
		}
		
		if (!bSkip && iCount>0 && (!bTestFilter || iCount<iMaxUnfilteredCount)){
		    pTest.append(pLine);
		}
	    
		tsOS.clear();
		tsARCH.clear();
		tsRELEASE.clear();
	    
	        p.append(pTest);
	    }
	    
	    iCount = 0;
	    
	    pTest.modify("testname", db.gets(1));
	    pTest.comment("com_showall", bTestFilter);
	    
	    sOldTest = sTest;
	    sOldKey = "";
	    bOk = false;
	    
	    bSkip = false;
	}
	
	if (!sKey.equals(sOldKey)){
	    //System.err.println("Key change : "+sOldKey+" -> "+sKey);
	
	    if (sOldKey.length()>0 && !bSkip){
		iCount++;
		
		if (!bTestFilter && iCount>iMaxUnfilteredCount){
		    pLine.toString();
		}
		else{
	            pTest.append(pLine);
	        }    
	    }
	    
	    sOldKey = sKey;
	    bSkip = false;
	    bOk = false;

	    StringTokenizer st = new StringTokenizer(sKey, ".");
	    
	    String sOS = st.hasMoreTokens() ? st.nextToken() : "?";
	    String sARCH = st.hasMoreTokens() ? st.nextToken() : "?";
	    String sRELEASE = st.hasMoreTokens() ? st.nextToken() : "?";

	    tsOS.add(sOS);
	    tsARCH.add(sARCH);
	    tsRELEASE.add(sRELEASE);
	    
	    final long lEndDate = db.getl(5)*1000;
	    final long lStartDate = st.hasMoreTokens() ? Long.parseLong(st.nextToken())*1000 : lEndDate;
	    
	    int iStatus = -1;
	    if (db.gets(3).endsWith("test")){
		try{
		    iStatus = (int) Math.round(Double.parseDouble(db.gets(4)));
		    bOk = iStatus == 1;
		}
		catch (Exception e){
		    // ignore
		    bOk = false;
		}
	    }
	    
	    long lDiff = lEndDate - lStartDate;
	    if (lDiff<0)
		lDiff = 0;
	    
	    if (
		(sOSFilter.length()>0 && !sOS.equals(sOSFilter)) ||
		(sARCHFilter.length()>0 && !sARCH.equals(sARCHFilter)) ||
		(sRELEASEFilter.length()>0 && !sRELEASE.equals(sRELEASEFilter)) ||
		(iTimeFilter>0 && System.currentTimeMillis() - lStartDate > iTimeFilter * 1000L*60*60*24) ||
		(iStateFilter>=0 && iStateFilter!=iStatus)
	    ){
		//System.err.println(sOSFilter+" - "+sOS);
		//System.err.println(sARCHFilter+" - "+sARCH);
		//System.err.println(sRELEASEFilter+" - "+sRELEASE);
		//System.err.println(iStateFilter +" -- "+iStatus);
	    
		bSkip = true;
		
		continue;
	    }

	    pLine.modify("os", sOS);
	    pLine.modify("arch", sARCH);
	    pLine.modify("release", sRELEASE);
	    
	    pLine.modify("testkey", sKey);
	    
	    pLine.modify("date", sdf.format(new Date(lStartDate)));
	    pLine.modify("enddate", sdf.format(new Date(lEndDate)));
	    pLine.modify("duration", Formatare.showInterval(lDiff));
	    
	    pLine.comment("com_ok", bOk);
	    
	    pLine.modify("testname", db.gets("testname"));
	}
	else{
	    if (bSkip)
		continue;
	}
	
	String sParam = db.gets(3);
	String sValue = db.gets(4);
	
	double dValue = 0;
	try{
	    dValue = Double.parseDouble(sValue);
	}
	catch (Exception e){
	}

	if (sParam.endsWith("size")){
	    pLine.modify("filesize", DoubleFormat.size(dValue));
	    pLine.modify("sizeparam", sParam);
	}
	else
	if (sParam.endsWith("test")){
	    pLine.modify("state", dValue>0.5 ? "<font color=#00CC00><b>OK</b></font>" : "<font color=#CC0000><b>FAILED</b></font>");
	    //pLine.modify("state", "<font color=#00CC00><b>OK</b></font>");
	}
	else
	if (sParam.endsWith("mem")){
	    pLine.modify(sParam, DoubleFormat.size(dValue));
	}
	else
	if (sParam.endsWith("time")){
	    pLine.modify(sParam, Formatare.showInterval((long)(dValue*1000)));
	}
	else
	    pLine.modify(sParam, sValue);
    }
    
    if (!bSkip && (!bTestFilter || iCount<iMaxUnfilteredCount)){
        pTest.append(pLine);
    }

    for (String s: tsOS){
	pTest.append("options_filter_os", "<option value=\""+s+"\" "+(s.equals(sOSFilter)?"selected" : "")+">"+s+"</option>");
    }

    for (String s: tsARCH){
	pTest.append("options_filter_arch", "<option value=\""+s+"\" "+(s.equals(sARCHFilter)?"selected" : "")+">"+s+"</option>");
    }
		
    for (String s: tsRELEASE){
	pTest.append("options_filter_release", "<option value=\""+s+"\" "+(s.equals(sRELEASEFilter)?"selected" : "")+">"+s+"</option>");
    }
    
    pTest.modify("filter_state_"+iStateFilter, "selected");
    pTest.modify("filter_date_"+iTimeFilter, "selected");

    p.append(pTest);
    
    // builds
    
    if (sTestFilter==null || sTestFilter.length()==0 || sTestFilter.equals("build")){
	Page pBuild = new Page("bits/bits_builds_table.res");
	Page pBuildLine = new Page("bits/bits_builds_line.res");
	
	String sQuery = "SELECT bb.* FROM bits_build bb ";
	
	for (String sField: new String[]{"os", "arch", "build_version"}){
	    // build the constraint now
	    String s = rw.esc("filter_"+sField);
	    if (s.length()>0){
		sQuery += "INNER JOIN bits_build bb"+sField+" ON bb.bb_id=bb"+sField+".bb_id AND bb"+sField+".bb_key='"+sField+"' AND bb"+sField+".bb_value='"+s+"' ";
	    }
	
	    // get all the distinct values
	    db.query("SELECT distinct bb_value FROM bits_build WHERE bb_key='"+sField+"';");
	    
	    while (db.moveNext()){
		pBuild.append("options_filter_"+sField, "<option value='"+db.gets(1)+"' "+(s.equals(db.gets(1)) ? "selected" : "")+">"+db.gets(1)+"</option>");
	    }	    
	}
	
	String s = rw.esc("filter_state");
	
	if (s.length()>0){
	    pBuild.modify("filter_state_"+s, "selected");
	    
	    sQuery+="INNER JOIN bits_build bbr ON bb.bb_id=bbr.bb_id AND bbr.bb_key='build_result' AND bbr.bb_value='"+s+".0' ";
	}
	
	int iTimeConstraint = rw.geti("filter_date");
	
	if (iTimeConstraint>0){
	    pBuild.modify("filter_date_"+iTimeConstraint, "selected");
	    
	    sQuery+="WHERE bb.bb_id>extract(epoch from now()-'"+iTimeConstraint+" days'::interval)::int ";
	}
	
	sQuery+="ORDER BY bb.bb_id DESC ";
	
	//System.err.println(sQuery);
	
	final boolean bLimit = sTestFilter==null || sTestFilter.length()==0;
	
	if (bLimit)
	    sQuery += " LIMIT 400";
	else
	    p.comment("com_benchmarks", false);
	
	pBuild.comment("com_showall", !bLimit);
	
	int iLastId = 0;
	iCount = 0;
	
	db.query(sQuery);
	
	while (db.moveNext()){
	    int iID = db.geti("bb_id");
	    
	    if (iID!=iLastId){
		if (iLastId>0){
		    pBuild.append(pBuildLine);
		    
		    if (bLimit && ++iCount>11){
			iLastId = 0;
			break;
		    }
		}
		
		pBuildLine.modify("date", sdf.format(new Date(1000L * iID)));
		
		iLastId = iID;
	    }
	    
	    s = db.gets("bb_key");
	    
	    if (s.equals("arch") || s.equals("os") || s.equals("build_version")){
		pBuildLine.modify(s, db.gets("bb_value"));
	    }
	    else
	    if (s.endsWith("_result")){
		double d = db.getd("bb_value");
		
		int i = (int) d;
		
		pBuildLine.modify(s, i<0||(i==0 && s.equals("build_result")) ? "red" : (i>0 ? "green" : "orange"));
		
		if (s.equals("build_result"))
		    pBuildLine.modify("state", i==0 ? "FAILED" : "OK");
	    }
	    else
	    if (s.endsWith("_time")){
		double d = db.getd("bb_value");
		
		pBuildLine.modify(s, Formatare.showInterval((long)(d*1000)));
	    }
	}
	
	if (iLastId>0)
	    pBuild.append(pBuildLine);
	
	p.append("builds", pBuild);
    }
    
    pMaster.append(p);
    
    pMaster.write();
        
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest(URL, baos.size(), request);
%>
