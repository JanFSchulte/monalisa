<%@ page import="alien.jobs.*,alien.catalogue.*,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.*,lia.Monitor.Store.*,java.util.*" %><%
    response.setContentType("text/plain");
    
    out.println("IDs : "+IDGenerator.size());
    
    final long l = System.currentTimeMillis();
    
    Vector<Integer> i = IDGenerator.getIDs(new monPredicate("*", "*", "*", -1, -1, new String[]{"eth0_in"}, null));
    
    out.println("Query took : "+(System.currentTimeMillis() - l)+" for "+i.size());
%>