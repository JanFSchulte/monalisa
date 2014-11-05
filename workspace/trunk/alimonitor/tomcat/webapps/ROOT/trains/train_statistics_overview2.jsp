<%@ page import="lia.web.servlets.web.display,lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*, alien.transfers.*,java.security.cert.*,auth.*, org.jfree.chart.plot.*, org.jfree.chart.renderer.xy.*, org.jfree.data.xy.*, org.jfree.chart.*, org.jfree.chart.entity.*, java.awt.Color, org.jfree.chart.axis.NumberAxis;" %><%!

      private static XYDataset[] getDataset(int stat_begin, Page p) {

      int stat_end = (int) (System.currentTimeMillis()/1000);

        XYSeriesCollection xySeriesCollection = new XYSeriesCollection();
        XYSeriesCollection xySeriesCollection_number = new XYSeriesCollection();
	XYSeries series = new XYSeries("submitted to Masterjobs submitted");
	XYSeries series2 = new XYSeries("masterjobs submitted to final merge submitted");
	XYSeries series3 = new XYSeries("final merge submitted to done");

	XYSeries series2_number = new XYSeries("number of trains");

	int number_week_in_year = stat_begin - 1356912000; //1356912000 is 31.12.2012 <- start of the first calendar week of 2013
	//31449600 is one day less than a year because need the correct start date of the calendar week
	//used definition: first thursday of the year is in the first calendar week
	int thursday = 3;
	int leap_year = 0;
        while(number_week_in_year>31449600){//subtract a year
	    thursday--;//next year the first thursday is one day earlier in the year
	    leap_year++;
	    number_week_in_year -= 31449600;
	    if(leap_year==4){
		leap_year = 0;
		number_week_in_year -= 24*3600;//subtract 29th of Februrary
		thursday --;
	    }
	    if(thursday<=0)
		number_week_in_year -= 7*24*3600;//the first kalendar week is one week later
	}

	int week_offset = number_week_in_year;
	
	number_week_in_year/=7*24*3600;//number_week can be negative at the end of the year and a bit more for 2012!
	week_offset -= number_week_in_year * 7*24*3600;
        number_week_in_year++; //this value gives now the number of the first week of the statistics, without the ++ it gives the number of the last week before
	stat_begin -= week_offset;//start with the beginning of the week

        final DB db = new DB("SELECT lpm_id, run_start, train_finished_timestamp, train_id, id from train_run WHERE run_start>"+stat_begin+" AND train_finished_timestamp<"+stat_end+" ORDER BY train_id, id;");

	int weeks = (stat_end - stat_begin)/(7*24*3600)+1;
	double[][] weeks_train_time = new double[2][weeks];//time from run_start to master jobs submitted
	double[][] weeks_train_time2 = new double[2][weeks];// time from master jobs submitted to final merge job submitted
	double[][] weeks_train_time3 = new double[2][weeks];// time from merge job submitted to merging finished
	for(int i=0; i<weeks_train_time[0].length; i++){
	    weeks_train_time[0][i] = 0;
	    weeks_train_time[1][i] = 0;
	    weeks_train_time2[0][i] = 0;
	    weeks_train_time2[1][i] = 0;
	    weeks_train_time3[0][i] = 0;
	    weeks_train_time3[1][i] = 0;
	}

	while(db.moveNext()){
	    boolean finalMergeSubmittedByHand = false;

	    final DB db2 = new DB("SELECT pid,lastseen FROM lpm_history INNER JOIN job_stats using(pid) WHERE chain_id="+db.geti("lpm_id")+" LIMIT 1;");
	    int samplepid = db2.geti("pid");
	    db2.query("SELECT jobtype,outputdir FROM job_runs_details WHERE pid="+samplepid+";");
	    final String stage5JobType = db2.gets(1)+"_Stage5_FinalMerging";
	    String outputDir = db2.gets(2);
	    int idxOfStage5 = outputDir.indexOf(db2.gets(1));
	    if (idxOfStage5<0){
		//could not find correct masterjobs so skipped this train run
		continue;
	    }
	    outputDir = "%/"+outputDir.substring(idxOfStage5);
	    db2.query("SELECT jt_id FROM job_types WHERE jt_field1='"+Format.escSQL(stage5JobType)+"';");
	    final int stage5JobTypeId = db2.geti(1);
	    db2.query("SELECT sum(cnt) FROM job_runs_details inner join job_stats_details using(pid) WHERE job_types_id="+stage5JobTypeId+" AND outputdir like '"+Format.escSQL(outputDir)+"' and state like 'DONE%';");
	    int stage5_jobs = db2.geti(1);

	    db2.query("SELECT * FROM lpm_chain WHERE id="+db.geti("lpm_id"));
	    int number_masterjobs_submitted = db2.geti("submitcount");

	    if(stage5_jobs<number_masterjobs_submitted){
		finalMergeSubmittedByHand = true;
	    }

	    db2.query("select max(firstseen) as masterJobSubmitted from job_stats natural join lpm_history where chain_id = "+db.geti("lpm_id")+";");
	    int this_week = (db.geti("run_start") - stat_begin)/(7*24*3600);
	    int masterJobSubmitted = db2.geti("masterJobSubmitted");

	    db2.query("SELECT final_merge_job_id from train_run_final_merge where train_id="+db.geti("train_id")+" AND id = "+db.geti("id")+" AND final_merge_finish_timestamp > 0;");
	    int firstFinMerge = 0;
	    while(db2.moveNext()){
		DB db3 = new DB("SELECT firstseen from job_stats where pid="+db2.geti("final_merge_job_id")+";");
		if(firstFinMerge==0 || db3.geti("firstseen")<firstFinMerge) firstFinMerge = db3.geti("firstseen");
	    }

	    if(this_week>=weeks) continue;

	    //do only sum up the times connected to the final merge submit if this was done automatically
	    if(finalMergeSubmittedByHand)
		continue;

	    int tmp = masterJobSubmitted - db.geti("run_start");
	    if(tmp>0 && db.geti("run_start")>0){
		weeks_train_time[0][this_week] += tmp;
		weeks_train_time[1][this_week]++;
	    }

	    tmp = firstFinMerge - masterJobSubmitted;
	    if(tmp>0 && masterJobSubmitted>0){
		weeks_train_time2[0][this_week] += tmp;
		weeks_train_time2[1][this_week]++;
	    }
	    tmp = db.geti("train_finished_timestamp") - firstFinMerge;
	    if(tmp>0 && firstFinMerge>0){
		weeks_train_time3[0][this_week] += tmp;
		weeks_train_time3[1][this_week]++;
	    }
	}


	for(int i=0; i<weeks_train_time[0].length; i++){
	    if(weeks_train_time[1][i]>0){
		weeks_train_time[0][i] /= weeks_train_time[1][i]*3600;
		series.add(number_week_in_year+i, weeks_train_time[0][i]);
	    }
	    if(weeks_train_time2[1][i]>0){
		weeks_train_time2[0][i] /= weeks_train_time2[1][i]*3600;
		series2.add(number_week_in_year+i, weeks_train_time2[0][i]);
		series2_number.add(number_week_in_year+i, weeks_train_time2[1][i]);
	    }
	    if(weeks_train_time3[1][i]>0){
		weeks_train_time3[0][i] /= weeks_train_time3[1][i]*3600;
		series3.add(number_week_in_year+i, weeks_train_time3[0][i]);
	    }
	}

	xySeriesCollection.addSeries(series);
	xySeriesCollection.addSeries(series2);
	xySeriesCollection.addSeries(series3);

	xySeriesCollection_number.addSeries(series2_number);

	XYSeriesCollection[] returnCollection = new XYSeriesCollection[2];
	returnCollection[0] = xySeriesCollection;
	returnCollection[1] = xySeriesCollection_number;

	return returnCollection;
      }
   
    %><%
    response.setHeader("Connection", "keep-alive");
    
    lia.web.servlets.web.Utils.logRequest("START /trains/train_statistics_overview2.jsp", 0, request);
    
    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
            
    final DB db = new DB();
    
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
    String[] aod_esd = new String[]{"0,4,5,6","1,2","0,4,5,6","1,2,3","0,1,2,3,4,5,6"};
    String[] times = new String[]{"last week", "last month", "2 months", "3 months", "6 months", "1 year"};//written time intervalls
    long[] times_intervall = new long[]{604800, 2592000, 5184000, 7776000, 15768000, 31536000};//correspondent seconds

    
    final Page p = new Page(baos, "trains/train_statistics_overview2.res", false);

    p.comment("com_apply",true);

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
//stat_begin=1367366400;
//stat_begin=1370044800;
//stat_begin=1376092800;
    p.append("statistics_start", stat_begin);
    
    int stat_end = (int) (System.currentTimeMillis()/1000 - offset);
