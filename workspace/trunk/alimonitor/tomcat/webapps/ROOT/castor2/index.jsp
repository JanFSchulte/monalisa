<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lazyj.*,java.io.*,java.util.*,java.awt.*,java.awt.image.*,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.data.category.*,org.jfree.chart.entity.*,org.jfree.chart.labels.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.chart.servlet.*,org.jfree.data.time.*,org.jfree.data.xy.*" %><%!

    private static void setSpiderCircles(final int rad, final int width, final int height, final double dMaxValue, final SpiderWebPlot plot, final boolean bSpiderLogScale, final String sCluster){
		final int centerX = width/2;
		final int centerY = height/2;
    
		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		final Graphics2D graphics = (Graphics2D) image.getGraphics();
		final Font font = new Font("Arial", Font.PLAIN, 10); // Font.PLAIN, Font.BOLD
		graphics.setFont(font);

		graphics.setColor(lia.web.utils.ColorFactory.getColor(255, 255, 255));
		graphics.fillRect(0, 0, width, height);

		graphics.setColor(lia.web.utils.ColorFactory.getColor(0, 20, 50));

		graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

		final int iMinCircles = bSpiderLogScale == true ? (int) Math.ceil(dMaxValue) : rad / 50;
		final int iMaxCircles = rad / 30;

		double dMaxTemp = dMaxValue;
		long lFactor = 0;

		while (dMaxTemp >= 1000) { // 3 digits max
		    dMaxTemp /= 10d;
		    lFactor++;
		}
		while (dMaxTemp < 100) { // 3 digits min
		    dMaxTemp *= 10d;
		    lFactor--;
		}

		double dScaledMax = dMaxValue;

		long lFactorTemp = lFactor;
		while (lFactor > 0) {
		    dScaledMax /= 10d;
		    lFactor--;
		}
		while (lFactor < 0) {
		    dScaledMax *= 10d;
		    lFactor++;
		}
		lFactor = lFactorTemp;

		int iCircles = iMinCircles;
		double dVisibleMax = Math.round(dMaxTemp / (10d * iCircles)) * (10d * iCircles);
		double dVisibleTemp;

		for (int i = iMinCircles + 1; i <= iMaxCircles; i++) {
		    dVisibleTemp = Math.round(dMaxTemp / (10d * i)) * (10d * i);

		    if (Math.abs(dScaledMax - dVisibleMax) > Math.abs(dScaledMax - dVisibleTemp)) {
			dVisibleMax = dVisibleTemp;
			iCircles = i;
		    }
		}

		while (lFactor > 0) {
		    dVisibleMax *= 10d;
		    lFactor--;
		}
		while (lFactor < 0) {
		    dVisibleMax /= 10d;
		    lFactor++;
		}

		if (bSpiderLogScale) {
		    dVisibleMax = Math.round(dVisibleMax);

		    if (iCircles > dVisibleMax)
			iCircles = (int) dVisibleMax;
		}

		final double dAbsMax = Math.max(dVisibleMax, dMaxValue);

		if (dAbsMax > dMaxValue)
		    plot.setMaxValue(dAbsMax);

		final FontMetrics fm = graphics.getFontMetrics();

		int iPos;
		double dValue, dValueTemp;
		for (int i = 1; i <= iCircles; i++) {
		    if (bSpiderLogScale)
			dValue = dVisibleMax - iCircles + i;
		    else
			dValue = (dVisibleMax * i) / iCircles;

		    dValueTemp = (dValue / dAbsMax) * rad;

		    iPos = (int) (dValueTemp);

    		    graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

		    graphics.drawOval(centerX - iPos - 1, centerY - iPos - 1, iPos * 2, iPos * 2);

		    graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF);

		    dValue = bSpiderLogScale == true ? Math.pow(10, dValue) : dValue;
		    String sValue = lia.web.utils.DoubleFormat.point(dValue);
		    graphics.drawString(sValue, centerX + 2, centerY - iPos - 2);

		    iPos = (int) (dValueTemp * 0.8660254037844386467868626477972782140569d);

		    graphics.drawString(sValue, centerX + iPos + 4 + (int) (dValueTemp / 20d), centerY + (int) (dValueTemp / 2d) - (int) (dValueTemp / 10d) + 3);

		    graphics.drawString(sValue, centerX - iPos - (int) (fm.stringWidth(sValue) * 0.866d) - 6 - (int) (dValueTemp / 20d), centerY + (int) (dValueTemp / 2d) - (int) (dValueTemp / 10d) + 3);
		}

    	    BufferedImage dfImage = getDFImage(sCluster);
	
	    if (dfImage!=null){
		// draw DF in the lower corner
		
		graphics.drawImage(dfImage, null, width-dfImage.getWidth(), height-dfImage.getHeight());
	    }
	
	    BufferedImage nodesImage = getNodesImage(sCluster);
	    
	    if (nodesImage!=null){
		graphics.drawImage(nodesImage, null, 20, 20);
	    }
	
	    plot.setBackgroundImage(image);
	    plot.setBackgroundImageAlpha(0.8f);
	    plot.setBackgroundImageAlignment(org.jfree.ui.Align.CENTER);	
    }
    
    private static final int NODES_BOX_IMG_WIDTH=120;
    private static final int NODES_BOX_IMG_HEIGHT=75;
    
    private static double getClusterParam(final String sCluster, final String sParam){	
	final monPredicate pred = new monPredicate("aliendb2.cern.ch", "server_cern_"+sCluster+"_Nodes_Summary", "sum", -1, -1, new String[]{sParam}, null);
    
	Object o = Cache.getLastValue(pred);
	
	if (o==null || !(o instanceof Result))
	    return -1;

	return ((Result) o).param[0];
    }
    
    private static BufferedImage getNodesImage(final String sCluster){
	final BufferedImage image = new BufferedImage(NODES_BOX_IMG_WIDTH, NODES_BOX_IMG_HEIGHT, BufferedImage.TYPE_INT_RGB);
	final Graphics2D graphics = (Graphics2D) image.getGraphics();
	final Font font = new Font("Arial", Font.PLAIN, 10); // Font.PLAIN, Font.BOLD
	graphics.setFont(font);

	graphics.setColor(lia.web.utils.ColorFactory.getColor(250, 250, 250));
	graphics.fillRect(0, 0, NODES_BOX_IMG_WIDTH, NODES_BOX_IMG_HEIGHT);

	graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	
	graphics.setColor(lia.web.utils.ColorFactory.getColor(150, 150, 150));
	graphics.drawRect(0, 0, NODES_BOX_IMG_WIDTH-1, NODES_BOX_IMG_HEIGHT-1);
	
	graphics.setColor(Color.BLACK);
	
	int iNodes = (int) getClusterParam(sCluster, "count");
	int iSockets = (int) getClusterParam(sCluster, "sockets_tcp");
	double load = getClusterParam(sCluster, "load1");

	if (load>=0 && iNodes>0){
	    load /= iNodes;
	}
	else
	    load = -1;
	
	graphics.drawString("Active servers: "+(iNodes > 0 ? ""+iNodes : "-"), 10, 20);
	graphics.drawString("Sockets: "+(iSockets > 0 ? ""+iSockets : "-"), 10, 40);
	graphics.drawString("Avg. load: "+(load>=0 ? lia.web.utils.DoubleFormat.point(load) : "-"), 10, 60);
	
	return image;
    }
    
    private static final int SPACE_BOX_IMG_WIDTH  = 300;
    private static final int SPACE_BOX_IMG_HEIGHT = 40;
    private static final int SPACE_BOX_X_OFF  = 80;
    private static final int SPACE_BOX_WIDTH  = 200;
    private static final int SPACE_BOX_HEIGHT = 20;
    private static final int SPACE_BOX_ALIGN  = org.jfree.ui.Align.BOTTOM_RIGHT;

    /**
     * @param sCluster cluster name
     * @param lTime epoch time, in seconds
     */
    private static double getHistoricalFree(final String sCluster, final long lTime){
	DB db = new DB();
	
	db.query("SELECT mi_id FROM monitor_ids WHERE mi_key='aliendb2.cern.ch/server_cern_"+Format.escSQL(sCluster)+"_Nodes_Summary/sum/cs2_disk_free';");
	
	if (!db.moveNext())
	    return -1;
	    
	int id = db.geti(1);
	
	String query = "SELECT mval FROM w4_1m_cs2_disk_free WHERE id="+id+" AND rectime>="+(lTime-60*60)+" AND rectime<="+(lTime+60*60)+" ORDER BY abs(rectime-"+lTime+") ASC LIMIT 1;";
	
	//System.err.println(query);
	
	db.query(query);
	
	if (!db.moveNext())
	    return -1;
	
	return db.getd(1);
    }
    
    private static BufferedImage getDFImage(final String sCluster){
	double dTotalSpace;
	double dFreeSpace;
	
	final monPredicate pred = new monPredicate("aliendb2.cern.ch", "server_cern_"+sCluster+"_Nodes_Summary", "sum", -1, -1, new String[]{"cs2_disk_space"}, null);
	
	Object o = Cache.getLastValue(pred);
	
	if (o==null || !(o instanceof Result))
	    return null;

	dTotalSpace = ((Result) o).param[0];
	
	pred.parameters[0] = "cs2_disk_free";
	
	o = Cache.getLastValue(pred);
	
	if (o==null || !(o instanceof Result))
	    return null;
	
	dFreeSpace = ((Result) o).param[0];
	
	if (dTotalSpace <=0 || dFreeSpace > dTotalSpace)
	    return null;
	
	final BufferedImage image = new BufferedImage(SPACE_BOX_IMG_WIDTH, SPACE_BOX_IMG_HEIGHT, BufferedImage.TYPE_INT_RGB);
	final Graphics2D graphics = (Graphics2D) image.getGraphics();
	final Font font = new Font("Arial", Font.PLAIN, 11); // Font.PLAIN, Font.BOLD
	graphics.setFont(font);

	graphics.setColor(lia.web.utils.ColorFactory.getColor(255, 255, 255));
	graphics.fillRect(0, 0, SPACE_BOX_IMG_WIDTH, SPACE_BOX_IMG_HEIGHT);

	graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF);
	
	final int free = (int) (dFreeSpace * SPACE_BOX_WIDTH / dTotalSpace);

	graphics.setColor(Color.GREEN);
	graphics.fillRect(SPACE_BOX_X_OFF, 0, free, SPACE_BOX_HEIGHT);
		
	graphics.setColor(Color.RED);
	graphics.fillRect(SPACE_BOX_X_OFF+free, 0, SPACE_BOX_WIDTH-free, SPACE_BOX_HEIGHT);
	
	// free space one day ago
	final double dPastFree = getHistoricalFree(sCluster, System.currentTimeMillis()/1000 - 60*60*24);
	
	if (dPastFree >= 0){
	    final int pastFree = (int) (dPastFree * SPACE_BOX_WIDTH / dTotalSpace);
	
	    if (pastFree != free){
	        graphics.setColor(new Color(0, 255, 0, 150));
		graphics.fillRect(SPACE_BOX_X_OFF, 5, pastFree, 10);

	        graphics.setColor(new Color(255, 0, 0, 150));
		graphics.fillRect(SPACE_BOX_X_OFF+pastFree, 5, SPACE_BOX_WIDTH-pastFree, 10);
	    }
	}


	final FontMetrics fm = graphics.getFontMetrics();
	
	String sSize = lia.web.utils.DoubleFormat.size(dFreeSpace, "M")+"B";
	int textWidth = fm.stringWidth(sSize);
	int textHeight = fm.getAscent();
	
	graphics.setColor(Color.GREEN.darker().darker());
	graphics.drawString(sSize, SPACE_BOX_X_OFF, SPACE_BOX_HEIGHT + textHeight);

	sSize = lia.web.utils.DoubleFormat.size(dTotalSpace - dFreeSpace, "M")+"B";
	textWidth = fm.stringWidth(sSize);

	graphics.setColor(Color.RED.darker().darker());
	graphics.drawString(sSize, SPACE_BOX_X_OFF + SPACE_BOX_WIDTH - textWidth, SPACE_BOX_HEIGHT + textHeight);

	sSize = lia.web.utils.DoubleFormat.size(dTotalSpace, "M")+"B";
	textWidth = fm.stringWidth(sSize);

	graphics.setColor(Color.BLACK);
	graphics.drawString(sSize, SPACE_BOX_X_OFF - textWidth - 5, SPACE_BOX_HEIGHT - (SPACE_BOX_HEIGHT - textHeight) / 2);

	return image;	
    }
    
    private static double process(final monPredicate pred, final DefaultCategoryDataset dataset, final String sLabel, final boolean bLog) {
	final TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();

	final java.util.Vector<Result> v = lia.web.servlets.web.Utils.toResultVector(store.select(pred));
	
	final long now = System.currentTimeMillis();
	
	final long[] limits = { now-1000*60*60, now-1000*60*60*6, now-1000*60*60*12, now-1000*60*60*24 };
	final double[] values = { 0, 0, 0, 0 };
	final int[] counters = { 0, 0, 0, 0 };
	final String[] labels = {"Last hour avg", "Last 6 hours avg", "Last 12 hours avg", "Last 24 hours avg"};

	double max = 0;

	for (final Result r: v){
	    for (int i=0; i<limits.length; i++){
		if (r.time > limits[i]){
		    values[i] += r.param[0];
		    counters[i] ++;
		}
	    }
	}

	if (v.size()>0){
	    double value = v.get(v.size()-1).param[0];
	    
	    if (bLog)
		value = log10(value);
	
	    dataset.addValue(value, sLabel, "Now");
	    
	    max = value;
	}
	
	for (int i=0; i<limits.length; i++){
	    if (counters[i] > 0){
		double avg = values[i] / counters[i];
	    
		if (bLog)
		    avg = log10(avg);
	    
		dataset.addValue(avg, sLabel, labels[i]);
		
		if (avg > max)
		    max = avg;
	    }
	}
	
	return max;
    }
    
    private static final double LOG10 = Math.log(10d);
	
    private static final double log10(final double x) {
	return Math.log(x) / LOG10;
    }
    
    private static final double pow10(final double x) {
	return Math.exp( x * LOG10 );
    }

    private static final class TooltipGen extends StandardCategoryToolTipGenerator {
	
	private final boolean bLog;
	
	public TooltipGen(final boolean bLog){
	    this.bLog = bLog;
	}

	protected Object[] createItemArray(CategoryDataset dataset, int row, int column) {
    	    Object[] result = new Object[4];
    	    result[0] = dataset.getRowKey(row).toString();
    	    result[1] = dataset.getColumnKey(column).toString();
    	    Number value = dataset.getValue(row, column);

	    if (value!=null){
		double dValue = value.doubleValue();

		if (bLog)
		    dValue = pow10(dValue);

		result[2] = lia.web.utils.DoubleFormat.point(dValue);
    	    }
	    else
		result[2] = "";

	    result[3] = "";

    	    return result;
	}
    }

