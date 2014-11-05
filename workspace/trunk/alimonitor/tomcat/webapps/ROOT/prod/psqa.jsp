<%@ page import="java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,alimonitor.*,java.awt.Dimension,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,lazyj.*,utils.*,org.jfree.data.statistics.*,org.jfree.chart.renderer.category.*,org.jfree.chart.labels.*,java.awt.Color,org.jfree.ui.*,org.jfree.chart.urls.*,org.jfree.data.category.*" %><%!
private static final class KeySplitter {

    public ArrayList<String> components = new ArrayList<String>();
    
    public KeySplitter(final String key){
	StringTokenizer st = new StringTokenizer(key,":");
	
	while (st.hasMoreTokens()){
	    String tok = st.nextToken().trim();
	    
	    if (tok.startsWith("\"") && tok.endsWith("\""))
		tok = tok.substring(1, tok.length()-1);
	    
	    components.add(tok);
	}
    }
    
    public String getSeriesName(){
	return components.get(components.size()-1);
    }
    
    public String getTitle(){
	return components.get(components.size()-2);
    }
}
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /prod/psqa.jsp", 0, request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "bits_chart");
    ByteArrayOutputStream baos = new ByteArrayOutputStream(2000);

    final RequestWrapper rw = new RequestWrapper(request);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "PS QA plots");

    final Page p = new Page("prod/psqa.res", false);

    final Page ps = new Page("WEB-INF/res/display/hist_series.res");

    StringTokenizer st = new StringTokenizer(request.getParameter("pid"), ",; \t\r\n");
    
    final Set<Integer> pids = new TreeSet<Integer>();
    
    int err = rw.geti("err", 1);
    
    p.modify("err_"+err, "selected");
    
    while (st.hasMoreTokens()){
	try{
	    pids.add(Integer.valueOf(st.nextToken()));
	}
	catch (Exception e){
	    // ignore
	}
    }
    
    final Set<Integer> runs = new TreeSet<Integer>();
    
    final String[] selectedRuns = rw.getValues("plot_series");
    
    if (selectedRuns!=null){
	for (final String run: selectedRuns){
	    try{
		runs.add(Integer.valueOf(run));
	    }
	    catch (Exception e){
		// ignore
	    }
	}
    }
    
    final String pidList = IntervalQuery.toCommaList(pids);
    final String runList = IntervalQuery.toCommaList(runs);
    
    p.modify("pidlist", pidList);
    
    String key = rw.gets("key");
    
    DB db = new DB();
    
    if (key==null || key.length()==0){
	db.query("select key from psqa where pid in ("+pidList+") order by key limit 1;");
	
	key = db.gets(1);
    }

    String q = "select runno,value,err,outputdir from psqa inner join job_runs_details using(pid) where pid in ("+pidList+") and key='"+lazyj.Format.escSQL(key)+"'";
    
    if (runList.length()>0)
	q += " and run in ("+runList+")";
	
    db.query(q);

    //XYSeries xys = new XYSeries(key);
    
    DefaultStatisticalCategoryDataset dataset = new DefaultStatisticalCategoryDataset();
    
    KeySplitter ks = new KeySplitter(key);
    
    final Set<Integer> seenRuns = new TreeSet<Integer>();
    
    double avg = 0;
    ArrayList<Double> values = new ArrayList<Double>();
    
    final HashMap<Integer, String> runToDir = new HashMap<Integer, String>();
    
    while (db.moveNext()){
	//xys.add(db.geti(1), db.getd(2));
	
	double val = db.getd(2);
	
	dataset.add(val, db.getd(3), ks.getSeriesName(), db.gets(1));
	
	avg += val;
	values.add(Double.valueOf(val));
	
	seenRuns.add(Integer.valueOf(db.geti(1)));
	
	runToDir.put(Integer.valueOf(db.geti(1)), db.gets(4));
    }
    
    double stddev = 0;
    
    if (values.size()>0){
	avg /= values.size();
    
	stddev = 0;
    
	for (Double val: values){
	    stddev += (val.doubleValue() - avg) * (val.doubleValue() - avg);
	}
	
	stddev = Math.sqrt(stddev / values.size());
    }

    db.query("select distinct key from psqa where pid in ("+pidList+") order by 1;");
    
    KeySplitter ksOld = null;
    
    while (db.moveNext()){
	String s = db.gets(1);
	
	KeySplitter ksNew = new KeySplitter(s);

	for (int i=0; i<ksNew.components.size(); i++){
	    String sNew = ksNew.components.get(i);
	    
	    if (ksOld==null || ksOld.components.size()<=i || !ksOld.components.get(i).equals(sNew)){
		sNew = lazyj.Format.escHtml(sNew);
		
		for (int j=0; j<i; j++){
		    sNew = "&nbsp;&nbsp;"+sNew;
		}
		
		p.append("opt_series", "<option "+(i==ksNew.components.size()-1 ? "value='"+lazyj.Format.escHtml(s)+"'" + (s.equals(key) ? " selected" :"") : "disabled='disabled'")+">"+sNew+"</option>");
	    }
	}	
	
	ksOld = ksNew;
    }

    /*    
    XYSeriesCollection xyseriescollection = new XYSeriesCollection();

    xyseriescollection.addSeries(xys);

    StandardXYToolTipGenerator ttg = new StandardXYToolTipGenerator(){
	public String generateToolTip(final org.jfree.data.xy.XYDataset dataset, final int series, final int item) {
	    if (dataset.getY(series, item) == null)
		return null;
		
	    String sSeriesName = null;
	    
	    if (dataset.getSeriesKey(series) != null)
		sSeriesName = dataset.getSeriesKey(series).toString();
		
	    final double d = dataset.getY(series, item).doubleValue();
	    
	    final int run = dataset.getX(series, item).intValue();
	    
	    String sRet = "<b>Run "+run+"</b> : "+d;
	    
	    return sRet;
	}
    };

    StandardXYItemRenderer xyir = new StandardXYItemRenderer(StandardXYItemRenderer.SHAPES_AND_LINES, ttg, null);

    NumberAxis xaxis = new NumberAxis("Run number");
    
    xaxis.setAutoRange(true);
    xaxis.setAutoRangeIncludesZero(false);
    xaxis.setVerticalTickLabels(true);
    
    XYPlot xyplot = new XYPlot(xyseriescollection, xaxis, yaxis, xyir);
    */
    
    NumberAxis yaxis = new NumberAxis(ks.getSeriesName());

    yaxis.setAutoRange(true);
    yaxis.setAutoRangeIncludesZero(false);
    
    CategoryAxis xaxis = new CategoryAxis("Run number");
    xaxis.setCategoryLabelPositions(CategoryLabelPositions.UP_90);
    
    LineAndShapeRenderer renderer;
    
    if (err==0){
	renderer = new DefaultCategoryItemRenderer();
    }
    else{
	renderer = new StatisticalLineAndShapeRenderer(true, true);
    }
    
    renderer.setSeriesShape(0, lia.web.servlets.web.Utils.SHAPE_CIRCLE);
    
    final String sFormat = "{1}: {0} = {2}";
		    
    renderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator(sFormat, new DecimalFormat())); 
    
    StandardCategoryURLGenerator scurlg = new StandardCategoryURLGenerator(){
	@Override
	public String generateURL(final CategoryDataset dataset, final int series, final int category){
	    Integer run = Integer.valueOf(dataset.getColumnKey(category).toString());
	
	    return "/users/download.jsp?path="+lazyj.Format.encode(runToDir.get(run)+"/event_stat.root");
	}
    };
    
    renderer.setBaseItemURLGenerator(scurlg);
    
    renderer.setUseSeriesOffset(false);

    CategoryPlot plot = new CategoryPlot(dataset, xaxis, yaxis, renderer);

    if (values.size()>1){
	ValueMarker averageMarker = new ValueMarker(avg, Color.BLACK, lia.web.servlets.web.Utils.SINGLE_VALUE_MARKER_STROKE);
	averageMarker.setLabelOffsetType(LengthAdjustmentType.EXPAND);
	averageMarker.setLabel("Avg: "+lazyj.Format.point(avg)+", "+(char)0x3C3+": "+lazyj.Format.point(stddev));
	averageMarker.setLabelFont(lia.web.servlets.web.Utils.ANNOTATION_LABEL_FONT);
	
	averageMarker.setLabelPaint(Color.BLACK);
	averageMarker.setLabelAnchor(RectangleAnchor.TOP_LEFT);
	averageMarker.setLabelTextAnchor(TextAnchor.BOTTOM_LEFT);
	
	plot.addRangeMarker(averageMarker, Layer.BACKGROUND);

	IntervalMarker intervalmarker = new IntervalMarker(avg - stddev, avg + stddev);
	intervalmarker.setPaint(Color.LIGHT_GRAY);
	intervalmarker.setAlpha(0.5f);
	
	plot.addRangeMarker(intervalmarker, Layer.BACKGROUND);
    }

    JFreeChart chart = new JFreeChart(ks.getTitle(), plot);
    
    lia.web.servlets.web.display.setChartProperties(chart, prop);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 600;
    
    int width = 1024;
    
    String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, lia.web.utils.ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());

    pMaster.append(p);

    lia.web.servlets.web.display.registerImageForDeletion(sImage, 60);    

    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/bits/bits_chart.jsp", baos.size(), request);
%>