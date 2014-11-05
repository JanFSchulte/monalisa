<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*" %><%!
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String sFile = rw.gets("file");
    
    try{
	final AliEnFile f = FileCache.getFile(sFile);

	final List<Replica> whereis = f.whereis();
	
	if (whereis==null){
	    out.println("command failed : "+sFile);
	    return;
	}
	    
	if (whereis.size()==0){
	    out.println("<font color=red><b>No replicas for this file!</b></font>");
	}
	
	DB db = new DB();
	
	for (Replica r: whereis){
	    final String sSE = r.getSE();
	    
	    String sColor = "black";
	    
	    db.query("select sum(status) from se_testing where lower(se_name)='"+Format.escSQL(sSE.toLowerCase())+"';");

	    int status = db.geti(1, -1);
	    
	    if (status==0)
		sColor = "green";
	    else
	    if (status>0)
		sColor = "red";
	    	    
	    final StringTokenizer st = new StringTokenizer(sSE, ":");
	    
	    out.println("<font color="+sColor+">"+st.nextToken()+"::<b>"+st.nextToken()+"</b>::"+st.nextToken()+"</font>");
	    
	    out.println("<BR>");
	}
    }
    catch (Exception e){
    }
    
    lia.web.servlets.web.Utils.logRequest("/catalogue/whereis.jsp?file="+sFile, 0, request);
%>