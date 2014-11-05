<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*"%><%
lia.web.servlets.web.Utils.logRequest("START /masterpage_news.jsp", 0, request);

ServletContext sc = getServletContext();
          
ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

final String SITE_BASE = sc.getRealPath("/");
    
final String BASE_PATH=SITE_BASE+"/";
    
final String RES_PATH=SITE_BASE+"/WEB-INF/res";
            
Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_admin.res");
pMaster.write();

String s = new String(baos.toByteArray());
out.println(s);

lia.web.servlets.web.Utils.logRequest("/masterpage_news.jsp", baos.size(), request);
        
%>