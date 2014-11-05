<%@ page import="java.io.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/view.jsp", 0, request);

    String sFile = "/home/monalisa/MLrepository/tomcat/webapps/ROOT/PWG/files/"+request.getParameter("file");
    
    Process p = Runtime.getRuntime().exec(new String[]{"/home/monalisa/highlight/bin/highlight", "-I", sFile, "--syntax", "C"});
    
    BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    BufferedReader brErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
    
    String sLine;
    
    while ( (sLine=br.readLine()) != null)
	out.println(sLine);

    while ( (sLine=brErr.readLine()) != null)
	out.println(sLine);
    
    br.close();
    brErr.close();
    
    p.waitFor();

    lia.web.servlets.web.Utils.logRequest("/PWG/view.jsp", 0, request);
%>