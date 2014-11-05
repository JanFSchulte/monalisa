<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /export/dashboard_caf.jsp", 0, request);

    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);
    
    final monPredicate pCAF = new monPredicate("aliendb1.cern.ch", "PROOF::CAF::STORAGE_xrootd_Nodes", "", -1, -1, new String[]{"xrootd_up", "cmsd_up"}, null);
    
    DB db = new DB("SELECT distinct split_part(mi_key,'/',3) FROM monitor_ids WHERE mi_key like 'aliendb1.cern.ch/PROOF::CAF::STORAGE_xrootd_Nodes/%';");
    
    boolean bMasterOK = false;
    
    int iCounterOK = 0;
    int iCounterFAIL = 0;
    
    while (db.moveNext()){
	String sNode = db.gets(1);
	
	pCAF.Node = sNode;
	
	Vector v = Cache.getLastValues(pCAF);
	
	boolean bxrootd = false;
	boolean bolbd = false;
	
	for (int i=0; v!=null && i<v.size(); i++){
	    Result r = (Result) v.get(i);
	    
	    if (r.param_name[0].equals("xrootd_up"))
		bxrootd = (int) r.param[0]>=1;
	    else
	    if (r.param_name[0].equals("cmsd_up"))
		bolbd = (int) r.param[0]==1;
	}
	
	boolean bOK = bxrootd && bolbd;
	
	if (bOK) iCounterOK ++;
	else iCounterFAIL ++;
	
	if (sNode.equals("lxbsq1409.cern.ch"))
	    bMasterOK = bOK;
    }
    
    out.println("Master OK : "+bMasterOK);
    out.println("Nodes OK : "+iCounterOK);
    out.println("Nodes ERR : "+iCounterFAIL);
    
    lia.web.servlets.web.Utils.logRequest("/export/dashboard_caf.jsp", 0, request);
%>