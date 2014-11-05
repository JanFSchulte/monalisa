<%@ page import="lia.web.servlets.web.display,lazyj.*,lia.web.utils.ServletExtension,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*, org.jfree.chart.*, org.jfree.data.general.DatasetUtilities, org.jfree.chart.plot.*, org.jfree.chart.entity.*, org.jfree.data.category.*, org.jfree.data.statistics.*, org.jfree.chart.axis.*, java.math.*, org.jfree.chart.title.LegendTitle, org.jfree.ui.RectangleEdge, org.jfree.chart.labels.StandardCategoryToolTipGenerator, java.text.DecimalFormat, org.jfree.chart.renderer.category.*, java.awt.Paint, java.awt.Font, java.awt.Color" %><%!
    %><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/input_files.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);


    final Page p = new Page(baos, "trains/admin/input_files.res", false);
    
    final DB db = new DB();


    final int lpm_id = rw.geti("lpm_id");

    //need the array first to add up the values in the histogramms
    String[] jobState = new String[]{"DONE", "ERROR_V", "ERROR_E (TTL)", "ERROR_E (mem)", "ERROR_E (disk)", "ERROR_EW", "Other"};//for these states the files histogram is computed
    String usedStates=" not in ('TOTAL";
    for(int jobStates2=0;jobStates2<jobState.length;++jobStates2){
	usedStates+="','"+jobState[jobStates2];
    }
    usedStates+="')";
    String states =  "";

   int maxFiles = 0;
   //find out maxFiles
   db.query("SELECT js.pid, files_histogram, files_size, cnt FROM (SELECT pid, files_histogram, files_size, cnt FROM job_stats_details where files_histogram IS NOT NULL) AS js LEFT JOIN lpm_history ON js.pid=lpm_history.pid WHERE chain_id="+lpm_id+";");
   while(db.moveNext()){
       List<Integer> values = DBFunctions.decodeToInt(db.gets("files_histogram"));
       for(int i=0;i<values.size();i++){
	   if(i>maxFiles && values.get(i)>0) maxFiles = i;
       }
   }

    double[][]data = new double[jobState.length][maxFiles+1];//maxFiles+1 because array goes from 0 to maxFiles
    
    for(int jobStates=0;jobStates<jobState.length;++jobStates){
	if(!jobState[jobStates].equals("Other")){
	    states="='"+jobState[jobStates]+"'";
	}else{
	    states=usedStates;
	}
	//get the data and fill it to the dataset
	db.query("SELECT js.pid, files_histogram, running_time FROM (SELECT pid, files_histogram, running_time FROM job_stats_details WHERE files_histogram IS NOT NULL and state"+states+") AS js left join lpm_history ON js.pid=lpm_history.pid WHERE chain_id="+lpm_id+";");
	    
	while(db.moveNext()){
	    List<Integer> values = DBFunctions.decodeToInt(db.gets("files_histogram"));
	    for(int i=1;i<values.size();i++){
		data[jobStates][i] += values.get(i);
		}
	}
    }
	    

    //write data to the dataset
    //the automatic method to add the whole array with different strings for the legend does not work, so it is done by hand
    DefaultCategoryDataset dataset = new DefaultCategoryDataset();
    for (int r = 0; r < data.length; r++) {
	//start at c=1 because the first bin is always 0
	for (int c = 1; c < data[r].length; c++) {
	    Comparable columnKey = c;
	    dataset.addValue(new Double(data[r][c]), jobState[r], columnKey);
	}
    }    
	
    //create stacked bar chart
    // ChartFactory.createStackedBarChart(plotTitle, xaxis, yaxis, dataset, orientation, show, toolTips, urls
    final JFreeChart chart = ChartFactory.createStackedBarChart("", "files/job", "Number of jobs", dataset, PlotOrientation.VERTICAL, true, false, false);
    
    final LegendTitle legend=chart.getLegend();
    legend.setPosition(RectangleEdge.LEFT);
    
    //rotate labels so that all labels are displayed and can be seen
    CategoryPlot plot = chart.getCategoryPlot();
    plot.setBackgroundPaint(Color.white);
    plot.setRangeGridlinePaint(Color.black);
    if(maxFiles>10){
	CategoryAxis domainAxis = plot.getDomainAxis();
	domainAxis.setCategoryLabelPositions(CategoryLabelPositions.createUpRotationLabelPositions(Math.PI / 4.0));
    }
    
//final CategoryItemRenderer renderer = plot.getRenderer();
    final StackedBarRenderer renderer = (StackedBarRenderer)plot.getRenderer();
    renderer.setSeriesPaint(0, Color.green.darker());
    renderer.setShadowVisible(false);
    renderer.setSeriesPaint(1, Color.blue.darker());
    renderer.setSeriesPaint(2, Color.red);
    renderer.setSeriesPaint(3, Color.cyan);
    renderer.setSeriesPaint(4, Color.yellow);
    renderer.setSeriesPaint(5, Color.magenta);
    renderer.setSeriesPaint(6, Color.black);

    final StandardCategoryToolTipGenerator ttg1 = new StandardCategoryToolTipGenerator("{0}: {1} files, {2} jobs",new DecimalFormat("0"));
    
    renderer.setBaseToolTipGenerator(ttg1);
    plot.setRenderer(renderer);
    
    //add chart to html page
    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    String sImage = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(chart, 480, 250, info, null);
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    Properties prop = lia.web.servlets.web.Utils.getProperties(sc.getRealPath("/")+"/WEB-INF/conf/", "bits_chart");
    ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));
    
    p.modify("statistics", sImage);
    p.modify("map", sw.toString());

    p.write();
    String s = new String(baos.toByteArray());
    out.println(s);
%>