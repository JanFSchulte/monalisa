<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*,alien.catalogue.*,alien.pool.*,java.util.regex.*"%><%!
    public String nanoToString(final long lNano){
	if (lNano<0)
	    return "";
	
	double dSeconds = lNano / 1000000000d;
	    
	if (dSeconds > 1){
	    return Format.point(dSeconds)+" s";
	}
	    
	dSeconds *= 1000;
	    
	return Format.point(dSeconds)+" ms";
    }
    
    public String nanoToInterval(final long lNano){
	return Format.toInterval(lNano / 1000000);
    }
%>
<html>
<head>
<title>
    AliEn Timings
</title>
</head>
<body>
<table border=1 cellspacing=0 cellpadding=5>
    <tr>
	<th>Command</th>
	<th>Execution count</th>
	<th>Average time / call</th>
	<th>Total time spent</th>
    </tr>
<%
    final RequestWrapper rw = new RequestWrapper(request);

    Map<String, AliEnTiming.Counters> counters = AliEnTiming.getCounters();
    
    long lCount = 0;
    long lTime = 0;
    
    for (Map.Entry<String, AliEnTiming.Counters> me: counters.entrySet()){
	AliEnTiming.Counters c = me.getValue();
    
	out.println("<tr><td>"+Format.escHtml(me.getKey())+"</td><td>"+c.getCount()+"</td><td>"+c.averageTimeAsString()+"</td><td>"+nanoToInterval(c.getTotalTime())+"</td></tr>");
	
	lCount += c.getCount();
	lTime += c.getTotalTime();
    }
    
    if (lCount>0)
	out.println("<tr><th>TOTAL</th><th>"+lCount+"</th><th>"+nanoToString(lTime / lCount)+"</th><th>"+nanoToInterval(lTime)+"</th></tr>");

    if (rw.getb("clear", false))
	AliEnTiming.clear();
%>
</table>
</body>
</html>
