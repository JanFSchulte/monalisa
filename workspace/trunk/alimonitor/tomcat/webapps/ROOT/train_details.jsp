<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.Formatare,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils"%><%
    if (true){
	response.sendRedirect("/prod/");
	return;
    }

    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /train_details.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("title", "Analysis train details");
    
    Page p = new Page("train_details.res");
    
    Page pLine = new Page("train_details_el.res");
    
    DB db = new DB();

    String sStatus = request.getParameter("status") == null ? "" : request.getParameter("status");
    
    String sQuery = "SELECT jt_id, jt_type, jt_description, jt_field1, jt_field2, jt_field3, "+
		    "sum(totaljobs.cnt) AS total_jobs, "+
		    "sum(donejobs.cnt) AS done_jobs, "+
		    "case when jt_field2 in ('Completed', 'Technical stop') then null else sum(runningjobs.cnt) end AS running_jobs, "+
		    "case when jt_field2 in ('Completed', 'Technical stop') then null else sum(waitingjobs.cnt) end AS waiting_jobs, "+
		    "min(runno) AS minrun, max(runno) AS maxrun, "+
		    "job_stats.owner "+
		    "FROM job_types LEFT OUTER JOIN job_runs_details ON job_types_id=jt_id "+
		    "LEFT OUTER JOIN job_stats USING (pid) "+
		    "LEFT OUTER JOIN job_stats_details totaljobs ON totaljobs.pid=job_stats.pid AND totaljobs.state='TOTAL' "+
		    "LEFT OUTER JOIN job_stats_details donejobs ON donejobs.pid=job_stats.pid AND donejobs.state='DONE' "+
		    "LEFT OUTER JOIN job_stats_details runningjobs ON runningjobs.pid=job_stats.pid AND runningjobs.state='RUNNING' "+
		    "LEFT OUTER JOIN job_stats_details waitingjobs ON waitingjobs.pid=job_stats.pid AND waitingjobs.state='WAITING' "+
		    "WHERE jt_field4='TRAIN' AND (jt_field2='Scheduled' OR job_stats.owner IN ('aliprod', 'alitrain', 'alidaq'))";
		    
    if(sStatus.length() > 0){
	sQuery += " AND jt_field2='"+Formatare.mySQLEscape(sStatus)+"' ";
	p.modify("filter", "Status : "+sStatus);
    }
		    
    sQuery += " GROUP BY jt_id, jt_type, jt_description, jt_field1, jt_field2,jt_field3,owner " ;
    
    p.modify("filter", "No filter");
		    
    sQuery += " ORDER BY jt_id desc;"; // jt_field1 DESC, jt_id DESC
    
    //System.err.println(sQuery);
    
    db.query(sQuery);
    
    int iCnt = 0;
    
    while(db.moveNext()){
    
	if("Running".equals(db.gets("jt_field2")))
	    pLine.modify("bgcolor", "#54E715");

	String sType = db.gets("jt_field2");

	if("Pending".equals(sType) || sType.startsWith("Quality") || sType.startsWith("Macros") || sType.startsWith("Software") || sType.startsWith("Technical") )
	    pLine.modify("bgcolor", "yellow");
	else
	if("Completed".equals(sType))
	    pLine.modify("bgcolor", "#A1EBFF");
	else
	if ("Scheduled".equals(sType))
	    pLine.modify("bgcolor", "pink");
	    
        pLine.modify("bgcolor", "#FFFFFF");
	    
	pLine.modify("tr_bgcolor", iCnt % 2 == 0 ? "#FFFFFF" : "#F0F0F0");    
    
	pLine.modify("type", db.gets("jt_type"));    
	pLine.modify("description", db.gets("jt_description"));
	pLine.modify("field1", db.gets("jt_field1"));
	pLine.modify("field2", db.gets("jt_field2"));
	pLine.modify("field3", db.gets("jt_field3"));
	pLine.modify("cnt1", db.gets("noevents"));	
	pLine.modify("cnt2", db.gets("nojobs"));
	pLine.modify("run_min", db.gets("minrun"));
	pLine.modify("run_max", db.gets("maxrun"));
	pLine.modify("owner", db.gets("owner"));

	final int id = db.geti("jt_id");
	
	final String sBaseDir = "/home/monalisa/MLrepository/tomcat/webapps/ROOT/productions/train/train_"+db.gets("jt_field1");
	
	final File f = new File(sBaseDir);
	
	if (f.exists() && f.isDirectory()){
	    pLine.comment("com_files", true);
	}
	else{
	    pLine.comment("com_files", false);
	}
	
	final File fDownload = new File(sBaseDir+"_download");
	
	if (fDownload.exists() && fDownload.isDirectory()){
	    pLine.comment("com_download", true);
	}
	else{
	    pLine.comment("com_download", false);
	}

	pLine.fillFromDB(db);
	
	int iDone = db.geti("done_jobs");
	int iTotal = db.geti("total_jobs");
	
	if (iTotal > 0){
	    pLine.modify("success_rate", (iDone*100 / iTotal)+"%");
	}

	iCnt ++;
	
	p.append(pLine);
    }
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/train_details.jsp", baos.size(), request);
%>