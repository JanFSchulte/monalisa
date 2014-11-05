<%@ page import="java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,java.awt.Dimension,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    Utils.logRequest("START /bits/bits_chart.jsp", 0, request);

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    response.setContentType("text/html");

    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    Properties prop = Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "bits_chart");
    ByteArrayOutputStream baos = new ByteArrayOutputStream(2000);

    Page p = new Page(baos, BASE_PATH+"/bits/bits_chart.res");

    final String sTestname  = request.getParameter("testname");
    final String sTestkey   = request.getParameter("testkey");
    final String sParameter = request.getParameter("parameter");

    XYSeries xys = new XYSeries(sParameter);
    
    String q = "select split_part(testkey,'.',4), result from bits_benchmark bb1 where testname='"+Formatare.mySQLEscape(sTestname)+"' and testkey like '"+Formatare.mySQLEscape(sTestkey)+".%' and parameter='"+Formatare.mySQLEscape(sParameter)+"' and '1.0'=(select result from bits_benchmark where testname=bb1.testname and testkey=bb1.testkey and parameter like '%test') order by split_part(testkey,'.',4)::int asc;";

    //System.out.println(q);

    DB db = new DB();
    db.query(q);

    long lMinTime = db.getl(1)*1000;
    long lMaxTime = lMinTime;

    while (db.moveNext()){
	lMaxTime = db.getl(1)*1000;
	xys.add(lMaxTime, db.getl(2));
    }

    XYSeriesCollection xyseriescollection = new XYSeriesCollection();

    xyseriescollection.addSeries(xys);
    
    ValueAxis va = Utils.getValueAxis(prop, lMinTime, lMaxTime);
    
    NumberAxis na = new NumberAxis();
    
    boolean bSize = !sParameter.endsWith("time");
    
    NumberFormat nf = new MyNumberFormat(bSize, "b", bSize ? "" : " s");
    na.setTickUnit(new NumberTickUnit(bSize ? 1.024 : 1.0, nf), false, false);
    na.setNumberFormatOverride(nf);

    final java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd.MM.yyyy HH:mm:ss");

    StandardXYToolTipGenerator ttg = new StandardXYToolTipGenerator(){
	public String generateToolTip(final org.jfree.data.xy.XYDataset dataset, final int series, final int item) {
	    if (dataset.getY(series, item) == null)
		return null;
		
	    String sSeriesName = null;
	    
	    if (dataset.getSeriesKey(series) != null)
		sSeriesName = dataset.getSeriesKey(series).toString();
		
	    final double d = dataset.getY(series, item).doubleValue();
	    
	    final long lTime = dataset.getX(series, item).longValue();
	    
	    final String sDate = sdf.format(new java.util.Date(lTime));
	    
	    String sRet = sSeriesName + ": (" + sDate + ") <b>";
	    
	    if (sParameter.endsWith("time"))
		sRet += Formatare.showInterval((long) d*1000);
	    else
		sRet += DoubleFormat.size(d);
	    
	    return sRet + "</b>";
	}
    };

    StandardXYItemRenderer xyir = new StandardXYItemRenderer(StandardXYItemRenderer.SHAPES_AND_LINES, ttg, null);
    
    XYPlot xyplot = new XYPlot(xyseriescollection, va, na, xyir);

    JFreeChart chart = new JFreeChart(null, xyplot);
    
    display.setChartProperties(chart, prop);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 310;
    
    int width = 480;
    
    String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);    

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    Utils.logRequest("/bits/bits_chart.jsp", baos.size(), request);
%>