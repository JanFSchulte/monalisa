<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.*,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /dproof/index.jsp", 0, request);
    
    RequestWrapper.setNotCache(response);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("dproof/index.res");

    final Page pLine = new Page("dproof/index_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "300");
    
    pMaster.modify("bookmark", "/dproof/");
    pMaster.modify("title", "dPROOF dashboard");

    // -------------------------

    DB db = new DB("SELECT distinct split_part(mi_key,'/',3) FROM monitor_ids WHERE split_part(mi_key,'/',2)='dPROOF' order by 1;");

    final monPredicate dPROOF = new monPredicate("*", "dPROOF", null, -1000*60, -1, new String[]{"*"}, null);

    int iTotalWorkers = 0;

    while (db.moveNext()){
	final String sHostname = db.gets(1);
    
	pLine.modify("hostname", sHostname);

	dPROOF.Node = sHostname;

	final Vector v = Cache.getLastValues(dPROOF);
    
	final ArrayList al = Cache.filterByTime(v, dPROOF);
	
	boolean bOnline = false;
	
	boolean bXRDOnline = false;
	boolean bXPROOFOnline = false;
	boolean bPROOFAgentOnline = false;
	
	String sFarmName = null;
	
	for (Object o: al){
	    if (o instanceof Result){
		final Result r = (Result) o;

		if (sFarmName==null)
		    sFarmName = r.FarmName;

		final int iValue = (int) r.param[0];

		final String f = r.param_name[0];

		pLine.modify(f, iValue);
		
		bOnline = true;
		
		if (f.equals("workers"))
		    iTotalWorkers += iValue;
		else
		if (f.equals("XROOTD_port"))
		    bXRDOnline = true;
		else
		if (f.equals("XPROOF_port"))
		    bXPROOFOnline = true;
		else
		if (f.equals("PoD_port"))
		    bPROOFAgentOnline = true;
	    }
	}
	
	pLine.modify("XROOTD_port_color", bXRDOnline ? "99FF99" : "FF9999");
	pLine.modify("XPROOF_port_color", bXPROOFOnline ? "99FF99" : "FF9999");
	pLine.modify("PoD_port_color", bPROOFAgentOnline ? "99FF99" : "FF9999");
	
	//sFarmName = "CERN-L";
	
	if (sFarmName==null){
	    DB db2 = new DB("SELECT split_part(mi_key,'/',1) FROM monitor_ids WHERE mi_key LIKE '%/dPROOF/"+Format.escSQL(sHostname)+"/workers' ORDER BY mi_lastseen DESC LIMIT 1;");
	    
	    if (db2.moveNext()){
		sFarmName = db2.gets(1);
	    }
	}
	
	if (sFarmName!=null)
	    pLine.modify("farmname", sFarmName);
	
	p.append(pLine);
    }
    
    p.modify("total_workers", iTotalWorkers);

    pMaster.append(p);

    pMaster.write();

    String s = new String(baos.toByteArray());
    out.println(s);
        
    lia.web.servlets.web.Utils.logRequest("/dproof/index.jsp", baos.size(), request);
%>