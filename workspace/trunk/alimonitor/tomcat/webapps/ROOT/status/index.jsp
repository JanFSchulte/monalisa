<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,org.jfree.chart.*,org.jfree.chart.plot.*,org.jfree.data.xy.*,org.jfree.chart.axis.*,org.jfree.chart.renderer.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.title.*,java.util.*,java.io.*,java.awt.*,org.jfree.ui.*,lia.web.servlets.web.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,lia.web.utils.ServletExtension,lia.web.utils.Annotation,lia.web.utils.Annotations,java.text.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*,lia.util.*,java.util.concurrent.*" %><%!
    private static final HashMap<String, String> hmAliases = new HashMap<String,String>();
    
    static{
	// put aliases here
    }

    private static java.util.List<String> getSeries(){
	java.util.List<String> ret = new ArrayList<String>();

	lia.Monitor.Store.Fast.DB db = new lia.Monitor.Store.Fast.DB("select se_name from list_ses;");
	
	while (db.moveNext()){
	    ret.add(db.gets(1));
	}

	Collections.reverse(ret);

	return ret;
    }

    private static final String getAlias(final String sSeries){
	String sAlias = hmAliases.get(sSeries);

	if (sAlias==null){
	    sAlias = sSeries;
	    
	    if (sAlias.startsWith("ALICE::"))
		sAlias=sAlias.substring(7);
	}

	return sAlias;
    }

    private static final class Point {
	final long x;
	final double z;
	
	public Point(final long x, final double z){
	    this.x = x;
	    this.z = z;
	}
	
	public String toString(){
	    return "("+(new Date(x))+", "+z+")";
	}
    }

    private static final ArrayList<Point> processValues(java.util.List<Point> values, final long lStart, final long lEnd, final long lStep){
	final ArrayList<Point> ret = new ArrayList<Point>();
    
	if (values==null || values.size()==0)
	    return ret;

	final long lGap = getGapLength();
	
	int idx = 0;
	
	while (idx<values.size() && values.get(idx).x<lStart)
	    idx++;
	
	for (long l=lStart; l<=lEnd; l+=lStep){
	    ArrayList<Point> intervalPoints = new ArrayList<Point>();

	    Point pPrev = idx>0 ? values.get(idx-1) : null;
	    
	    if (pPrev!=null && l+lStep/2-pPrev.x>lGap)
		pPrev = null;
	    
	    Point p;

	    while ( idx<values.size() && (p=values.get(idx)).x>=l && p.x<=l+lStep ){
		intervalPoints.add(p);
		idx++;
	    }
	    
	    if (intervalPoints.size()==0){
		// no point in the interval
		
		ret.add(new Point(l+lStep/2, pPrev!=null ? 1-pPrev.z : -1));
	    }
	    else{
		double dPrev = pPrev!=null ? pPrev.z : intervalPoints.get(0).z;
		
		long tPrev = l;
		
		double d = 0;
		
		for (Point point: intervalPoints){
		    d += dPrev * (point.x - tPrev);
		    
		    dPrev = point.z;
		    tPrev = point.x;
		}
		
		d += dPrev * (l+lStep - tPrev);

		ret.add(new Point(l+lStep/2, 1-d/lStep));
	    }
	}

	//System.err.println("Returning "+ret.size()+" values");

	return ret;
    }

    private static double[][] toData(final Map<String, java.util.List<Point>> m, final long lStart, final long lEnd, final long lStep){
	final int iSize = (int) (m.size() * (2 + (lEnd - lStart) / lStep));
    
	final double[] dx = new double[iSize];
	final double[] dy = new double[iSize];
	final double[] dz = new double[iSize];
	
	int idx = 0;
	int y = 0;
	
	for (final java.util.List<Point> lp: m.values()){
	    long lPrevious = lStart-lStep;
	
	    ArrayList<Point> values = processValues(lp, lStart, lEnd, lStep);
	
	    for (final Point p: values){
		for (long l=lPrevious+lStep; l<p.x; l+=lStep){
		    dx[idx] = l;
		    dy[idx] = y;
		    dz[idx] = -1;
		    
		    idx++;
		}
		
		dx[idx] = p.x;
	        dy[idx] = y;
		dz[idx] = p.z;
	    
		lPrevious = p.x;
	    
	        idx++;
	    }
	    
	    for (long l=lPrevious+lStep; l<=lEnd; l+=lStep){
		dx[idx] = l;
		dy[idx] = y;
		dz[idx] = -1;
		    
		idx++;
	    }
	    
	    y++;
	}

	//System.err.println("OK: "+idx);

	return new double[][] {dx, dy, dz};
    }
    
    private static SymbolAxis getAxis(Map<String, java.util.List<Point>> m){
	String[] names = new String[m.size()];
	
	int idx = 0;
	
	for (String s: m.keySet()){
	    names[idx++] = getAlias(s);
	}

	SymbolAxis yaxis = new SymbolAxis(null, names);
	yaxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
	
	return yaxis;
    }
    
    private static String formatAnnotation(final Annotation a, final boolean bGlobal){
	final Date dStart = new Date(a.from);
	final Date dEnd   = new Date(a.to);

	final String sDateStart = ServletExtension.showDottedDate(dStart)+" "+ServletExtension.showTime(dStart);
	final String sDateEnd   = dEnd.getTime() > System.currentTimeMillis() ? "<b><i>continues</i></b>" : ServletExtension.showDottedDate(dEnd)+" "+ServletExtension.showTime(dEnd);
													
	return "("+sDateStart+", "+sDateEnd+")<br><font color=#"+lia.web.servlets.web.Utils.toHex(a.textColor)+"><b>"+a.text+"</b></font><br><br>";
    }
    
    private static Page getAnnotations(final AnnotationCollection ac, final String sSeriesName){
	final Page pAnn = new Page("WEB-INF/res/display/hist_annotations.res");
	
	int iCnt = 0;
	
	if (ac==null)
	    return null;
	
	java.util.List<Annotation> l = (java.util.List<Annotation>)ac.getChartAnnotations();
	
	if (l!=null){
	    for (Annotation a: l){
		pAnn.append(formatAnnotation(a, true));
	        iCnt ++;
	    }
	}
	
	l = (java.util.List<Annotation>)ac.getSeriesAnnotations(sSeriesName);
	if (l!=null){
	    for (Annotation a: l){
		pAnn.append(formatAnnotation(a, false));
	        iCnt ++;
	    }
	}
	
	return iCnt > 0 ? pAnn : null;
    }
    
    /**
     * Remove OK values that come too soon after an ERR.
     */
    private static void cleanupSeries(final java.util.List lData){
	if (lData==null || lData.size()<2)
	    return;
	
	final Iterator<Result> it = ((java.util.List<Result>)lData).iterator();
	
	Result r = it.next();
	
	long lLastTime = r.time;
	
	int iOld = (int) r.param[0];
	
	while (it.hasNext()){
	    r = it.next();
	    
	    final int iNew = (int) r.param[0];
	    
	    if (iNew==1 && iOld==0 && r.time - lLastTime < 120000){
		it.remove();
		continue;
	    }
	    
	    iOld = iNew;
	    lLastTime = r.time;
	}
    }
    
    private static void applyTransition(final Result r, final Page p){
	final int iState = (int) r.param[0];

	p.modify("state", iState==1 ? "<font color=#009900>OK</font>" : "<font color=red>ERR</font>");
	p.modify("time", r.time/1000);
    }
    
    private static Page getTransitions(final java.util.List lData){
	final Page p = new Page("status/transitions.res");
	final Page pEl = new Page("status/transitions_line.res");

	if (lData==null || lData.size()==0)
	    return p;
	
	final Iterator it = lData.iterator();
	
	Result r = (Result) it.next();
	    
	int iOld = (int) r.param[0];
	applyTransition(r, pEl);
	p.append(pEl);
	
	long lLastTime = r.time;
	long lLastTransition = r.time;
	
	while (it.hasNext()){
	    r = (Result) it.next();
	
	    final int iNew = (int) r.param[0];
	    
	    //if (iNew!=iOld && (iOld==1 || r.time-lLastTransition > 90000)){
	    if (iNew!=iOld){
		applyTransition(r, pEl);
		p.append(pEl);
		iOld = iNew;
		lLastTransition = r.time;
	    }
	    /*
	    else
	    if (iNew==0 && iOld==0){
		lLastTransition = r.time;
	    }
	    */
	    
	    lLastTime = r.time;
	}
	
	pEl.modify("state", "EOD");
	pEl.modify("time", lLastTime/1000);
	p.append(pEl);

	return p;
    }
    
    private static long getGapLength(){
	return 1000*60*60*24*7;
    }
    
    private static void finalStatistics(final String sName, final Page pStatistics, final ArrayList<Point> points, final long lEnd){
	if (points==null || points.size()==0)
	    return;

	int iTestsOK = 0;
	int iTestsFailed = 0;
	
	double dAvailability = 0;
	long lTime = 0;

	Point pOld = points.get(0);
	
	pStatistics.modify("data_start", pOld.x);
	
	final long lGap = getGapLength();
	
	if (pOld.z < 0.5)
	    iTestsOK++;
	else
	    iTestsFailed++;
	
	for (int i=1; i<points.size(); i++){
	    Point p = points.get(i);
	
	    if (p.x - pOld.x < lGap){
	        dAvailability += pOld.z * (p.x - pOld.x);
		lTime += p.x - pOld.x;
	    }
	    else{
		dAvailability += pOld.z * lGap;
		lTime += lGap;
	    }

	    if (p.z < 0.5)
		iTestsOK++;
	    else
		iTestsFailed++;
	    
	    pOld = p;
	}
	
	if (lEnd - pOld.x < lGap){
	    dAvailability += pOld.z  * (lEnd - pOld.x);
	    lTime += lEnd - pOld.x;
	}
	else{
	    dAvailability += pOld.z * lGap;
	    lTime += lGap;
	}
	
	pStatistics.modify("data_end", pOld.x);
	
	dAvailability /= lTime;
	
	dAvailability = (1 - dAvailability) * 100;
	
	pStatistics.modify("availability", lazyj.Format.showDottedDouble(dAvailability, 2)+"%");
	pStatistics.modify("avail_color", getColor(dAvailability));
	
	pStatistics.modify("tests_ok", iTestsOK);
	pStatistics.modify("tests_failed", iTestsFailed);
	
	double dOK = (double) iTestsOK / points.size();
	
	pStatistics.modify("tests_ok_percentage", lazyj.Format.showDottedDouble(dOK*100, 2)+"%");
    }
    
    private static Map<String, java.util.List<Point>> getValues(final Set<String> series, final long lStart, final long lEnd, final long lStep, final Page p, final AnnotationCollection annotations){
	final Map<String, java.util.List<Point>> mValues = new LinkedHashMap<String, java.util.List<Point>>();

	String q = "SELECT se_name,status,testtime FROM se_testing_history WHERE testtime>"+(lStart/1000 - 60*60)+" AND testtime<"+(lEnd/1000)+" AND test_type=0";

	java.util.List<String> allSeries = getSeries();

	if (series.size()>0 && (series.size()!=allSeries.size() || !series.containsAll(allSeries))){
	    String sIn = "";
	    
	    for (String s: series){
		sIn += (sIn.length()>0 ? "," : "") + "'"+lazyj.Format.escSQL(s)+"'";
	    }
	    
	    q += " AND se_name IN ("+sIn+")";
	}
	
	q += " ORDER BY lower(se_name) DESC,testtime ASC;";

	//System.err.println(q);

	lia.Monitor.Store.Fast.DB db = new lia.Monitor.Store.Fast.DB(q);

	String sName = null;
	ArrayList<Point> values = null;

	final Page pStatistics = new Page("status/index_line.res");

	while (db.moveNext()){
	    if (!db.gets(1).equals(sName)){
		if (sName!=null){
		    finalStatistics(sName, pStatistics, values, lEnd);
		    p.append("statistics", pStatistics, true);
		}

		sName = db.gets(1);
		values = new ArrayList<Point>(values!=null ? values.size() : 128);

		String sAlias = getAlias(sName);

		pStatistics.modify("link", sAlias);
		pStatistics.modify("annotations", getAnnotations(annotations, sName));
		
		mValues.put(sAlias, values);
	    }
	    
	    values.add(new Point(db.getl(3)*1000, db.getd(2)));
	}

	if (sName!=null){
	    finalStatistics(sName, pStatistics, values, lEnd);
	    p.append("statistics", pStatistics, true);
	}
	
	return mValues;
    }
    
    private static int getXSize(final RequestWrapper rw){
	final String sSize = rw.gets("imgsize");
	
	final int idx = sSize.indexOf("x");
	
	int x = iDefaultXSize;
	
	if (idx>0){
	    try{
		x = Integer.parseInt(sSize.substring(0, idx));
	    }
	    catch (Exception e){
	    }
	}
	else{
	    try{
		x = Integer.parseInt(sSize);
	    }
	    catch (Exception e){
	    }
	}
	
	return x;
    }

    private static int getYSize(final RequestWrapper rw){
	final String sSize = rw.gets("imgsize");
	
	final int idx = sSize.indexOf("x");
	
	int y = iDefaultYSize;
	
	if (idx>0){
	    try{
		y = Integer.parseInt(sSize.substring(idx+1));
	    }
	    catch (Exception e){
	    }
	}
	
	return y;
    }

    private static final long lDefaultIntervalMin = 1000L*60*60*24;
    private static final long lDefaultIntervalMax = 0;
    private static final int iDefaultAnnotations = 5;
    private static final int iDefaultBins = 300;
    private static final int iDefaultXSize = 1000;
    private static final int iDefaultYSize = 1000;

    private static String addToURL(final String sURL, final String sKey, final String sValue){
        String s = sURL;
	
	if (s.indexOf("?")<0)
	    s += "?";
	else
	    s += "&";
				
	return s+lazyj.Format.encode(sKey)+"="+lazyj.Format.encode(sValue);
    }
				
    private static java.util.List<Annotation> getAnnotations(final long lStart, final long lEnd){
	final HashSet<Integer> groups = new HashSet<Integer>(1);
	groups.add(Integer.valueOf(1));
    
	return Annotations.getAnnotations(lStart, lEnd, groups);
    }
    
    private static final class AnnotationLengthComparator implements Comparator<Annotation>{
	public int compare(Annotation a1, Annotation a2){
	    long lDiff1 = a1.to - a1.from;
	    long lDiff2 = a2.to - a2.from;
	    
	    if (lDiff1 < lDiff2)
		return -1;
	    
	    if (lDiff1 > lDiff2)
		return 1;
	
	    return 0;
	}
    }
    
    private static final AnnotationLengthComparator annotationLengthComparator = new AnnotationLengthComparator();
    
    private static void filterAnnotations(final java.util.List<Annotation> annotations, final int iCount){
	if (annotations.size()<=iCount)
	    return;
    
	Collections.sort(annotations, annotationLengthComparator);
	Collections.reverse(annotations);
	
	while (annotations.size()>iCount)
	    annotations.remove(annotations.size()-1);
    }
    
    private static String getColor(final double d){
	if (d<80) return "#FF0000";
	if (d<90) return "#FFA500";
	if (d<95) return "#FFFF00";
	if (d<98) return "#9EE600";
	if (d<100) return "#00FF00";
	return "#26BD26";
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /status/index.jsp", 0, request);

    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "status");

    RequestWrapper rw = new RequestWrapper(request);
    
    Page p = new Page("status/index.res");
    
    String sBookmark = "/status/index.jsp";

    long lIntervalMin = rw.getl("interval.min", lDefaultIntervalMin);
    long lIntervalMax = rw.getl("interval.max", lDefaultIntervalMax);

    if (lIntervalMin!=lDefaultIntervalMin)
	sBookmark = addToURL(sBookmark, "interval.min", ""+lIntervalMin);
	
    if (lIntervalMax!=lDefaultIntervalMax)
	sBookmark = addToURL(sBookmark, "interval.max", ""+lIntervalMax);

    final long lStart = System.currentTimeMillis() - lIntervalMin;
    final long lEnd = System.currentTimeMillis() - lIntervalMax;
    
    final int iAnnotations = rw.geti("annotations", iDefaultAnnotations);
    
    if (iAnnotations != iDefaultAnnotations){
	sBookmark = addToURL(sBookmark, "annotations", ""+iAnnotations);
    }
    
    int iRequestedBins = rw.geti("bins", iDefaultBins);
    
    if (iRequestedBins!=iDefaultBins)
	sBookmark = addToURL(sBookmark, "bins", ""+iRequestedBins);
    
    long lStep = (lIntervalMin - lIntervalMax) / iRequestedBins;
    
    if (lStep < 1000*60*60)
	lStep = 1000*60*60;

    // ------------- annotations 

    final AnnotationCollection annotationCollection;
    
    if (iAnnotations!=0){
	final java.util.List<Annotation> annotations = getAnnotations(lStart, lEnd);
	
	if (iAnnotations>0)
	    filterAnnotations(annotations, iAnnotations);
	    
	annotationCollection = annotations.size()>0 ? new AnnotationCollection(annotations, null) : null;
    }
    else{
	annotationCollection = null;
    }
    
    // ------------- /annotations
    
    Set<String> series = new HashSet<String>();

    for (String sName: rw.getValues("plot_series")){
	series.add(sName);
	sBookmark = addToURL(sBookmark, "plot_series", sName);
    }

    Map<String, java.util.List<Point>> mValues = getValues(series, lStart, lEnd, lStep, p, annotationCollection);

    java.util.List<String> allSeries = getSeries();
    
    Page pSeries = new Page("WEB-INF/res/display/hist_series.res");
    
    for (String sName: allSeries){
	String sAlias = getAlias(sName);
	
	boolean bSelected = mValues.containsKey(sAlias);
	
	pSeries.modify("realname", sName);
	pSeries.modify("name", sAlias);
	pSeries.modify("plot", bSelected ? "true" : "false");
	
	p.append("content", pSeries, true);
    }

    DefaultXYZDataset xyzdataset = new DefaultXYZDataset();
    xyzdataset.addSeries("Series 1", toData(mValues, lStart, lEnd, lStep));
    
    ValueAxis xaxis = lia.web.servlets.web.Utils.getValueAxis(prop, lStart, lEnd);
    xaxis.setLowerBound(lStart);
    xaxis.setUpperBound(lEnd);
    
    SymbolAxis yaxis = getAxis(mValues);
    
    XYBlockRenderer xyblockrenderer = new XYBlockRenderer();
    
    LookupPaintScale lookuppaintscale = new LookupPaintScale(0, 1, new Color(200, 200, 200));
    lookuppaintscale.add(-1, new Color(200, 200, 200));
    lookuppaintscale.add(0, Color.red);
    lookuppaintscale.add(0.80D, Color.orange);
    lookuppaintscale.add(0.90D, Color.yellow);
    lookuppaintscale.add(0.95D, new Color(158, 230, 0));
    lookuppaintscale.add(0.98D, Color.green);
    lookuppaintscale.add(1, Color.green.darker());
    xyblockrenderer.setPaintScale(lookuppaintscale);
    xyblockrenderer.setBlockWidth(lStep);

    XYPlot xyplot = new XYPlot(xyzdataset, xaxis, yaxis, xyblockrenderer);
    xyplot.setBackgroundPaint(Color.lightGray);
    xyplot.setDomainGridlinePaint(Color.white);
    xyplot.setRangeGridlinePaint(Color.white);
    xyplot.setForegroundAlpha(0.66F);
    //xyplot.setAxisOffset(new RectangleInsets(5D, 5D, 5D, 5D));
    
    JFreeChart jfreechart = new JFreeChart("AliEn SEs availability", xyplot);
    jfreechart.removeLegend();
    jfreechart.setBackgroundPaint(Color.white);
    
    PaintScaleLegend paintscalelegend = new PaintScaleLegend(lookuppaintscale, new NumberAxis("Availability acceptance range"));
    //paintscalelegend.setAxisOffset(5D);
    paintscalelegend.setPosition(RectangleEdge.RIGHT);
    paintscalelegend.setMargin(new RectangleInsets(3D, 15D, 85D, 0D));
    paintscalelegend.setBackgroundPaint(new Color(0,0,0,0));
    
    lia.web.servlets.web.Utils.addAnnotations(xyplot, annotationCollection, prop);
    
    jfreechart.addSubtitle(paintscalelegend);
    
    display.setChartProperties(jfreechart, prop);
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "Status reports");
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    //int height = getYSize(rw);

    int width = getXSize(rw);
    
    int height = 85 + mValues.size() * (9 + width/200);
    
    if (width!=iDefaultXSize)
	sBookmark = addToURL(sBookmark, "imgsize", ""+width);
    
    final String sImage = ServletUtilities.saveChartAsPNG(jfreechart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());
    p.modify("interval_min", lIntervalMin);
    p.modify("interval_max", lIntervalMax);
    p.modify("imgsize_"+width, "selected");
    p.modify("bins_"+iRequestedBins, "selected");
    p.modify("annotations_"+iAnnotations, "selected");

    final SimpleDateFormat sdf = new SimpleDateFormat("M/d/yyyy H:00:00");
    p.modify("current_date_time", sdf.format(new Date()));

    display.registerImageForDeletion(sImage, 60);

    // alternates
    pMaster.append("alternates", "Alternative views: <a href='/display?page=SE/table' class=link>Current SE status</a>");
    pMaster.comment("com_alternates", true);

    pMaster.append(p);

    pMaster.modify("comment_refresh", "//");
    pMaster.modify("bookmark", sBookmark);
    pMaster.write();
    
    response.setContentType("text/html");
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/status/index.jsp", baos.size(), request);
%>