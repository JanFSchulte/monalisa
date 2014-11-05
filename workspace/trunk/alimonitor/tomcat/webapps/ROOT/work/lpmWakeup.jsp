<%!
    public static final String getQueuedJobs(final String account, final String status){
	final lia.Monitor.monitor.monPredicate pred = new lia.Monitor.monitor.monPredicate("CERN", "ALICE_Users_Jobs_Summary", account, -1, -1, new String[]{status+"_jobs"}, null);
	
	final Object o = lia.Monitor.Store.Cache.getLastValue(pred);
	
	if (o instanceof lia.Monitor.monitor.Result){
	    
	    return ""+((int) ((lia.Monitor.monitor.Result) o).param[0]);
	}
	
	return "No such object";
    }

%><%
    for (String user: new String[]{"aliprod", "alitrain", "alidaq", "pwg_pp", "pwg_cf", "pwg_dq", "pwg_ga", "pwg_hf", "pwg_je", "pwg_lf", "pwg_ud"}){
//    for (String user: new String[]{"alidaq"}){
	alien.managers.LPMManager.getInstance(user).wakeup();
    }
    
    //out.println(getQueuedJobs("aliprod", "WAITING"));
%>