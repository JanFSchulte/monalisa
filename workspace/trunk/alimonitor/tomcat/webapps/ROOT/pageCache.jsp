<%@ page import="lazyj.*" %><%
lia.web.servlets.web.Utils.logRequest("START /pageCache.jsp", 0, request);

final String clear = request.getParameter("clear");

if (clear!=null && clear.trim().length()>0)
    PageCache.clear();
%>

<html>
    <head>
        <title>Cache contents</title>
    </head>
    <body bgcolor=white>
	<table>
	    <tr>
		<th>URL</th>
		<th>Accesses</th>
		<th>Sec. left</th>
		<th>Bonus</th>
		<th>Zip / Full</th>
		<th>Type</th>
	    </tr>
		    
    	    <%
    		for (CachingStructure c : PageCache.getCacheContent())
    		    out.println(c);
    	    %>
    </body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/pageCache.jsp", 0, request);
%>