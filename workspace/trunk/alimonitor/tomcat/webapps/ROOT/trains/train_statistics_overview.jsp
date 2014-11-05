<%@ page import="lia.web.servlets.web.display,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*, alien.transfers.*,java.security.cert.*,auth.*, org.jfree.chart.plot.*, org.jfree.chart.renderer.xy.*, org.jfree.data.xy.*, org.jfree.chart.*, org.jfree.chart.entity.*, java.awt.Color, org.jfree.chart.axis.NumberAxis;" %><%!
  
    %><%
    response.setHeader("Connection", "keep-alive");
    
    lia.web.servlets.web.Utils.logRequest("START /trains/train_statistics_overview.jsp", 0, request);
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
            
    final DB db = new DB();
    final DB db_selected = new DB();
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    final String submit = rw.gets("submit");

    pMaster.modify("title", "Analysis trains");

    //one Button in use, which is called Apply, it just should reload the page

    //content

    String[] modes = new String[]{"ESD","AOD","MC ESD","MC AOD & Kinematics only", "all trains"};
    // 0 ESD
    // 1 AOD production
    // 2 AOD produced together with ESD 
    // 3 Kinematics only
    // 4 ESD (special wSDD production)
    // 5 ESD cpass1 (barrel)
    // 6 ESD cpass1 (outer)
    // 256 train name contains MC -> AOD way of showing that this is a MC analysis
    // 512 train has an activated MC handler -> ESD way of showing that this is a MC analysis
    String[] aod_esd = new String[]{"0,4,5,6","1,2","0,4,5,6","1,2,3","0,1,2,3,4,5,6"};
    String[] times = new String[]{"last week", "last month", "2 months", "3 months", "6 months", "1 year", "2 years", "3 years"};//written time intervalls
    long[] times_intervall = new long[]{604800, 2592000, 5184000, 7776000, 15768000, 31536000, 63072000, 94608000};//correspondent seconds
    
    final Page p = new Page(baos, "trains/train_statistics_overview.res", false);

    p.comment("com_apply",true);
    p.comment("com_table", false);

    String interval_selected = rw.gets("number_train");
    if(interval_selected.equals("")) interval_selected=times[0];

    final long offset = 3600*24*14; // stat only available after 2 weeks
    long intervall = 0;
    for(int i=0;i<times.length;i++){
	Boolean isSelected = times[i].equals(interval_selected);
	p.append("number_train_date","<option value='"+times[i]+"' "+(isSelected ? "selected" : "")+">"+times[i]+"</option>");
	if(isSelected) intervall = times_intervall[i];
    }

    int stat_begin =  (int) (System.currentTimeMillis()/1000-intervall-offset);
    p.append("statistics_start", stat_begin);
    if(stat_begin<1362096000)//before 1st of March 2013 only a part of the statistics was gathered
	p.comment("com_show_warning", true);
    else
	p.comment("com_show_warning", false);

    int stat_end = (int) (System.currentTimeMillis()/1000 - offset);
    p.append("statistics_end", stat_end);


        String q_all = ""; //query to get all the train runs
        String q_weeks = ""; //query to get all the selected train runs per week
        String q_selected = "SELECT " //query to get all the train runs which are automatically merged and have more than 75% success rate
	    +"wg_no, "
	    +"COUNT(DISTINCT train_id) AS number_trains, "
	    +"COUNT(DISTINCT(train_id, id)) AS number_train_runs, "
	    +"SUM(number_jobs) AS number_jobs, "
	    +"SUM(total_wall) AS total_wall_time, "
	    +"SUM(hasTotalWall) AS has_total_wall, "
	    +"AVG(train_finished_timestamp - run_start) AS runTime_avg, "
	    +"AVG(submit_masterSubmit - run_start) AS submit_masterSubmit_avg, "
	    +"AVG(firstFinMerge - submit_masterSubmit) AS firstFinMerge_avg, "
	    +"AVG(train_finished_timestamp - firstFinMerge) AS merge_finished_avg "
	    +"FROM"
	    +" (SELECT wg_no, train_run.train_id, train_run.id, total_wall, run_start, train_finished_timestamp,"
	    +" EXTRACT(YEAR FROM TIMESTAMP 'epoch' + run_start * INTERVAL '1 second') AS year,"
	    +" EXTRACT(WEEK FROM TIMESTAMP 'epoch' + run_start * INTERVAL '1 second') AS week,"
	    +" (SELECT SUM(jobs) FROM train_run_statistics WHERE train_run_statistics.train_id = train_run.train_id AND train_run_statistics.id = train_run.id) AS number_jobs,"
	    +" (SELECT SUM(jobs) FROM train_run_statistics WHERE train_run_statistics.train_id = train_run.train_id AND train_run_statistics.id = train_run.id AND state = 'DONE') AS done_jobs,"
	    +" (SELECT 1 from train_run as tr2 where train_run.id=tr2.id and train_run.train_id=tr2.train_id and total_wall>0) as hasTotalWall,"
	    +" (SELECT MAX(firstseen) FROM lpm_history NATURAL INNER JOIN job_stats WHERE chain_id = lpm_id) AS submit_masterSubmit,"
	    +" (SELECT MIN(firstseen) FROM train_run_final_merge LEFT JOIN job_stats ON final_merge_job_id = pid WHERE train_run_final_merge.train_id = train_run.train_id AND train_run_final_merge.id = train_run.id) AS firstFinMerge"
	    +" FROM train_run "
	    +" LEFT JOIN train_def ON train_def.train_id = train_run.train_id" //need train_def for the wg_no
            +" WHERE"
	    +" run_start>"+stat_begin+" AND run_start<"+stat_end+" XXX ";//the tripple X is used to be replaced by the ana_dataset, this is done because the ana_dataset is different for each mode and the XXX is easy to identify and replace

	q_all = q_selected;
	q_all += ") AS foo2 GROUP BY wg_no ORDER BY wg_no;";
	
	q_selected += " AND merged_by_hand = 0 AND train_finished_timestamp > 0 AND slow_train_run=0"
	    +") AS foo1 " // end of the inner query which collects the total job number, the successful jobs number and all the time intervals
	    +"WHERE done_jobs > number_jobs*0.75 "
	    +"AND submit_masterSubmit - run_start > 0 AND firstFinMerge - submit_masterSubmit > 0 "
	    +"AND train_finished_timestamp - firstFinMerge > 0 ";

        q_weeks = q_selected;
        q_weeks +=  "AND (year > EXTRACT(YEAR FROM TIMESTAMP 'epoch' + "+stat_begin+" * INTERVAL '1 second') OR week>=EXTRACT(WEEK FROM TIMESTAMP 'epoch' + "+stat_begin+" * INTERVAL '1 second') AND year=EXTRACT(YEAR FROM TIMESTAMP 'epoch' + "+stat_begin+" * INTERVAL '1 second')) "
            //+"AND (year < EXTRACT(YEAR FROM TIMESTAMP 'epoch' + "+stat_end+" * INTERVAL '1 second') OR week<=EXTRACT(WEEK FROM TIMESTAMP 'epoch' + "+stat_end+" * INTERVAL '1 second') AND year=EXTRACT(YEAR FROM TIMESTAMP 'epoch' + "+stat_end+" * INTERVAL '1 second')) "
	    //don't need an end, use everything until today
            +"GROUP BY year, week ORDER BY year, week;";
        q_weeks = q_weeks.replace("run_start>"+stat_begin+" AND run_start<"+stat_end+" XXX  AND", "");//select the weeks according to the weeks parameter and not accordint to the run_start timestamp
        q_weeks = q_weeks.replace("wg_no, COUNT(DISTINCT train_id)", "year, week, COUNT(DISTINCT train_id)");

        q_selected += "GROUP BY wg_no ORDER BY wg_no;";   



      //show the plot with the different time intervals on top of the statistics
      db.query(q_weeks);
