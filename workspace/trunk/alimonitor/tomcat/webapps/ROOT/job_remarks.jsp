<%@ page import="alimonitor.*,java.util.*,java.io.*,javax.servlet.http.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lia.web.utils.Formatare,java.security.cert.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /job_remarks.jsp", 0, request);

    response.setHeader("Connection", "keep-alive");

    session.setAttribute("user_authenticated", "true");
    
    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

    	if (cert!=null && cert.length>0){
	    String sDN = cert[0].getSubjectDN().getName();
	    
	    auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);

	    session.setAttribute("user_account", principal.getName());
	}
    }

    if (request.getParameter("deljob")!=null){
	try{
	    final DB db = new DB();
	    
	    final int pid = Integer.parseInt(request.getParameter("deljob"));
	    
	    db.query("INSERT INTO job_runs_delete (path) VALUES ((select outputdir from job_runs_details where pid="+pid+"));", true);
	    
	    db.query("DELETE FROM job_runs_details WHERE pid="+pid+";");
	}
	catch (Exception e){
	}
    }
    
    final String[] vsBulkDel = request.getParameterValues("bulk_del");
    
    if (vsBulkDel!=null && vsBulkDel.length>0){
	final DB db = new DB();
	
	db.query("VACUUM job_runs_details;");
    
	for (int i=0; i<vsBulkDel.length; i++){
	    try{
		final int pid = Integer.parseInt(vsBulkDel[i]);
		
		db.query("INSERT INTO job_runs_delete (path) VALUES ((select outputdir from job_runs_details where pid="+pid+"));", true);
		
		db.query("DELETE FROM job_runs_details WHERE pid="+pid+";");
	    }
	    catch (Exception e){
	    }
	}
    }
    
    if (request.getParameter("edit_job")!=null){
	int runno = -1;
    
	try{
	    runno = Integer.parseInt(request.getParameter("runno"));
	}
	catch (Exception e){};
	
	String owner = request.getParameter("owner");
	
	int events = -1;
	
	try{
	    events = Integer.parseInt(request.getParameter("events"));
	}
	catch (Exception e){};
	
	int pid = -1;
	
	try{
	    pid = Integer.parseInt(request.getParameter("pid"));
	}
	catch (Exception e){};
	
	String app_root = request.getParameter("app_root");
	String app_aliroot = request.getParameter("app_aliroot");
	String app_geant = request.getParameter("app_geant");
	
	String date = request.getParameter("date");
	
	String outputdir = request.getParameter("outputdir");
	String jobtype = request.getParameter("jobtype");
	
	if (pid>0){
	    DB db = new DB();
	    db.syncUpdateQuery(
		"UPDATE job_runs_details SET "+
		    "runno="+runno+","+
	    	    "events="+events+","+
		    "app_root='"+Formatare.mySQLEscape(app_root)+"',"+
		    "app_aliroot='"+Formatare.mySQLEscape(app_aliroot)+"',"+
		    "app_geant='"+Formatare.mySQLEscape(app_geant)+"',"+
		    "outputdir='"+Formatare.mySQLEscape(outputdir)+"',"+
		    "jobtype='"+Formatare.mySQLEscape(jobtype)+"'"+
		" WHERE pid="+pid+";"
	    );
	    
	    final SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");
	    
	    try{
		Date d = sdf.parse(request.getParameter("date"));
		
		db.query("UPDATE job_stats SET firstseen="+d.getTime()/1000+" WHERE pid="+pid+";");
	    }
	    catch (Exception e){
		//System.err.println("ERROR PARSING DATE : "+e+" ("+e.getMessage()+")");
	    }
	}
    }
    
    if (request.getParameter("returnpath")!=null){
	response.sendRedirect(request.getParameter("returnpath"));
	return;
    }

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page p = new Page(baos, "job_remarks.res");
    Page pLine = new Page("job_remarks_line.res");
    
    try{
	int delid = Integer.parseInt(request.getParameter("delete"));
	
	if (delid > 0)
	    new DB("DELETE FROM job_runs_remarks WHERE id="+delid+";");
    }
    catch (Exception e){
    }
    
    if (request.getParameter("submit")!=null){
	String runint=request.getParameter("runint");
	String remark=request.getParameter("remark");
	
	if (runint!=null && remark!=null && runint.length()>0 && remark.length()>0)
	    new DB("INSERT INTO job_runs_remarks (runint, remark) VALUES ('"+Formatare.mySQLEscape(runint)+"', '"+Formatare.mySQLEscape(remark)+"');");
    }
    
    DB db = new DB("SELECT * FROM job_runs_remarks ORDER BY id DESC;");
    
    while (db.moveNext()){
	pLine.modify("runint", db.gets("runint"));
	pLine.modify("remark", db.gets("remark"));
	pLine.modify("id", db.gets("id"));
	
	p.append(pLine);
    }
    
    p.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/job_remarks.jsp", baos.size(), request);
%>
