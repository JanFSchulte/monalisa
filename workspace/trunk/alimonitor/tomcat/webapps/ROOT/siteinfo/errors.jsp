<%@ page import="alimonitor.*,lazyj.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.Monitor.Store.*,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /siteinfo/errors.jsp", 0, request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final RequestWrapper rw = new RequestWrapper(request);

    final String sSite = rw.gets("site");
    
    if (sSite.length()==0)
	return;

    final Page p = new Page(baos, "siteinfo/errors.res");

    p.modify("site", sSite);
	
    // -----------------
    
    final long lMinTime = 86400000;
    final long lMaxTime = 0;
    
    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    final Properties prop = new Properties();
    prop.setProperty("compact.min_interval", "120000");
    prop.setProperty("compact.displaypoints", "200");
    prop.setProperty("history.integrate.enable", "true");
    prop.setProperty("history.integrate.timebase", "1");
    prop.setProperty("data.align_timestamps", "true");
    prop.setProperty("default.measurement_interval", "120");

    for (String sState: new String[] {"ERROR_A", "ERROR_E", "ERROR_IB", "ERROR_R", "ERROR_SV", "ERROR_VN", "ERROR_VT", "ERROR_V", "ERROR_RE", "EXPIRED", "FAILED", "KILLED", "LOST"}){
	monPredicate pred = Formatare.toPred("CERN/ALICE_Sites_Jobs_Summary/"+sSite+"/-"+lMinTime+"/-1/"+sState+"_jobs_R");
    
	DataSplitter ds = store.getDataSplitter(new monPredicate[]{pred}, 120000);
    
	Vector v = ds.get(pred);
    
	long l = 0;
    
	if (v!=null && v.size()>0){
	    lia.web.servlets.web.Utils.integrateSeries(v, prop, true, lMinTime, lMaxTime);
	
    	    if (v!=null && v.size()>0){
		l = (long) ((Result) v.lastElement()).param[0];
	    }
	}
	
	p.append("<tr><td align=left>"+sState+"</td><td align=right>"+l+"</td></tr>");
    }

    
    // -----------------
	
    p.write();
    
    out.println(new String(baos.toByteArray()));
    
    lia.web.servlets.web.Utils.logRequest("/siteinfo/errors.jsp?site="+sSite, baos.size(), request);
%>