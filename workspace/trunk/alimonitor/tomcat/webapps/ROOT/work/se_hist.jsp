<%@ page import="lazyj.*,org.jfree.chart.*,org.jfree.chart.plot.*,org.jfree.data.xy.*,org.jfree.chart.axis.*,org.jfree.chart.renderer.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.title.*,java.util.*,java.io.*,java.awt.*,org.jfree.ui.*,lia.web.servlets.web.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,lia.web.utils.ServletExtension,lia.web.utils.Annotation,lia.web.utils.Annotations,java.text.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*,lia.util.*,java.util.concurrent.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /work/se_hist.jsp", 0, request);

    final DB db = new DB("SELECT se_name FROM list_ses;");
    
    while (db.moveNext()){
	final String sSE = db.gets(1);
    
	final DB db2 = new DB("SELECT mi_id FROM monitor_ids WHERE mi_key='_STORAGE_/"+sSE+"/ADD/OK';");
	
	int iID = db2.geti(1);
	
	db2.query("SELECT rectime,mval FROM w4_100m_ok WHERE id="+iID+" AND rectime<(SELECT min(testtime) from se_testing_history where se_name='"+sSE+"') ORDER BY rectime ASC;");
	
	final DB db3 = new DB();
	
	int iCount = 0;
	int iOk = 0;
	int iFail = 0;
	
	while (db2.moveNext()){
	    long lTime = db2.getl(1);
	    int status = 1 - db2.geti(2);
	    
	    //out.println(lTime+" - "+status+" ("+db2.getd(2)+")<BR>");
	
	    db3.query("INSERT INTO se_testing_history (se_name, status, testtime) VALUES ('"+sSE+"', "+status+", "+lTime+");");
	    
	    iCount++;
	    
	    if (status==0) iOk++; else iFail++;
	}
	
	out.println(sSE+" - "+iCount+" ("+iOk+" ok, "+iFail+" fail)<BR>");
	
	//break;
    }
    
    lia.web.servlets.web.Utils.logRequest("/work/se_hist.jsp", 0, request);
%>