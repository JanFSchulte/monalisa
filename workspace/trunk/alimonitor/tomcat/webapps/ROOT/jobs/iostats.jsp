<%@ page import="alien.taskQueue.*,lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*,java.util.regex.*,alien.catalogue.*,alien.repository.*"%><%!
%>
<html>
<head>
<title>IOStats</title>
</head>
<body>
<%
    final RequestWrapper rw = new RequestWrapper(request);
    
    final String[] pidList = rw.getValues("pid");
    
    final Set<Integer> pids = new HashSet<Integer>();
    
    for (final String s: pidList){
	final StringTokenizer st = new StringTokenizer(s, " \t\r\n,;");
	
	while (st.hasMoreTokens()){
	    try{
		pids.add(Integer.valueOf(st.nextToken()));
	    }
	    catch (Exception e){
		// ignore
	    }
	}
    }
    
    final int[] ipids = new int[pids.size()];
    
    int pos = 0;
    
    for (Integer i: pids)
	ipids[pos++] = i.intValue();
    
    Map<Integer, IOStats> stats = IOStats.getCachedStats(ipids);
    
    IOStats agg = new IOStats();
    
    for (IOStats stat: stats.values())
	agg.merge(stat);
%>
<pre>
<%=agg.toString()%>
</pre>
</body>
</html>