%><%
    lia.web.servlets.web.Utils.logRequest("START /castor2/index.jsp", 0, request);

    RequestWrapper.setNotCache(response);
    final RequestWrapper rw = new RequestWrapper(request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");
    
    final String BASE_PATH=SITE_BASE+"/";

    final Properties prop = lia.web.servlets.web.Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "jsp_castor2");

    final Enumeration e = request.getParameterNames();
    
    while (e.hasMoreElements()){
	String sKey = (String) e.nextElement();
	prop.setProperty(sKey, rw.gets(sKey));
    }
    
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(100000);
        
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    final Page pChart = new Page("castor2/index.res");

    final DB db = new DB();
    
    lia.web.servlets.web.display.initMasterPage(pMaster, prop, BASE_PATH+"WEB-INF/res/");

    // ------- parameters
    
    String sCluster = rw.gets("cluster");
    
    if (sCluster.length()==0)
	sCluster = "alicedisk";
    
    for (String cluster: new String[]{"alicedisk", "t0alice"}){
	pChart.append("opt_clusters", "<option value='"+cluster+"' "+(cluster.equals(sCluster) ? "selected" : "")+">"+cluster+"</option>");
    }

    final boolean bLog = rw.getb("log", false);
    
    pChart.modify("opt_log_"+bLog, "selected");
    
    // ------- data

    final DefaultCategoryDataset categoryDataset = new DefaultCategoryDataset();

    monPredicate pred = new monPredicate("aliendb2.cern.ch", "server_cern_"+sCluster+"_Nodes_Summary", "sum", -1000*60*60*24, -1, new String[]{"eth0_in"}, null);

    double maxIn = process(pred, categoryDataset, "IN (KB/s)", bLog);
    
    pred.parameters[0] = "eth0_out";
    
    double maxOut = process(pred, categoryDataset, "OUT (KB/s)", bLog);

    // ------- chart
    
    boolean bOrderByRows = true;

    final SpiderWebPlot plot = new SpiderWebPlot(categoryDataset, bOrderByRows ? org.jfree.util.TableOrder.BY_ROW : org.jfree.util.TableOrder.BY_COLUMN);
    
    plot.setWebFilled(true);
    
    plot.setToolTipGenerator(new TooltipGen(bLog));
    
    double max = Math.max(maxIn, maxOut);

    int size = rw.geti("size");
    
    int chartWidth = 800;
    int chartHeight = 600;
    int chartRadius = 203;
    
    if (size==700){
	chartWidth = 700;
	chartHeight = 600;
	chartRadius = 186;
    }
    
    if (max>1)
	setSpiderCircles(chartRadius, chartWidth-16, chartHeight-54, Math.max(maxIn, maxOut), plot, bLog, sCluster);

    final JFreeChart chart = new JFreeChart("Castor2x "+sCluster+" diskpool traffic", plot);
    
    lia.web.servlets.web.display.setChartProperties(chart, prop);

    //chart.removeLegend();

    final ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    final StringWriter sw = new StringWriter();
    final PrintWriter pw = new PrintWriter(sw);
    
    try{
        final String sImage = ServletUtilities.saveChartAsPNG(chart, chartWidth, chartHeight, info, null);
        ChartUtilities.writeImageMap(pw, sImage, info, true);
        pw.flush();
        pChart.modify("map", sw.toString());
	pChart.modify("image", sImage);
        lia.web.servlets.web.display.registerImageForDeletion(sImage, 300);
    }
    catch (Exception ex){
        System.err.println("castor2/index.jsp : Exception generating the chart : "+ex);
    }

    pMaster.append(pChart);

    pMaster.write();
            
    out.println(new String(baos.toByteArray()));
                
    lia.web.servlets.web.Utils.logRequest("/castor2/index.jsp", baos.size(), request);
%>