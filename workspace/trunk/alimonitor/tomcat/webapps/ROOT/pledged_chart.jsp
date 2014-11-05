<%@ page import="java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,java.awt.*,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,org.jfree.ui.*" %><%
    Utils.logRequest("START /pledged_chart.jsp", 0, request);

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
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page p = new Page(baos, BASE_PATH+"/pledged_chart.res");

    final int iResource = Integer.parseInt(request.getParameter("r"));

    XYSeriesCollection xyseriescollection = new XYSeriesCollection();

    String[] vsSites = request.getParameterValues("s");
    
    DB db = new DB();
    
    Date d = new Date();
    
    d.setDate(1);
    d.setHours(1);
    
    long lMin = 0;
    long lMax = 0;

    for (int i=0; i<vsSites.length; i++){
	final boolean bTotals = vsSites[i].equals("_TOTALS_");
    
	final XYSeries xys = new XYSeries(bTotals ? "SUM" : vsSites[i]);
    
	if (bTotals)
	    db.query("select sum(val),year,quarter FROM pledged_future where resource="+iResource+" group by year, quarter order by year asc, quarter asc;");
	else
	    db.query("SELECT val,year,quarter FROM pledged_future WHERE resource="+iResource+" AND site='"+Formatare.mySQLEscape(vsSites[i])+"' ORDER BY year ASC, quarter ASC;");

	while (db.moveNext()){
	    d.setYear(db.geti(2)-1900);
	    d.setMonth(db.geti(3)*3);
	    d.setDate(1);
	    d.setHours(1);
	    
	    if (d.getTime()<lMin || lMin==0)
		lMin = d.getTime();
		
	    if (d.getTime()>lMax)
		lMax = d.getTime();
	    
	    d.setTime(d.getTime() + 45*24*60*60*1000L);
	
	    long lTime = d.getTime();
	    
	    xys.add(lTime, db.getd(1));
	}
	
	xyseriescollection.addSeries(xys);
    }

    PeriodAxis va = new PeriodAxis("Time");
    PeriodAxisLabelInfo aperiodaxislabelinfo[] = new PeriodAxisLabelInfo[2];
    
    aperiodaxislabelinfo[0] = new PeriodAxisLabelInfo(
	org.jfree.data.time.Month.class, 
	new SimpleDateFormat("MMM"), 
	new RectangleInsets(1D, 1D, 1D, 1D), 
	new Font("SansSerif", 0, 10), 
	Color.black,
	true, 
	PeriodAxisLabelInfo.DEFAULT_DIVIDER_STROKE, 
	PeriodAxisLabelInfo.DEFAULT_DIVIDER_PAINT
    );
    
    aperiodaxislabelinfo[1] = new PeriodAxisLabelInfo(org.jfree.data.time.Year.class, new SimpleDateFormat("yyyy"), new RectangleInsets(0D, 0D, 0D, 0D), new Font("SansSerif", Font.BOLD, 10), Color.blue.darker(), true, PeriodAxisLabelInfo.DEFAULT_DIVIDER_STROKE, PeriodAxisLabelInfo.DEFAULT_DIVIDER_PAINT);
    va.setLabelInfo(aperiodaxislabelinfo);
    va.setMinorTickMarksVisible(false);
    va.setMajorTickTimePeriodClass(org.jfree.data.time.Month.class);
    va.setLowerBound(lMin);
    va.setUpperBound(lMax+90*24*60*60*1000L);
    
    NumberAxis na = new NumberAxis();
    
    boolean bSize = iResource>2;
    
    NumberFormat nf = new MyNumberFormat(bSize, iResource==3 ? "M" : "T", iResource==3 ? "bps" : (iResource==4 ? "B" : ""));
    na.setTickUnit(new NumberTickUnit(bSize ? 1.024 : 1.0, nf), false, false);
    na.setNumberFormatOverride(nf);

    final java.text.SimpleDateFormat sdfMonth = new java.text.SimpleDateFormat("MMM");
    final java.text.SimpleDateFormat sdfYear = new java.text.SimpleDateFormat("yyyy");

    StandardXYToolTipGenerator ttg = new StandardXYToolTipGenerator(){
	public String generateToolTip(final org.jfree.data.xy.XYDataset dataset, final int series, final int item) {
	    if (dataset.getY(series, item) == null)
		return null;
		
	    String sSeriesName = null;
	    
	    if (dataset.getSeriesKey(series) != null)
		sSeriesName = dataset.getSeriesKey(series).toString();
		
	    final double d = dataset.getY(series, item).doubleValue();
	    
	    final long lTime = dataset.getX(series, item).longValue();
	    
	    final String sDate = sdfMonth.format(new java.util.Date(lTime-45*24*60*60*1000L)) + 
				    " - "+
				    sdfMonth.format(new java.util.Date(lTime+40*24*60*60*1000L))+
				    " "+
				    sdfYear.format(new java.util.Date(lTime));
	    
	    String sRet = sSeriesName + ": (" + sDate + ") <b>";
	    
	    if (iResource<=2)
		sRet += (long) d;
	    else{
		if (iResource==3)
		    sRet += DoubleFormat.size(d, "M", true)+"bps";
		else
		    sRet += DoubleFormat.size(d, "T", false)+"B";
	    }
	    
	    return sRet + "</b>";
	}
    };

    StandardXYItemRenderer xyir = new StandardXYItemRenderer(StandardXYItemRenderer.SHAPES_AND_LINES, ttg, null);
    
    XYPlot xyplot = new XYPlot(xyseriescollection, va, na, xyir);

    d = new Date();
    d.setDate(1);
    d.setMonth((d.getMonth()/3) * 3);
    
    final IntervalMarker intervalmarker = new IntervalMarker(d.getTime(), d.getTime()+90*24*60*60*1000L);
                
    intervalmarker.setPaint(new Color(255, 200, 200));
    intervalmarker.setAlpha(0.3f);
    xyplot.addDomainMarker(intervalmarker, org.jfree.ui.Layer.BACKGROUND);

    JFreeChart chart = new JFreeChart(null, xyplot);
    
    display.setChartProperties(chart, prop);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = Integer.parseInt(request.getParameter("height"));
    
    int width = Integer.parseInt(request.getParameter("width"));
    
    String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);    

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    Utils.logRequest("/pledged_chart.jsp", baos.size(), request);
%>