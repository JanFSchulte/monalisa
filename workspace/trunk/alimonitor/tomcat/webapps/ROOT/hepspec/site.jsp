<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.DB,org.jfree.chart.*,org.jfree.chart.axis.NumberAxis,org.jfree.chart.labels.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.category.*,org.jfree.data.category.*,org.jfree.data.statistics.*,java.awt.*,org.jfree.ui.*,org.jfree.chart.entity.*,org.jfree.chart.axis.*,org.jfree.chart.urls.*" %><%!
    public static final double hepspec(final double rootmarks){
	//return rootmarks / 231.7;
	return rootmarks / 189.567;
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /hepspec/site.jsp", 0, request);

    final ServletContext sc = getServletContext();

    final RequestWrapper rw = new RequestWrapper(request);
    
    String sBookmark = "/hepspec/site.jsp";

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("title", "HepSpec06 results");
    pMaster.modify("comment_refresh", "//");
    pMaster.comment("com_alternates", false);

  
    final Page p = new Page("hepspec/site.res");
    final Page pLine = new Page("hepspec/site_line.res");
    
    String sSite = rw.gets("site");
    
    if (sSite.length()==0)
	sSite = "FZK";

    sBookmark += "?site="+Format.encode(sSite);
	
    pMaster.modify("bookmark", sBookmark);
    
    // -------------------

    final DefaultStatisticalCategoryDataset dataset = new DefaultStatisticalCategoryDataset();
    
    final DB db = new DB();
    
    String q = "select cpumodel,cachesize,avg(rootmarks) as rootmarks_avg,stddev(rootmarks) as rootmarks_stddev,count(1) as tests,count(distinct hostname) as hosts from rootmarks_view where site='"+Format.escSQL(sSite)+"' group by cpumodel, cachesize order by 3 desc, 4 asc, 1 asc ;";
    
    //System.err.println(q);
    
    db.query(q);

    p.modify("site", sSite);

    while (db.moveNext()){
        double hep = hepspec(db.getd("rootmarks_avg"));
        double stddev = hepspec(db.getd("rootmarks_stddev"));
	
	dataset.add(hep, stddev, sSite, db.gets("cpumodel")+"/"+db.gets("cachesize"));
	
	pLine.fillFromDB(db);
	pLine.modify("hepspec", hep);
	pLine.modify("stddev", stddev);
	pLine.modify("site", sSite);
	
	p.append(pLine);
    }
    
    db.query("select count(distinct (cpumodel,cachesize)) as models, avg(rootmarks) as rootmarks_avg, stddev(rootmarks) as rootmarks_stddev, count(distinct hostname) as hosts, count(1) as cnt from rootmarks_view where site='"+Format.escSQL(sSite)+"';");
    
    p.fillFromDB(db);
    p.modify("hepspec", hepspec(db.getd("rootmarks_avg")));
    p.modify("stddev", hepspec(db.getd("rootmarks_stddev")));
    
    db.query("select value,count(1) from rootmarks_string where key='AliEn Site' group by 1 order by 1;");
    
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_sites", "<option value='"+Format.escHtml(s)+"'"+(s.equals(sSite) ? " selected" :"")+">"+Format.escHtml(s)+" ("+db.geti(2)+")</option>");
    }

    StatisticalBarRenderer statisticalbarrenderer = new StatisticalBarRenderer();
    statisticalbarrenderer.setDrawBarOutline(false);
    statisticalbarrenderer.setErrorIndicatorPaint(Color.cyan.darker());
    statisticalbarrenderer.setIncludeBaseInRange(false);
    statisticalbarrenderer.setBaseItemLabelGenerator(new StandardCategoryItemLabelGenerator());
    statisticalbarrenderer.setBaseItemLabelsVisible(true);
    statisticalbarrenderer.setBaseItemLabelPaint(Color.yellow);
    statisticalbarrenderer.setBasePositiveItemLabelPosition(new ItemLabelPosition(ItemLabelAnchor.INSIDE6, TextAnchor.BOTTOM_CENTER));
    
    final CategoryAxis categoryAxis = new CategoryAxis("CPU Type");
    
    categoryAxis.setCategoryLabelPositions(CategoryLabelPositions.UP_90);
    
    final NumberAxis numberAxis = new NumberAxis("HepSpec06 / core");
    
    final CategoryPlot plot = new CategoryPlot(dataset, categoryAxis, numberAxis, statisticalbarrenderer);
    
    final JFreeChart jfreechart = new JFreeChart("HepSpec06 benchmarking results @ "+sSite, plot);
    
    //"CPU type", "HepSpec", dataset, PlotOrientation.VERTICAL, true, true, true);
    
    numberAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
    numberAxis.setAutoRangeIncludesZero(false);
    
    GradientPaint gradientpaint = new GradientPaint(0.0F, 0.0F, Color.blue, 0.0F, 0.0F, new Color(0, 0, 64));
    statisticalbarrenderer.setSeriesPaint(0, gradientpaint);
    statisticalbarrenderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator("{1} = {2}", java.text.NumberFormat.getInstance()));
    
    statisticalbarrenderer.setBaseItemURLGenerator(new StandardCategoryURLGenerator("cpu_site.jsp", "series", "category"));
    
    final String SITE_BASE = sc.getRealPath("/");

    Properties prop = lia.web.servlets.web.Utils.getProperties(SITE_BASE+"/WEB-INF/conf/", "hepspec_index");
    
    lia.web.servlets.web.display.setChartProperties(jfreechart, prop);
    
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 800;
    
    int width = 1050;
        
    String sImage = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(jfreechart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, lia.web.utils.ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());

    lia.web.servlets.web.display.registerImageForDeletion(sImage, 60);
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/hepspec/index.jsp", baos.size(), request);
%>