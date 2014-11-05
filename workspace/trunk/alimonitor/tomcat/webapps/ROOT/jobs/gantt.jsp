OB<%@ page import="lia.web.servlets.web.display,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.gantt.*,org.jfree.data.time.*,org.jfree.data.xy.*,org.jfree.chart.renderer.category.*,org.jfree.chart.labels.*,org.jfree.chart.entity.*,alien.taskQueue.*,org.jfree.chart.urls.*,alien.jobs.*,java.awt.Color,org.jfree.data.category.*,java.awt.Paint" %><%!
    private static final java.text.DateFormat DATE_FORMAT = new java.text.SimpleDateFormat("MMM dd, HH:mm");
    
    static final Color waitingColor = new Color(255, 168, 88);
    static final Color runningColor = new Color(0, 123, 0);
    static final Color savingColor = new Color(0, 0, 128);
    
    private static final String traceSearch = "]: Job state transition ";

%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /jobs/gantt.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();

    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page("jobs/gantt.res", false);
    
    final int pid = rw.geti("pid");
    
    p.modify("pid", pid);
    
    final Masterjob job = new Masterjob(pid, null, false);
	
    p.modify("owner", job.getUsername());
	
    final TaskSeriesCollection taskseriescollection = new TaskSeriesCollection();
    
    final TaskSeries tasks = new TaskSeries("Running");
    
    final List<String> labels = new ArrayList<String>();
    
    long lMin = 0;
    long lMax = 0;
    
    Set<Integer> subjobs = job.getSubjobIDs(null);
    
    if (subjobs==null){
	subjobs = new HashSet<Integer>();
	subjobs.add(Integer.valueOf(pid));
    }
    
    final Map<String, String> jobToSite = new HashMap<String, String>();
    
    for(final Integer jobId: subjobs){
	final String key = jobId.toString();
    
	labels.add(key);
	
	final List<String> sortedTrace = Trace.getSortedTrace(jobId.intValue());
	
	long lMinTime = 0;
	long lMaxTime = 0;

	if (sortedTrace!=null){
	    long lPrevWaiting = 0;
	    long lPrevRunning = 0;
	    long lPrevSaving = 0;
	    long lPrevFinal = 0;
	    
	    List<Task> subtasks = new ArrayList<Task>();
	    
	    String site = null;

	    Task tRun = null;

	    for (final String line: sortedTrace){
		int idx = line.indexOf(traceSearch);
		
		if (idx>=0){
		    int idxSite = line.indexOf(" site: ");
		
		    if (idxSite>0){
			StringTokenizer st = new StringTokenizer(line.substring(idxSite+7));
		    
			if (st.hasMoreTokens()){
			    site = st.nextToken();
			    
			    jobToSite.put(key, site);
			}
		    }
		    
		    long timestamp = Long.parseLong(line.substring(0,10)) * 1000;
		    
		    lMaxTime = Math.max(lMaxTime, timestamp);
		    
		    lMinTime = lMinTime==0 ? timestamp : Math.min(lMinTime, timestamp);
		
		    idx += traceSearch.length();
		    
		    StringTokenizer st = new StringTokenizer(line.substring(idx));
		    
		    st.nextToken();
		    String stateFrom = st.nextToken();
		    
		    String stateTo = "";
		    
		    if (st.hasMoreTokens())
    		         stateTo = st.nextToken();

		    if (!"to".equals(stateFrom)){
        		if (st.hasMoreTokens())
			    stateTo = st.nextToken();
			else
			    stateTo = null;
		    }
			
		    //System.err.println(new Date(timestamp)+ " : "+stateFrom+" : "+stateTo+", "+tRun+", "+lPrevRunning);
			
		    if ("WAITING".equals(stateTo)){
			lPrevRunning = lPrevSaving = lPrevFinal = 0;
			tRun = null;
			site = null;
			lPrevWaiting = timestamp;
		    }
		    else
		    if ("ASSIGNED".equals(stateTo)){
			lPrevRunning = timestamp;

			lPrevSaving = lPrevFinal = 0;
			tRun = null;
			
			if (lPrevWaiting>0){
			    subtasks.add(new Task("Waiting", new Date(lPrevWaiting), new Date(lPrevRunning)));
			    lPrevWaiting = 0;
			}
		    }
		    else
		    if ("SAVING".equals(stateTo)){
			lPrevSaving = timestamp;
			
			if (lPrevRunning > 0){
			    tRun = new Task("Running"+(site!=null ? " @ "+site : ""), new Date(lPrevRunning), new Date(lPrevSaving));
			    subtasks.add(tRun);
			    
			    lPrevRunning = 0;
			}
		    }
		    else
		    if (stateFrom.startsWith("E") || stateFrom.startsWith("Z") || (stateTo!=null && (stateTo.startsWith("E") || stateTo.startsWith("D") || stateTo.startsWith("Z")))){
			lPrevFinal = timestamp;
			
			if (lPrevSaving > 0){
			    subtasks.add(new Task("Saving"+(site!=null ? " @ "+site : ""), new Date(lPrevSaving), new Date(lPrevFinal)));
			    
			    if (tRun!=null && (stateTo==null || !stateTo.startsWith("D"))){
				tRun.setPercentComplete(0);
			    }
			
			    lPrevSaving = 0;
			}
			else
			if (lPrevRunning > 0){
			    tRun = new Task("Running"+(site!=null ? " @ "+site : ""), new Date(lPrevRunning), new Date(lPrevFinal));
			    
			    tRun.setPercentComplete(0);
			    
			    subtasks.add(tRun);
			    
			    tRun = null;
			    
			    lPrevRunning = 0;
			}
		    }
		}
		else
		if (line.indexOf("The job has been resubmited (back to WAITING)")>=0){
		    lPrevRunning = lPrevSaving = lPrevFinal = 0;
		    tRun = null;
		    site = null;
		    lPrevWaiting = Long.parseLong(line.substring(0,10)) * 1000;
		}
	    }
	             
	    if (lPrevWaiting > 0){
		subtasks.add(new Task("Waiting", new Date(lPrevWaiting), new Date(System.currentTimeMillis())));
	    }
	    else
	    if (lPrevRunning > 0){
		subtasks.add(new Task("Running"+(site!=null ? " @ "+site : ""), new Date(lPrevRunning), new Date(System.currentTimeMillis())));
	    }
	    else
	    if (lPrevSaving > 0){
		subtasks.add(new Task("Saving"+(site!=null ? " @ "+site : ""), new Date(lPrevSaving), new Date(System.currentTimeMillis())));
	    }
	    
	    if (subtasks.size()>0){
	        final Task t = new Task(key, new Date(lMinTime), new Date(lMaxTime));
	    
		for (final Task sub: subtasks)
		    t.addSubtask(sub);
		
	        tasks.add(t);
	    }
	}
    }
    
    taskseriescollection.add(tasks);
    
    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "train_gantt");
    
    final GanttRenderer renderer = new GanttRenderer(){
	private final List<Color> clut = new ArrayList<Color>();
	private int row;
	private int col;
	private int index;
    
	@Override
	public java.awt.Paint getItemPaint(final int row, final int col) {
	    if (clut.isEmpty() || this.row != row || this.col != col) {
	        initClut(row, col);
	        this.row = row;
	        this.col = col;
	        index = 0;
	    }
	    
	    return clut.get(index++);
	}
	
	private void initClut(final int row, final int col){
	    clut.clear();
	
	    final Task t = tasks.get(col);

	    for (int i=0; i<t.getSubtaskCount(); i++){
		final Task st = t.getSubtask(i);
	    
		if (st.getDescription().startsWith("Waiting"))
		    clut.add(waitingColor);
		else
		if (st.getDescription().startsWith("Running"))
		    clut.add(runningColor);
		else
		if (st.getDescription().startsWith("Saving"))
		    clut.add(savingColor);
		else
		    clut.add(Color.black);
	    }
	}
    };
    
    renderer.setDrawBarOutline(false);
    renderer.setDefaultBarPainter(new org.jfree.chart.renderer.category.StandardBarPainter());
    renderer.setShadowVisible(false);
    renderer.setGradientPaintTransformer(null);
    renderer.setItemMargin(0);
    
    CategoryAxis yaxis = new CategoryAxis("Subjob ID");
    //yaxis.setGridBandsVisible(false);
    yaxis.setUpperMargin(0);
    yaxis.setLowerMargin(0);
                           
    ValueAxis xaxis = lia.web.servlets.web.Utils.getValueAxis(prop, lMin, lMax);
    
    for (Map.Entry<String, String> entry: jobToSite.entrySet()){
	String site = entry.getValue();
	
	site = site.substring(site.indexOf("::")+2, site.lastIndexOf("::"));
	
	String jobid = entry.getKey();
	Paint paint = org.jfree.chart.plot.DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE[ Math.abs(site.hashCode()) % org.jfree.chart.plot.DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE.length ];
	
	paint = display.getColor(prop, site+".color", (Color) paint);
	
	yaxis.setTickLabelPaint(jobid, paint);
    }

    final CategoryToolTipGenerator tt = new CategoryToolTipGenerator(){
	private final List<String> clut = new ArrayList<String>();
	private int row;
	private int col;
	private int index;

	public String generateToolTip(final CategoryDataset dataset, final int row, final int col) {
	    if (clut.isEmpty() || this.row != row || this.col != col) {
	        initClut(row, col);
	        this.row = row;
	        this.col = col;
	        index = 0;
	    }

	    return clut.get(index++);	    
	}

	private void initClut(final int row, final int col){
	    clut.clear();
	
	    final Task t = tasks.get(col);

	    for (int i=0; i<t.getSubtaskCount(); i++){
		final Task st = t.getSubtask(i);
	    
	        final String key = t.getDescription();
	    
	        final TimePeriod tp = st.getDuration();
	    
		clut.add(
		    key+":<B>"+Format.toInterval(tp.getEnd().getTime() - tp.getStart().getTime())+"</B> ("+
		    DATE_FORMAT.format(tp.getStart())+" - "+DATE_FORMAT.format(tp.getEnd())+")<BR>"+
	    	    st.getDescription()
		);
	    }
	}
    };
    renderer.setBaseToolTipGenerator(tt);
    
    final CategoryURLGenerator url = new CategoryURLGenerator(){
	public String generateURL(final CategoryDataset dataset, final int series, final int category) {
	    final Task t = tasks.get(category);
	    
	    return "javascript:void(0)\" onClick=\"javascript:openLive('"+t.getDescription()+"');\"";
	}
    };
    renderer.setBaseItemURLGenerator(url);
    
    //renderer.setEndPercent(0);
    //renderer.setStartPercent(0);
    
    CategoryPlot plot = new CategoryPlot(taskseriescollection, yaxis, xaxis, renderer);
    plot.setOrientation(PlotOrientation.HORIZONTAL);
    
    JFreeChart chart = new JFreeChart("Subjobs of "+pid, null, plot, false);
    
    final LegendItemCollection legendCollection = new LegendItemCollection();
    legendCollection.add(new LegendItem("Waiting", waitingColor));
    legendCollection.add(new LegendItem("Running", runningColor));
    legendCollection.add(new LegendItem("Saving", savingColor));
    
    org.jfree.chart.title.LegendTitle legend = new org.jfree.chart.title.LegendTitle(new LegendItemSource(){
	public LegendItemCollection getLegendItems(){
	    return legendCollection;
	}
    });
    
    legend.setPosition(org.jfree.ui.RectangleEdge.BOTTOM);
    
    chart.addLegend(legend);
    
    display.setChartProperties(chart, prop);
    
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 80 + labels.size()*11;
    
    int width = 800;
    
    String sImage = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, lia.web.utils.ServletExtension.pgetb(prop, "overlib_tooltips", true));

    pw.flush();
    
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Subjobs of "+pid);
    
    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);
    
    pMaster.append(p);
    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/jobs/gantt.jsp", baos.size(), request);
%>