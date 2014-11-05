<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.monitor.AppConfig,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*,java.util.regex.*,java.text.SimpleDateFormat,alien.taskQueue.*"%><%!
    private static final Pattern p = Pattern.compile("^(\\d{10,13})\\s+.*");
    
    //private static final Pattern splitter = Pattern.compile("((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dev) ([0-3]?)[0-9] ([0-2]?)[0-9]:[0-5][0-9]:[0-5][0-9] (info|error|warn|notice|debug))");
    private static final Pattern splitter = Pattern.compile("((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dev)\\s+([0-3]?)[0-9] ([0-2]?)[0-9]:[0-5][0-9]:[0-5][0-9]\\s*(info|error|warn|notice|debug))");
    
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

%><%
//    out.println(org.apache.jsp.work.updateEvents_jsp.p);
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /jobs/trace.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();
    
    final int pid = rw.geti("pid");

    final Job job = TaskQueueUtils.getJob(pid);
    
    final String htmltitle;
    final String title;

    if (job==null || job.split<0){
        htmltitle = "Trace of job <a target=_blank href='details.jsp?pid="+pid+"' onMouseOver='jobDetails("+pid+");' onMouseOut='nd()' title='"+(job!=null ? job.getStatusName() : "")+"'><font color="+getColor(job)+">"+pid+"</font></a>";
        title = "Trace of job "+pid;
    }
    else{
        Job master = TaskQueueUtils.getJob(job.split);
	
	if (job.split<=0){
	    htmltitle = "Trace of job <a target=_blank href='details.jsp?pid="+pid+"' title='"+job.getStatusName()+"'><font color="+getColor(job)+">"+pid+"</font></a>";
    	    title = "Trace of job "+pid;
    	}
    	else{
    	    htmltitle = "Trace of subjob <a target=_blank href='details.jsp?pid="+pid+"' title='"+job.getStatusName()+"'><font color="+getColor(job)+">"+pid+"</font></a>, masterjob <a target=_blank title='"+(master!=null ? master.getStatusName() : "")+"' href='details.jsp?pid="+job.split+"' onMouseOver='jobDetails("+job.split+");' onMouseOut='nd()'><font color="+getColor(master)+">"+job.split+"</font></a>";
    	    title = "Trace of subjob "+pid+", masterjob "+job.split;
    	}
    }
%>
<html>
<head>
<title><%=title%></title>
<style type="text/css">
A { text-decoration: none; }
A:hover { text-decoration: underline; }
</style>
</head>
<body>
<span style="font-family:Verdana;font-size:12px">
<div align=center style='font-family:Verdana;font-size:14px'><b><%=htmltitle%></b></div><br>
<%
    final List<String> sortedTrace = alien.jobs.Trace.getSortedTrace(pid);

    if (sortedTrace==null){
        out.println("The trace log for pid "+pid+" is not available");
        return;
    }

    final SimpleDateFormat sdf = new SimpleDateFormat("MMM dd HH:mm:ss");

    for (String sLine: sortedTrace){
	Matcher m = p.matcher(sLine);
	
	if (m.matches()){
	    final long timestamp = Long.parseLong(m.group(1));
	    
	    final Date d = new Date(timestamp*1000);
	    
	    sLine = sdf.format(d) + sLine.substring(sLine.indexOf(' '));
	    
	    int idx = sLine.indexOf(" resultsjdl: ");
	    
	    if (idx>0)
		idx = sLine.indexOf("[", idx);
	    
	    int idx2 = sLine.indexOf("] spyurl: ");
	    
	    //System.err.println(idx+", "+idx2+" : "+sLine);
	    
	    if (idx>=0 && idx2>idx){
		out.println(utils.CatalogueHighlight.highlight(lia.web.utils.HtmlColorer.logLineColorer(sLine.substring(0, idx+1))));
		out.println("<br>");

		String sJdlContent = sLine.substring(idx+1, idx2).trim();

		try{
		    
		    alien.taskQueue.JDL j = new alien.taskQueue.JDL(sJdlContent);
		    
		    out.println("<div style='font-size:10px;margin-left:50px'>");
		    out.println(utils.CatalogueHighlight.highlight(j.toHTML(), pid, j.getUser()));
		    out.println("</div>");
		}
		catch (Exception e){
		    out.println(utils.CatalogueHighlight.highlight(lia.web.utils.HtmlColorer.logColorer(sJdlContent)));
		}
		
		out.println(sLine.substring(idx2)+"<BR>");
		
		continue;
	    }
	}
	else{
	    if (sLine.trim().length()==0)
		continue;
	}
	
	sLine = utils.CatalogueHighlight.highlight(lia.web.utils.HtmlColorer.logLineColorer(sLine));
    
	if (sLine.contains("Validation error cause")){
	    sLine = Format.replace(sLine, "\\n", "<BR>");
	    sLine = "<div style='margin-top:10px'><B>"+sLine+"</B></div>";
	}
    
        out.println(sLine);
        out.println("<br>");
    }
    
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/jobs/trace.jsp?pid="+pid, 0, request);
%>