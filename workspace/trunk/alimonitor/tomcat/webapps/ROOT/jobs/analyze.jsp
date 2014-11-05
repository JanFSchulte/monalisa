<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,alien.pool.*,java.util.*,alien.jobs.*,java.util.concurrent.atomic.*"%><%!
    private static final int get(final Map<String, AtomicInteger> m, final String state){
	if (m==null)
	    return 0;
	    
	final AtomicInteger ai = m.get(state);
	
	if (ai==null)
	    return 0;
	    
	return ai.get();
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /users/analyze.jsp", 0, request);
  
    RequestWrapper rw = new RequestWrapper(request);
  
    int pid = rw.geti("pid");
    
	final Masterjob j = new Masterjob(pid);
	
	Map<String, Set<Integer>> subjobStates = j.getSubjobIDs();
	
	//alien.repository.Masterjob.updateStatus(j);
	
	final JDL masterJDL = new JDL(pid);
	
	    final TreeMap<Integer, AtomicInteger> tm = new TreeMap<Integer, AtomicInteger>();
	    
	    final TreeMap<Integer, Map<String, AtomicInteger>> tmStates = new TreeMap<Integer, Map<String, AtomicInteger>>();
	    
	    int iTotalJobs = 0;
	    
	    for (int id: j.getSubjobIDs(null)){
		iTotalJobs ++;
	    
		final JDL jdl = new JDL(id);
		
		final List<String> data = jdl.getInputData();
	    
		if (data==null){
		    //System.err.println("Cannot get input data for "+id);
		    break;
		}
		
		final Integer cnt = Integer.valueOf(data.size());
		
		AtomicInteger ai = tm.get(cnt);
		
		if (ai==null){
		    ai = new AtomicInteger(1);
		    tm.put(cnt, ai);
		}
		else
		    ai.incrementAndGet();
		    
		String state = null;
		
		final Integer ID = Integer.valueOf(id);
		
		for (Map.Entry<String, Set<Integer>> me: subjobStates.entrySet()){
		    if (me.getValue().contains(ID)){
			state = me.getKey();
			break;
		    }
		}
		
		if (state==null)
		    state = "UNKNOWN";
		    
		Map<String, AtomicInteger> m = tmStates.get(cnt);
		
		if (m==null){
		    m = new HashMap<String, AtomicInteger>();
		    tmStates.put(cnt, m);
		}
		
		ai = m.get(state);
		
		if (ai==null){
		    ai = new AtomicInteger(1);
		    m.put(state, ai);
		}
		else{
		    ai.incrementAndGet();
		}
	    }
%>
<html>
    <head>
	<title>Input files distribution</title>
	<script src="/js/sorttable.js"></script>
    	<script src="/overlib/overlib.js"></script>
</head>
    <body>
	Masterjob: <a href="http://alimonitor.cern.ch/jobs/details.jsp?pid=<%=pid%>" target=_blank><%=pid%></a>, SplitMaxInputFileNumber=<%=masterJDL.get("SplitMaxInputFileNumber")%><br>
	<br>
	<table border=1 cellspacing=0 cellpadding=3 class=sortable>
	    <thead>
	    <tr>
		<th>Input files</th>
		<th>Subjobs</th>
		<th>% jobs/total</th>
		<th>Done</th>
		<th>Active</th>
		<th>Err</th>
	    </tr>
	    </thead>
	    <tbody>
<%
    int iTotalFiles = 0;
    
    int iJobs = 0;
    
    int iTotalDone = 0;
    int iTotalActive = 0;
    int iTotalOther = 0;

    for (Map.Entry<Integer, AtomicInteger> me: tm.entrySet()){
        iJobs += me.getValue().intValue();
        
        final Map<String, AtomicInteger> m = tmStates.get(me.getKey());
        
        int iDone = get(m, "DONE") + get(m, "DONE_WARN");
        int iActive = get(m, "RUNNING") + get(m, "SAVING") + get(m, "SAVED") + get(m, "SAVED_WARN") + get(m, "INSERTING") + get(m, "WAITING") + get(m, "STARTING") + get(m, "STARTED");
        int iOther = me.getValue().intValue() - iDone - iActive;
        
        if (iOther<0)
    	    iOther = 0;
	
	out.println("<tr><td align=right>"+me.getKey()+"</td><td align=right>"+me.getValue()+"</td><td align=right>"+(iJobs*100 / iTotalJobs)+"%</td>");
	out.println("<td align=right>"+iDone+"</td><td align=right>"+iActive+"</td><td align=right>"+iOther+"</td></tr>");
	
	iTotalFiles += me.getKey().intValue() * me.getValue().intValue();
	
	iTotalDone += iDone;
	iTotalActive += iActive;
	iTotalOther += iOther;
    }
%>
	    </tbody>
	    <tfoot>
		<tr>
		    <th><%=iTotalFiles%> files</th>
		    <th><%=iTotalJobs%> jobs</th>
		    <th><%=tm.size()%> kinds</th>
		    <th><%=iTotalDone%> jobs</th>
		    <th><%=iTotalActive%> jobs</th>
		    <th><%=iTotalOther%> jobs</th>
		</tr>
		<tr>
		    <th colspan=6>
			<%=Format.point((double) iTotalFiles / iTotalJobs)%> files / subjob
		    </th>
		</tr>
	    </tfoot>
	</table>
    </body>
</html>
