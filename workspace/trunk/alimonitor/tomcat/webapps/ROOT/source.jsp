<%@page import="lazyj.*"%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    String className = rw.gets("class");
    
    String javaSource = Format.replace(className, ".", "/");
    
    if (className.startsWith("alien.lpm.") || className.startsWith("alien.daq.") || className.startsWith("alien.jobs.") || className.startsWith("alien.managers.") || className.startsWith("alien.repository") || className.startsWith("alien.runs") || className.startsWith("alien.users") || className.startsWith("alien.utils") || className.startsWith("auth.") || className.startsWith("actions.") || className.startsWith("filters.") || className.startsWith("producers.") || className.startsWith("utils.")){
	response.sendRedirect("http://aliendb9.cern.ch/viewvc/alimonitor-lib/alimonitor_lib/"+javaSource+".java?view=markup");
    }
    else
    if (className.startsWith("alien.")){
	response.sendRedirect("http://aliendb9.cern.ch/viewvc/alien-java/trunk/src/"+javaSource+".java?view=markup");
    }
    else
    if (className.startsWith("daqreg.")){
	response.sendRedirect("http://aliendb9.cern.ch/viewvc/daqreg/trunk/src/"+javaSource+".java?view=markup");
    }
%>