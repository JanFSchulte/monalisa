<%@ page import="alimonitor.*,lia.web.utils.ServletExtension,lia.web.utils.Formatare,lazyj.RequestWrapper,java.io.*,java.util.*,java.text.*,lia.Monitor.Store.Fast.DB,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.web.servlets.web.*,java.awt.*,javax.swing.JPanel,org.jfree.chart.*,org.jfree.chart.axis.*,org.jfree.chart.plot.*,org.jfree.chart.renderer.xy.*,org.jfree.data.xy.*,org.jfree.chart.entity.*,org.jfree.chart.servlet.*,org.jfree.chart.labels.*,org.jfree.chart.urls.*,org.jfree.ui.*,org.jfree.data.category.*,org.jfree.data.time.*" %><%!
%><%
    Utils.logRequest("START /buzzer/index.jsp", 0, request);

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    response.setContentType("text/html");
    
    final RequestWrapper rw = new RequestWrapper(request);

    final ServletContext sc = getServletContext();
    
    final String BASE_PATH=sc.getRealPath("/")+"/";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    String sPath = rw.gets("path");
    
    if (sPath.indexOf("/")>0 || sPath.startsWith("."))
	return;    

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("title", "Buzzer test "+sPath);
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    Page p = new Page("buzzer/details.res");
    
    Page pLine = new Page("buzzer/details_line.res");
    
    // final bits and pieces
    
    File base = new File(BASE_PATH+"buzzer/"+sPath);
    
    ArrayList<File> directories = new ArrayList<File>();
    
    for (File f: base.listFiles()){
	if (f.isDirectory()){
	    directories.add(f);
	}
    } 
    
    Collections.sort(directories);
    
    for (File f: directories){
	pLine.modify("path", sPath);
	pLine.modify("dir", f.getName());
	p.append(pLine);
    }

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    Utils.logRequest("/caf/cafquota.jsp", baos.size(), request);
%>