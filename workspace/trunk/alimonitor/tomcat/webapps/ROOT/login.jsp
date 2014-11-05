<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.util.*,java.io.*,lia.web.servlets.web.*,lia.web.utils.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /login.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(4000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_empty.res");
    Page pLogin = new Page(baos, RES_PATH+"/masterpage/login.res");    

    pMaster.modify("title", "Administration Login");
//    pMaster.comment("com_menu", false);
    
    response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
    response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
    response.setHeader("Pragma", "no-cache");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    pMaster.append(pLogin);

    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/login.jsp", 0, request);
%>