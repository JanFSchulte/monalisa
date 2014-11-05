<%@ page import="alimonitor.*,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /bits/bits_pertest.jsp", 0, request);
    
    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "AliRoot benchmarking - per test results");
    
    Page p = new Page("bits/bits_pertest.res");
    Page pTest = new Page("bits/bits_pertest_table.res");
    Page pLine = new Page("bits/bits_pertest_line.res");

    String JSP = "bits/bits_pertest.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    String URL="/"+JSP;

    String sTestFilter = request.getParameter("test");
    
    if (sTestFilter==null || sTestFilter.length()==0){
	response.sendRedirect("bits_benchmark.jsp");
	return;
    }
    
    DB db = new DB();
    
    db.query("SELECT testkey FROM (SELECT DISTINCT testkey FROM bits_benchmark WHERE testkey LIKE '%.%.%.%') AS tests ORDER BY split_part(testkey,'.',4)::int DESC, testkey ASC;");
    
    StringBuilder sbTests = new StringBuilder();
    
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd.MM.yyyy HH:mm");
    
    while (db.moveNext()){
	String sTestKey = db.gets(1);
    
	long lDate = Long.parseLong(sTestKey.substring(sTestKey.lastIndexOf(".")+1))*1000;
    
	String sNiceName = sTestKey.substring(0, sTestKey.lastIndexOf("."));
    
	sbTests.append("<option value=\""+sTestKey+"\" "+(sTestKey.equals(sTestFilter)?"selected":"")+">"+sNiceName+" ("+sdf.format(new Date(lDate))+")</option>");
    }
    
    String q = "select testname,testkey,parameter,result,testtime from bits_benchmark" +
	" where testkey='"+Formatare.mySQLEscape(sTestFilter)+"'" +
	" order by testname like '%pp' desc, testname like 'Simulation%' desc, testname asc, split_part(testkey,'.',4) desc, parameter like '%test' desc, testtime desc";

    db.query(q);
    
    TreeSet<String> tsOS = new TreeSet<String>();
    TreeSet<String> tsARCH = new TreeSet<String>();
    TreeSet<String> tsRELEASE = new TreeSet<String>();
    
    int iCount = 0;
    
    final int iMaxUnfilteredCount = 10;
    
    // ---------- filters -----------
    
    int iStateFilter = -1;
    try{
	iStateFilter = Integer.parseInt(request.getParameter("filter_state"));
    }
    catch (Exception e){
    }
    
    int iTimeFilter = 0;
    try{
	iTimeFilter = Integer.parseInt(request.getParameter("filter_date"));
    }
    catch (Exception e){
    }
    
    final String sOSFilter = request.getParameter("filter_os")!=null ? request.getParameter("filter_os") : "";
    final String sARCHFilter = request.getParameter("filter_arch")!=null ? request.getParameter("filter_arch") : "";
    final String sRELEASEFilter = request.getParameter("filter_release")!=null ? request.getParameter("filter_release") : "";
    
    // ------------------------------
    
    boolean bSkip = false;

    String sOldTest = "";
    
    while (db.moveNext()){
	String sTest = db.gets(1);
	String sKey  = db.gets(2);

	if (!sTest.equals(sOldTest)){
	    //System.err.println("Key change : "+sOldTest+" -> "+sKey);
	
	    if (sOldTest.length()>0 && !bSkip){
		iCount++;
		
		if (iCount>iMaxUnfilteredCount){
		    pLine.toString();
		}
		else{
	            pTest.append(pLine);
	        }    
	    }
	    
	    sOldTest = sTest;
	    bSkip = false;

	    StringTokenizer st = new StringTokenizer(sKey, ".");
	    
	    String sOS = st.nextToken();
	    String sARCH = st.nextToken();
	    String sRELEASE = st.nextToken();

	    tsOS.add(sOS);
	    tsARCH.add(sARCH);
	    tsRELEASE.add(sRELEASE);
	    
	    final long lStartDate = Long.parseLong(st.nextToken())*1000;
	    final long lEndDate = db.getl(5)*1000;
	    
	    int iStatus = -1;
	    if (db.gets(3).endsWith("test")){
		try{
		    iStatus = (int) Math.round(Double.parseDouble(db.gets(4)));
		}
		catch (Exception e){
		    // ignore
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
	    
	    pLine.modify("test", db.gets(1));
	    pLine.modify("date", sdf.format(new Date(lStartDate)));
	    pLine.modify("enddate", sdf.format(new Date(lEndDate)));
	    pLine.modify("duration", Formatare.showInterval(lDiff));
	    
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
    
    if (!bSkip){
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
    pTest.modify("options_tests", sbTests.toString());

    p.append(pTest);
    
    pMaster.append(p);
    
    pMaster.write();
        
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest(URL, baos.size(), request);
%>
