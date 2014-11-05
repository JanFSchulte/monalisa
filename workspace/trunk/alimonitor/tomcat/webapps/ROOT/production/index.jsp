<%
    lia.web.servlets.web.Utils.logRequest("START /production/index.jsp", 0, request);

    response.sendRedirect("raw.jsp");

    lia.web.servlets.web.Utils.logRequest("/production/index.jsp", 0, request);
%>