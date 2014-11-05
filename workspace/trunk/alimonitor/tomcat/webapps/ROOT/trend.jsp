<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.ServletExtension,lia.web.utils.Formatare,lia.Monitor.monitor.*,lia.Monitor.Store.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /trend.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    int iSort = Integer.parseInt(request.getParameter("sort") == null || request.getParameter("sort").length() == 0 ? "1" : request.getParameter("sort"));
    int iSortType = Integer.parseInt(request.getParameter("type") == null || request.getParameter("type").length() == 0 ? "0" : request.getParameter("type"));
    int iFilter = Integer.parseInt(request.getParameter("filter") == null || request.getParameter("filter").length() == 0 ? "0" : request.getParameter("filter"));
    
    final String SITE_BASE = sc.getRealPath("/");

    ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("bookmark", "/trend.jsp");
    
    pMaster.modify("title", "Running jobs trend");
    
    Page p = new Page("trend_new.res");
    
    Page pLine = new Page("trend_line_new.res");
    
    DB db = new DB();
    
    String sQuery = 
	"select '_TOTALS_' as name,1 as cpus,1 as ksi2k UNION "+
	"select * FROM (SELECT name,get_pledged(name, 1)::bigint as cpus,get_pledged(name, 2)::bigint as ksi2k from abping_aliases where (select count(1) from monitor_ids where mi_key=name||'/Site_Jobs_Summary/jobs/RUNNING_jobs')=1 ";
    
    if(iSort < 1 || iSort>3){
	iSort = 1;
    }
    
    if(iSortType < 0 || iSortType>1){
	iSortType = 0;
    }
    
    final int iSortFinal = iSort;
    final int iSortTypeFinal = iSortType;
    
    p.modify("type_"+iSort, (iSortType+1) % 2);
    p.modify("type_"+iSort+"_img", iSortType == 0 ? "desc" : "asc");
    p.modify("sort_link", "&sort="+iSort+"&type="+iSortType);

    final HashMap<String,Integer> hmCPUs = new HashMap<String, Integer>();
    final HashMap<String,Integer> hmSI2K = new HashMap<String, Integer>();
    final HashMap<String,Integer> hmRJob = new HashMap<String, Integer>();
    final HashMap<String,Integer> hmPSI2 = new HashMap<String, Integer>();

    Comparator<String> comp = null;

    switch (iSort) {
	case 1:
	    sQuery += " ORDER BY lower(name) "+(iSortType == 1 ? "DESC" : "ASC");
	
	    comp = new Comparator<String>(){
		public int compare(String s1, String s2){
		    return s1.toLowerCase().compareTo(s2.toLowerCase()) * (iSortTypeFinal == 1 ? -1 : 1);
		}
	    };
	
	    p.comment("com_2", false);
	    p.comment("com_3", false);
	    break;
	    
	case 2:
	    p.comment("com_1", false);
	    p.comment("com_3", false);
	    
	    comp = new Comparator<String>(){
		public int compare(String s1, String s2){
		    Integer i1 = hmRJob.get(s1);
		    Integer i2 = hmRJob.get(s2);
		    
		    int cmp = i1==null ? (i2==null ? 0 : -1) : (i2==null ? 1 : i1.compareTo(i2));
		    
		    if (cmp==0)
			cmp = s1.toLowerCase().compareTo(s2.toLowerCase());
			
		    return cmp * (iSortTypeFinal == 1 ? -1 : 1);
		}
	    };
	    
	    break;
	    
	case 3:
	    p.comment("com_1", false);
	    p.comment("com_2", false);
	    
	    comp = new Comparator<String>(){
		public int compare(String s1, String s2){
		    Integer i1 = null;
		    Integer i2 = null;
		    
		    if (hmSI2K.containsKey(s1)){
			/*
			i1 = hmPSI2.get(s1);
			
			i1 = new Integer((i1 == null ? 0 : i1.intValue()) * 100 / hmSI2K.get(s1).intValue());
			*/
			
			i1 = hmSI2K.get(s1).intValue();
		    }

		    if (hmSI2K.containsKey(s2)){
			/*
			i2 = hmPSI2.get(s2);
			
			i2 = new Integer((i2 == null ? 0 : i2.intValue()) * 100 / hmSI2K.get(s2).intValue());
			*/
			
			i2 = hmSI2K.get(s2).intValue();
		    }
		    
		    int cmp = i1==null ? (i2==null ? 0 : -1) : (i2==null ? 1 : i1.compareTo(i2));
		    
		    if (cmp==0)
			cmp = s1.toLowerCase().compareTo(s2.toLowerCase());
			
		    return cmp * (iSortTypeFinal == 1 ? -1 : 1);
		}
	    };

	    break;	    
    }
    
    sQuery += ") as x;";
    
    if(iFilter >=0){
	if(iFilter > 3){
    	    iFilter = 0;
	}
	
	p.modify("title_sort", iFilter);
	p.modify("filter", iFilter);
    }

    db.query(sQuery);
    
    monPredicate pred = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -1000*60*60*24, -1, new String[]{"RUNNING_jobs"}, null);
    monPredicate predServices = new monPredicate("*", "AliEnServicesStatus", "*", -1000*60*60*24, -1, new String[]{"Status"}, null);
    monPredicate predMessages = new monPredicate("*", "AliEnServicesStatus", "*", -1000*60*60*24, -1, new String[]{"Message"}, null);
    monPredicate predSI2K = new monPredicate("*", "Site_Jobs_Summary", "sum", -1000*60*60*24, -1, new String[]{"run_ksi2k_R"}, null);
    
    TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();
    
    DataSplitter ds = store.getDataSplitter(new monPredicate[] {pred, predSI2K}, 120000);
    
    final long[] lTimes = new long[] {1000*60*60, 1000*60*60*6, 1000*60*60*12, 1000*60*60*24};
    
    final long lNow = System.currentTimeMillis();
    
    int iCount = 0;
    
    int max = 0;
    
    Vector vCache = Cache.getLastValues(pred);
    
    for (int i=0; i<vCache.size(); i++){
	Object o = vCache.get(i);
	
	if (o instanceof Result){
	    Result r = (Result) o;
	    
	    if (!r.FarmName.equals("_TOTALS_") && r.param[0] > max)
		max = (int) r.param[0];
	}
    }
    
    int serv_ok = 0;
    int serv_warn = 0;
    int serv_down = 0;

    final Properties prop = new Properties();
    
    prop.setProperty("compact.min_interval", "120000");
    prop.setProperty("compact.displaypoints", "200");
    prop.setProperty("history.integrate.enable", "1");
    prop.setProperty("history.integrate.timebase", "1");
    prop.setProperty("data.align_timestamps", "true");
    prop.setProperty("default.measurement_interval", "120");
    prop.setProperty("size", "false");
    prop.setProperty("skipnull", "1");

    Vector<String> vSites = new Vector<String>();
    
    int iTotalKSI2K = 0;
    
    while (db.moveNext()){
	String sSite = db.gets(1);
	int icpus = db.geti(2);
	int iksi2k = db.geti(3);
	
	vSites.add(sSite);
	
	if (icpus>0)
	    hmCPUs.put(sSite, icpus);
	    
	if (iksi2k>0)
	    hmSI2K.put(sSite, iksi2k);
	
	pred.Node = sSite;
	predSI2K.Farm = sSite;
	
	Object o = Cache.getLastValue(pred);
	
	int lastValue = 0;
	
	final boolean bt = sSite.equals("_TOTALS_");
	
	if (!bt)
	    iTotalKSI2K += iksi2k;
	
	if (o != null && o instanceof Result){
	    double v = ((Result) o).param[0];
	    hmRJob.put(sSite, (int) v);
	}
	
	Vector vSI2K = ds.get(predSI2K);
	
	Vector vIntegrate = Utils.integrateSeries(vSI2K, prop, false, 1000*60*60*24, 0);

	if (vIntegrate.size() > 0){
	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
	
	    double si2k = rInt.param[0] / (60*60*24);
		
	    hmPSI2.put(sSite, (int) si2k);
	}
    }
    
    if (comp != null)
	Collections.sort(vSites, comp);
	
    for (int iSite=0; iSite<vSites.size(); iSite++){
	final String sSite = vSites.get(iSite);
	final int icpus = hmCPUs.containsKey(sSite) ? hmCPUs.get(sSite) : 0;
	
	pred.Node = sSite;

	int lastValue = 0;
	
	final boolean bt = sSite.equals("_TOTALS_");
	
	final int iksi2k = bt ? iTotalKSI2K : (hmSI2K.containsKey(sSite) ? hmSI2K.get(sSite) : 0);
	
	if (hmRJob.containsKey(sSite)){
	    lastValue = hmRJob.get(sSite);
	    
	    (bt ? p : pLine).modify("running", lastValue);
	    
	    (bt ? p : pLine).modify("ratio_cpus", ServletExtension.showDottedDouble(lastValue * 100d / icpus, 2)+"%");
	}
	else{
	    (bt ? p : pLine).modify("running", "-");
	}
	
	int iStatus = 0;
	
	if (!bt){
	    predServices.Farm = sSite;
	    Vector vServices = Cache.getLastValues(predServices);
	
	    if (vServices==null || vServices.size()==0){
		pLine.modify("icon", "trend_stop");
		pLine.modify("message", "No monitoring information");
		
		iStatus = 3;
		
		serv_down++;
	    }
	    else{
		boolean ok = true;
	    
	        String sMessage = "";
	
		for (int i=0; i<vServices.size(); i++){
		    Object o = vServices.get(i);
		
		    if (o instanceof Result){
			Result r = (Result) o;
		    
			if (r.param[0] > 0.5){
			    ok = false;
			
			    predMessages.Farm = sSite;
			    predMessages.Node = r.NodeName;
			
			    o = Cache.getLastValue(predMessages);
			
			    sMessage += "<b>"+r.NodeName+"</b> : <br>";
			
			    if (o instanceof eResult){
				sMessage += Formatare.replace(((eResult) o).param[0].toString(), "\n", "<br>")+"<br><br>";
			    }
			}
		    }
		}
	    
		if (ok){
		    pLine.modify("icon", "trend_ok");
		    pLine.modify("message", "All services are OK");
		    
		    iStatus = 1;
		    
		    serv_ok++;
		}
		else{
		    pLine.modify("icon", "trend_alert");
		    pLine.modify("message", sMessage);
		    
		    iStatus = 2;
		    
		    serv_warn++;
		}
	    }

	    double l = Math.sqrt(lastValue);
	    double m = Math.sqrt(max);
	
	    int r = (int) (255 - (l * 55 / m));
	    int b = 255;
	    int g = (int) (255 - (l * 55 / m));
	
	    pLine.modify("running_color", Utils.toHex(new Color(r,g,b)));
	    
	}
	
	int iSIProvided = 0;
	
	if (hmPSI2.containsKey(sSite)){
	    iSIProvided = hmPSI2.get(sSite);
		
	    (bt ? p : pLine).modify("ksi2k", ""+iSIProvided);
		
	    if (iksi2k>0){
	        if (iSIProvided*2 < iksi2k)
	    	    (bt ? p : pLine).modify("ksi2k_color", "FFCCCC");
		else
		    (bt ? p : pLine).modify("ksi2k_color", "DDFFEE");
		    
		(bt ? p : pLine).modify("ratio_ksi2k", ServletExtension.showDottedDouble(iSIProvided * 100 / iksi2k, 2)+"%");
	    }
	    else{
	        (bt ? p : pLine).modify("ksi2k_color", "FFAAAA");
	        
	        (bt ? p : pLine).modify("ratio_ksi2k", "?");
	    }
	}
	else{
	    (bt ? p : pLine).modify("ksi2k", "-");
	    (bt ? p : pLine).modify("ksi2k_color", "FFAAAA");
	    (bt ? p : pLine).modify("ratio_ksi2k", "-");
	}
	
	Vector v = ds.get(pred);
	
	//System.err.println("Got "+v.size()+" values for "+pred);
	
	long[] lClosest = new long[] {1000*60*15, 1000*60*30, 1000*60*60, 1000*60*60*2};
	int[] lValues = new int[] {-1, -1, -1, -1};
	
	for (int i=0; i<v.size(); i++){
	    Object o = v.get(i);
	    
	    if (o instanceof Result){
		Result r = (Result) o;
		
		for (int j=0; j<lTimes.length; j++){
		    long lDiff = Math.abs(lNow - r.time - lTimes[j]);
		
		    if (lDiff < lClosest[j]){
			lClosest[j] = lDiff;
			lValues[j] = (int) r.param[0];
		    }
		}
		
	    }
	}
	
	for (int j=0; j<lTimes.length; j++){
	    if (lValues[j] >= 0){
		final int v2 = lValues[j];
		final int v1 = lastValue;
		
		(bt ? p : pLine).modify("count_"+j, "<b>"+lValues[j]+"</b>");
		
		final int width = 20;
		final int height = 20;
		
		float sloap;
		
		if (v1 == 0){
			sloap = v2==0 ? 0 : -100000;
		}
		else{
		    if ( v2==0 )
			sloap = 100000;
		    else
			sloap = (float) (v1 - v2) / v2;
		}
		
		final float sloap_abs = (float) Math.abs(sloap);
		
		float dx1, dx2, dy1, dy2;
		int x1, x2, y1, y2;
		
		if (sloap_abs < 1){
			dx1 = 0;
			dx2 = width-1;
			
			dy1 = height/2 * (sloap+1);
			// sanity check
			if (dy1<0) dy1 = 0;
			if (dy1>=height) dy1 = height-1;
			
			dy2 = height - dy1;
		}
		else{
			if (sloap>0){
				dy1 = height - 1;
				dy2 = 0;
			}
			else{
				dy1 = 0;
				dy2 = height - 1;
			}
			
			dx1 = width * (sloap*sloap - 1) / (2*sloap*sloap);
			dx2 = width - dx1 -1;
			
			if (dx1 > dx2){
				dx1 = dx2 = width/2f;
			}
			
			//System.err.println("  dx1 = "+dx1+", dx2 = "+dx2);
		}
		
		final float dx = dx2 - dx1;
		final float dy = dy2 - dy1;
		final float l = (float) Math.sqrt(dx * dx + dy * dy);
		final float dir_x = dx / l;
		final float dir_y = dy / l;
		
		final double angle = Math.acos(dx/l) * 180 / Math.PI;
		
		final int angle_rnd = Math.round((float)angle) * (sloap < 0 ? -1 : 1);
	
		String sAngle = "flat";
		
		if (Math.abs(angle)>5){
		    sAngle = sloap < 0 ? "down" : "up";
		}
		
		int iPercent = iksi2k > 0 ? iSIProvided * 20 / iksi2k : 0;
		
		if (iPercent>19)
		    iPercent = 19;
		
		if (iPercent>=10){
		    sAngle = "green_"+sAngle+"_"+(19-iPercent);
		}
		else{
		    sAngle = "red_"+sAngle+"_"+iPercent;
		}
	
		(bt ? p : pLine).modify("angle_"+j, v1==0 && v2==0 ? "x" : sAngle);
		
		if (v1!=0 && v2!=0){
		    int r;
		    int g;
		    int b;
		
		    if (sloap > 0){
			r = 0;
			g = sloap_abs > 1 ? 0 : (int) (255 * (1-sloap_abs));
			b = sloap_abs > 1 ? 255 : (int) (255 * sloap_abs);
		    }
		    else{
			r = Math.min(sloap_abs > 1 ? 255 : (int) (255 * 3 * sloap_abs), 255);
			g = sloap_abs > 1 ? 0 : (int) (255 * (1-sloap_abs));
			b = 0;			
		    }

		    Color c = new Color(r,g,b).darker();
		
		    double percent = (double) (v1 - v2) / v2 * 100;
		    
		    (bt ? p : pLine).modify("extra_"+j, "<br>variation: "+ "<font color=#"+Utils.toHex(c)+"><b>"+(percent>0 ? "+" : "") +ServletExtension.showDottedDouble(percent, 1) + "%</b></font>");
		}
	    }
	    else{
		(bt ? p : pLine).modify("count_"+j, "no");
		(bt ? p : pLine).modify("angle_"+j, "x");
	    }
	}
	
	if (!bt && (iFilter==0 || iFilter==iStatus)){
	    pLine.modify("color", iCount%2==0 ? "FFFFFF" : "F0F0F0");
	    iCount++;

	    pLine.modify("count", iCount);
	    pLine.modify("site", sSite);
	    pLine.modify("pledged_cpus", icpus);
	    pLine.modify("pledged_ksi2k", iksi2k);

	    p.append(pLine);
	}
	else
	    pLine.toString();
	    
	if (bt){
	    p.modify("pledged_cpus", icpus);
	    p.modify("pledged_ksi2k", iksi2k);
	}
    }
    
    p.modify("services_stats", "<font color=#009900>OK:</font> "+serv_ok+"<br><font color=#CCAA00>Services down:</font> "+serv_warn+"<br><font color=#DD0000>Site down:</font> "+serv_down);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/trend.jsp", baos.size(), request);
%>