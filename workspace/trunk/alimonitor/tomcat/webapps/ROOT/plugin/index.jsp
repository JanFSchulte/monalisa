<%
    lia.web.servlets.web.Utils.logRequest("START /plugin/index.jsp", 0, request);

    response.sendRedirect("alienml.xpi");

    lia.web.servlets.web.Utils.logRequest("/plugin/index.jsp", 0, request);
%>