<%@ page import="lia.web.servlets.web.display,lazyj.*,lia.web.utils.ServletExtension,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.text.SimpleDateFormat, org.jfree.chart.*, org.jfree.chart.renderer.xy.*, org.jfree.chart.plot.*, org.jfree.chart.entity.*, org.jfree.data.category.*, org.jfree.data.statistics.*, org.jfree.chart.axis.*, java.math.*, org.jfree.chart.util.LogFormat, java.text.NumberFormat, org.jfree.chart.labels.StandardXYToolTipGenerator, java.text.DecimalFormat, java.awt.Paint, java.awt.Font, java.awt.Color" %><%!
    %><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/running_time.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);


    final Page p = new Page(baos, "trains/admin/running_time.res", false);
    
    final DB db = new DB();

    final int lpm_id = rw.geti("lpm_id");

     db.query("SELECT max(unnest) FROM (SELECT pid, unnest(running_time) FROM job_stats_details) AS js LEFT JOIN lpm_history ON js.pid=lpm_history.pid WHERE chain_id="+lpm_id+";");
    int maxRunningTime = db.geti(1);
    int bins = 51; //number of bins in the histogram
    double bin_width =  ((double)maxRunningTime)/((bins-1)*60000); //bin width in the histogram in minutes
    if(bin_width<0.001) bin_width=1;//if there is no running Time statistic, but the other statistics is there
    SimpleHistogramDataset dataset_time = new SimpleHistogramDataset("Running time per job");

    for(int i=0;i<bins;i++){
	SimpleHistogramBin bin = new SimpleHistogramBin(i*bin_width,(i+1)*bin_width,true,false);
	dataset_time.addBin(bin);
    }
    dataset_time.setAdjustForBinSize(false);
    
    
    db.query("SELECT js.pid, files_histogram, running_time FROM (SELECT pid, files_histogram, running_time FROM job_stats_details WHERE files_histogram IS NOT NULL and state='DONE') AS js left join lpm_history ON js.pid=lpm_history.pid WHERE chain_id="+lpm_id+";");

    while(db.moveNext()){
	List<Integer> val_runTime = DBFunctions.decodeToInt(db.gets("running_time"));
	double[]data_hist = new double[val_runTime.size()];
	int data_hist_ind = 0;
	for(int i=0;i<val_runTime.size();i++){
	    int value = val_runTime.get(i);
	    if(value<0)
		continue;
	    value = (int)(value/60000);
	    data_hist[data_hist_ind++]= value;
	}
	if(data_hist_ind<val_runTime.size()){
	    double[]data_hist2 = new double[data_hist_ind];
	    for(int i=0; i<data_hist_ind;i++)
		data_hist2[i] = data_hist[i];
	    dataset_time.addObservations(data_hist2);
	}else
	    dataset_time.addObservations(data_hist);
    }
    
    boolean show = false; 
    boolean toolTips = false;//toolTips are realised with the tooltipgenerator below
    boolean urls = false; 
    JFreeChart chart_time = ChartFactory.createHistogram("" , "time/job (min)", "", dataset_time, PlotOrientation.VERTICAL, show, toolTips, urls);
    final XYPlot plot_time = chart_time.getXYPlot();
    plot_time.setBackgroundPaint(Color.white);
    plot_time.setRangeGridlinePaint(Color.black);
    LogAxis y_Axis = new LogAxis("Number of jobs (log scale)");
    y_Axis.setNumberFormatOverride(NumberFormat.getIntegerInstance()) ;
    y_Axis.setTickLabelFont(new Font("Tahoma", Font.PLAIN, 12));//this is the same font as the axis already has, except that is plain here and bold on the other axis, but the bold axis differs much more from the x axis
    y_Axis.setLabelFont(new Font("Tahoma", Font.BOLD, 15));
    
    double scale = 0;
    for(int i=0;i<bins;i++){
	double binScale = dataset_time.getYValue(0,i);
	if(binScale>scale) scale = binScale;
    }
    if(scale>0)
	y_Axis.setRange(0.5,scale*1.5);
    plot_time.setRangeAxis(y_Axis);
    
    final XYBarRenderer renderer_time = new XYBarRenderer();
    renderer_time.setShadowVisible(false);
    renderer_time.setSeriesPaint(0, Color.green.darker());
    final StandardXYToolTipGenerator ttg = new StandardXYToolTipGenerator("{0}: {1} min, {2} jobs",new DecimalFormat("0"), new DecimalFormat("0"));
    renderer_time.setBaseToolTipGenerator(ttg);
    plot_time.setRenderer(renderer_time);
    
    ChartRenderingInfo info_time = new ChartRenderingInfo(new StandardEntityCollection());
    String sImage_time = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart_time, 350, 250, info_time, null);
    StringWriter sw_time = new StringWriter();
    PrintWriter pw_time = new PrintWriter(sw_time);
    
    ChartUtilities.writeImageMap(pw_time, sImage_time, info_time, true);
    
    p.modify("statistics_time", sImage_time);
    p.modify("map_time", sw_time.toString());
    

    p.write();
    String s = new String(baos.toByteArray());
    out.println(s);
%>