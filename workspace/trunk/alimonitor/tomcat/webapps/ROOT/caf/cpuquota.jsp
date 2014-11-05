<%@ page import="alimonitor.*,lia.web.utils.ServletExtension,lia.web.utils.Formatare,lazyj.RequestWrapper,java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.web.servlets.web.*,java.awt.*,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.*,org.jfree.chart.servlet.*,org.jfree.chart.labels.*,org.jfree.chart.urls.*,org.jfree.ui.*,org.jfree.data.category.*,org.jfree.data.time.*" %><%!
int getIndex(final String sSeriesName, final int iArrayLength){
    int colorIndex = sSeriesName.hashCode();
				
    if (colorIndex < 0)
        colorIndex *= -1;

    return colorIndex % iArrayLength;
}

Color getColor(final Properties prop, final String sSeriesName){
    final int colorIndex = getIndex(sSeriesName, DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE.length);
		
    return ServletExtension.getColor(prop, sSeriesName+".color", (Color) DefaultDrawingSupplier.DEFAULT_PAINT_SEQUENCE[colorIndex]);
}

Shape getShape(final String sSeriesName){
    final int colorIndex = getIndex(sSeriesName, DefaultDrawingSupplier.DEFAULT_SHAPE_SEQUENCE.length);
        
    return DefaultDrawingSupplier.DEFAULT_SHAPE_SEQUENCE[colorIndex];
}

RegularTimePeriod getTableTime(final long time, final TimeZone tz, final long lCompactInterval){
    return new MySecond(new Date(time), tz, lCompactInterval);
}

TimeZone getTimeZone(final Properties prop) {
    final String sTimezone = ServletExtension.pgets(prop, "timezone", "GMT");

    if (sTimezone.equals("local") || sTimezone.equals("default"))
        return TimeZone.getDefault();
    
    try {
	return TimeZone.getTimeZone(sTimezone);
    }
    catch (Exception e) {
        return TimeZone.getDefault();
    }
}

