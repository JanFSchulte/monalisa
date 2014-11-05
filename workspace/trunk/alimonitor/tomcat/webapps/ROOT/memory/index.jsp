<%@ page import="lia.Monitor.Store.Cache,lia.Monitor.Store.Fast.DB,lia.Monitor.monitor.*,alimonitor.*,java.util.*,java.io.*,lazyj.*,alien.pool.*,lazyj.commands.*"%><%!
    private static final class Job{
	String site;
	String host;
	String user;
	int jobid;
	long rss;
	long virtualmem;
	int open_files;
	double cpu_time;
	double run_time;
        
	public Job(final String sFarm, final String sNode){
	    site = sFarm;
	    
	    user = sNode.substring(sNode.indexOf('_')+1, sNode.lastIndexOf('_'));
	
	    monPredicate pred = new monPredicate(sFarm, "Jobs_Memory_Offenders", sNode, -1, -1, new String[]{"rss", "virtualmem", "host", "jobid", "job_user", "open_files", "cpu_time_abs", "run_time_abs"}, null);
	
	    Vector v = Cache.getLastValues(pred);
	    
	    if (v==null)
		return;
	
	    for (Object o: v){
		if (o instanceof Result){
		    Result r = (Result) o;
		    
		    if (r.param_name[0].equals("rss"))
			rss = (long) r.param[0];
		    else
		    if (r.param_name[0].equals("virtualmem"))
			virtualmem = (long) r.param[0];
		    else
		    if (r.param_name[0].equals("jobid"))
			jobid = (int) r.param[0];
		    else
		    if (r.param_name[0].equals("open_files"))
			open_files = (int) r.param[0];
		    else
		    if (r.param_name[0].equals("run_time_abs"))
			run_time = r.param[0];
		    else
		    if (r.param_name[0].equals("cpu_time_abs"))
			cpu_time = r.param[0];
		}
		else
		if (o instanceof eResult){
		    eResult r = (eResult) o;
		
		    if (r.param_name[0].equals("host"))
			host = (String) r.param[0];
		    else
		    if (r.param_name[0].equals("job_user"))
			user = (String) r.param[0];
		}
	    }
	}
	
	public void fillPage(final Page p){
	    p.modify("rss", rss);
	    p.modify("virtualmem", virtualmem);
	    p.modify("jobid", jobid);
	    p.modify("host", host);
	    p.modify("user", user);
	    p.modify("site", site);
	    p.modify("open_files", open_files);
	    p.modify("cpu_time", cpu_time);
	    p.modify("run_time", run_time);
	}
    }
    
    private static final Comparator<Job> jobComparatorRSS = new Comparator<Job>(){
	public int compare(final Job j1, final Job j2){
	    final long diff = j2.rss - j1.rss;
	    
	    return diff < 0 ? -1 : (diff > 0 ? 1 : 0);
	}
    };

    private static final Comparator<Job> jobComparatorVirtualmem = new Comparator<Job>(){
	public int compare(final Job j1, final Job j2){
	    final long diff = j2.virtualmem - j1.virtualmem;
	    
	    return diff < 0 ? -1 : (diff > 0 ? 1 : 0);
	}
    };
%><%
    lia.web.servlets.web.Utils.logRequest("START /memory/index.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);
    
    final DB db = new DB();

    final String sField = rw.gets("field", "virtualmem");


    final monPredicate pred = new monPredicate("*", "Jobs_Memory_Offenders", "top"+sField+"_%_1", -1000*60*5, -1, new String[]{sField}, null);
    
    final Vector v = Cache.getLastValues(pred);
    
    final ArrayList l = Cache.filterByTime(v, pred);
    
    final ArrayList<Job> jobs = new ArrayList<Job>(l.size());
    
    for (Object o: l){
	final Result r = (Result) o;
    
	final Job j = new Job(r.FarmName, r.NodeName);
	
	jobs.add(j);
    }
    
    if (sField.equals("virtualmem"))
	Collections.sort(jobs, jobComparatorVirtualmem);
    else
	Collections.sort(jobs, jobComparatorRSS);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    //pMaster.modify("comment_refresh", "//");
    pMaster.modify("refresh_time", 120);

    pMaster.modify("title", "List of largest memory consuming jobs");
    
    final Page p = new Page("memory/index.res");
    
    final Page pLine = new Page("memory/index_el.res");
    
    for (Job j: jobs){
	j.fillPage(pLine);
	p.append(pLine);
    }
    
    pMaster.append(p);

    pMaster.modify("bookmark", "/memory/index.jsp?field="+Format.encode(sField));
    
    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/memory/index.jsp", baos.size(), request);
%>