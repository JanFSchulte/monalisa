<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*"%><%!
%><%
    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");
        
    final String BASE_PATH=SITE_BASE+"/";
            
    final Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "jobResUsageSum_time_cpu");
                
    final RequestWrapper rw = new RequestWrapper(request);
    
    final boolean hideGroups = rw.getb("hide", false);
    
    final Page p = new Page("export/cpu_report.res", false);
    final Page pLine = new Page("export/cpu_report_line.res", false);
    
    final long lNow    = System.currentTimeMillis();
    //final long lStart1 = 1320102000000L;	// 2011-11-01
    final long lStart1 = lNow - 1000L*60*60*24*31;
    
    Date dApril1 = new Date((new Date()).getYear(), 3, 1);
    
    if (dApril1.getTime() > System.currentTimeMillis())
	dApril1 = new Date((new Date()).getYear()-1, 3, 1);
    
    final long lStart2 = dApril1.getTime();

    final long lInt1 = lNow - lStart1;
    final long lInt2 = lNow - lStart2;

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res", false);
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("title", "CPU accounting information");

    TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

    monPredicate pred1 = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInt1, -1, new String[]{"run_time_R", "run_ksi2k_R", "cpu_time_R"}, null);
    monPredicate pred2 = new monPredicate("*", "Site_Jobs_Summary", "sum", -lInt2, -1, new String[]{"run_time_R", "run_ksi2k_R", "cpu_time_R"}, null);

    DataSplitter ds1 = store.getDataSplitter(new monPredicate[] {pred1}, lia.web.servlets.web.Utils.getCompactInterval(prop, lInt1, 0));
    DataSplitter ds2 = store.getDataSplitter(new monPredicate[] {pred2}, lia.web.servlets.web.Utils.getCompactInterval(prop, lInt2, 0));

    final DB db = new DB();

    db.query("select groupname,site from pledged_dynamic where length(groupname)>0 and site in (select distinct split_part(mi_key,'/',1) from monitor_ids where mi_key like '%/Site_Jobs_Summary/sum/run_time_R') order by 1,2;");

    double sum_hep2 = -1;

    double total_hep2 = -1;
    
    double sum_hep1 = -1;
    
    double total_hep1 = -1;

    String prevGroup = null;
    
    double sum_cpu1 = 0;
    double sum_wall1 = 0;
    double sum_cpu2 = 0;
    double sum_wall2 = 0;

    while (db.moveNext()){
	final String site = db.gets(2);

	if (site.equals("_TOTALS_"))
	    continue;

	final String group = db.gets(1);
	
	if (!group.equals(prevGroup) && !hideGroups){
	    if (prevGroup!=null && (sum_hep1>0 || sum_hep2>0)){
		pLine.modify("site", "<b><div align=right>"+prevGroup+"</div></b>");

		if (sum_hep1>0)
		    pLine.modify("hep1", "<B>"+Format.point(sum_hep1)+"</B>");
		    
		if (sum_hep2>0)
		    pLine.modify("hep2", "<B>"+Format.point(sum_hep2)+"</B>");
		    
		p.append(pLine);
		p.append(pLine);
	    }
	    
	    sum_hep1 = -1;
	    sum_hep2 = -1;
	    
	    prevGroup = group;
	}

	pred1.Farm=site;
	pred1.parameters = new String[]{"run_time_R"};

	Vector v = ds1.get(pred1);

	Vector vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt1, 0);
	
	double wall1 = -1;
	double cpu1 = -1;
	double wallsi2k1 = -1;

	double wall2 = -1;
	double cpu2 = -1;

	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    wall1 = rInt.param[0] / (60*60);
    	    
    	    sum_wall1 += wall1;
	}
	
	pred1.parameters = new String[]{"cpu_time_R"};
	v = ds1.get(pred1);
	
	vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt1, 0);
	
	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    cpu1 = rInt.param[0] / (60*60);
    	    
    	    sum_cpu1 += cpu1;
	}
	    
	pred1.parameters = new String[]{"run_ksi2k_R"};
	v = ds1.get(pred1);
	
	vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt1, 0);
	
	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    wallsi2k1 = rInt.param[0] / (60*60);
	}

	double factor = wall1>0 ? wallsi2k1/wall1 : -1;
		
	pred2.Farm = site;
	pred2.parameters = new String[]{"run_time_R"};
	
	v = ds2.get(pred2);
	vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt2, 0);
	
	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    wall2 = rInt.param[0] / (60*60);
    	    
    	    sum_wall2 += wall2;
	}

	pred2.parameters = new String[]{"cpu_time_R"};
	
	v = ds2.get(pred2);
	vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt2, 0);
	
	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    cpu2 = rInt.param[0] / (60*60);
    	    
    	    sum_cpu2 += cpu2;
	}

	pred2.parameters = new String[]{"run_ksi2k_R"};
	
	v = ds2.get(pred2);
	vIntegrate = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lInt2, 0);
	
	double factor2 = -1;
	
	if (vIntegrate.size() > 0){
    	    Result rInt = (Result) vIntegrate.get(vIntegrate.size()-1);
    	    
    	    double wallsi2k2 = rInt.param[0] / (60*60);
    		    
    	    factor2 = wallsi2k2 / wall2;
	}

	if (wall1<=0 && cpu1<=0 && wall2<=0 && cpu2<=0)
	    continue;

	pLine.modify("site", site);
	
	if (wall1>=0){
	    pLine.modify("wall1", (long) wall1);
	    pLine.modify("occ1", Format.point((wall1 * 60 * 60 * 1000)/lInt1));
	}
	    
	if (cpu1>=0)
	    pLine.modify("cpu1", (long) cpu1);
	
	if (wall1>0 && cpu1>0)
	    pLine.modify("eff1", Format.point(cpu1*100/wall1));

	if (wallsi2k1>=0){
	    pLine.modify("si2k1", (long) wallsi2k1);
	    
	    double power1 = (wallsi2k1 * 60 * 60 * 1000) / lInt1;
	    
	    pLine.modify("power1", Format.point(power1));

	    double hep1 = power1 * 4.2 / 1000;
	    
	    pLine.modify("hep1", Format.point(hep1));
	    
	    sum_hep1 = Math.max(sum_hep1, 0) + hep1;
	    total_hep1 = Math.max(total_hep1, 0) + hep1;
	}

	if (wall2>=0){
	    pLine.modify("wall2", (long) wall2);
	    pLine.modify("occ2", Format.point((wall2 * 60 * 60 * 1000)/lInt2));
	}
	    
	if (cpu2>=0)
	    pLine.modify("cpu2", (long) cpu2);
	
	if (wall2>0 && cpu2>0)
	    pLine.modify("eff2", Format.point(cpu2*100/wall2));

	if ((factor>0 || factor2>0) && wall2>0){
	    factor2 = Math.max(factor, factor2);
	
	    double wallsi2k2 = factor2 *wall2;
	
	    pLine.modify("si2k2", (long) wallsi2k2);
	    
	    double power2 = (wallsi2k2 * 60 * 60 * 1000) / lInt2;
	    
	    pLine.modify("power2", Format.point(power2));
	    
	    double hep2 = power2 * 4.2 / 1000;
	    
	    pLine.modify("hep2", Format.point(hep2));
	    
	    sum_hep2 = Math.max(sum_hep2, 0) + hep2;
	    total_hep2 = Math.max(total_hep2, 0) + hep2;
	}

	if (factor>0)
	    pLine.modify("avg1", Format.point(factor));
	
	if (factor2>0)
	    pLine.modify("avg2", Format.point(factor2));
	
        p.append(pLine);
    }
    
    if (!hideGroups){
	if (prevGroup!=null){
	    pLine.modify("site", "<b><div align=right>"+prevGroup+"</div></b>");
		
	    if (sum_hep1>0)
		pLine.modify("hep1", "<B>"+Format.point(sum_hep1)+"</B>");
	    
	    if (sum_hep2>0)
		pLine.modify("hep2", "<B>"+Format.point(sum_hep2)+"</B>");
		    
	    p.append(pLine);
	    p.append(pLine);
	}

	if (total_hep1>0 || total_hep2>0){
	    pLine.modify("site", "<b><div align=right>TOTAL</div></b>");
	
	    if (total_hep1>0)
		pLine.modify("hep1", "<B>"+Format.point(total_hep1)+"</B>");

	    if (total_hep2>0)
		pLine.modify("hep2", "<B>"+Format.point(total_hep2)+"</B>");
		
	    pLine.modify("cpu1", (long) sum_cpu1);
	    pLine.modify("cpu2", (long) sum_cpu2);
	    
	    pLine.modify("wall1", (long) sum_wall1);
	    pLine.modify("wall2", (long) sum_wall2);
	    
	    pLine.modify("eff1", Format.point(sum_cpu1 * 100 / sum_wall1)+"%");
	    pLine.modify("eff2", Format.point(sum_cpu2 * 100 / sum_wall2)+"%");
		
	    p.append(pLine);
	}
    }
    
    p.modify("hours1", lInt1/(1000*60*60));
    p.modify("hours2", lInt2/(1000*60*60));

    p.comment("com_hide", !hideGroups);

    pMaster.append(p);

    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("bookmark", "/export/cpu_report.jsp");

    pMaster.write();

    response.setContentType("text/html");

    String s = new String(baos.toByteArray());
    out.println(s);
                    
%>