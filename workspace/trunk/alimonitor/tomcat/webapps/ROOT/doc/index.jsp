<%@ page import="java.util.*,java.io.*,alimonitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /doc/index.jsp", 0, request);

    final ServletContext sc = getServletContext();

    final String SITE_BASE=sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/doc";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    String sPage = request.getParameter("page");

    if (sPage==null)
	sPage = "index";
    
    boolean bFull = sPage.equals("index") || sPage.startsWith("full/");
    
    final String sOriginalPage = sPage;
    
    Page pMaster = new Page(baos, bFull ? "WEB-INF/res/masterpage/masterpage.res" : "doc/index.res");
	
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    String sFile = BASE_PATH+"/"+sPage+".html";
    
    if (!(new File(sFile)).exists()){
	sPage = "missing";
    }

    Page pFile = new Page("doc/"+sPage+".html", false);
    
    pFile.modify("page", sOriginalPage);

    pMaster.append(pFile);
    
    pMaster.modify("page", sOriginalPage);

    pMaster.write();
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/doc/index.jsp", baos.size(), request);
%>