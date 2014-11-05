<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /plugin/version.jsp", 0, request);

    RequestWrapper.setCacheTimeout(response, 600);
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/plain; charset=UTF-8");
    response.setHeader("Content-Language", "en");                                                                                                    

    out.print("1.6.8");
    out.flush();

    lia.web.servlets.web.Utils.logRequest("/plugin/version.jsp", 0, request);
%>