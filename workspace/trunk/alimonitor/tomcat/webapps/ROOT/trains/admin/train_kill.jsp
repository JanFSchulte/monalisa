<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,alien.taskQueue.*" %><%!

    private final static String basePath = System.getProperty("user.home")+"/train-workdir/";
    
    private final void kill(final int pid, final JspWriter out, final String prefix) throws IOException {
	final DB db = new DB();
	
	final Job j = TaskQueueUtils.getJob(pid, false);
	
	if (j==null){
	    out.println(prefix+"Job "+pid+" cannot be found in the TQ");
	}
	else{
	    if (db.syncUpdateQuery("INSERT INTO lpm_ignore (jobid) VALUES ("+pid+");", true)){
		out.println(prefix+pid+" set to be ignored by LPM");
	    }	
	
	    final List<Job> subjobs = TaskQueueUtils.getSubjobs(pid);
	    
	    int killed = 0;
	    
	    if (subjobs!=null){
		for (final Job sj: subjobs){
		    if (sj.isActive()){
			alien.pool.AliEnPool.executeCommand("admin", "kill "+sj.queueId);
			killed++;
		    }
		}
		
		out.println(prefix+pid+" : killed "+killed+" subjobs");
	    }
	    else{
		out.println(prefix+pid+" : cannot retrieve the subjobs");
	    }
	}

	
	db.query("SELECT pid FROM lpm_history WHERE parentpid="+pid);
	
	while (db.moveNext()){
	    kill(db.geti(1), out, prefix+"    ");
	}
    }
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_kill.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    
    response.setContentType("text/plain");
            
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    
    int id = rw.geti("id");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    boolean admin = true; //principal.hasRole("admin");
    
    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
	
	admin = db.moveNext();
    }

    if (!admin){
	out.println("You are not allowed here");
	return;
    }
    
    db.query("select lpm_id, test_path from train_run where train_id="+train_id+" and id="+id);
    String sTestPath = db.gets(2);
    
    if (!db.moveNext()){
	out.println("This train run ("+train_id+"/"+id+") doesn't exist in the database");
	return;
    }
    
    final int lpm_id=db.geti(1);
    
    if (lpm_id<=0){
	out.println("LPM entry not defined for "+train_id+"/"+id);
	return;
    }
    
    db.syncUpdateQuery("UPDATE lpm_chain SET enabled=0 WHERE id="+lpm_id);
    
    if (db.getUpdateCount()==1){
	out.println("LPM entry #"+lpm_id+" disabled");
    }
    else{
	out.println("LPM entry #"+lpm_id+" cannot be located");
    }
    
    db.query("select pid from lpm_history where chain_id="+lpm_id+" order by 1");
    
    while (db.moveNext()){
	kill(db.geti(1), out, "");
    }

    FileWriter w;
    w = new FileWriter(basePath+sTestPath+"/train_killed");
    w.write("\n");
    w.flush();
    w.close();

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_kill.jsp?train_id="+train_id+"&id="+id+"&username="+principal.getName(), 0, request);
%>