//p.append("statistics_kind", "|"+q_weeks+"|");
      XYSeriesCollection xySeriesCollection = new XYSeriesCollection();
      XYSeriesCollection xySeriesCollection_number = new XYSeriesCollection();
      XYSeries series = new XYSeries("submitted to Masterjobs submitted");
      XYSeries series2 = new XYSeries("masterjobs submitted to final merge submitted");
      XYSeries series3 = new XYSeries("final merge submitted to done");

      XYSeries series_number = new XYSeries("number of trains");

      int weeks_count = db.count();

      while(db.moveNext()){
	  int week = db.geti("week");
	  //0 is always the beginning of the current year. For 3 years in the past go pack up to -156 weeks into the past
	  if(week + weeks_count>52)
	      week -= 53;//subtract 53 instead of 52 because the last week of the last year is -1 and the first week of this year is +1
	  while(week + weeks_count>52)
	      week -= 52;//subtract 52 for all years before the last year, because there is no week 0 in between for the counting now
	  weeks_count--;
	  
	  series.add(week, (double)db.getl("submit_masterSubmit_avg")/3600);
	  series2.add(week, (double)db.getl("firstFinMerge_avg")/3600);
	  series3.add(week, (double)db.getl("merge_finished_avg")/3600);

	  series_number.add(week, db.geti("number_train_runs"));
      }
      xySeriesCollection.addSeries(series);
      xySeriesCollection.addSeries(series2);
      xySeriesCollection.addSeries(series3);

      xySeriesCollection_number.addSeries(series_number);

    JFreeChart jfreechart = ChartFactory.createScatterPlot("","week", "average train duration (user time) [h]", xySeriesCollection, PlotOrientation.VERTICAL, true, true, false);

    XYPlot xyPlot = (XYPlot) jfreechart.getPlot();

    final NumberAxis axis2 = new NumberAxis("Number of train runs");
    axis2.setAutoRangeIncludesZero(false);
    xyPlot.setRangeAxis(1, axis2);
    xyPlot.setDataset(1, xySeriesCollection_number);
    xyPlot.mapDatasetToRangeAxis(1, 1);

    XYDotRenderer xydotrenderer_y = new XYDotRenderer();
    xydotrenderer_y.setDotHeight(15);
    xydotrenderer_y.setDotWidth(15);
    xydotrenderer_y.setBasePaint(Color.black);
    xydotrenderer_y.setSeriesPaint(0, Color.black);
    xyPlot.setRenderer(1, xydotrenderer_y);

    XYDotRenderer xydotrenderer = new XYDotRenderer();
    xydotrenderer.setDotHeight(10);
    xydotrenderer.setDotWidth(10);
    xydotrenderer.setSeriesPaint(2, Color.green.darker());
    xyPlot.setRenderer(0, xydotrenderer);
  
    xyPlot.setDomainCrosshairVisible(true);
    xyPlot.setRangeCrosshairVisible(true);
       
    ChartRenderingInfo info_time = new ChartRenderingInfo(new StandardEntityCollection());
    String sImage_time = org.jfree.chart.servlet.ServletUtilities.saveChartAsPNG(jfreechart, 700, 500, info_time, null);
    StringWriter sw_time = new StringWriter();
    PrintWriter pw_time = new PrintWriter(sw_time);
    
    ChartUtilities.writeImageMap(pw_time, sImage_time, info_time, true);
    
    p.modify("statistics_train_time", sImage_time);

    //save some statistics for a general overview statistic behind the modes statistics
    long[][] totalWall = new long[10][modes.length];
    int ind_totalWall = 0;

    for(int mode=0;mode<modes.length;mode++){
	if(mode!=0) p.comment("com_apply",false);//show the statistics plot only over the first table
	p.comment("com_normal", true);
	p.comment("com_table", true);
	p.append("statistics_kind",modes[mode]);

	//put the correct analyzed dataset into the query
	String ana_dataset = " AND analyzed_dataset in ("+aod_esd[mode]+") ";
	if(modes[mode].contains("MC"))
	    ana_dataset = " AND ((analyzed_dataset-256) in ("+aod_esd[mode]+") OR (analyzed_dataset-512) in ("+aod_esd[mode]+") OR (analyzed_dataset-768) in ("+aod_esd[mode]+")) ";
	else if(modes[mode].contains("all trains"))
	    ana_dataset = "";

	String q_all_mode = q_all.replace("XXX", ana_dataset);
	String q_selected_mode = q_selected.replace("XXX", ana_dataset);
	//p.append("statistics_kind", "|"+q_all_mode+"|");
	//i==1 is the sum of the wagons
	for(int i=0; i<2; i++){
	    if(i==1){
		q_selected_mode = q_selected_mode.replace("wg_no, ", "");
		q_selected_mode = q_selected_mode.replace("GROUP BY wg_no ORDER BY wg_no", "");
		q_all_mode = q_all_mode.replace("wg_no, ", "");
		q_all_mode = q_all_mode.replace("GROUP BY wg_no ORDER BY wg_no", "");

		//p.append("statistics_kind", "|"+q_selected_mode+"|");
	    }
	    db_selected.query(q_selected_mode);
	    db.query(q_all_mode);

	    while(db_selected.moveNext()){
		String wg_no = db_selected.gets("wg_no");
		//need the db with all the train runs to fill the number of train runs and jobs
		while(!wg_no.equals(db.gets("wg_no"))){
		    if(!db.moveNext())
			break;
		}

		final Page p2 = new Page(baos, "trains/train_statistics_overview_line.res", false);

		if(i==1){
		    p.append("Number_train","<tr><td align=center colspan=10>"+String.format("%190s", "-").replace(' ', '-')+"</td></tr>");
		    p2.append("wg_no", "sum");
		}
	    
		p2.fillFromDB(db);

		long totalWallTime = db.getl("total_wall_time");
		int wg_no_number = 1;
		//order number in alphabetical order of the PWG names
		if(wg_no.equals("CF")) wg_no_number = 0;
		else if(wg_no.equals("DQ")) wg_no_number = 1;
		else if(wg_no.equals("GA")) wg_no_number = 2;
		else if(wg_no.equals("HF")) wg_no_number = 3;
		else if(wg_no.equals("JE")) wg_no_number = 4;
		else if(wg_no.equals("LF")) wg_no_number = 5;
		else if(wg_no.equals("PP")) wg_no_number = 6;
		else if(wg_no.equals("UD")) wg_no_number = 7;
		else if(wg_no.equals("ZZ")) wg_no_number = 8;
		else wg_no_number = 9; //sum

		totalWall[wg_no_number][mode] = totalWallTime;

		//p2.append("total_wall", Format.toInterval((long)totalWallTime));
		//p2.append("avg_train_duration", Format.toInterval((long)(totalWallTime/db_selected.getl("number_train_runs"))));
		p2.append("total_wall", Format.toInterval((long)totalWallTime));
		long hasTotalWall = db.getl("has_total_wall");
		if(hasTotalWall==0) hasTotalWall=1;
		p2.append("avg_train_duration", Format.toInterval((long)(totalWallTime/hasTotalWall)));
		p2.append("avg_train_duration_real", Format.toInterval((long)db_selected.getl("runTime_avg")*1000L));
		p2.append("avg_time_submit_subMaster", Format.toInterval((long)db_selected.getl("submit_masterSubmit_avg")*1000L));
		p2.append("avg_time_subMaster_finMerge", Format.toInterval((long)db_selected.getl("firstFinMerge_avg")*1000L));	
		p2.append("avg_time_finMerge_done", Format.toInterval((long)db_selected.getl("merge_finished_avg")*1000L));
		
		p.append("Number_train", p2);
	    }
	}

	pMaster.append(p);
    }

    //last statistics which shows the percentage of AOD and ESD
    final Page p_end = new Page(baos, "trains/train_statistics_overview.res", false);
    p_end.modify("statistics_kind", "all trains");

    db.query("SELECT distinct wg_no FROM train_def ORDER BY wg_no;");
    int wg = 0;//saves the PWG number
    String pwg_name = "";
    if(db.moveNext())
	pwg_name = db.gets("wg_no");
    Boolean morePWG = true;
    while(morePWG){
	p_end.comment("com_normal", false);
	p_end.comment("com_apply",false);

	int esd_perc = (int)((100*(double)totalWall[wg][0]/totalWall[wg][4]+0.5));
	int aod_perc = (int)((100*(double)totalWall[wg][1]/totalWall[wg][4]+0.5));
	int esd_mc_perc = (int)((100*(double)totalWall[wg][2]/totalWall[wg][4]+0.5));
	int aod_mc_perc = (int)((100*(double)totalWall[wg][3]/totalWall[wg][4]+0.5));

	p_end.append("Number_train","<tr><td> "+pwg_name+" </td><td>"+Format.toInterval(totalWall[wg][4])+"</td><td>"+Format.toInterval(totalWall[wg][0])+"</td><td>"+esd_perc+"</td><td>"+Format.toInterval(totalWall[wg][1])+"</td><td>"+aod_perc+"</td><td>"+Format.toInterval(totalWall[wg][2])+"</td><td>"+esd_mc_perc+"</td><td>"+Format.toInterval(totalWall[wg][3])+"</td><td>"+aod_mc_perc+" </td></tr>");

	wg++;
	if(db.moveNext()){
	    pwg_name = db.gets("wg_no");
	}else{
	    if(pwg_name.equals("sum")){
		morePWG = false;
	    }else{
		pwg_name = "sum";
		p_end.append("Number_train","<tr><td align=center colspan=10>"+String.format("%190s", "-").replace(' ', '-')+"</td></tr>");
	    }
	}
    }
    pMaster.append(p_end);
    
   
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    %>