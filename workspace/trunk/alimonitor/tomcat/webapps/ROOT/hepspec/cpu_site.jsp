<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.text.DecimalFormat,java.io.*,lia.Monitor.Store.Fast.DB,org.jfree.chart.*,org.jfree.chart.axis.NumberAxis,org.jfree.chart.labels.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.category.*,org.jfree.data.category.*,org.jfree.data.statistics.*,java.awt.*,org.jfree.ui.*,org.jfree.chart.entity.*,org.jfree.chart.axis.*,org.jfree.chart.urls.*,org.jfree.chart.renderer.xy.*" %><%!
    public static final double hepspec(final double rootmarks){
	//return rootmarks / 231.7;
	return rootmarks / 189.567;
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /hepspec/cpu.jsp", 0, request);

    final ServletContext sc = getServletContext();

    final RequestWrapper rw = new RequestWrapper(request);
    

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("comment_refresh", "//");
    pMaster.comment("com_alternates", false);

    String sSite = rw.gets("series");
    String sCPU = rw.gets("category");
    
    String sCacheSize = "";
    
    if (sCPU.indexOf('/')>0){
	sCacheSize = sCPU.substring(sCPU.lastIndexOf('/')+1);
	sCPU = sCPU.substring(0, sCPU.lastIndexOf('/'));
    }

    String sBookmark = "/hepspec/cpu_site.jsp?category="+Format.encode(sCPU)+"&series="+Format.encode(sSite);
    pMaster.modify("bookmark", sBookmark);

    pMaster.modify("title", "HepSpec06 results for "+Format.escHtml(sCPU)+" / "+Format.escHtml(sCacheSize)+" @ "+Format.escHtml(sSite));
  
    final Page p = new Page("hepspec/cpu_site.res");
    final Page pLine = new Page("hepspec/cpu_site_line.res");

    p.modify("cpu", sCPU);
    p.modify("cachesize", sCacheSize);
    p.modify("site", sSite);
    
    // -------------------

    HistogramDataset dataset = new HistogramDataset();

    final DB db = new DB();    

    String q = "select count(1) as cnt, avg(rootmarks) as avg, min(rootmarks) as min, max(rootmarks) as max, stddev(rootmarks) as stddev, count(distinct hostname) as hosts from rootmarks_view "+
	"where site='"+Format.escSQL(sSite)+"' and cpumodel='"+Format.escSQL(sCPU)+"' and cachesize='"+Format.escSQL(sCacheSize)+"';";

    db.query(q);

    final int cnt = db.geti(1);
    final double avg = db.getd(2);
    final double min = db.getd(3);
    final double max = db.getd(4);
    final double stddev = db.getd(5);
    
    p.fillFromDB(db);
    p.modify("havg", hepspec(avg));
    p.modify("hmin", hepspec(min));
    p.modify("hmax", hepspec(max));
    p.modify("hstddev", hepspec(stddev));

    db.query("select rootmarks_view.*, rload.value as load1, rtotalmem.value as total_mem  from rootmarks_view left outer join rootmarks_numeric rload on rootmarks_view.jobid=rload.jobid and rload.key='load1'"+
     " left outer join rootmarks_numeric rtotalmem on rootmarks_view.jobid=rtotalmem.jobid and rtotalmem.key='total_mem' "+
     "where site='"+Format.escSQL(sSite)+"' and cpumodel='"+Format.escSQL(sCPU)+"' and cachesize='"+Format.escSQL(sCacheSize)+"' order by hostname, ip, rootmarks desc;");
    
    double[] data = new double[cnt];

    for (int i=0; i<cnt; i++){
	db.moveNext();

	final double rootmarks = db.getd("rootmarks");
	final double hep = hepspec(rootmarks);

	data[i] = hep;	
	pLine.fillFromDB(db);
	pLine.modify("hepspec", hep);
	
	int r = 0;
	int g = 255;
	int b = 0;
	
	if (rootmarks>avg){
	    b = (int) (150 * (rootmarks - avg) / (max - avg));
	    g = 255 - b;
	}
	else
	if (rootmarks<avg){
	    r = (int) (255 * (avg-rootmarks) / (avg - min));
	    g = 255 - r/2;
	}
	
	pLine.modify("hepspec_color", lia.web.servlets.web.Utils.toHex(new int[]{r,g,b}));
	
	p.append(pLine);
    }
    
    try{
        dataset.addSeries(sCPU+" / "+sCacheSize+" @ "+sSite, data, 50);
    }
    catch (Exception e){
	e.printStackTrace();
    }

    final XYBarRenderer renderer = new XYBarRenderer();
    renderer.setDrawBarOutline(false);
    
    renderer.setBaseToolTipGenerator(new StandardXYToolTipGenerator());
    
    final NumberAxis xAxis = new NumberAxis("HepSpec06 / core");
    final NumberAxis yAxis = new NumberAxis("Count");
    
    xAxis.setAutoRangeIncludesZero(false);
    
    db.query("select min(rootmarks), max(rootmarks) from rootmarks_view where cpumodel='"+Format.escSQL(sCPU)+"' and cachesize='"+Format.escSQL(sCacheSize)+"';");
    //xAxis.setRange(hepspec(db.getd(1)), hepspec(db.getd(2)));
    
    yAxis.setNumberFormatOverride(new DecimalFormat("0"));
    //yAxis.setTickUnit(new NumberTickUnit(1));
    
    XYPlot plot = new XYPlot(dataset, xAxis, yAxis, renderer);
    
    final JFreeChart jfreechart = new JFreeChart(sSite, plot);
    
    final String SITE_BASE = sc.getRealPath("/");

    Properties prop = lia.web.servlets.web.Utils.getProperties(SITE_BASE+"/WEB-INF/conf/", "hepspec_index");
    
    lia.web.servlets.web.display.setChartProperties(jfreechart, prop);
    
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 600;
    
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