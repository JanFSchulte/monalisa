<%@ page import="java.util.*,java.io.*,alimonitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /doc/edit.jsp", 0, request);
    
    final ServletContext sc = getServletContext();

    final String SITE_BASE=sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/doc";
    
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    final Page pMaster = new Page(baos, "doc/edit.res");
	
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    String sPage = request.getParameter("page");

    if (sPage==null)
	sPage = "index";
	
    if (!sPage.matches("^[\\w/-]+$"))
	return;
	
    final String sContent = request.getParameter("content");
    
    final String sFile = BASE_PATH+"/"+sPage+".html";

    if (sContent!=null){
	final PrintWriter pw = new PrintWriter(new FileWriter(sFile));
	
	pw.print(sContent.trim());
	
	pw.flush();
	
	pw.close();
	
	response.sendRedirect("index.jsp?page="+sPage);
	
	return;
    }

    pMaster.modify("page", sPage);    
    pMaster.append(new Page("doc/"+sPage+".html", false));
    
    pMaster.write();
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/doc/edit.jsp", baos.size(), request);
%>