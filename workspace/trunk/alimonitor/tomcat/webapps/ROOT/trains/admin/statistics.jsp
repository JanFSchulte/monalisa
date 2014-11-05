<%@ page import="lia.web.servlets.web.display,lazyj.*,lia.web.utils.ServletExtension,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.text.SimpleDateFormat, org.jfree.chart.*, org.jfree.chart.renderer.xy.*, org.jfree.chart.plot.*, org.jfree.chart.entity.*, org.jfree.data.category.*, org.jfree.data.statistics.*, org.jfree.chart.axis.*, java.math.*, org.jfree.chart.util.LogFormat, java.text.NumberFormat, org.jfree.chart.labels.StandardXYToolTipGenerator, java.text.DecimalFormat, java.awt.Paint, java.awt.Font, java.awt.Color, alien.transfers.*,java.security.cert.*,auth.*, org.jfree.chart.plot.*, org.jfree.chart.renderer.xy.*, org.jfree.data.xy.*, org.jfree.ui.*, org.jfree.util.*" %><%!


    final static class XYDatasetInfo {
	private final XYDataset dataset;
	private final double percentage;

	public XYDatasetInfo(XYDataset dataset, double percentage) {
	    this.dataset = dataset;
	    this.percentage = percentage;
	}

	public XYDataset getDataset() {
	    return dataset;
	}

	public double getPercentage() {
	    return percentage;
	}
    }

      private static XYDatasetInfo getDataset(String xvalue, String yvalue, String yaxis, double maxX, double maxY, Boolean isState, int only_train_id, Boolean export, Page p) {
        final DB db = new DB();

	    double all_train_runs = 0;
	    double shown_train_runs = 0;

	    String state = "";
	    if(!isState){
		state="DONE";
	    }else{
		state = yvalue;
	    }
	    db.query("select * from train_run_statistics natural join train_run_wagon natural join train_run where state='"+state+"' and wagon_name='__ALL__';");
	    
	    XYSeriesCollection xySeriesCollection = new XYSeriesCollection();
	    XYSeries series = new XYSeries(yaxis);
	    while(db.moveNext()){
		if(only_train_id!=0 && db.geti("train_id")!=only_train_id) continue;// shows the statistics information only for one train
		int test_events = 1;
		if(xvalue.equals("test_wall_time")) test_events = db.geti("test_events");
		if(test_events==0)
		    continue;
		all_train_runs++;
		double test_variable = db.geti(xvalue);
		if(!isState||xvalue.equals("test_wall_time"))
		    test_variable /= test_events;
		
		if(test_variable<maxX||maxX==0){
		    final DB db2 = new DB();
		    double y_value = (double)db.geti(yvalue);
		    if(isState){
			//calculate relative events which are in this state
			y_value = (double)db.geti("jobs");
			db2.query("select sum(jobs) from train_run_statistics where train_id="+db.geti("train_id")+" and id="+db.geti("id")+";");
			int totalEvt = db2.geti(1);
			y_value/=totalEvt;
		    }else{
			//change time from milli seconds to seconds
			y_value/=1000;
			//normalize per Event
			db2.query("select sum(files) from train_run_statistics where train_id="+db.geti("train_id")+" and id="+db.geti("id")+";");
			double inputFiles = db2.geti(1);
			if(inputFiles<1) continue;
			
			db2.query("SELECT sum(train_output), sum(mc_generated), sum(raw_reconstructed) from lpm_history left join job_events on lpm_history.parentpid=job_events.pid where chain_id="+db.geti("lpm_id")+";");
			
			double events = Math.max(db2.geti(1), db2.geti(2));
			events = Math.max(events, db2.geti(3));

			if(events<=1) continue;		    
			double avgFiles = db.getd("files_job_avg");
			double faktor = events/inputFiles*avgFiles;
			if(faktor<1) continue;
			y_value /= faktor;
		    }
		    if(y_value<maxY||maxY==0){
			series.add(test_variable, y_value);
			if(export)
			    p.append("statistics_points", db.geti("train_id")+"|"+test_variable+"; "+y_value+" <br>");
			shown_train_runs++;
		    }
		}
	    }
	    xySeriesCollection.addSeries(series);

	    double percentage = 100*shown_train_runs/all_train_runs;
	    return new XYDatasetInfo(xySeriesCollection, percentage);
      }

    
    %><%
    response.setHeader("Connection", "keep-alive");
    
    lia.web.servlets.web.Utils.logRequest("START /trains/admin/statistics.jsp", 0, request);
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
            
    final Page p = new Page(baos, "trains/admin/statistics.res", false);
    
    final DB db = new DB();
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    pMaster.modify("title", "Analysis trains");

    Boolean exportStats = false;

    if (!(principal.getName().equals("mazimmer")|principal.getName().equals("jgrosseo")|principal.getName().equals("grigoras"))){
	out.println("You are not allowed here");
	return;
    }
    
    //content
    
    if (submit.startsWith("Apply")){
	
    }if (submit.startsWith("Export points")){
	exportStats = true;
    }
    
    
    double maxShownRunningTime = rw.getd("maxShownRunningTime");
    String yvalue = rw.gets("yvalue_statistics");
    String xvalue = rw.gets("xvalue_statistics");
    double maxY_value = rw.getd("maxY_value");
    if(yvalue.equals("")) yvalue="running_time_job_avg";
    if(xvalue.equals("")) xvalue="test_wall_time";
    

    //add error state to yvalues and check if yvalue is already an error state
    Boolean isState = false;
    db.query("SELECT distinct state from train_run_statistics where state!='TOTAL';");
    while(db.moveNext()){
	if(db.gets(1).equals(yvalue)) isState=true;
	p.append("yvalue_statistics", "<option value='"+Format.escHtml(db.gets(1))+"' "+(yvalue.equals(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }

    int selected_train_id = rw.geti("available_train_ids");
    db.query("SELECT distinct train_id from train_run order by train_id");
    p.append("available_train_id", "<option value='0' "+(selected_train_id==0 ? "selected" : "")+">0</option>");
    while(db.moveNext()){
	p.append("available_train_id", "<option value='"+db.geti(1)+"' "+(selected_train_id==db.geti(1) ? "selected" : "")+">"+db.geti(1)+"</option>");
    }

    XYDataset dataset;
    String xLabel="";
    String yLabel="";
    if(!xvalue.equals("test_wall_time")){
	xLabel = "train_run_wagon(__ALL__)->"+xvalue;
    }

    if(isState){
	if(xvalue.equals("test_wall_time")){
	    xLabel = "train_run_statistics->"+xvalue+"/test_events (s/event)";
	}
	yLabel = yvalue+"/all jobs";
    }else{
	if(xvalue.equals("test_wall_time")){
	    xLabel = "train_run_wagon(__ALL__)->test_wall_time/test_events (s/event)";
	}
	yLabel = yvalue+"/event (s/event)";
    }

    XYDatasetInfo result = getDataset(xvalue, yvalue, xvalue+" - "+yvalue+" correlation", maxShownRunningTime, maxY_value, isState, selected_train_id, exportStats, p);
    dataset = result.getDataset();
    double percentage_shown = result.getPercentage();
    p.append("percentage_shown", percentage_shown);
    JFreeChart jfreechart = ChartFactory.createScatterPlot("",xLabel, yLabel, dataset, PlotOrientation.VERTICAL, true, true, false);

    XYPlot xyPlot = (XYPlot) jfreechart.getPlot();
    XYItemRenderer renderer = xyPlot.getRenderer();
    renderer.setBasePaint(Color.red);
    XYDotRenderer xydotrenderer = new XYDotRenderer();
    xydotrenderer.setDotHeight(2);
    xydotrenderer.setDotWidth(2);
    xyPlot.setRenderer(xydotrenderer);
    
    xyPlot.setDomainCrosshairVisible(true);
    xyPlot.setRangeCrosshairVisible(true);
    
    
    
    ChartRenderingInfo info_time = new ChartRenderingInfo(new StandardEntityCollection());
    String sImage_time = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(jfreechart, 700, 500, info_time, null);
    StringWriter sw_time = new StringWriter();
    PrintWriter pw_time = new PrintWriter(sw_time);
    
    ChartUtilities.writeImageMap(pw_time, sImage_time, info_time, true);
    
    p.modify("statistics_time", sImage_time);


    //find possible columns for the table axis
    db.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'train_run_wagon' AND (column_name LIKE 'test_mem%' OR column_name='test_wall_time') ORDER BY column_name;");
    while(db.moveNext()){
	p.append("xvalue_statistics", "<option value='"+Format.escHtml(db.gets(1))+"' "+(xvalue.equals(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }
    db.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'train_run_statistics' and column_name like 'running%';");
    while(db.moveNext()){
	p.append("yvalue_statistics", "<option value='"+Format.escHtml(db.gets(1))+"' "+(yvalue.equals(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }






    //find critical trains
    String state=rw.gets("find_error_state");
    int lastRuns=rw.geti("lastRuns");
    if(state.equals("")) state="ERROR_E (TTL)";
    if(lastRuns==0) lastRuns=10;
    p.modify("lastRuns_size",lastRuns);
    
    //put new states in the selection menu
    db.query("SELECT distinct state from train_run_statistics order by state;");
    while(db.moveNext()){
	p.append("found_errors", "<option value='"+Format.escHtml(db.gets(1))+"' "+(state.equals(db.gets(1)) ? "selected" : "")+">"+Format.escHtml(db.gets(1))+"</option>");
    }
    
    //see critical trains of the last month
    int critical_trains_start = (int)(System.currentTimeMillis()/1000-2592000);

    db.query("select train_id, id, jobs, train_finished_timestamp from train_run_statistics natural join train_run as trs where id+"+lastRuns+">(Select max(id) from train_run where train_id=trs.train_id) and state='"+state+"' and jobs>1 and train_finished_timestamp>"+critical_trains_start+" order by trs.train_id,trs.id;");
    while(db.moveNext()){
	DB db_all = new DB();
	db_all.query("select sum(jobs) from train_run_statistics where train_id="+db.geti("train_id")+" and id="+db.geti("id")+";");
	int allJobs = db_all.geti(1);
	if(allJobs<1) allJobs=1;
	double error_percentage = (double) db.geti(3)/allJobs;
	Page pLine = new Page("trains/admin/statistics_line.res", false);
	pLine.comment("com_toManyErrors",false);
	pLine.fillFromDB(db);
	pLine.append("AllJobs", allJobs);
	pLine.append("error_percentage", error_percentage);
	if(error_percentage>0.1)
	    pLine.comment("com_toManyErrors",true);
	p.append("found_errors_ids", pLine);
    }


    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);



    lia.web.servlets.web.Utils.logRequest("/trains/admin_page.jsp?username="+principal.getName(), baos.size(), request);
%>