<%@ page import="lia.Monitor.Store.Cache,lia.Monitor.Store.Fast.DB,lia.Monitor.monitor.*,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*"%><%!
    private static class Job implements Comparable<Job>{
	int pid;
	String site;

	double run_time = -1;
	String host = null;
	int host_pid = -1;
	double cpu_time = -1;
	
	String user = null;
	
	double rss = -1;
	double virtualmem = -1;
    
	public Job(final String site, final int pid){
	    this.site = site;
	    this.pid = pid;
	}
	
	public int compareTo(final Job j){
	    double eff = cpu_time / run_time;
	    
	    double oth_eff = j.cpu_time / j.run_time;
	    
	    if (eff<oth_eff)
		return -1;
	
	    if (eff>oth_eff)
		return 1;
		
	    if (run_time < j.run_time)
		return 1;
	
	    if (run_time > j.run_time)
		return -1;
		
	    return 0;
	}
	
	public void fill(final Page p){
	    p.modify("site", site);
	    p.modify("host", host);
	    p.modify("pid", String.valueOf(pid));
	    p.modify("host_pid", String.valueOf(host_pid));
	    p.modify("cpu_time", String.valueOf(cpu_time));
	    p.modify("run_time", String.valueOf(run_time));
	    p.modify("efficiency", String.valueOf(100 * cpu_time / run_time));
	    p.modify("user", user);
	    p.modify("rss", rss);
	    p.modify("virtualmem", virtualmem);
	}
    }

%><%
    lia.web.servlets.web.Utils.logRequest("START /debug/efficiency.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();

    String site = rw.gets("site", "*");

    final monPredicate pred = new monPredicate(site, "ALICE::%_Jobs", "%", -1000*60*5, -1, new String[]{"run_time", "cpu_time", "host", "host_pid", "job_user", "rss", "virtualmem"}, null);

    final Vector v = Cache.getLastValues(pred);
    
    final ArrayList l = Cache.filterByTime(v, pred);
    
    System.err.println("Before/after filtering: "+v.size()+"/"+l.size());

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(100000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    //pMaster.modify("refresh_time", 120);
    pMaster.modify("title", "Jobs by efficiency");

    final Page p = new Page("debug/efficiency.res", false);
    
    final Page pLine = new Page("debug/efficiency_el.res", false);

    HashMap<Integer, Job> jobs = new HashMap<Integer, Job>();

    for (final Object o: l){
	Job j;
    
	if (o instanceof Result){
	    Result r = (Result) o;
	
	    Integer pid = Integer.valueOf(r.NodeName);
	    
	    j = jobs.get(pid);
	    
	    if (j==null){
		j = new Job(r.FarmName, pid.intValue());
		
		jobs.put(pid, j);
	    }
	    
	    if (r.param_name[0].equals("cpu_time"))
		j.cpu_time = r.param[0];
	    else
	    if (r.param_name[0].equals("run_time"))
		j.run_time = r.param[0];
	    else
	    if (r.param_name[0].equals("host_pid"))
		j.host_pid = (int) r.param[0];
	    else
	    if (r.param_name[0].equals("rss"))
		j.rss = r.param[0];
	    else
	    if (r.param_name[0].equals("virtualmem"))
		j.virtualmem = r.param[0];
	}
	else{
	    eResult r = (eResult) o;
	
	    Integer pid = Integer.valueOf(r.NodeName);
	    
	    j = jobs.get(pid);
	    
	    if (j==null){
		j = new Job(r.FarmName, pid.intValue());
		
		jobs.put(pid, j);
	    }
	    
	    if (r.param_name[0].equals("host"))
		j.host = (String) r.param[0];
	    else
		j.user = (String) r.param[0];
	}
    }
    
    LinkedList<Job> joblist = new LinkedList<Job>(jobs.values());
    
    Iterator<Job> it = joblist.iterator();
    
    while (it.hasNext()){
	Job j = it.next();
	
	if (j.cpu_time < 0 || j.run_time < 0 || j.host_pid < 0 || j.host==null)
	    it.remove();
    }
    
    Collections.sort(joblist);
    
    int cnt = 0;
    
    for (Job j: joblist){
	j.fill(pLine);
	pLine.modify("cnt", ++cnt);
	p.append(pLine);
    }
    
    pMaster.append(p);

    pMaster.modify("bookmark", "/debug/efficiency.jsp");
    
    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/debug/efficiency.jsp", baos.size(), request);

%>