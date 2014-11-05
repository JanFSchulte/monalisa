<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/delete_request.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);

    DB db = new DB("DELETE FROM pwg WHERE p_id="+rw.geti("id")+";");
    
    response.sendRedirect("../");
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/delete_request.jsp", 0, request);
%>
