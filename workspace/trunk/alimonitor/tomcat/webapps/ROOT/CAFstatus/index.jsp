<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,org.jfree.chart.*,org.jfree.chart.plot.*,org.jfree.data.xy.*,org.jfree.chart.axis.*,org.jfree.chart.renderer.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.title.*,java.util.*,java.io.*,java.awt.*,org.jfree.ui.*,lia.web.servlets.web.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,lia.web.utils.ServletExtension,lia.web.utils.Annotation,lia.web.utils.Annotations,java.text.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*,lia.util.*,java.util.concurrent.*" %><%!
    private static final HashMap<String, String> hmAliases = new HashMap<String,String>();
    
    static{
	//hmAliases.put("CHI-GVA", "CHI-GVA (Qwest)");
    }

    private static java.util.List<String> getSeries(){
	java.util.List<String> ret = new ArrayList<String>();

	DB db = new DB("select distinct split_part(mi_key,'/',4) from monitor_ids where mi_key like '%ROOT_SESSIONS_CAFPRO/USERS/%';");
	
	while (db.moveNext())
	    ret.add(db.gets(1));

	Collections.reverse(ret);

	return ret;
    }

    private static final String getAlias(final String sSeries){
	final String sAlias = hmAliases.get(sSeries);

	return sAlias!=null ? sAlias : sSeries;	
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

    private static double[][] toData(final Map<String, java.util.List<Point>> m, final long lStart, final long lEnd, final long lStep){
	final int iSize = (int) (m.size() * (2 + (lEnd - lStart) / lStep));
    
	final double[] dx = new double[iSize];
	final double[] dy = new double[iSize];
	final double[] dz = new double[iSize];
	
	int idx = 0;
	int y = 0;
	
	for (final java.util.List<Point> lp: m.values()){
	    long lPrevious = lStart-lStep;
	
	    for (final Point p: lp){
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
    
    private static final class Work {
	public final long lStart, lEnd, lStep;
	public final String sLink;
	public final AnnotationCollection annotations;
	public final ArrayList<Point> points;
	
	public final Page pStatistics = new Page("CAFstatus/index_line.res");
	
	public long lUptime = 0;
	public long lDowntime = 0;
	
	public Work(final long lStart, final long lEnd, final long lStep, final String sLink, final AnnotationCollection annotations, final ArrayList<Point> points){
	    this.lStart = lStart;
	    this.lEnd = lEnd;
	    this.lStep = lStep;
	    this.sLink = sLink;
	    this.annotations = annotations;
	    this.points = points;
	}
	
	public void doWork(){
	    final monPredicate pred = new monPredicate("aliendb1.cern.ch", "ROOT_SESSIONS_CAFPRO", "USERS", lStart, lEnd, new String[]{sLink}, null);
	    
	    final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();
	    
	    final DataSplitter ds = store.getDataSplitter(new monPredicate[]{pred}, -1);
	    
	    final java.util.List lData = ds.toVector();
	    
	    pStatistics.modify("link", getAlias(sLink));
	    
	    final int iSize = lData.size();
	    
	    pStatistics.modify("annotations", getAnnotations(annotations, sLink));
	    
	    if (iSize==0){
		pStatistics.modify("availability", "N/A");
		
		return;
	    }
	    
	    final StatusPercentage sp = new StatusPercentage(lData);
	    
	    int iStart = 0;
	    
	    synchronized(lData){
		// it is said to accelerate a bit Vector operations
		for (long l=lStart-lStep; l<lEnd; l+=lStep){
		    iStart = sp.analyze(iStart, iSize, l, l+lStep);
		
		    if (sp.getDataAvailabilityPercentage()>0)
	    		points.add(new Point(l, sp.getUpPercentage()/100));
	        }
		
		sp.analyze();
	    }

	    pStatistics.modify("data_start", sp.getStartTime());
	    pStatistics.modify("data_end", sp.getEndTime());
	    
	    final double dUp = sp.getUpPercentage();
	    
	    pStatistics.modify("availability", lazyj.Format.showDottedDouble(dUp, 2)+"%");
	    
	    pStatistics.modify("avail_color", getColor(dUp));

	    lDowntime = sp.getGapTotalTime();
	    lUptime = sp.getEndTime()-sp.getStartTime()-lDowntime;
	    
	    pStatistics.modify("dataavailability", lazyj.Format.showDottedDouble(sp.getDataAvailabilityPercentage(), 2)+"%");
	    pStatistics.modify("downtime", lia.web.utils.Formatare.showInterval(lDowntime));
	    pStatistics.modify("uptime", lia.web.utils.Formatare.showInterval(lUptime));
	}
    }
    
    private static final class DataGrabberThread extends Thread {

	private final Queue<Work> queue;
	private int iThreadID;
	
	public DataGrabberThread(final Queue<Work> queue, final int iThreadID){
	    this.queue = queue;
	    this.iThreadID = iThreadID;
	}
    
	public void run(){
	    Work w;
	    
	    while ( (w=queue.poll())!=null ){
		w.doWork();
		
		//System.err.println((new Date())+" : thread "+iThreadID+" finished job "+w.sLink);
	    }
	}
    }
    
    private static final int THREADS = 2;

    private static Map<String, java.util.List<Point>> getValues(final long lStart, final long lEnd, final long lStep, final Page p, final AnnotationCollection annotations){
	final Map<String, java.util.List<Point>> mValues = new LinkedHashMap<String, java.util.List<Point>>();

	final LinkedList<DataGrabberThread> llThreads = new LinkedList<DataGrabberThread>();

	final Queue<Work> queue = new LinkedBlockingQueue<Work>();
	
	final LinkedList<Work> llWork = new LinkedList<Work>();
	
	final long lStartTimestamp = System.currentTimeMillis();

	int iEstimatedSize = (int) ((lEnd - lStart) / lStep + 16);
	
	for (String sLink: getSeries()){
	    final ArrayList<Point> points = new ArrayList<Point>(iEstimatedSize);
	    
	    mValues.put(sLink, points);
	    
	    final Work w = new Work(lStart, lEnd, lStep, sLink, annotations, points);

	    queue.offer(w);
	    
	    llWork.add(w);
	    
	    p.append("series_names", sLink+",");
	}
	
	for (int i=0; i<THREADS; i++){
	    final DataGrabberThread thread = new DataGrabberThread(queue, i);
	    
	    thread.start();
	    
	    llThreads.add(thread);
	}
	
	for (DataGrabberThread thread: llThreads){
	    try{
	        thread.join();
	    }
	    catch (InterruptedException ie){
		// ignore
	    }
	}
	
	double dTotalUptime = 0;
	double dTotalDowntime = 0;
	
	for (Work w: llWork){
	    p.append("statistics", w.pStatistics, true);
	    
	    dTotalUptime += w.lUptime;
	    dTotalDowntime += w.lDowntime;
	}
	
	p.modify("interval", lia.web.utils.Formatare.showInterval(lEnd-lStart));
	p.modify("uptime", lia.web.utils.Formatare.showInterval((long) dTotalUptime));
	p.modify("availability", lazyj.Format.point(dTotalUptime / (lEnd-lStart)));
	
	//System.err.println("Retrieval of "+lia.web.utils.Formatare.showInterval(lEnd-lStart)+" history on "+THREADS+" threads took "+(System.currentTimeMillis() - lStartTimestamp)+" ms");
	
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
	if (d<95) return "#FF0000";
	if (d<97) return "#FFA500";
	if (d<98) return "#FFFF00";
	if (d<99) return "#9EE600";
	if (d<100) return "#00FF00";
	return "#26BD26";
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START CAFstatus/index.jsp", 0, request);

    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "status");

    RequestWrapper rw = new RequestWrapper(request);
    
    Page p = new Page("CAFstatus/index.res");
    
    String sBookmark = "/CAFstatus/index.jsp";

    long lIntervalMin = rw.getl("interval.min", lDefaultIntervalMin);
    long lIntervalMax = rw.getl("interval.max", lDefaultIntervalMax);

    if (lIntervalMin!=lDefaultIntervalMin)
	sBookmark = addToURL(sBookmark, "interval.min", ""+lIntervalMin);
	
    if (lIntervalMax!=lDefaultIntervalMax)
	sBookmark = addToURL(sBookmark, "interval.max", ""+lIntervalMax);

    final long lStart = System.currentTimeMillis() - lIntervalMin;
    final long lEnd = System.currentTimeMillis() - lIntervalMax;
    
    final int iAnnotations = rw.geti("annotations", iDefaultAnnotations);
    
    int iRequestedBins = rw.geti("bins", iDefaultBins);
    
    if (iRequestedBins!=iDefaultBins)
	sBookmark = addToURL(sBookmark, "bins", ""+iRequestedBins);
    
    long lStep = (lIntervalMin - lIntervalMax) / iRequestedBins;
    
    if (lStep < 1000*60*10)
	lStep = 1000*60*10;

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
    

    Map<String, java.util.List<Point>> mValues = getValues(lStart, lEnd, lStep, p, annotationCollection);

    DefaultXYZDataset xyzdataset = new DefaultXYZDataset();
    xyzdataset.addSeries("Series 1", toData(mValues, lStart, lEnd, lStep));
    
    ValueAxis xaxis = lia.web.servlets.web.Utils.getValueAxis(prop, lStart, lEnd);
    xaxis.setLowerBound(lStart);
    xaxis.setUpperBound(lEnd);
    
    SymbolAxis yaxis = getAxis(mValues);
    
    XYBlockRenderer xyblockrenderer = new XYBlockRenderer();
    
    LookupPaintScale lookuppaintscale = new LookupPaintScale(-1, 1, new Color(200, 200, 200));
    lookuppaintscale.add(-1, new Color(200, 200, 200));
    lookuppaintscale.add(0, Color.red);
    lookuppaintscale.add(0.95D, Color.orange);
    lookuppaintscale.add(0.97D, Color.yellow);
    lookuppaintscale.add(0.98D, new Color(158, 230, 0));
    lookuppaintscale.add(0.99D, Color.green);
    lookuppaintscale.add(1, Color.green.darker());
    xyblockrenderer.setPaintScale(lookuppaintscale);
    xyblockrenderer.setBlockWidth(lStep);

    XYPlot xyplot = new XYPlot(xyzdataset, xaxis, yaxis, xyblockrenderer);
    xyplot.setBackgroundPaint(Color.lightGray);
    xyplot.setDomainGridlinePaint(Color.white);
    xyplot.setRangeGridlinePaint(Color.white);
    xyplot.setForegroundAlpha(0.66F);
    //xyplot.setAxisOffset(new RectangleInsets(5D, 5D, 5D, 5D));
    
    JFreeChart jfreechart = new JFreeChart("CAF users' activity", xyplot);
    jfreechart.removeLegend();
    jfreechart.setBackgroundPaint(Color.white);
    
    PaintScaleLegend paintscalelegend = new PaintScaleLegend(lookuppaintscale, new NumberAxis("Availability acceptance range"));
    //paintscalelegend.setAxisOffset(5D);
    paintscalelegend.setPosition(RectangleEdge.RIGHT);
    paintscalelegend.setMargin(new RectangleInsets(3D, 15D, 85D, 0D));
    paintscalelegend.setBackgroundPaint(new Color(0,0,0,0));
    
    lia.web.servlets.web.Utils.addAnnotations(xyplot, annotationCollection, prop);
    
    //jfreechart.addSubtitle(paintscalelegend);
    
    display.setChartProperties(jfreechart, prop);
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "CAF usage");
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = getYSize(rw);
    
    int width = getXSize(rw);
    
    if (width!=iDefaultXSize || height!=iDefaultYSize)
	sBookmark = addToURL(sBookmark, "imgsize", width+"x"+height);
    
    final String sImage = ServletUtilities.saveChartAsPNG(jfreechart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("image", sImage);
    p.modify("map", sw.toString());
    p.modify("interval_min", lIntervalMin);
    p.modify("interval_max", lIntervalMax);
    p.modify("imgsize_"+width+"x"+height, "selected");
    p.modify("bins_"+iRequestedBins, "selected");
    p.modify("annotations_"+iAnnotations, "selected");

    final SimpleDateFormat sdf = new SimpleDateFormat("M/d/yyyy H:00:00");
    p.modify("current_date_time", sdf.format(new Date()));

    display.registerImageForDeletion(sImage, 60);

    pMaster.append(p);

    pMaster.modify("comment_refresh", "//");
    pMaster.modify("bookmark", sBookmark);
    pMaster.write();
    
    response.setContentType("text/html");
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("CAFstatus/index.jsp", baos.size(), request);
%>