<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,java.security.cert.*,auth.*,lia.Monitor.monitor.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /export/dashboard.jsp", 0, request);

    response.setContentType("text/plain");
    
    RequestWrapper.setNotCache(response);

    out.println("VOBox,hostname,ip,alive,ALIEN_CE,ALIEN_PackMan,ALIEN_Monitor,SE_add,SE_ls,SE_get,SE_whereis,SE_rm");

    DB db = new DB("select name,ip from (select distinct name,ip from abping_aliases inner join monitor_ids on name=split_part(mi_key,'/',1) and split_part(mi_key,'/',2)='AliEnServicesStatus' and name not like '%.cern.ch') as x order by lower(name) asc;");
    
    final String[] vsAlienServices = new String[]{"CE", "PackMan", "Monitor"};
    final String[] vsSETests = new String[]{"ADD", "LS", "GET", "WHEREIS", "RM"};
    
    final monPredicate pAlien = new monPredicate("", "AliEnServicesStatus", "", -1, -1, new String[]{"Status"}, null);
    final monPredicate pSE  = new monPredicate("_STORAGE_", "", "", -1, -1, new String[]{"Status"}, null);
    
    while (db.moveNext()){
	String sName = db.gets(1);
    
	out.print(sName+",");
	
	String sIP = db.gets(2);
	
	out.print(lazyj.Utils.getHostName(sIP)+","+sIP+",");
	
	Object o = Cache.getLastValue(ServletExtension.toPred(sName+"/MonaLisa/%/Load5"));
	
	out.print(o==null ? "-1," : "0,");
	
	for (String sService: vsAlienServices){
	    pAlien.Farm = sName;
	    pAlien.Node = sService;
	
	    o = Cache.getLastValue(pAlien);
	    
	    if (o!=null && (o instanceof Result)){
		Result r = (Result) o;
		
		out.print((int)r.param[0]+",");
	    }
	    else{
		out.print("-1,");
	    }
	}
	
	for (String sTest: vsSETests){
	    pSE.Cluster = "ALICE::"+sName+"::%";
	    pSE.Node = sTest;
	    
	    Vector v = Cache.getLastValues(pSE);
	    
	    if (v==null || v.size()==0)
		out.print("-1");
	    else{
		int iAnd = 0;
		
		for (int i=0; i<v.size(); i++){
		    Result r = (Result) v.get(i);
		    
		    iAnd += (int)r.param[0] == 0 ? 0 : 1;
		}
		
		out.print(iAnd==0 ? "0" : iAnd==v.size() ? "1" : "2");
	    }
		
	    if (!sTest.equals(vsSETests[vsSETests.length - 1])){
		out.print(",");
	    }
	}
	
	out.println();
    }

    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/export/dashboard.jsp", 1, request);
%>