<%@ page import="alien.taskQueue.*,lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*,java.util.regex.*,alien.catalogue.*"%><%!
    private static String getColor(final Job j){
	if (j==null)
	    return "black";
	
	if (j.isDone())
	    return "green";
	
	if (j.isError())
	    return "red";
	
	if (j.isActive())
	    return "blue";
	
	return "black";
    }
%><html>
<head>
<style type="text/css">
A { text-decoration: none; }
A:hover { text-decoration: underline; }
</style>
<script type="text/javascript" src="/overlib/overlib.js"></script>
<script type="text/javascript" src="/overlib/overlib_crossframe.js"></script>
<script type="text/javascript" src="/js/tooltips.js"></script>
<%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /jobs/jdl.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();
    
    final int pid = rw.geti("pid");

    String title = "";
    String htmltitle = "";
    String text = "";

    try{
	JDL j = new JDL(Job.sanitizeJDL(TaskQueueUtils.getJDL(pid, rw.getb("original", true))));
	//new JDL(pid);
    
	text = utils.CatalogueHighlight.highlight(j.toHTML(), pid, j.getUser());
	
	Job job = TaskQueueUtils.getJob(pid);

	Integer masterjobid = j.getInteger("MasterJobID");
	
	if (masterjobid==null){
	    htmltitle = "JDL of masterjob <a target=_blank href='details.jsp?pid="+pid+"' onMouseOver='jobDetails("+pid+");' onMouseOut='nd()' title='"+job.getStatusName()+"'><font color="+getColor(job)+">"+pid+"</font></a>";
	    title = "JDL of masterjob "+pid;
	}
	else{
	    Job master = TaskQueueUtils.getJob(masterjobid.intValue());
	
	    htmltitle = "JDL of subjob <a target=_blank href='details.jsp?pid="+pid+"' title='"+job.getStatusName()+"'><font color="+getColor(job)+">"+pid+"</font></a>, masterjob <a target=_blank title='"+master.getStatusName()+"' href='details.jsp?pid="+masterjobid+"' onMouseOver='jobDetails("+masterjobid+");' onMouseOut='nd()'><font color="+getColor(master)+">"+masterjobid+"</font></a>";
	    title = "JDL of subjob "+pid+", masterjob "+masterjobid;
	}
    }
    catch (Exception e){
	// ignore
    }
%>
<title><%=title%></title>
</head>
<body>
<span style="font-family:Verdana;font-size:12px">
<div align=center style='font-family:Verdana;font-size:14px'><b><%=htmltitle%></b></div><br>
<%=text%>
</span>
</body>
</html>
<%
    lia.web.servlets.web.Utils.logRequest("/jobs/jdl.jsp?pid="+pid, 0, request);
%>
