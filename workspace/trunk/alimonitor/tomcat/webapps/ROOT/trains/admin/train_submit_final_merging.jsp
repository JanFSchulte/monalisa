<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*,lazyj.commands.*,alien.pool.*,alien.user.*,alien.repository.*,alien.managers.*" %><%!
    private static final boolean DEBUG = true;
    
    private static final void debug(final String line){
	System.err.println("/trains/admin/train_submit_final_merging.jsp : "+(new Date()).toString()+" : "+line);
    }
%><%
    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /trains/admin/train_submit_final_merging.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final DB db = new DB();
    
    final int train_id = rw.geti("train_id");
    
    final int id = rw.geti("id");
    
    final AlicePrincipal principal = new AlicePrincipal(""); //Users.get(request);

    boolean admin = true; //principal.hasRole("admin");

    debug("train_id: "+train_id+" / id: "+id+" / admin:"+admin+" / principal: "+principal);
    
    if (!admin){
	db.query("SELECT 1 FROM train_operator_permission WHERE username='"+Format.escSQL(principal.getName())+"' and train_id="+train_id);
	
	admin = db.moveNext();
    }

    if (!admin){
	debug("train_id: "+train_id+" / id: "+id+" : not allowed");
    
	out.println("You are not allowed here");
	return;
    }

    // ----------------------------------------------    
    
    db.query("SELECT Count(*) FROM train_run WHERE train_id="+train_id+" AND id="+id);
    if (db.geti(1)!=1)
    {
	debug("train_id: "+train_id+" / id: "+id+" : train run not found");
    
	out.println("Train run not found.");
	return;
    }

    db.query("SELECT max(final_merge_job_id) FROM train_run_final_merge WHERE train_id="+train_id+" AND id="+id);
    if (db.geti(1) > 0)
    {
	debug("train_id: "+train_id+" / id: "+id+" : merge job(s) already submitted");
    
	out.println("Merge job(s) already submitted.");
	return;
    }

    //response.setContentType("text/plain");

    int pids[] = PWGTrainManager.submitFinalMerging(train_id, id, out);

    db.syncUpdateQuery("UPDATE train_run SET merged_by_hand=1 WHERE train_id="+train_id+" AND id="+id);

    try{
	final PrintWriter pw = new PrintWriter(new FileWriter("/home/monalisa/MLrepository/logs/lpm.manual." + "alitrain", true));
	pw.println("---------------------------------------------------------------------------------------");
	pw.println("LPM action at " + new Date());
	pw.println("train_id: "+train_id+" / id: "+id);
	for (int i=0; i<pids.length; i++)
	    pw.println("  returned PID: "+pids[i]);
	pw.println();
	//pw.println(lpm.getLog(false));
	pw.flush();
	pw.close();
    }
    catch (Exception e){
	// ignore
    }

    for (int i=0; i<pids.length; i++) {
	if (pids[i] <= 0) {
	    debug("train_id: "+train_id+" / id: "+id+" : submission failed");
	    
	    response.setContentType("text/html");
	    out.println("Job submission failed.<BR>\n");
	    return;
	}
    }

    response.sendRedirect("train_edit_run.jsp?train_id="+train_id+"&id="+id);
     
    // ------------------------ final bits and pieces

    lia.web.servlets.web.Utils.logRequest("/trains/admin/train_submit_final_merging.jsp?train_id="+train_id+"&id="+id, baos.size(), request);
%>