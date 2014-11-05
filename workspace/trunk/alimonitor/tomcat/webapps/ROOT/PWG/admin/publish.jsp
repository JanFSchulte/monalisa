<%@ page import="lia.web.utils.Formatare,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/publish.jsp", 0, request);

    response.setContentType("text/html");
%>
<html>
    <head>
	<title>Publish PWG request in AliEn</title>
    </head>
    <body bgcolor=white>
	<div style="font-family:Verdana,Helvetica,Arial;font-size:12px">
<%
    int id;

    try{
	id = Integer.parseInt(request.getParameter("id"));
    }
    catch (Exception e){
	out.println("id parameter missing");
	return;
    }

    Process child = lia.util.MLProcess.exec(new String[]{"/home/monalisa/MLrepository/bin/publish/publish.sh", ""+id});
    
    OutputStream child_out = child.getOutputStream();
    child_out.close();
    
    BufferedReader br = new BufferedReader(new InputStreamReader(child.getInputStream()));
    String sLine;
    
    while ( (sLine=br.readLine())!=null ){
	out.println(HtmlColorer.logLineColorer(sLine)+"<BR>");
	out.flush();
    }
    br.close();
    
    br = new BufferedReader(new InputStreamReader(child.getErrorStream()));
    while ( (sLine=br.readLine())!=null ){
	out.println(HtmlColorer.logLineColorer("stderr: "+sLine)+"<BR>");
	out.flush();
    }
    br.close();
    
    child.waitFor();
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/publish.jsp", 0, request);
%>
	</div>
    </body>
</html>
