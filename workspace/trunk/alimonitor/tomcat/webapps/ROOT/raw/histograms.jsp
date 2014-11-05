<%@ page import="lia.web.servlets.web.display,lia.web.utils.ServletExtension,lia.Monitor.Store.Fast.DB,alimonitor.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lazyj.*,java.io.*,java.util.*,java.awt.*,java.awt.image.*,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.data.category.*,org.jfree.chart.entity.*,org.jfree.chart.labels.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.servlet.*,org.jfree.data.time.*,org.jfree.data.xy.*,org.jfree.data.statistics.*" %><%!
    private void imageToPage(Page p, Properties prop, JFreeChart chart, int imageId) throws IOException {
	display.setChartProperties(chart, prop);
    
	ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
	StringWriter sw = new StringWriter();
	PrintWriter pw = new PrintWriter(sw);
    
	int height = ServletExtension.pgeti(prop, "height", 500);
    
        int width = ServletExtension.pgeti(prop, "width", 1000);
    
	String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
	ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

	pw.flush();
    
	p.modify("image"+imageId, sImage);
	p.modify("map"+imageId, sw.toString());
	
	lia.web.servlets.web.display.registerImageForDeletion(sImage, 60);
    }
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /raw/histograms.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "RAW data production requests");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    Page p = new Page("raw/histograms.res");
    
    RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();

    String sBookmark = "";    

    String sRuns = rw.gets("runs");
    
    // -------------------

    StringTokenizer st = new StringTokenizer(sRuns," ,");
    
    StringBuilder sbRuns = new StringBuilder();
    
    while (st.hasMoreTokens()){
	try{
	    int i = Integer.parseInt(st.nextToken());
	    
	    if (sbRuns.length()>0)
		sbRuns.append(',');
	
	    sbRuns.append(i);
	}
	catch (Exception e){
	}
    }
    
    if (sbRuns.length()==0)
	return;

    // ----------------------------------
    // ------- First chart : events
    db.query("SELECT events/10000,count(1) FROM rawdata_runs WHERE run IN ("+sbRuns.toString()+") AND events IS NOT NULL and events>0 GROUP BY events/10000 ORDER BY 1;");

    SimpleHistogramDataset dataset = new SimpleHistogramDataset("Events per run");
    
    while (db.moveNext()){
	int ev = db.geti(1);
	int count = db.geti(2);
    
	SimpleHistogramBin bin = new SimpleHistogramBin(ev, (ev+1), true, false);
	bin.setItemCount(count);
	
	dataset.addBin(bin);
    }
    
    XYBarRenderer renderer = new XYBarRenderer();
    renderer.setDrawBarOutline(true);
    renderer.setToolTipGenerator(new StandardXYToolTipGenerator());
    renderer.setShadowVisible(false);
    
    ValueAxis xAxis = new NumberAxis("Events x 10^4");
    ValueAxis yAxis = new NumberAxis("Number of runs");                                
    
    XYPlot xyplot = new XYPlot(dataset, xAxis, yAxis, renderer);

    JFreeChart chart = new JFreeChart("Events per run", xyplot);
    
    imageToPage(p, new Properties(), chart, 1);
    
    // ----------------------------------
    // ------- Second chart: raw data size
    db.query("SELECT (size)/(1024*1024*1024),count(1) FROM rawdata_runs WHERE run IN ("+sbRuns.toString()+") AND size is not null and size>0 GROUP BY (size)/(1024*1024*1024) ORDER BY 1;");

    dataset = new SimpleHistogramDataset("Raw data size");
    
    while (db.moveNext()){
	double size = db.getd(1);
	int count = db.geti(2);
    
	SimpleHistogramBin bin = new SimpleHistogramBin(size, (size+1), true, false);
	bin.setItemCount(count);
	
	dataset.addBin(bin);
    }
    
    renderer = new XYBarRenderer();
    renderer.setDrawBarOutline(true);
    renderer.setToolTipGenerator(new StandardXYToolTipGenerator());
    renderer.setShadowVisible(false);
    
    xAxis = new NumberAxis("Raw data size (GB)");
    yAxis = new NumberAxis("Number of runs");                                
    
    xyplot = new XYPlot(dataset, xAxis, yAxis, renderer);

    chart = new JFreeChart("Raw data size", xyplot);
    
    imageToPage(p, new Properties(), chart, 2);

    // ----------------------------------
    // ------- Second chart: ESD data size
    db.query("SELECT (size_pass1)/(1024*1024*1024),count(1) FROM rawdata_runs WHERE run IN ("+sbRuns.toString()+") AND size_pass1 is not null and size_pass1>0 GROUP BY (size_pass1)/(1024*1024*1024) ORDER BY 1;");

    dataset = new SimpleHistogramDataset("ESDs size");
    
    while (db.moveNext()){
	double size = db.getd(1);
	int count = db.geti(2);
    
	SimpleHistogramBin bin = new SimpleHistogramBin(size, (size+1), true, false);
	bin.setItemCount(count);
	
	dataset.addBin(bin);
    }
    
    renderer = new XYBarRenderer();
    renderer.setDrawBarOutline(true);
    renderer.setToolTipGenerator(new StandardXYToolTipGenerator());
    renderer.setShadowVisible(false);
    
    xAxis = new NumberAxis("ESDs size (GB)");
    yAxis = new NumberAxis("Number of runs");                                
    
    xyplot = new XYPlot(dataset, xAxis, yAxis, renderer);

    chart = new JFreeChart("ESDssize", xyplot);
    
    imageToPage(p, new Properties(), chart, 3);
    
    // statistics
    
    db.query("SELECT sum(events) as total_events, avg(events)::bigint as avg_events, sum(size) as total_size, avg(size)::bigint as avg_size, sum(size_pass1) as total_pass1_size, avg(size_pass1)::bigint as avg_pass1_size FROM rawdata_runs WHERE run IN ("+sbRuns.toString()+");");
    
    p.fillFromDB(db);
    
    long lAvgEvents = db.getl("avg_events");
    
    if (lAvgEvents>0)
	p.modify("events_runs", (long) Math.round(db.getl("total_events")/(double)lAvgEvents));
	
    long lAvgSize = db.getl("avg_size");

    if (lAvgSize>0)
	p.modify("size_runs", (long) Math.round(db.getl("total_size")/(double)lAvgSize));

    long lAvgSizePass1 = db.getl("avg_pass1_size");

    if (lAvgSizePass1>0)
	p.modify("size_pass1_runs", (long) Math.round(db.getl("total_pass1_size")/(double)lAvgSizePass1));
    
    // Create the bookmarks
    
    pMaster.modify("bookmark", sBookmark);
    
    // -------------------
        
    pMaster.append(p);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
                    
    lia.web.servlets.web.Utils.logRequest("/raw/histograms.jsp", baos.size(), request);
%>