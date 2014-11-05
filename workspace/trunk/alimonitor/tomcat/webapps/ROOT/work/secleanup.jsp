<%@ page import="lazyj.*,java.util.*,java.io.*,alien.catalogue.*" %><%
    response.setContentType("text/plain");

    out.println("Queued: "+utils.ReduceReplicas.recurse(LFNUtils.getLFN("/alice/sim/2011")));

/*
    final java.util.Collection<LFN> f = LFNUtils.find("/alice/data/2010/LHC10h/", "000137%/ESDs/pass1/%archive", 0);
    
    int cnt = 0;
    
    boolean commit = false;
    
    for (final LFN l: f){
	String name = l.getCanonicalName();
	
	int copies = 1;	// for ESDs
	
	if (name.endsWith("/log_archive") || name.endsWith("/log_archive.zip"))
	    copies=0;
	else
	if (name.indexOf("/AOD")>=0 || name.indexOf("/QA")>=0)
	    copies=2;
    
	cnt++;
    
	if (!commit)
	    out.println(cnt+". "+l.getCanonicalName()+"  :  "+copies);
	else
	    utils.ReduceReplicas.queueRemoval(l, copies);
    }
    
    if (commit)
	out.println("Queued : "+cnt);
*/
%>