//stat_end=1370044800;
//stat_end=1372636800;
//stat_end=1378771200;
    p.append("statistics_end", stat_end);

    XYDataset[] datasets = getDataset(stat_begin, p);

    JFreeChart jfreechart = ChartFactory.createScatterPlot("","week", "average train duration (user time) [h]", datasets[0], PlotOrientation.VERTICAL, true, true, false);

    XYPlot xyPlot = (XYPlot) jfreechart.getPlot();

    final NumberAxis axis2 = new NumberAxis("Number of train runs");
    axis2.setAutoRangeIncludesZero(false);
    xyPlot.setRangeAxis(1, axis2);
    xyPlot.setDataset(1, datasets[1]);
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
	if(mode!=0) p.comment("com_apply",false);
	p.comment("com_normal", true);
	p.append("statistics_kind",modes[mode]);

	db.query("SELECT distinct wg_no FROM train_def ORDER BY wg_no;");
	String wg_no = "CF";
	ind_totalWall = 0;

	//sum over all working groups
	int sum_count = 0;
	double sum_total_wall = 0;
	int sum_count_runs = 0;
	int sum_count_runs_merged = 0;
	int sum_count_auto_merged = 0;
	int sum_jobs = 0;
	double sum_total_wall_real = 0;
	//	long sum_wall_time_with_merge = 0;

	double sum_time_submit_subMaster = 0;
	double sum_time_subMaster_finMerge = 0;
	double sum_time_finMerge_done = 0;

	while(db.moveNext()){
	    wg_no = db.gets("wg_no");
	    DB db2 = new DB();

	    int count = 0;//counts the trains in this PWG
	    int last_train_id = 0;//variable which helps to count the trains
	    db2.query("SELECT * from train_run natural join train_def natural join train_run_statistics natural join train_run_period natural join train_period WHERE wg_no='"+wg_no+"' AND aod in ("+aod_esd[mode]+") and run_start>"+stat_begin+" AND train_finished_timestamp<"+stat_end+" ORDER BY train_id, id;");
	    
	    double total_wall = 0;
	    int count_runs = 0;
	    int count_runs_merged = 0;
	    int count_auto_merged = 0;
	    int jobs = 0;
	    double total_wall_real = 0;

	    double time_submit_subMaster = 0;
	    double time_subMaster_finMerge = 0;
	    double time_finMerge_done = 0;
	    
	    while(db2.moveNext()){
		//used for getting statistics only for this one dataset
		//if(!db2.gets("period_name").equals("LHC10d_AOD0135"))
		//continue;

		//do only analyze this train if this is a MC train and statistic is for a MC train or if both isn't for MC
		if(!modes[mode].equals("all trains") && (db2.gets("train_name").contains("_MC")^modes[mode].contains("MC"))) continue;
		if(db2.geti("train_id")!=last_train_id){
		    last_train_id=db2.geti("train_id");
		    count++;
		}
		
		jobs += db2.geti("jobs");
		//count jobs of the error states, but count the other statistics only once per train run
		if(!db2.gets("state").equals("DONE")) continue;
		count_runs++;

		DB db3 = new DB("select pid, wall_time, owner from lpm_history natural join job_stats where chain_id ="+db2.geti("lpm_id")+";");
		
		while(db3.moveNext()){
		    DB db4 = new DB();
		    int new_pid = db3.geti("pid");
		    if(db3.gets("owner").equals("alitrain")){//just check again, should already be the case
			total_wall += db3.getd("wall_time")*3600*1000;
		    }
		    while(new_pid>0){
			db4.query("SELECT lpm_history.pid, wall_time, parentpid, owner from lpm_history left join job_stats ON lpm_history.pid=job_stats.pid where lpm_history.parentpid="+new_pid+";");
			new_pid = db4.geti("pid");
			if(db4.gets("owner").equals("alitrain")){//just check again, should already be the case
			    total_wall += db4.getd("wall_time")*3600*1000;
			}
		    }
		}
		//final merging time
		db3.query("SELECT final_merge_job_id from train_run_final_merge where train_id="+last_train_id+" AND id = "+db2.geti("id")+" AND final_merge_finish_timestamp > 0;");
		double firstFinMerge = 0;
		while(db3.moveNext()){
		    DB db4 = new DB("SELECT firstseen from job_stats where pid="+db3.geti("final_merge_job_id")+";");
		    if(firstFinMerge==0 || db4.geti("firstseen")<firstFinMerge) firstFinMerge = db4.geti("firstseen");
		    int new_pid = db3.geti("final_merge_job_id");
		    while(new_pid>0){
			db4.query("SELECT lpm_history.pid, wall_time, parentpid, owner from lpm_history left join job_stats ON lpm_history.pid=job_stats.pid where lpm_history.parentpid="+new_pid+";");
			new_pid = db4.geti("pid");
			if(db4.gets("owner").equals("alitrain")){//just check again, should already be the case
			    total_wall += db4.getd("wall_time")*3600*1000;
			}
		    }
		}
		
		
		//find out if this train run was submitted to the final merge by hand or automatically
		boolean finalMergeSubmittedByHand = false;

		db3.query("SELECT pid,lastseen FROM lpm_history INNER JOIN job_stats using(pid) WHERE chain_id="+db2.geti("lpm_id")+" LIMIT 1;");
		int samplepid = db3.geti("pid");
		db3.query("SELECT jobtype,outputdir FROM job_runs_details WHERE pid="+samplepid+";");
		final String stage5JobType = db3.gets(1)+"_Stage5_FinalMerging";
		String outputDir = db3.gets(2);
		int idxOfStage5 = outputDir.indexOf(db3.gets(1));
		if (idxOfStage5<0){
		    //could not find correct masterjobs so skipped this train run
		    finalMergeSubmittedByHand = true;
		}
		else{
		    outputDir = "%/"+outputDir.substring(idxOfStage5);
		    db3.query("SELECT jt_id FROM job_types WHERE jt_field1='"+Format.escSQL(stage5JobType)+"';");
		    final int stage5JobTypeId = db3.geti(1);
		    db3.query("SELECT sum(cnt) FROM job_runs_details inner join job_stats_details using(pid) WHERE job_types_id="+stage5JobTypeId+" AND outputdir like '"+Format.escSQL(outputDir)+"' and state like 'DONE%';");
		    int stage5_jobs = db3.geti(1);
		    
		    db3.query("SELECT * FROM lpm_chain WHERE id="+db2.geti("lpm_id"));
		    int number_masterjobs_submitted = db3.geti("submitcount");
		    
		    if(stage5_jobs<number_masterjobs_submitted){
			finalMergeSubmittedByHand = true;
		    }
		}
		
		//job was submitted from hand to the final merging
		if(finalMergeSubmittedByHand)
		    continue;

		db3.query("select max(firstseen) as masterJobSubmitted from job_stats natural join lpm_history where chain_id = "+db2.geti("lpm_id")+";");

		if (db2.geti("train_finished_timestamp") > db2.geti("run_start")){
		    count_runs_merged++;
		    total_wall_real += (db2.geti("train_finished_timestamp") - db2.geti("run_start"))*1000L;
		    double tmp = db3.geti("masterJobSubmitted") - db2.geti("run_start");
		    if(tmp>0 && db2.geti("run_start")>0){
			time_submit_subMaster += tmp;
		    }

		    count_auto_merged++;
		    tmp = firstFinMerge - db3.geti("masterJobSubmitted");
		    if(tmp>0 && db3.geti("masterJobSubmitted")>0)
			time_subMaster_finMerge += tmp;
		    tmp = db2.geti("train_finished_timestamp") - firstFinMerge;
		    if(tmp>0 && firstFinMerge>0)
			time_finMerge_done += tmp;
		}
		
	    }
	    
	    double avg_train_duration = 0;
	    double avg_train_duration_real = 0;
	    double avg_time_submit_subMaster = 0;
	    double avg_time_subMaster_finMerge = 0;
	    double avg_time_finMerge_done = 0;
	    if(count_runs!=0){
		avg_train_duration = total_wall/count_runs;
	    }
	    if (count_runs_merged!=0){
		avg_train_duration_real = total_wall_real/count_runs_merged;
		avg_time_submit_subMaster = time_submit_subMaster/count_runs_merged;
	    }
	    if(count_auto_merged!=0){
		avg_time_subMaster_finMerge = time_subMaster_finMerge/count_auto_merged;
		avg_time_finMerge_done = time_finMerge_done/count_auto_merged;
	    }

	    /*
	    //get complete wall time inclusive the merging time
	    db2.query("SELECT wall_time, train_name, train_id, id, parentpid, lpm_history.pid, owner from train_run natural join train_def natural join train_run_period natural join train_period left join lpm_history ON train_run.lpm_id=lpm_history.chain_id left join job_stats on lpm_history.pid=job_stats.pid WHERE wg_no='"+wg_no+"' AND aod in ("+aod_esd[mode]+") and run_end>"+stat_begin+" AND run_end<"+stat_end+" order by train_id;");
	    double wall_time_with_merge = 0;//db2.getl("wall_time_with_merge");
	    
	    while(db2.moveNext()){
		//do only analyze this train if this is a MC train and statistic is for a MC train or if both isn't for MC
		if(!modes[mode].equals("all trains") && (db2.gets("train_name").contains("_MC")^modes[mode].contains("MC"))) continue;

		if(db2.gets("owner").equals("alitrain")){//just check again, should already be the case
		    wall_time_with_merge += db2.getd("wall_time");
		}
		//do also add the wall_time of the child jobs		
		DB db3 = new DB();
		int new_pid = db2.geti("pid");
		while(new_pid>0){
		    db3.query("SELECT lpm_history.pid, wall_time, parentpid, owner from lpm_history left join job_stats ON lpm_history.pid=job_stats.pid where lpm_history.parentpid="+new_pid+";");
		    new_pid = db3.geti("pid");
		    if(db3.gets("owner").equals("alitrain")){//just check again, should already be the case
			wall_time_with_merge += db3.getd("wall_time");
		    }
		}
	    }

	    //add run time of final merge jobs
	    db2.query("select train_run_final_merge.final_merge_job_id, wall_time, owner from train_def natural join train_run natural join train_run_final_merge left join job_stats on train_run_final_merge.final_merge_job_id=job_stats.pid where wg_no='"+wg_no+"' AND run_end>"+stat_begin+" AND run_end<"+stat_end+";");
	    while(db2.moveNext()){
		//do only analyze this train if this is a MC train and statistic is for a MC train or if both isn't for MC
		if(!modes[mode].equals("all trains") && (db2.gets("train_name").contains("_MC")^modes[mode].contains("MC"))) continue;
	

		if(db2.gets("owner").equals("alitrain")){//just check again, should already be the case
		    wall_time_with_merge += db2.getd("wall_time");
		}
		DB db3 = new DB();
		int new_pid = db2.geti("final_merge_job_id");
		while(new_pid>0){
		    db3.query("SELECT lpm_history.pid, wall_time, parentpid, owner from lpm_history left join job_stats ON lpm_history.pid=job_stats.pid where lpm_history.parentpid="+new_pid+";");
		    new_pid = db3.geti("pid");
		    if(db3.gets("owner").equals("alitrain")){//just check again, should already be the case
			wall_time_with_merge += db3.getd("wall_time");
		    }
		}
	    }
	
	    wall_time_with_merge*=3600*1000;
	    */

	    //total wall is computed out of the information in train_run (which comes at the end aus job_stats_details), while wall_time_with_merge is computed out of the time in job_stats, wall_time_with_merge is exactly the same time as the time showed on ML
	    p.append("Number_train","<tr><td>"+wg_no+"</td><td>"+count+"</td><td>"+Format.toInterval((long)total_wall)+"</td><td>"+count_runs+"</td><td>"+jobs+"</td><td>"+Format.toInterval((long)avg_train_duration)+"</td><td>"+Format.toInterval((long)avg_train_duration_real)+"</td><td>"+Format.toInterval((long)avg_time_submit_subMaster*1000L)+"</td><td>"+Format.toInterval((long)avg_time_subMaster_finMerge*1000L)+"</td><td>"+Format.toInterval((long)avg_time_finMerge_done*1000L)+"</td></tr>");
	    totalWall[ind_totalWall++][mode] = (long)total_wall;
	
	    sum_count += count;
	    sum_total_wall += total_wall;//was used for the average running time, now this is done with sum_wall_time_with_merge
	    sum_count_runs += count_runs;
	    sum_count_runs_merged += count_runs_merged;
	    sum_count_auto_merged += count_auto_merged;
	    sum_jobs += jobs;
	    sum_total_wall_real += total_wall_real;
	    //sum_wall_time_with_merge += wall_time_with_merge;
	    sum_time_submit_subMaster += time_submit_subMaster;
	    sum_time_subMaster_finMerge += time_subMaster_finMerge;
	    sum_time_finMerge_done += time_finMerge_done;
	}
	//sum over all working groups
	double sum_avg_train_duration = 0;
	double sum_avg_train_duration_real = 0;
	if(sum_count_runs!=0)
	    sum_avg_train_duration = sum_total_wall/sum_count_runs;
	if (sum_count_runs_merged!=0){
	    sum_avg_train_duration_real = sum_total_wall_real/sum_count_runs_merged;
	    sum_time_submit_subMaster /= sum_count_runs_merged;
	}
	if (sum_count_auto_merged!=0){
	    sum_time_subMaster_finMerge /= sum_count_auto_merged;
	    sum_time_finMerge_done /= sum_count_auto_merged;
	}
	//add  style='font-size:1.8em'  to <tr> to get a bigger font
	p.append("Number_train","<tr><td align=center colspan=10>"+String.format("%130s", "-").replace(' ', '-')+"</td></tr>");
	p.append("Number_train","<tr><td> sum </td><td>"+sum_count+"</td><td>"+Format.toInterval((long)sum_total_wall)+"</td><td>"+sum_count_runs+"</td><td>"+sum_jobs+"</td><td>"+Format.toInterval((long)sum_avg_train_duration)+"</td><td>"+Format.toInterval((long)sum_avg_train_duration_real)+"</td><td>"+Format.toInterval((long)sum_time_submit_subMaster*1000L)+"</td><td>"+Format.toInterval((long)sum_time_subMaster_finMerge*1000L)+"</td><td>"+Format.toInterval((long)sum_time_finMerge_done*1000L)+"</td></tr>");
	totalWall[9][mode] = (long)sum_total_wall;//fill the last position in the first array because this is the sum and not a wg_no
    
	/*
	// this computes the running time of all jobs in the statistics time. The Problem is, that these are only parts of the trains at the beginning and ending of the statistic time
	if(modes[mode].equals("all trains")){
	    DB db2 = new DB("select sum(wall_time) from job_stats where lastseen>="+stat_begin+" and lastseen<="+stat_end+" and owner='alitrain';");
	    p.append("Number_train","<tr><td> with merge</td><td></td><td></td><td></td><td></td><td></td><td></td><td>"+Format.toInterval(db2.getl(1)*3600*1000)+" </td></tr>");
	}
	*/
	pMaster.append(p);
    }


    final Page p_end = new Page(baos, "trains/train_statistics_overview2.res", false);
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