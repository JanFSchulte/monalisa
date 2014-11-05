<%@page import="lazyj.*,alimonitor.*,lia.web.utils.HtmlColorer,java.util.*,java.io.*,java.util.regex.*"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /production/viewlog.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    response.setContentType("text/html");
    
    // -------------------
    
    try{
	final BufferedReader br = new BufferedReader(new FileReader("/home/monalisa/MLrepository/tomcat/webapps/ROOT"+rw.gets("file")));
	
	String sLine;
	
	while ( (sLine = br.readLine())!=null ){
	    String s = HtmlColorer.logLineColorer(sLine);
	    s = utils.CatalogueHighlight.highlight(s);
	    out.println(s+"<BR>");
	}
    }
    catch (IOException ioe){
    }
    
    // -------------------
    
    lia.web.servlets.web.Utils.logRequest("/production/viewlog.jsp", 1, request);
%>