<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,org.jfree.chart.*,org.jfree.chart.plot.*,org.jfree.data.category.*,org.jfree.chart.axis.*,org.jfree.chart.renderer.category.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.title.*,java.util.*,java.io.*,java.awt.*,org.jfree.ui.*,lia.web.servlets.web.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.*,org.jfree.chart.urls.XYURLGenerator,lia.web.utils.ServletExtension,java.text.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*" %><%!
    int getXSize(final RequestWrapper rw){
	String sSize = rw.gets("imgsize");
	
	int idx = sSize.indexOf("x");
	
	int x = 1000;
	
	if (idx>0){
	    try{
		x = Integer.parseInt(sSize.substring(0, idx));
	    }
	    catch (Exception e){
	    }
	}
	
	return x;
    }

    int getYSize(final RequestWrapper rw){
	String sSize = rw.gets("imgsize");
	
	int idx = sSize.indexOf("x");
	
	int y = 400;
	
	if (idx>0){
	    try{
		y = Integer.parseInt(sSize.substring(idx+1));
	    }
	    catch (Exception e){
	    }
	}
	
	return y;
    }
    
    String getColor(final int iPledged, final double dDelivered){
	final double dRatio = dDelivered / iPledged;
	
	String sColor = "#009900";
	
	if (dRatio<0.60)
	    sColor = "#990000";
	else
	if (dRatio<0.80)
	    sColor = "#BB9900";
	
	return sColor;
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /barreports/index.jsp", 0, request);

    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "reports/tab");
    
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "Sites KSI2k reports");
    
    final Page p = new Page("barreports/index.res");
    
    final Page pLine = new Page("barreports/index_el.res");

    final RequestWrapper rw = new RequestWrapper(request);

    long lIntervalMin = rw.getl("interval.min", 1000*60*60*24);
    long lIntervalMax = rw.getl("interval.max", 0);
    
    if (lIntervalMin < lIntervalMax){
	long lTemp = lIntervalMin;
	lIntervalMin = lIntervalMax;
	lIntervalMax = lTemp;
    }

    final long lStart = System.currentTimeMillis() - lIntervalMin;
    final long lEnd = System.currentTimeMillis() - lIntervalMax;

    // -------------
    
    final boolean bSites = rw.getb("sites", true);
    
    String sQuery;
    
    if (bSites){
	sQuery = "select site, pledged from (select site, get_pledged(site, 2) as pledged from (SELECT DISTINCT split_part(mi_key,'/',3) AS site FROM monitor_ids WHERE mi_key LIKE 'CERN/ALICE_Sites_Jobs_Summary/%/RUNNING_jobs') as x where site!='_TOTALS_') as y where pledged is not null and pledged>0;";
    }
    else{
	sQuery = "select groupname, pledged from (SELECT groupname, get_pledged_group(groupname, 2) as pledged FROM sites_groups) as x where pledged is not null and pledged > 0;";
    }
    
    final monPredicate pred = bSites ? 
				new monPredicate("*", "Site_Jobs_Summary", "sum", lStart, lEnd, new String[]{"run_ksi2k_R"}, null) : 
				new monPredicate("_GROUPS_", "*", "Site_Jobs_Summary_sum", lStart, lEnd, new String[]{"run_ksi2k_R"}, null);
    
    final DataSplitter ds = ((TransparentStoreFast)TransparentStoreFactory.getStore()).getDataSplitter(new monPredicate[]{pred}, lia.web.servlets.web.Utils.getCompactInterval(prop, lIntervalMin, lIntervalMax));
    
    // -------------
    
    final DefaultCategoryDataset categoryDataset = new DefaultCategoryDataset();
    
    DB db = new DB(sQuery);
    
    int iTotalPledged = 0;
    double dTotalDelivered = 0;
    
    while (db.moveNext()){
	final String sName = db.gets(1);
	final int iPledged = db.geti(2);
    
	if (bSites)
	    pred.Farm = sName;
	else
	    pred.Cluster = sName;
    
	Vector v = ds.get(pred);
	
	double dValue = 0;
	
	if (v.size()>0){
	    v = lia.web.servlets.web.Utils.integrateSeries(v, prop, false, lIntervalMin, lIntervalMax);
	    
	    dValue = ((Result) v.get(v.size()-1)).param[0];
	    
	    dValue /= (lIntervalMin - lIntervalMax)/1000;
	}
    
	categoryDataset.addValue(dValue, "Delivered", sName);
	categoryDataset.addValue(iPledged, "Pledged", sName);
	
	iTotalPledged += iPledged;
	dTotalDelivered += dValue;
	
	pLine.modify("site", sName);
	pLine.modify("pledged", iPledged);
	pLine.modify("delivered", lia.web.utils.DoubleFormat.point(dValue));
	    
	pLine.modify("color", getColor(iPledged, dValue));
	
	p.append(pLine);
    }

    CategoryItemRenderer cir = new BarRenderer3D(5, 4);

    NumberAxis numberAxis = new NumberAxis3D("KSI2k");
    
    NumberFormat nf = new MyNumberFormat(false, "", "");    

    numberAxis.setNumberFormatOverride(nf);
    
    cir.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator(ServletExtension.pgets(prop, "tooltips.format", "{1}: {0} = {2}"), nf));

    CategoryAxis catAxis = new CategoryAxis3D(bSites ? "Sites" : "Countries");
    
    catAxis.setCategoryLabelPositions(CategoryLabelPositions.UP_90);

    CategoryPlot categoryPlot = new CategoryPlot(categoryDataset, catAxis, numberAxis, cir);
    
    JFreeChart jfreechart = new JFreeChart("Resources usage report", categoryPlot);
    
    // -------------

    display.setChartProperties(jfreechart, prop);
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());

    int height = getYSize(rw);
    
    int width = getXSize(rw);
    
    final StringWriter sw = new StringWriter();
    final PrintWriter pw = new PrintWriter(sw);

    String sImage = ServletUtilities.saveChartAsPNG(jfreechart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());
    p.modify("interval_min", lIntervalMin);
    p.modify("interval_max", lIntervalMax);
    p.modify("imgsize_"+rw.gets("imgsize"), "selected");
    p.modify("sites_"+(bSites ? 1 : 0), "selected");

    p.modify("header_name", bSites ? "Site" : "Country");
    
    p.modify("pledged", iTotalPledged);
    p.modify("delivered", lia.web.utils.DoubleFormat.point(dTotalDelivered));
    p.modify("color", getColor(iTotalPledged, dTotalDelivered));

    SimpleDateFormat sdf = new SimpleDateFormat("M/d/yyyy H:00:00");
    p.modify("current_date_time", sdf.format(new Date()));

    display.registerImageForDeletion(sImage, 60);

    pMaster.append(p);

    pMaster.modify("comment_refresh", "//");
    pMaster.write();
    
    response.setContentType("text/html");
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/barreports/index.jsp", baos.size(), request);
%>