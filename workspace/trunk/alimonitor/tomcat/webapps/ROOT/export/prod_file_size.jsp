<%@ page import="java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,java.awt.Dimension,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.StandardEntityCollection,org.jfree.chart.servlet.ServletUtilities,org.jfree.chart.labels.StandardXYToolTipGenerator,org.jfree.chart.urls.XYURLGenerator,org.jfree.data.statistics.*,lazyj.*,alien.catalogue.*" %><%
%><%
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "bits_chart");
    ByteArrayOutputStream baos = new ByteArrayOutputStream(2000);

    Page p = new Page(baos, BASE_PATH+"/export/prod_file_size.res", false);

    final HistogramDataset dataset = new HistogramDataset();
    
    RequestWrapper rw = new RequestWrapper(request);
    
    String path = rw.gets("path", "/alice/sim/LHC11b10c");
    String pattern = rw.gets("pattern", "sim.log");
    
    long threshold = rw.getl("threshold", 0);
    
    p.modify("path", path);
    p.modify("pattern", pattern);
    p.modify("threshold", threshold);
    
    Collection<LFN> searchResults = LFNUtils.find(path, pattern, 0);

    //System.err.println("Found : "+searchResults.size()+" files based on : "+path+" & "+pattern);

    double[] sizes = new double[searchResults.size()];
    
    int cnt = 0;
    
    int above = 0;
    int below = 0;
    
    for (LFN l: searchResults){
	//System.err.println(l.getCanonicalName()+ " : "+l.size);
    
	sizes[cnt++] = l.size;
	
	if (l.size>=threshold) above++;
	else below++;
    }
    
    p.modify("above", above);
    p.modify("below", below);
    
    p.modify("above_percentage", above*100d/(above+below));
    p.modify("below_percentage", below*100d/(above+below));
		
    dataset.addSeries(
	pattern + "  in  "+path, 
	sizes,
	80
    );
			
    HistogramType type = HistogramType.RELATIVE_FREQUENCY;

    dataset.setType(type);
		
    final XYBarRenderer renderer = new XYBarRenderer();
    renderer.setDrawBarOutline(false);
		
    final ValueAxis xAxis = new NumberAxis("File size");
		
    final ValueAxis yAxis = new NumberAxis("Frequency");

    renderer.setToolTipGenerator(new StandardXYToolTipGenerator());
		
    XYPlot plot = new XYPlot(dataset, xAxis, yAxis, renderer);
		
    JFreeChart chart = new JFreeChart(null, plot);
    
    display.setChartProperties(chart, prop);

    ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    
    int height = 600;
    
    int width = 1024;
    
    String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
    ChartUtilities.writeImageMap(pw, sImage, info, true);

    p.modify("image", sImage);
    p.modify("map", sw.toString());

    display.registerImageForDeletion(sImage, 60);    

    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);    
%>