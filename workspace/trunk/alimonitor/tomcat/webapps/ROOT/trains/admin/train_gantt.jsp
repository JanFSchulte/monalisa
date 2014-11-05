<%@ page import="lia.web.servlets.web.display,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.gantt.*,org.jfree.data.time.*,org.jfree.data.xy.*,org.jfree.chart.renderer.category.*,org.jfree.chart.labels.*,org.jfree.chart.entity.*,alien.taskQueue.*,org.jfree.chart.urls.*,java.awt.Paint,java.awt.Color" %><%!
    private static final java.text.DateFormat DATE_FORMAT = new java.text.SimpleDateFormat("MMM dd, HH:mm");
    
    private static final void debug(final String message){
	if (false){
	    System.err.println(message);
	}
    }
    
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_gantt.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();

    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page p = new Page("trains/admin/train_gantt.res", false);
    
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");

    final int id = rw.geti("id");
    
    db.query("select lpm_id from train_run where train_id="+train_id+" and id="+id+";");
    
    if (!db.moveNext()){
	out.println("No such train");
	return;
    }

    int lpm_id = db.geti(1);
    
    final Set<Integer> final_merge_job_ids = new HashSet<Integer>();
    
    db.query("SELECT final_merge_job_id FROM train_run_final_merge WHERE train_id="+train_id+" and id="+id+" AND final_merge_job_id>0;");
    
    while (db.moveNext()){
	final_merge_job_ids.add(Integer.valueOf(db.geti(1)));
    }

    final DB db2 = new DB();
    
    final TaskSeriesCollection taskseriescollection = new TaskSeriesCollection();
    
    final List<String> labels = new ArrayList<String>();
    
    long lMin = 0;
    long lMax = 0;

    for (Integer final_merge_job_id: final_merge_job_ids){
	int pid = final_merge_job_id.intValue();
	
	final TaskSeries ts = new TaskSeries("Final merging");
	
	labels.add("Final merging");
	
	do{
	    db2.query("select firstseen,lastseen from job_stats where pid="+pid);

	    long lStart = db2.getl(1) * 1000;
	    long lEnd = db2.getl(2) * 1000;
	    
	    Job j = TaskQueueUtils.getJob(pid, true);

	    String title = "";

	    if (j!=null && j.mtime!=null){
		//System.err.println("For "+pid+" using "+j.mtime.getTime()+" instead of "+lEnd+" ("+lStart+")");
		lEnd = Math.max(lEnd, j.mtime.getTime());
	    }

	    try{
		JDL jdl = new JDL(pid);

		title = "<BR><B>"+jdl.getComment();
	    }
	    catch (final IOException ioe){
		// ignore
	    }
	    
	    lMin = lMin==0 ? lStart : Math.min(lStart, lMin);
	    lMax = Math.max(lMax, lEnd);
	    
	    if (lStart <= lEnd){
		final Task t = new Task(pid+title, new Date(lStart), new Date(lEnd));
	    
		debug(pid+title+" - "+lStart+" - "+lEnd);
	    
		ts.add(t);
	    }
	    
	    db2.query("select pid from lpm_history where parentpid="+pid);
	    
	    pid = db2.geti(1);
	}
	while (pid>0);
	
	taskseriescollection.add(ts);
    }

    db.query("select pid,runno from lpm_history where chain_id="+lpm_id+" order by pid desc;");
    
    while (db.moveNext()){
	final TaskSeries ts = new TaskSeries(db.gets(2));
	
	labels.add(db.gets(2));
	
	int pid = db.geti(1);
	
	do{
	    db2.query("select firstseen,lastseen from job_stats where pid="+pid);

	    Job j = TaskQueueUtils.getJob(pid, false);

	    long lStart = db2.getl(1) * 1000;
	    long lEnd = db2.getl(2) * 1000;
	    
	    if (j!=null && j.mtime!=null){
		//System.err.println("For "+pid+" using "+j.mtime.getTime()+" instead of "+lEnd+" ("+lStart+")");
		lEnd = Math.max(lEnd, j.mtime.getTime());
	    }

	    String title = "";

	    try{
		JDL jdl = new JDL(pid);

		title = "<BR><B>"+jdl.getComment();
	    }
	    catch (final IOException ioe){
		// ignore
	    }
	    
	    lMin = lMin==0 ? lStart : Math.min(lStart, lMin);
	    lMax = Math.max(lMax, lEnd);
	    
	    if (lStart <= lEnd){
		final Task t = new Task(pid+title, new Date(lStart), new Date(lEnd));
	    
		debug(pid+title+" - "+lStart+" - "+lEnd);
	    
		ts.add(t);
	    }
	    
	    db2.query("select pid from lpm_history where parentpid="+pid);
	    
	    pid = db2.geti(1);
	}
	while (pid>0);
	
	taskseriescollection.add(ts);
    }
    
    final Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "train_gantt");

    final List<Color> clut = new ArrayList<Color>();

    clut.add(new Color(0, 215, 64));
    clut.add(new Color(0, 143, 215));
    clut.add(new Color(0, 93, 215));
    clut.add(new Color(64, 0, 215));
    clut.add(new Color(173, 2, 215));
    clut.add(new Color(215, 109, 9));
    
    final XYBarRenderer renderer = new XYBarRenderer(){
	private int row;
	private int col;
	private int index;
    
	@Override
	public Paint getItemPaint(int row, int col) {
	    if (row<final_merge_job_ids.size())
		return super.getItemPaint(row, col);

    	    if (this.row != row) {
    		this.row = row;
        	index = 0;
    	    }
        
	    return clut.get(index++);
	}

    };
    renderer.setUseYInterval(true);
    renderer.setDrawBarOutline(false);
    renderer.setDefaultBarPainter(new org.jfree.chart.renderer.xy.StandardXYBarPainter());

    final SymbolAxis yaxis = new SymbolAxis("Run number", labels.toArray(new String[0]));
    yaxis.setGridBandsVisible(false);
    
    final ValueAxis xaxis = lia.web.servlets.web.Utils.getValueAxis(prop, lMin, lMax);

    final XYToolTipGenerator tt = new StandardXYToolTipGenerator(){
	@Override
	public String generateToolTip(final XYDataset dataset, final int series, final int item) {
	    final TaskSeries ts = taskseriescollection.getSeries(series);
	
	    final String key = ts.getKey().toString();
	    
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
	    
	    String desc = t.getDescription();
	    
	    int idx = desc.indexOf('<');
	    
	    if (idx>=0)
		desc = desc.substring(0, idx);
	    
	    return "javascript:void(0)\" onClick=\"javascript:openLive('"+desc+"');\"";
	}
    };
    renderer.setURLGenerator(url);
    
    renderer.setShadowVisible(false);
    
    for (int iFinal=0; iFinal<final_merge_job_ids.size(); iFinal++){
	renderer.setSeriesPaint(iFinal, java.awt.Color.BLACK);
    }
    
    final XYPlot plot = new XYPlot(new XYTaskDataset(taskseriescollection), yaxis, xaxis, renderer);
    plot.setOrientation(PlotOrientation.HORIZONTAL);
    
    final JFreeChart chart = new JFreeChart("Job execution timing for train "+train_id+" / "+id, plot);
    chart.removeLegend();
    
    display.setChartProperties(chart, prop);
    
    final ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    final StringWriter sw = new StringWriter();
    final PrintWriter pw = new PrintWriter(sw);
    
    final int height = 80 + labels.size()*12;
    
    final int width = 800;
    
    final String sImage = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, lia.web.utils.ServletExtension.pgetb(prop, "overlib_tooltips", true));

    pw.flush();
    
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Job execution timing for train "+train_id+" / "+id);
    
    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);
    
    pMaster.append(p);
    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_gantt.jsp", baos.size(), request);
%>