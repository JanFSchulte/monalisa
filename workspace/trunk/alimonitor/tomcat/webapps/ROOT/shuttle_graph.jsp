<%@ page import="java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,java.awt.Dimension,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,lazyj.RequestWrapper,java.awt.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    Utils.logRequest("START /shuttle_graph.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);

    int iRun = rw.geti("run");

    if (iRun==0){    
	response.sendRedirect("/shuttle.jsp");
	return;
    }
    
    int iPrevRun = rw.geti("prevrun", -1);
    
    String sInstance = rw.gets("instance");

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "600");
    
    pMaster.modify("bookmark", "/shuttle_graph.jsp?run="+iRun);
    
    pMaster.modify("title", "SHUTTLE detailed information per run");
    
    Page p = new Page(BASE_PATH+"/shuttle_graph.res");
    
    p.modify("instance", sInstance);

    /**  Range axis  */
    
    final String[] vsStates = new String[] {
	"Started",
	"DCSStarted",
	"DCSError",
	"PPStarted",
	"FXSError",
	"PPError",
	"PPOutOfMemory",
	"PPTimeOut",
	"PPDone",
	"StoreStarted",
	"StoreDelayed",
	"StoreError",
	"Done",
	"Skipped",
	"Failed"
    };
    
    SymbolAxis symbolaxis = new SymbolAxis(null, vsStates);
    
    symbolaxis.setUpperMargin(0.0D);
    
    final HashMap hmStates = new HashMap(vsStates.length);
    
    for (int i=0; i<vsStates.length; i++){
	hmStates.put(vsStates[i], Integer.valueOf(i));
    }
    
    //System.err.println(hmStates);
    
    /** Data walk */
    
    DB db = new DB();
    
    /*
    final String[] vsDetectors = new String[] {
	"SPD",
	"SDD",
	"SSD",
	"TPC",
	"TRD",
	"TOF",
	"PHS",
	"CPV",
	"HLT",
	"HMP",
	"EMC",
	"MCH",
	"MTR",
	"FMD",
	"ZDC",
	"PMD",
	"T00",
	"V00",
	"GRP"
    };*/
    
    final String[] vsDetectors = new String[] {
	"ACO",
	"EMC",
	"FMD",
	"GRP",
	"HLT",
	"HMP",
	"MCH",
	"MTR",
	"PHS",
	"CPV",
	"PMD",
	"SPD",
	"SDD",
	"SSD",
	"TOF",
	"TPC",
	"TRD",
	"TRI",
	"T00",
	"V00",
	"ZDC"
    };
    

    final HashMap hmSeries = new HashMap(vsDetectors.length);
    
    final HashMap hmLastValues = new HashMap(vsDetectors.length);
    
    final HashMap hmRunNumbers = new HashMap(vsDetectors.length);
    
    String sDetectors = "";
    
    for (int i=0; i<vsDetectors.length; i++){
	final String detector = vsDetectors[i];
    
	hmSeries.put(detector, new XYSeries(detector));
	
	hmLastValues.put(detector, Integer.valueOf(-1));
	
	hmRunNumbers.put(detector, new TreeMap());
	
	final String sParamValue = request.getParameter("detector_"+detector);
	
	final boolean bDetectorEnabled = sParamValue!=null && sParamValue.length()>0 ;
	
	if (bDetectorEnabled)
	    sDetectors += (sDetectors.length()>0 ? "," : "") + "'"+Formatare.mySQLEscape(detector)+"'";
    }

    for (int i=0; i<vsDetectors.length; i++){
	final String detector = vsDetectors[i];
    
	final String sParamValue = request.getParameter("detector_"+detector);
    
	final boolean bChecked = sDetectors.length()==0 || (sParamValue!=null && sParamValue.length()>0);
    
	p.append("detectors", "<nobr><input type=checkbox name=detector_"+detector+" id=detector_"+detector+" value=yes"+(bChecked? " checked" : "")+"><label for=detector_"+detector+">"+detector+"</label></nobr> ");
    }

    db.query("SELECT min(event_time), max(event_time) FROM shuttle_history WHERE run="+iRun+" AND detector!='SHUTTLE';");
    
    final long lMinTime = db.getl(1)*1000;
    final long lMaxTime = (1+db.getl(2)/60)*60*1000;

    final java.text.SimpleDateFormat calendarTimeFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");

    long lRequestMinTime = lMinTime;
    long lRequestMaxTime = lMaxTime;
    
    if (iRun == iPrevRun){
	try{
	    lRequestMinTime = calendarTimeFormat.parse(request.getParameter("interval_date_low")).getTime();
	}
	catch (Exception e){
	}
    
	try{
	    lRequestMaxTime = calendarTimeFormat.parse(request.getParameter("interval_date_high")).getTime();
	}
	catch (Exception e){
	}
    }
    
    p.modify("time_low", calendarTimeFormat.format(new Date(lRequestMinTime)));
    p.modify("time_high", calendarTimeFormat.format(new Date(lRequestMaxTime)));

    int iTryCount = -1;
    
    try{
	iTryCount = Integer.parseInt(request.getParameter("count"));
    }
    catch (Exception e){
    }
    
    db.query("select distinct count from shuttle_history where run="+iRun+" AND detector!='SHUTTLE' order by count asc;");
    
    while (db.moveNext()){
	int iCount = db.geti(1);
    
	p.append("sel_count", "<option value="+iCount+(iCount==iTryCount? " selected":"")+">"+iCount+"</option>");
    }

    String q = "SELECT event_time,detector,status,count FROM shuttle_history WHERE "+
	"run="+iRun+" "+
        " AND instance='"+Formatare.mySQLEscape(sInstance)+"' "+
	" AND event_time>="+lRequestMinTime/1000+" AND event_time<="+lRequestMaxTime/1000+
	(iTryCount>=0 ? " AND count="+iTryCount+" " : "")+
	(sDetectors.length()>0 ? " AND detector IN ("+sDetectors+") " : "")+
	"ORDER BY event_time ASC, id ASC;";

    //System.err.println(q);
    
    db.query(q);

    while (db.moveNext()){
	final XYSeries xys = (XYSeries) hmSeries.get(db.gets(2));
	
	final Integer iState = (Integer) hmStates.get(db.gets(3));
	
	final Integer iPrevState = (Integer) hmLastValues.get(db.gets(2));
	
	if (xys!=null && iState!=null){
	    if (iPrevState.intValue() > iState.intValue()){
		//System.err.println("Prev state : "+iPrevState+", state : "+iState);
		xys.add(db.getl(1)*1000 - 1, null);
	    }
	
	    xys.add(db.getl(1)*1000, iState.doubleValue());
	    
	    hmLastValues.put(db.gets(2), iState);
	    
	    TreeMap tm = (TreeMap) hmRunNumbers.get(db.gets(2));
	    tm.put(new Long(db.getl(1)*1000), Integer.valueOf(db.geti(4)));
	}
    }
    
    XYSeriesCollection xyseriescollection = new XYSeriesCollection();
    
    for (int i=0; i<vsDetectors.length; i++){
	xyseriescollection.addSeries( (XYSeries) hmSeries.get(vsDetectors[i]) );
    }
    
    /** Time axis */
    
    Properties prop = Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "shuttle_graph");
    
    ValueAxis va = Utils.getValueAxis(prop, lMinTime, lMaxTime);

    /** Plot generation */

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
	    
	    String sRet = sSeriesName + ": (" + sDate + ") " + vsStates[(int) Math.round(d)];
	    
	    final TreeMap tmRunNumber = (TreeMap) hmRunNumbers.get(sSeriesName);

	    if (tmRunNumber!=null){
		final Integer iRunNumber = (Integer) tmRunNumber.get(new Long(lTime));
		
		if (iRunNumber!=null)
		    sRet += " ("+iRunNumber+")";
	    }
	    
	    return sRet;
	}
    };
    
    XYURLGenerator xyug = new XYURLGenerator() {
	public String generateURL(final XYDataset dataset, final int series, final int item) {
	    String sSeriesName = null;
	      
	    if (dataset.getSeriesKey(series) != null)
		sSeriesName = dataset.getSeriesKey(series).toString();
		
	    return "JavaScript:only('"+sSeriesName+"')";
	}
    };

    // StandardXYItemRenderer.SHAPES_AND_LINES
    StandardXYItemRenderer xyir = new StandardXYItemRenderer(StandardXYItemRenderer.SHAPES_AND_LINES, ttg, xyug);
    
    XYPlot xyplot = new XYPlot(xyseriescollection, va, symbolaxis, xyir);

    final java.awt.Color colorErr = new java.awt.Color(255, 200, 200);
    
    final java.awt.Color colorFail = new java.awt.Color(255, 150, 150);
    
    final java.awt.Color colorOK  = new java.awt.Color(200, 255, 200);

    for (int i=0; i<vsStates.length; i++){
	String sStateLower = vsStates[i].toLowerCase();
	
	java.awt.Color color = null;
	
	if (sStateLower.indexOf("err")>=0 || sStateLower.indexOf("timeout")>=0 || sStateLower.indexOf("outofmemory")>=0)
	    color = colorErr;

	if (sStateLower.indexOf("fail")>=0)
	    color = colorFail;

	if (sStateLower.equals("done") || sStateLower.equals("skipped"))
	    color = colorOK;

	if (color!=null){
	    final IntervalMarker intervalmarker = new IntervalMarker(i-0.5, i+0.5);
	    
	    intervalmarker.setPaint(color);
	    intervalmarker.setAlpha(0.3f);
	    
	    xyplot.addRangeMarker(intervalmarker, org.jfree.ui.Layer.BACKGROUND);
	}
    }

    /** Colors */
    
    final Paint[] DEFAULT_PAINT_SEQUENCE = { 
	Color.red, 
	Color.green, 
	Color.blue, 
	Color.yellow.darker(), 
	Color.magenta, 
	Color.orange, 
	Color.gray, 
	Color.pink, 
	Color.cyan, 
	Color.black, 
	Color.lightGray, 
	Color.red.darker(), 
	Color.green.darker(), 
	Color.blue.darker(), 
	Color.orange.darker(), 
	Color.cyan.darker(), 
	Color.magenta.darker(), 
	Color.green.darker().darker(), 
	ColorFactory.getColor(106, 13, 162), 
	ColorFactory.getColor(49, 147, 150), 
	ColorFactory.getColor(142, 145, 69), 
	ColorFactory.getColor(137, 97, 74)
    };
    
    final Paint[] colors = new Paint[vsDetectors.length];

    for (int i=0; i<vsDetectors.length; i++){
	colors[i] = ServletExtension.getColor(vsDetectors[i], (Color) DEFAULT_PAINT_SEQUENCE[i % DEFAULT_PAINT_SEQUENCE.length]);
    }
    
    final DrawingSupplier ds = new DefaultDrawingSupplier(
	colors, 
	DefaultDrawingSupplier.DEFAULT_OUTLINE_PAINT_SEQUENCE,
	DefaultDrawingSupplier.DEFAULT_STROKE_SEQUENCE, 
	DefaultDrawingSupplier.DEFAULT_OUTLINE_STROKE_SEQUENCE,
	DefaultDrawingSupplier.DEFAULT_SHAPE_SEQUENCE
    );
    
    xyplot.setDrawingSupplier(ds);

    /** Chart rendering */
    
    JFreeChart chart = new JFreeChart("Shuttle states for run "+iRun, xyplot);
    
    display.setChartProperties(chart, prop);
    
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = ServletExtension.pgeti(prop, "height", 500);
    
    int width = ServletExtension.pgeti(prop, "width", 800);
    
    String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    pw.flush();
    
    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);
    
    /** Final composition */

    p.modify("run", iRun);

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    Utils.logRequest("/shuttle_graph.jsp", baos.size(), request);
%>