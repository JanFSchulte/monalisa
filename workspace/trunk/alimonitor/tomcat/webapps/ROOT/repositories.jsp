<%@ page import="alimonitor.*,java.util.*,java.io.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /repositories.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(15000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    pMaster.modify("bookmark", "/repositories.jsp");
    
    pMaster.modify("title", "Other computer clusters monitored with MonALISA");
    
    Page p = new Page("repositories.res");
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/repositories.jsp", baos.size(), request);
%>