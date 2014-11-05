<%@ page import="alimonitor.*,utils.*,lazyj.cache.*,java.net.*,lia.Monitor.monitor.*,lia.web.utils.ThreadedPage,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*,utils.IntervalQuery" %><%
    RequestWrapper rw = new RequestWrapper(request);
    
    int pass = rw.geti("pass", 0);

    final DB db = new DB();
    
    String q = "SELECT distinct run FROM configuration INNER JOIN lpm_history ON (run=runno AND jdl LIKE '/alice/cern.ch/user/a/alidaq/QA/QA%/QA.jdl' and status=2) WHERE (quality is null or quality=1 or quality=3 or quality=16) AND sum_trigger>0";
    
    if (pass>0){
	if (pass==1){
	    q += " AND parameters LIKE '%/ESDs/pass1%'";
	}
	else{
	    q += " AND parameters LIKE '%/ESDs/pass%' AND parameters NOT LIKE '%/ESDs/pass1%'";
	}
    }

    String energy = rw.gets("energy");
    
    if (energy.length()>0){
	final String sClause = IntervalQuery.numberInterval(energy, "energy");
	    
	if (sClause.length()>0){
    	    q += " AND "+sClause;
        }    
    }

    String field = rw.gets("field");
    
    if (field.length()>0){
	final String sClause = IntervalQuery.numberInterval(field, "field");
	    
	if (sClause.length()>0){
    	    q += " AND "+sClause;
        }    
    }
    
    q += " ORDER BY run DESC;";
    
    db.query(q);
    
    response.setContentType("text/plain");
    
    while (db.moveNext()){
	out.println(db.gets(1));
    }
    
    lia.web.servlets.web.Utils.logRequest("/services/eva.jsp", 0, request);
%>