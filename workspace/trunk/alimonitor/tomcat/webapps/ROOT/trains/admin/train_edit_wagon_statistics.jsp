<%@ page import="lia.web.servlets.web.display,lia.web.utils.ServletExtension,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*, java.awt.*, org.jfree.chart.*, org.jfree.chart.plot.*, org.jfree.chart.entity.*, org.jfree.data.xy.*, org.jfree.chart.renderer.xy.XYLineAndShapeRenderer, org.jfree.chart.axis.*, org.jfree.chart.labels.*, java.text.DecimalFormat" %><%!
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_edit_wagon_statistics.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page p = new Page(baos, "trains/admin/train_edit_wagon_statistics.res", false);
    
    final DB db = new DB();
    
    int train_id = rw.geti("train_id");
    String wagon_name = rw.gets("wagon_name");

    if(train_id==0) train_id=rw.geti("train_id_field");
    if(wagon_name.equals("")) wagon_name=rw.gets("wagon_name_field");
    
    p.append("train_id_field", train_id);
    p.append("wagon_name_field", wagon_name);

    //find all dataset which were used for at least one run with this wagon
    db.query("SELECT distinct period_name FROM train_run_wagon NATURAL JOIN train_run_period WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"' AND test_exitcode=0 ORDER BY period_name;");

    String dataset_statistic=rw.gets("dataset_statistic");
    if(dataset_statistic.equals("")) {
	DB db2 = new DB("SELECT period_name FROM train_run_period WHERE train_id="+train_id+" AND id=(SELECT max(id) FROM train_run_wagon NATURAL JOIN train_run_period WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"' AND test_exitcode=0);");
	dataset_statistic=db2.gets(1);
    }

    while (db.moveNext()){
	p.append("dataset_statistic", "<option value='"+Format.escHtml(db.gets(1))+"' "+(dataset_statistic.equals(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }

     
    //calculate values for the id dependence of cpu and memory time
    XYSeries stat_cpu = new XYSeries("CPU Usage");
    XYSeries stat_mem_rss = new XYSeries("resident memory");
    XYSeries stat_mem_virt = new XYSeries("virtual memory");
    
    db.query("SELECT id FROM train_run_wagon NATURAL JOIN train_run_period WHERE train_id="+train_id+" AND wagon_name='"+wagon_name+"' AND period_name='"+dataset_statistic+"' AND test_exitcode=0;");
    
    while (db.moveNext()){
	// same calculation as in the test results
	final DB db2 = new DB();
	db2.query("SELECT *,test_cpu_time*1000/max(test_events,1) AS cpu_per_event,test_wall_time*1000/max(test_events,1) AS wall_per_event FROM train_run_wagon LEFT OUTER JOIN train_wagon USING(train_id, wagon_name) WHERE train_id="+train_id+" AND id="+db.geti("id")+" ORDER BY wagon_name='__ALL__',wagon_name!='__BASELINE__',dependencies IS NOT NULL,length(dependencies) asc, lower(dependencies) asc,lower(wagon_name) asc;");
	
	Map<String, Map<String, Double>> memoryMap = new HashMap<String, Map<String, Double>>();
	// configuration of the test in train_edit_run.jsp
	final String[] deltas = new String[]{"test_mem_rss", "test_mem_virt", "cpu_per_event"};
	
	while (db2.moveNext()){
	    String sNiceName = db2.gets("wagon_name");
	    final Map<String, Double> testMemory = new HashMap<String, Double>();
	    
	    for (final String delta: deltas){
		testMemory.put(delta, db2.getd(delta));
	    }
	    
	    final StringTokenizer st = new StringTokenizer("__BASELINE__,"+db2.gets("dependencies"), ",; \t\r\n");
	    final Map<String, Double> deltaMemory = new HashMap<String, Double>(testMemory);
	    
	    while (st.hasMoreTokens()){
		final String tok = st.nextToken();
		final Map<String, Double> ref = memoryMap.get(tok);
		
		if (ref!=null){
		    for (final String delta: deltas){
			double d = Math.min(testMemory.get(delta).doubleValue() - ref.get(delta).doubleValue(), deltaMemory.get(delta).doubleValue());
			deltaMemory.put(delta, d);
		    }
		}
	    }
	    memoryMap.put(sNiceName, testMemory);
	    if(sNiceName.equals(wagon_name)){
		stat_cpu.add(db.geti("id"), deltaMemory.get("cpu_per_event"));
		stat_mem_rss.add(db.geti("id"), deltaMemory.get("test_mem_rss"));
		stat_mem_virt.add(db.geti("id"), deltaMemory.get("test_mem_virt"));
	    }
	}
    }


    // Add the series to data set
    XYSeriesCollection dataset_cpu = new XYSeriesCollection();
    dataset_cpu.addSeries(stat_cpu);
    XYSeriesCollection dataset_mem_rss = new XYSeriesCollection();
    dataset_mem_rss.addSeries(stat_mem_rss);
    XYSeriesCollection dataset_mem_virt = new XYSeriesCollection();
    dataset_mem_virt.addSeries(stat_mem_virt);
    // Generate the graph
    JFreeChart chart_cpu = ChartFactory.createXYLineChart("", // Title
						      "run",// x-axis Label
						      "CPU (ms/evt)",// y-axis Label
						      dataset_cpu,// Dataset
						      PlotOrientation.VERTICAL, // Plot Orientation
						      true,// Show Legend
						      true,// Use tooltips
						      false// Configure chart to generate URLs?
						      );
    
    // get a reference to the plot for further customisation...
    XYPlot plot = chart_cpu.getXYPlot();
    plot.setBackgroundPaint(Color.white);
    plot.setRangeGridlinePaint(Color.black);
    final XYLineAndShapeRenderer renderer_cpu = new XYLineAndShapeRenderer();
    renderer_cpu.setSeriesLinesVisible(0, true);
    final StandardXYToolTipGenerator ttg1 = new StandardXYToolTipGenerator("{0}: (run {1}, {2} ms/evt)",new DecimalFormat("0"), new DecimalFormat("0.0"));
    renderer_cpu.setBaseToolTipGenerator(ttg1);
    plot.setRenderer(renderer_cpu);

    //add other datasets to the graph
    final NumberAxis axis2 = new NumberAxis("memory (MB)");
    NumberAxis axis1 = (NumberAxis) plot.getDomainAxis();
    axis2.setTickLabelFont(axis1.getTickLabelFont());
    axis2.setLabelFont(axis1.getLabelFont());
    axis2.setAutoRangeIncludesZero(false);
    plot.setRangeAxis(1, axis2);

    plot.setDataset(1, dataset_mem_rss);
    plot.mapDatasetToRangeAxis(1, 1);

    plot.setDataset(2, dataset_mem_virt);
    plot.mapDatasetToRangeAxis(2, 1);

    final XYLineAndShapeRenderer renderer_mem_rss = new XYLineAndShapeRenderer();
    renderer_mem_rss.setSeriesPaint(0, Color.blue);
    final StandardXYToolTipGenerator ttg2 = new StandardXYToolTipGenerator("{0}: (run {1}, {2} MB)",new DecimalFormat("0"), new DecimalFormat("0.0"));
    renderer_mem_rss.setBaseToolTipGenerator(ttg2);
    plot.setRenderer(1, renderer_mem_rss);

    final XYLineAndShapeRenderer renderer_mem_virt = new XYLineAndShapeRenderer();
    renderer_mem_virt.setSeriesPaint(0, Color.green);
    renderer_mem_virt.setBaseToolTipGenerator(ttg2);
    plot.setRenderer(2, renderer_mem_virt);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);

    final String SITE_BASE = sc.getRealPath("/");
    final String BASE_PATH=SITE_BASE+"/";
    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "bits_chart");
    String s_cpu = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart_cpu, 350, 350, info, null);

    ChartUtilities.writeImageMap(pw, s_cpu, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

    p.modify("statistic_cpu", s_cpu);
    p.modify("map", sw.toString());

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
%>