%><%
    Utils.logRequest("START /caf/cafquota.jsp", 0, request);

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    response.setContentType("text/html");
    
    final RequestWrapper rw = new RequestWrapper(request);

    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    Properties prop = Utils.getProperties(BASE_PATH+"/WEB-INF/conf/", "bits_chart");
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("title", "CAF (CERN Analysis Facility) CPU Quota monitoring");

    Page p = new Page("caf/cpuquota.res");

    // now actual work begins
    
    // ----------- Parameter sanity check
    
    String sCluster = rw.gets("cluster");
    
    if (sCluster.length()==0)
	sCluster = "PROOF::CAF::STORAGE";
    
    String sGroup = rw.gets("group");
    
    String sUser = rw.gets("user");
    
    if (sUser.length()!=0 && sGroup.length()!=0){
	sUser="";
    }
    
    if (sUser.length()==0 && sGroup.length()==0){
	sGroup="*";
    }

    if (sGroup.equals("*"))
	p.modify("opt_group_all", "selected");
    
    if (sUser.equals("*"))
	p.modify("opt_user_all", "selected");

    long lIntervalMin = rw.getl("interval.min", 86400000);
    long lIntervalMax = rw.getl("interval.max", 0);
    
    SimpleDateFormat sdf2 = new SimpleDateFormat("M/d/yyyy H:00:00");

    if (lIntervalMin < lIntervalMax){
	long l = lIntervalMin;
	lIntervalMin = lIntervalMax;
	lIntervalMax = lIntervalMin;
    }
    
    //System.err.println("min = "+lIntervalMin+", max = "+lIntervalMax);
    
    p.modify("interval_min", lIntervalMin);
    p.modify("interval_max", lIntervalMax);
    
    lIntervalMin /= 1000*60*60;
    lIntervalMax /= 1000*60*60;
    
    p.modify("current_date_time", sdf2.format(new Date()));
    
    String sMode = request.getParameter("mode");
    
    if (sMode==null || (!sMode.equals("history") && !sMode.equals("pie")))
	sMode = "history";

    p.modify("opt_mode_"+sMode, "selected");
    
    TreeSet<String> tsParameters = new TreeSet<String>();
    
    String[] vsParameters = request.getParameterValues("parameters");
    
    for (int i=0; vsParameters!=null && i<vsParameters.length; i++){
	tsParameters.add(vsParameters[i]);
    }
    
    DB db = new DB();
    
    // ----------- Build the drop-down select menu
    
    db.query("SELECT distinct cafcluster FROM cafquota;");
    while (db.moveNext()){
	String s = db.gets(1);
	p.append("opt_cluster", "<option value='"+s+"' "+(s.equals(sCluster) ? "selected" : "")+">"+s+"</option>\n");
    }

    db.query("SELECT name FROM (SELECT distinct name FROM cafquota WHERE cafcluster='"+Formatare.mySQLEscape(sCluster)+"' AND isuser=false) AS x ORDER BY name!='_TOTALS_';");
    while (db.moveNext()){
	String s = db.gets(1);
	
	p.append("opt_group", "<option value='"+s+"' "+(s.equals(sGroup) ? "selected" : "")+">"+(s.equals("_TOTALS_") ? "- SUM -" : s)+"</option>\n");
    }
    
    db.query("SELECT name FROM (SELECT distinct name FROM cafquota WHERE cafcluster='"+Formatare.mySQLEscape(sCluster)+"' AND isuser=true) AS x ORDER BY name!='_TOTALS';");
    while (db.moveNext()){
	String s = db.gets(1);
	
	p.append("opt_user", "<option value='"+s+"' "+(s.equals(sUser) ? "selected" : "")+">"+(s.equals("_TOTALS_") ? "- SUM -" : s)+"</option>\n");
    }
    
    // ----------- Get the data from the database
    
    String sPeriod  = "period";
    String sValue   = "value";
    String sGroupBy = "";
    
    boolean bHour = true;
    boolean bDay  = false;
    boolean bWeek = false;
    boolean bMonth = false;
    
    if (Math.abs(lIntervalMin - lIntervalMax) > 2400){
        sPeriod = "date_trunc('month', period)";
        sValue  = "sum(value)";
        sGroupBy = " GROUP BY date_trunc('month', period), name, parameter";
        
        bHour = false;
        bMonth = true;
    }
    else
    if (Math.abs(lIntervalMin - lIntervalMax) > 1000){
        sPeriod = "date_trunc('week', period)";
        sValue  = "sum(value)";
        sGroupBy = " GROUP BY date_trunc('week', period), name, parameter";
        
        bHour = false;
        bWeek = true;
    }
    else
    if (Math.abs(lIntervalMin - lIntervalMax) > 100){
	sPeriod  = "date_trunc('day', period)";
	sValue   = "sum(value)";
	sGroupBy = " GROUP BY date_trunc('day', period), name, parameter";
	
	bHour = false;
	bDay  = true;
    }
    
    String sQuery = "SELECT "+sPeriod+", name, parameter, "+sValue+" FROM cafquota WHERE cafcluster='"+Formatare.mySQLEscape(sCluster)+"' AND isuser=";
    
    if (sUser.length()>0){
	sQuery += "true";
	
	if (!sUser.equals("*")){
	    sQuery += " AND name='"+Formatare.mySQLEscape(sUser)+"'";
	}
	else{
	    sQuery += " AND name!='_TOTALS_'";
	}
    }
    else{
	sQuery += "false";
	
	if (sGroup.length()>0 && !sGroup.equals("*")){
	    sQuery += " AND name='"+Formatare.mySQLEscape(sGroup)+"'";
	}
	else{
	    sQuery += " AND name!='_TOTALS_'";
	}
    }
    
    sQuery += " AND period>=date_trunc('hours', now() - '"+lIntervalMin+" hours'::interval) AND period<=date_trunc('hours', now() - '"+lIntervalMax+" hours'::interval)";
    
    sQuery += sGroupBy+" ORDER BY 1,2,3;";
    
    //System.err.println(sQuery);
    
    db.query(sQuery);
    
    /*
     * Parameter
     *   Name
     *     Function ('history' or 'aggregated')
     *       Time1 - value1
     *       Time2 - value2
     *       ...
     */
    TreeMap<String, TreeMap<String, TreeMap<String, TreeMap<Long, Double>>>> tm = new TreeMap<String, TreeMap<String, TreeMap<String, TreeMap<Long, Double>>>>();
    
    while (db.moveNext()){
	String sTime  = db.gets(1);
	String sName  = db.gets(2);
	String sParam = db.gets(3);
	double dValue = db.getd(4);
    
	if (tsParameters.size()>0 && !tsParameters.contains(sParam))
	    continue;
    
	Long lTime = Long.valueOf( lazyj.Format.parseDate(sTime).getTime() );
    
	//System.err.println(lTime+" = "+sTime+" - "+sName+" - "+sParam+" - "+dValue);
	
	TreeMap<String, TreeMap<String, TreeMap<Long, Double>>> tmParameter = tm.get(sParam);
	if (tmParameter==null){
	    tmParameter = new TreeMap<String, TreeMap<String, TreeMap<Long, Double>>>();
	    tm.put(sParam, tmParameter);
	}
	
	TreeMap<String, TreeMap<Long, Double>> tmName = tmParameter.get(sName);
	if (tmName==null){
	    tmName = new TreeMap<String, TreeMap<Long, Double>>();
	    tmParameter.put(sName, tmName);
	}
	
	TreeMap<Long, Double> tmHistory = tmName.get("history");
	TreeMap<Long, Double> tmAggregated = tmName.get("aggregated");
	
	double dPrev = 0;
	
	if (tmHistory==null){
	    tmHistory = new TreeMap<Long, Double>();
	    tmAggregated = new TreeMap<Long, Double>();
	    
	    tmName.put("history", tmHistory);
	    tmName.put("aggregated", tmAggregated);
	}
	else{
	    Long lLast = tmAggregated.lastKey();
	    dPrev = tmAggregated.get(lLast).doubleValue();
	}
	
	tmHistory.put(lTime, new Double(dValue));
	tmAggregated.put(lTime, new Double(dValue + dPrev));
    }
    
    // --------------- now we have the data, let's generate some plots
    
    Plot plot = null;
    
    int plots = 0;
    
    if (sMode.equals("pie")){
	final DefaultCategoryDataset dataset = new DefaultCategoryDataset();
	
	for (Map.Entry<String, TreeMap<String, TreeMap<String, TreeMap<Long, Double>>>> me: tm.entrySet()){
	    final String sParam = me.getKey();
	    
	    for (Map.Entry<String, TreeMap<String, TreeMap<Long, Double>>> meName: me.getValue().entrySet()){
		final String sName = meName.getKey();

		TreeMap<Long, Double> tmValues = meName.getValue().get("aggregated");
		
		Double dValue = tmValues.get(tmValues.lastKey());
		
		dataset.addValue(dValue, sName, sParam);
	    }
	}
	
	MultiplePiePlot mpp = new MultiplePiePlot(dataset);
	
	JFreeChart jfreechart1 = mpp.getPieChart();
	PiePlot pieplot = (PiePlot)jfreechart1.getPlot();
	pieplot.setToolTipGenerator(new StandardPieToolTipGenerator("{0} = {2} ({1})"));                
	
	plot = mpp;
    }
    else{
	CombinedDomainXYPlot cdxyp = new MyCombinedDomainXYPlot();
    
	TreeSet<String> tsActiveNames = new TreeSet<String>();
    
	for (Map.Entry<String, TreeMap<String, TreeMap<String, TreeMap<Long, Double>>>> me: tm.entrySet()){
	    final String sParam = me.getKey();
	    
	    TimeTableXYDataset ttxyd = new TimeTableXYDataset();
	    TimeSeriesCollection tsc = new TimeSeriesCollection();
	    
	    ArrayList<String> alNames = new ArrayList<String>();
	    
	    double dAbsMax = 0;
	    
	    boolean bTime = false;
	    
	    // base axis
	    
	    String sAxisName = sParam;
	    
	    if (sAxisName.equals("count"))
		sAxisName = "connections";

	    if (sAxisName.equals("cputime")){
		sAxisName = "CPU time (h)";
		bTime = true;
	    }
	    
	    if (sAxisName.equals("walltime")){
		sAxisName = "Wall time (h)";
		bTime = true;
	    }
	    	    
	    for (Map.Entry<String, TreeMap<String, TreeMap<Long, Double>>> meName: me.getValue().entrySet()){
		final String sName = meName.getKey();

		TimeSeries ts = new TimeSeries(null, Minute.class);

		TreeMap<Long, Double> tmAggregated = meName.getValue().get("aggregated");

		for (Map.Entry<Long, Double> meHistory: meName.getValue().get("history").entrySet()){
		    Long lTime = meHistory.getKey();
		    Double dValue = meHistory.getValue();
		    Double dAggregated = tmAggregated.get(lTime);
		    
		    if (bTime){
			dValue = Double.valueOf(dValue.doubleValue() / 3600);
			dAggregated = Double.valueOf(dAggregated.doubleValue() / 3600);
		    }
		    
		    RegularTimePeriod rtpHistory = null;
		    
		    if (bHour)
			rtpHistory = new Hour(new Date(lTime.longValue()));
		    else
		    if (bDay)	
			rtpHistory = new Day(new Date(lTime.longValue()));
		    else
		    if (bWeek)	
			rtpHistory = new Week(new Date(lTime.longValue()));
		    else
		    if (bMonth)	
			rtpHistory = new Month(new Date(lTime.longValue()));
		    
		    RegularTimePeriod rtpAggregated = new Minute(new Date(rtpHistory.getFirstMillisecond() + (rtpHistory.getLastMillisecond()-rtpHistory.getFirstMillisecond())/2));
		    
		    ttxyd.add(rtpHistory, dValue.doubleValue(), sName);
		    
		    ts.add(rtpAggregated, dAggregated.doubleValue());
		    
		    dAbsMax = Math.max(dAggregated.doubleValue(), dAbsMax);
		}
		
		tsc.addSeries(ts);
		alNames.add(sName);
	    }

	    boolean bSize = sParam.equals("bytesread") || sParam.equals("events");
	    boolean bEvents = sParam.equals("events");


	    NumberFormat nf = null;
	    NumberTickUnit ntu = null;
	    
	    if (bSize){
	    	nf = new MyNumberFormat(true, "b", bEvents ? "" : "B");
		ntu = new NumberTickUnit(1.0, nf);
	    }
	    else{
		nf = new MyNumberFormat(false, "b", "");
		ntu = new NumberTickUnit(1.0, nf);
	    }
	
	    NumberAxis na = new NumberAxis(sAxisName){
	    };
	    
	    if (nf!=null){
		na.setNumberFormatOverride(nf);
		na.setTickUnit(ntu, false, false);
	    }

	    XYBarRenderer barRenderer = new StackedXYBarRenderer();
	    
	    MyXYToolTipGenerator ttg = new MyXYToolTipGenerator(
		false, 
		bSize, 
		"b", 
		false,
		"",
		"", 
		(lIntervalMin - lIntervalMax) < 24 * 3 ? "MMM d, HH:mm" : "yyyy, MMM d"
	    );

	    MyXYToolTipGenerator ttg2 = new MyXYToolTipGenerator(
		false, 
		bSize, 
		"b", 
		false,
		"",
		"", 
		(lIntervalMin - lIntervalMax) < 24 * 3 ? "MMM d, HH:00" : "yyyy, MMM d"
	    );
	    ttg2.setAlternateSeriesNames(new java.util.Vector(alNames));
	    
	    barRenderer.setBaseToolTipGenerator(ttg);
	    
	    XYPlot subplot = new XYPlot(ttxyd, null, na, barRenderer);
	    
	    // second axis
	    NumberAxis numberaxis = new NumberAxis("Cummulative");
	    
	    if (nf!=null){
		numberaxis.setNumberFormatOverride(nf);
		
		double unit = 1;
		
		double base = 1000;
		
		if (bSize){
		    base = 1024;
		}
		
		unit = Math.floor(Math.log(dAbsMax) / Math.log(base));

		unit = Math.round(Math.pow(base, unit));
		    
		if (dAbsMax>0 && unit!=0){
	    	    double dLowerLimit = tm.size()>3 ? 10 : 20;
		    double dUpperLimit = tm.size()>3 ? 4 : 8;
		    
		    int cnt = 0;
		    
    		    while ( (unit < dAbsMax / dLowerLimit) && (++cnt < 100) )
			unit *= 2;
		    
		    
		    cnt = 0;
		    
		    while ( (unit > dAbsMax / dUpperLimit) && (++cnt < 100) )
			unit /= 2;
		}
			
		numberaxis.setTickUnit(new NumberTickUnit(unit), false, false);
	    }
	    
	    XYLineAndShapeRenderer standardxyitemrenderer1 = new XYLineAndShapeRenderer();
	    standardxyitemrenderer1.setBaseShapesVisible(true);
	    standardxyitemrenderer1.setUseFillPaint(true);
	    standardxyitemrenderer1.setBaseToolTipGenerator(ttg2);
	    
	    subplot.setRangeAxis(1, numberaxis);
	    subplot.setRenderer(1, standardxyitemrenderer1);
	    subplot.setDataset(1, tsc);
	    subplot.mapDatasetToRangeAxis(1, 1);
	    
	    subplot.setDatasetRenderingOrder(DatasetRenderingOrder.FORWARD);
	    
	    //now let's fix the colors
	    for (int i=0; i<ttxyd.getSeriesCount(); i++){
		String sSeriesName = ttxyd.getSeriesKey(i).toString();
		
		Color c = getColor(prop, sSeriesName);
		
		barRenderer.setSeriesPaint(i, c);
	    }
	    
	    // the same for the second axis
	    for (int i=0; i<alNames.size(); i++){
		String sSeriesName = alNames.get(i);
		
		Color c = getColor(prop, sSeriesName);
		
		standardxyitemrenderer1.setSeriesPaint(i, c);
		standardxyitemrenderer1.setSeriesFillPaint(i, Utils.alterColor(c, 150));
		standardxyitemrenderer1.setSeriesShape(i, getShape(sSeriesName));
	    }
	    
	    tsActiveNames.addAll(alNames);
	    
	    cdxyp.add(subplot, 50);
	    
	    plots ++;
	}
	
	boolean bShowOnlyActiveGroups = rw.getb("onlyactive", true);
	
	p.modify("onlyactive_"+bShowOnlyActiveGroups, "selected");
	
	if (false && (tsParameters.size()==0 || tsParameters.contains("cpuquota"))){
	    final String sPred = "aliendb1.cern.ch/ROOT_CPUQUOTA_CAF"+sCluster+"/__PROCESSINGINFO__/";
	
	    db.query("select distinct split_part(mi_key,'/',4) from monitor_ids where mi_key like '"+sPred+"%';");
	    
	    final TimeTableXYDataset ttxyd = new TimeTableXYDataset();
	    
	    final monPredicate pred = ServletExtension.toPred(sPred+"/%");
	    pred.tmin = - lIntervalMin*1000*60*60;
	    pred.tmax = - lIntervalMax*1000*60*60;
	    
	    final long lCompactInterval = Utils.getCompactInterval(prop, -pred.tmin, -pred.tmax);
	    
	    final DataSplitter ds = ((TransparentStoreFast) TransparentStoreFactory.getStore()).getDataSplitter(new monPredicate[]{pred}, lCompactInterval);
	    
	    final TimeZone tz = getTimeZone(prop);
	    
	    final ArrayList<String> alNames = new ArrayList<String>();
	    
	    while (db.moveNext()){
		final String sName = db.gets(1);
		
		pred.parameters[0] = sName;
		
		if (bShowOnlyActiveGroups && tsActiveNames.size()>0 && !tsActiveNames.contains(sName))
		    continue;
		    
		alNames.add(sName);
		
		final java.util.Vector data = ds.get(pred);
		
		Utils.filterMultipleSeries(data, prop, sName, true);
		Utils.fixupHistorySeries(data, prop, -pred.tmin, -pred.tmax, true);
		
		long lOldTime = 0;
		double dOldValue = 0;
		
		for (int i=0; data!=null && i<data.size(); i++){
		    final Result r = (Result) data.get(i);
		    
		    final double dVal = r.param[0];
		    
		    final long lTimeDiff = r.time - lOldTime;
		    
		    if (lOldTime>0 && lTimeDiff>lCompactInterval){
			final double dValueDiff = dVal - dOldValue;
		    
			for (long time=lOldTime+lCompactInterval; time<r.time; time+=lCompactInterval){
			    final RegularTimePeriod rtp = getTableTime(time, tz, lCompactInterval);
			    
			    final double dIntVal = dOldValue + (dValueDiff*(time - lOldTime))/lTimeDiff;
			    
			    ttxyd.add(rtp, new Double(dIntVal), sName, false);
			}
		    }
		    
		    final RegularTimePeriod rtp = getTableTime(r.time, tz, lCompactInterval);
		    
		    ttxyd.add(rtp, new Double(dVal), sName, false);
		    
		    lOldTime = r.time;
		    dOldValue = dVal;
		}
	    }
	    
	    //final XYAreaRenderer2 axyir = ServletExtension.pgetb(prop, "areachart.stacked", true) ? new StackedXYAreaRenderer2() : new XYAreaRenderer2();
	    final XYItemRenderer axyir = new StandardXYItemRenderer(StandardXYItemRenderer.SHAPES_AND_LINES);

	    MyXYToolTipGenerator ttg = new MyXYToolTipGenerator(
		false, 
		false, 
		"b", 
		false,
		"",
		"", 
		(lIntervalMin - lIntervalMax) < 24 * 3 ? "MMM d, HH:mm" : "yyyy, MMM d"
	    );

	    axyir.setBaseToolTipGenerator(ttg);
	    
	    for (int i=0; i<ttxyd.getSeriesCount(); i++){
		final String sSeriesName = ttxyd.getSeriesKey(i).toString();
		
		final Color c = getColor(prop, sSeriesName);
		
		axyir.setSeriesPaint(i, c);
	    }
	    
	    final NumberAxis na = new NumberAxis("Allocated %");
	    
	    final XYPlot subplot = new XYPlot(ttxyd, null, na, axyir);
	    
	    cdxyp.add(subplot, 50);
	    
	    plots ++;
	}
	
	cdxyp.setDomainAxis(Utils.getValueAxis(prop, lIntervalMin*1000*60*60+1, lIntervalMax*1000*60*60+1));
	
	plot = cdxyp;
    }
    
    if (plot!=null){
	//System.err.println("Generating plot");
    
	JFreeChart chart = new JFreeChart(null, plot);
    
        display.setChartProperties(chart, prop);

	ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
    
        StringWriter sw = new StringWriter();
	PrintWriter pw = new PrintWriter(sw);
    
        int height = 150*plots + 30;
    
	int width = 900;
    
	String sImage = ServletUtilities.saveChartAsPNG(chart, width, height, info, null);
	ChartUtilities.writeImageMap(pw, sImage, info, ServletExtension.pgetb(prop, "overlib_tooltips", true));

	p.modify("image", sImage);
	p.modify("map", sw.toString());

	display.registerImageForDeletion(sImage, 60);    
    }

    if (tsParameters.size()==0){
	p.modify("parameters_events", "checked");
	p.modify("parameters_walltime", "checked");
	p.modify("parameters_cputime", "checked");
	p.modify("parameters_bytesread", "checked");
	//p.modify("parameters_cpuquota", "checked");
	p.modify("parameters_count", "checked");
    }
    else{
	for (String sParameter: tsParameters){
	    p.modify("parameters_"+sParameter, "checked");
	}
    }
    
    // final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    Utils.logRequest("/caf/cafquota.jsp", baos.size(), request);
%>
