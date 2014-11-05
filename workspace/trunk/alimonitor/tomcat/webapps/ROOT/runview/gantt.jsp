<%@ page import="lia.web.servlets.web.display,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.gantt.*,org.jfree.data.time.*,org.jfree.data.xy.*,org.jfree.chart.renderer.category.*,org.jfree.chart.labels.*,org.jfree.chart.entity.*,alien.taskQueue.*,org.jfree.chart.urls.*,java.awt.Paint,java.awt.Color" %><%!
    private static final java.text.DateFormat DATE_FORMAT = new java.text.SimpleDateFormat("MMM dd, HH:mm");

    private static void getTasks(final List<Task> tasks, final int pid, final boolean excludePWG){
	final DB db = new DB();

	db.query("select firstseen,lastseen,jobtype from job_stats inner join job_runs_details using(pid) where pid="+pid);
	
	if (!db.moveNext())
	    return;

	final Job j = TaskQueueUtils.getJob(pid, false);

	long lStart = db.getl(1) * 1000;
	long lEnd = db.getl(2) * 1000;
	    
	if (j!=null && j.mtime!=null){
	    lEnd = Math.max(lEnd, j.mtime.getTime());
        }

	if (lStart <= lEnd){
    	    final Task t = new Task(pid+"<BR><B>"+db.gets(3), new Date(lStart), new Date(lEnd));

	    tasks.add(t);	    
	}
	    
	if (excludePWG)
	    db.query("SELECT pid FROM lpm_history INNER JOIN job_runs_details USING(pid) WHERE parentpid="+pid+" AND jobtype NOT LIKE 'PWG%' ORDER BY pid ASC;");
	else
	    db.query("SELECT pid FROM lpm_history WHERE parentpid="+pid+" ORDER BY pid ASC;");
	  
	while (db.moveNext())
	    getTasks(tasks, db.geti(1), excludePWG);
    }
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /runview/gantt.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();

    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page("runview/gantt.res", false);
    
    final DB db = new DB();
    
    DB db2 = new DB();
    
    final TaskSeriesCollection taskseriescollection = new TaskSeriesCollection();
    
    final List<String> labels = new ArrayList<String>();
    
    long lMin = 0;
    long lMax = 0;

    int pid = rw.geti("pid");

    int run = rw.geti("run");

    final List<Task> tasks = new ArrayList<Task>();

    getTasks(tasks, pid, rw.getb("filter", true));
    
    for (final Task t: tasks){
	String title = t.getDescription().substring(t.getDescription().lastIndexOf("<BR><B>")+7);
	
	labels.add(title);
	
	TaskSeries ts = new TaskSeries(title);
	ts.add(t);
	taskseriescollection.add(ts);
	
	lMin = lMin==0 ? t.getDuration().getStart().getTime() : Math.min(lMin, t.getDuration().getStart().getTime());
	
	lMax = Math.max(lMax, t.getDuration().getEnd().getTime());
    }

    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "train_gantt");

    final List<Color> clut = new ArrayList<Color>();

    clut.add(new Color(0, 215, 64));
    clut.add(new Color(0, 143, 215));
    clut.add(new Color(0, 93, 215));
    clut.add(new Color(64, 0, 215));
    clut.add(new Color(173, 2, 215));
    clut.add(new Color(215, 109, 9));
    
    XYBarRenderer renderer = new XYBarRenderer(){
	@Override
        public Paint getItemPaint(final int row, final int col) {
    	    String label = labels.get(row).trim();
    	  
    	    if (label.indexOf("(")>0)
    		label = label.substring(0, label.indexOf("(")).trim();
    	
    	    label = label.replaceAll("\\_Stage\\d+", "").trim();
    	    
    	    boolean merging = label.indexOf("_Merging")>0;
    	    
    	    boolean finalMerging = label.indexOf("_FinalMerging")>0;
    	    
    	    if (merging || finalMerging)
    		label = label.replaceAll("\\_(Final)?Merging", "").trim();
    	
    	    Color c = (Color) org.jfree.chart.plot.DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE[ Math.abs(label.hashCode()) % org.jfree.chart.plot.DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE.length ];
    	    
    	    if (merging)
    		c = c.brighter();
    	
    	    if (finalMerging)
    		c = c.darker();
    	    
    	    return c;
    	}
    };
    
    renderer.setUseYInterval(true);
    renderer.setDrawBarOutline(false);
    renderer.setDefaultBarPainter(new org.jfree.chart.renderer.xy.StandardXYBarPainter());

    SymbolAxis yaxis = new SymbolAxis("Activity", labels.toArray(new String[0]));
    yaxis.setGridBandsVisible(false);
    
    ValueAxis xaxis = lia.web.servlets.web.Utils.getValueAxis(prop, lMin, lMax);

    final XYToolTipGenerator tt = new StandardXYToolTipGenerator(){
	@Override
	public String generateToolTip(final XYDataset dataset, final int series, final int item) {
	    final TaskSeries ts = taskseriescollection.getSeries(series);
	
	    String key = ts.getKey().toString();
	    
	    if (key.indexOf(':')>0)
		key = key.substring(0, key.indexOf(':'));
	
	    if (key.indexOf('(')>0)
		key = key.substring(0, key.indexOf('('));
	    
	    final Task t = ts.get(item);
	    
	    final TimePeriod tp = t.getDuration();
	    
	    return key+":<B>"+Format.toInterval(tp.getEnd().getTime() - tp.getStart().getTime())+"</B> ("+
		DATE_FORMAT.format(tp.getStart())+" - "+DATE_FORMAT.format(tp.getEnd())+")<BR>"+
		"Job ID: "+t.getDescription();
	}
    };
    renderer.setBaseToolTipGenerator(tt);
    
    final XYURLGenerator url = new StandardXYURLGenerator(){
	@Override
	public String generateURL(final XYDataset dataset, final int series, final int item) {
	    final TaskSeries ts = taskseriescollection.getSeries(series);
	
	    final Task t = ts.get(item);
	    
	    String s = t.getDescription();

	    s = s.substring(0, s.indexOf('<'));	    
	    return "javascript:void(0)\" onClick=\"javascript:openLive('"+s+"');\"";
	}
    };
    renderer.setURLGenerator(url);
    
    renderer.setShadowVisible(false);
    //renderer.setSeriesPaint(0, java.awt.Color.BLACK);
    
    XYPlot plot = new XYPlot(new XYTaskDataset(taskseriescollection), yaxis, xaxis, renderer);
    plot.setOrientation(PlotOrientation.HORIZONTAL);
    
    JFreeChart chart = new JFreeChart("Processing chain"+(run>0 ? " of run "+run : ""), plot);
    chart.removeLegend();
    
    display.setChartProperties(chart, prop);
    
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 80 + labels.size()*15;
    
    int width = 1200;
    
    String sImage = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, lia.web.utils.ServletExtension.pgetb(prop, "overlib_tooltips", true));

    pw.flush();
    
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Processing chain"+(run>0 ? " of run "+run : "")+" starting from "+pid);
    
    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);
    
    pMaster.append(p);
    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/runview/gantt.jsp", baos.size(), request);
%>