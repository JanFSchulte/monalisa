<%@ page import="alien.taskQueue.*,lazyj.*,alien.catalogue.*,alien.jobs.*,alimonitor.Page,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,auth.*,alimonitor.*,java.util.concurrent.atomic.*,java.text.*,org.jfree.chart.*,org.jfree.chart.plot.*,org.jfree.data.category.*,org.jfree.chart.axis.*,org.jfree.chart.renderer.category.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.title.*,java.util.*,java.io.*,java.awt.*,org.jfree.ui.*,lia.web.servlets.web.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.*,org.jfree.chart.urls.XYURLGenerator,lia.web.utils.ServletExtension,org.jfree.chart.urls.*,alien.utils.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /users/jobs.jsp", 0, request);

    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(16000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    pMaster.modify("title", "Jobs management");
    
    final Page p = new Page("users/jobs.res", false);
    final Page pLine = new Page("users/jobs_line.res", false);
    
    final AlicePrincipal user = Users.get(request);
    
    if (user==null){
	System.err.println("users/jobs.jsp : User is not authenticated");
	return;
    }
    
    p.modify("username", user.getName());
    
    boolean bTable = rw.getb("table", true);
    
    p.modify("chart_display", bTable ? "none" : "inline");
    p.modify("table_display", bTable ? "inline" : "none");

    int flag = rw.geti("j");

    java.util.List<Job> masterJobs;
    
    String sUserFilter = rw.gets("user");
    
    if (sUserFilter.length()>0){
	masterJobs = TaskQueueUtils.getMasterjobs(sUserFilter, true);
    }
    else
    if (flag==0){
	masterJobs = new ArrayList<Job>();
    
        for (String s: user.getNames())
    	    masterJobs.addAll(TaskQueueUtils.getMasterjobs(s, true));
    }
    else
    if (flag==1){
	masterJobs = new ArrayList<Job>();
    
	for (String s: user.getRoles())
	    masterJobs.addAll(TaskQueueUtils.getMasterjobs(s, true));
    }
    else{
	masterJobs = TaskQueueUtils.getMasterjobs(null, true);
    }
    
    masterJobs = TaskQueueUtils.filterMasterjobs(masterJobs, 1000*60*60*8);

    final Map<Job, Map<JobStatus, Integer>> jobs = TaskQueueUtils.getMasterjobStats(masterJobs);
    
    for (final Map<JobStatus, Integer> stats: jobs.values()){
	Integer done_warn = stats.remove(JobStatus.DONE_WARN);
	
	if (done_warn!=null){
	    Integer done = stats.remove(JobStatus.DONE);
	    
	    if (done!=null){
		done_warn = Integer.valueOf(done_warn.intValue() + done.intValue());
	    }
	    
	    stats.put(JobStatus.DONE, done_warn);
	}
    }
    
    final Map<JobStatus, AtomicInteger> totals = new EnumMap<JobStatus, AtomicInteger>(JobStatus.class);

    final DefaultCategoryDataset categoryDataset = new DefaultCategoryDataset();
    
    for (final Map.Entry<Job, Map<JobStatus, Integer>> me: jobs.entrySet()){
	Job j = me.getKey();
	
        final Map<JobStatus, Integer> subjobs = me.getValue();
    
	int total_count = 0;
	
	for (final Integer i: subjobs.values()){
	    total_count += i.intValue();
	}
	
	pLine.modify("id", j.queueId);
	
	pLine.modify("owner", j.getOwner());
	pLine.modify("state", j.status());
	pLine.modify("total_count", total_count);
	
	if (subjobs!=null){
	    for (final Map.Entry<JobStatus, Integer> me2: subjobs.entrySet()){
		pLine.modify(me2.getKey().name(), me2.getValue());
		
		categoryDataset.addValue(me2.getValue(), me2.getKey().name(), Integer.valueOf(j.queueId));
		
		AtomicInteger ai = totals.get(me2.getKey());
		
		if (ai==null){
		    ai = new AtomicInteger(me2.getValue());
		    totals.put(me2.getKey(), ai);
		}
		else{
		    ai.addAndGet(me2.getValue());
		}
	    }
	}

	String command = j.name;
	
	if (command!=null && command.indexOf("/")>=0)
	    command = command.substring(command.lastIndexOf('/')+1);
	
	pLine.modify("command", command);
	pLine.modify("command_path", j.name);
	
	try{
	    alien.jobs.JDL jdl = new alien.jobs.JDL(j.getJDL());
	
	    pLine.modify("jobcomment", jdl.getComment());
	}
	catch (Exception e){
	    // ignore
	}
	
	p.append(pLine);
    }
    
    p.modify("count", jobs.size());
    
    int iTotal = 0;
    
    for (Map.Entry<JobStatus, AtomicInteger> me: totals.entrySet()){
	p.modify(me.getKey().name(), me.getValue());
	iTotal += me.getValue().intValue();
    }
    
    p.modify("total_count", iTotal);

    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";

    final Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "users/jobs");
    
    CategoryItemRenderer cir = new StackedBarRenderer3D(5, 4);

    int width=1024;
    int height=jobs.size() * 12 + 100;

    NumberAxis numberAxis = new NumberAxis3D("Number of jobs");
    
    NumberFormat nf = new MyNumberFormat(false, "", "");

    numberAxis.setNumberFormatOverride(nf);
    
    cir.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator(ServletExtension.pgets(prop, "tooltips.format", "{1}: {0} = {2}"), nf));

    CategoryURLGenerator scurlg = new CategoryURLGenerator(){
	public String generateURL(final CategoryDataset dataset, final int series, final int category){
	    return "javascript:void(0);\" onClick=\"openLive('"+dataset.getColumnKey(category)+"#"+dataset.getRowKey(series)+"')";
	}
    };
    
    cir.setBaseItemURLGenerator(scurlg);

    java.util.List<String> l = (java.util.List<String>) categoryDataset.getRowKeys();
    
    for (String category: l){
	int colorIndex = category.hashCode();
	
	if (colorIndex<0)
	    colorIndex *= -1;
    
	Color defaultColor = (Color) DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE[colorIndex % DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE.length];
    
	Color c = display.getColor(prop, category+".color", defaultColor);

	int idx = categoryDataset.getRowIndex(category);
	
	//System.err.println("Setting "+idx+" ("+category+") to "+c+" (default = "+defaultColor+")");
	
	cir.setSeriesPaint(idx, c);
    }

    CategoryAxis catAxis = new CategoryAxis3D("Master job IDs");
    
    CategoryPlot categoryPlot = new CategoryPlot(categoryDataset, catAxis, numberAxis, cir);
    
    categoryPlot.setOrientation(PlotOrientation.HORIZONTAL);
    
    categoryPlot.setDatasetRenderingOrder(DatasetRenderingOrder.FORWARD);
    
    JFreeChart jfreechart = new JFreeChart("Jobs status", categoryPlot);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    final StringWriter sw = new StringWriter();
    final PrintWriter pw = new PrintWriter(sw);
    
    String sImage = ServletUtilities.saveChartAsPNG(jfreechart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));
    
    lia.web.servlets.web.display.registerImageForDeletion(sImage, 600);
    
    p.modify("image", sImage);
    p.modify("map", sw.toString());
    
    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/users/jobs.jsp?u="+user.getName(), baos.size(), request);
%>