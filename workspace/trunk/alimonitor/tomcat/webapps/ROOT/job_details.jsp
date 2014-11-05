<%@ page import="alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.Formatare,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils"%><%
    lia.web.servlets.web.Utils.logRequest("START /job_details.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("title", "Job details");
    
    Page p = new Page("job_details.res", false);
    
    Page pLine = new Page("job_details_el.res", false);
    
    DB db = new DB();

    String sStatus = request.getParameter("status") == null ? "" : request.getParameter("status");
    
    String sQuery = "SELECT x.*, p_reqev FROM (SELECT jt_id, jt_type, jt_description, jt_field1, jt_field2, jt_field3, jt_known_issues, "+
		    "sum(events) AS noevents, "+
		    "sum(mc_generated) AS mc_generated,"+
		    "sum(train_output) AS train_output,"+
		    "min(runno) AS minrun, max(runno) AS maxrun, sum(wall_time) as wall_time, sum(saving_time) as saving_time, sum(outputsize) as outputsize "+
		    "FROM job_types LEFT OUTER JOIN job_runs_details ON jt_id=job_types_id "+
		    "LEFT OUTER JOIN job_stats USING (pid) LEFT OUTER JOIN job_events USING (pid) WHERE jt_field4='MC' AND job_stats.owner='aliprod' ";
		    
    if(sStatus.length() > 0){
	sQuery += " AND jt_field2='"+Formatare.mySQLEscape(sStatus)+"' ";
	p.modify("filter", "Status : "+sStatus);
    }
		    
    sQuery += " GROUP BY jt_id, jt_type, jt_description, jt_field1, jt_field2,jt_field3,jt_known_issues " ;
    
    p.modify("filter", "No filter");
		    
    sQuery += ") x LEFT OUTER JOIN pwg ON jt_field1=p_tag ORDER BY jt_id desc;"; // jt_field1 DESC, jt_id DESC
    
    //System.err.println(sQuery);
    
    db.query(sQuery);
    
    int iCnt = 0;
    
    double dWallTime = 0;
    double dSavingTime = 0;
    long lOutputSize = 0;
        
    while(db.moveNext()){
    
	if("Running".equals(db.gets("jt_field2")))
	    pLine.modify("bgcolor", "#54E715");

	String sType = db.gets("jt_field2");

	if("Pending".equals(sType) || sType.startsWith("Quality") || sType.startsWith("Macros") || sType.startsWith("Software") || sType.startsWith("Technical") )
	    pLine.modify("bgcolor", "yellow");

	if("Completed".equals(db.gets("jt_field2")))
	    pLine.modify("bgcolor", "#A1EBFF");

	dWallTime += db.getd("wall_time");
	dSavingTime += db.getd("saving_time");
	
	lOutputSize += db.getl("outputsize");
	    
        pLine.modify("bgcolor", "#FFFFFF");
	    
	pLine.modify("tr_bgcolor", iCnt % 2 == 0 ? "#FFFFFF" : "#F0F0F0");    
    
	int iEv = db.geti("noevents");
	
	if (iEv <= 0)
	    iEv = db.geti("mc_generated");
	
	if (iEv <= 0)
	    iEv = db.geti("train_output");
    
	pLine.modify("type", db.gets("jt_type"));    
	pLine.modify("description", db.gets("jt_description"));
	pLine.modify("field1", db.gets("jt_field1"));
	pLine.modify("field2", db.gets("jt_field2"));
	pLine.modify("field3", db.gets("jt_field3"));
	pLine.modify("known_issues", db.gets("jt_known_issues"));
	pLine.modify("cnt1", iEv);
	pLine.modify("cnt2", db.gets("p_reqev"));
	pLine.modify("run_min", db.gets("minrun"));
	pLine.modify("run_max", db.gets("maxrun"));
	pLine.modify("wall_time", db.getd("wall_time"));
	pLine.modify("saving_time", db.getd("saving_time"));
	pLine.modify("outputsize", db.getl("outputsize"));

	int id = db.geti("jt_id");
	
	File f = new File("/home/monalisa/MLrepository/tomcat/webapps/ROOT/productions/"+id);
	
	if (f.exists() && f.isDirectory()){
	    pLine.modify("jt_id", id);
	    pLine.comment("com_files", true);
	}
	else{
	    pLine.comment("com_files", false);
	}
	
	iCnt ++;
	
	p.append(pLine);
    }

    p.modify("wall_time", dWallTime);
    p.modify("saving_time", dSavingTime);
    p.modify("outputsize", lOutputSize);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/job_details.jsp", baos.size(), request);
%>