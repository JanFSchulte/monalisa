<%@ page import="lia.Monitor.monitor.*,java.io.*,java.util.*,lazyj.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /export/getValues.jsp", 0, request);

    response.setContentType("text/plain");

    final RequestWrapper rw = new RequestWrapper(request);

    final String sPredicate = rw.gets("p");
    
    if (sPredicate.length()==0)
	return;
    
    monPredicate pred = lia.web.utils.Formatare.toPred(sPredicate);
	
    Vector v = lia.Monitor.Store.Cache.getLastValues(pred);

    for (Object o: v){
	String sValue = "";

	if (o!=null){
	    if (o instanceof Result){
		sValue = ""+((Result)o).param[0];
	    }
	    else
	    if (o instanceof eResult){
		sValue = '"' + Format.replace(((eResult)o).param[0].toString(), "\"", "\\\"") + '"';
	    }
	}
    
	if (sValue.matches("^[0-9]+\\.0$"))
	    sValue = sValue.substring(0, sValue.length()-2);
	
	out.println(sValue+" "+lia.Monitor.Store.Fast.IDGenerator.generateKey(o, 0));
    }
    
    lia.web.servlets.web.Utils.logRequest("/export/getValues.jsp?p="+sPredicate, 0, request);
%>