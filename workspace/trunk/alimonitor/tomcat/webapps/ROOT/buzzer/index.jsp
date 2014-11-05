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

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("title", "Buzzer tests");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
  
    Page p = new Page("buzzer/index.res");
 
    Page pLine = new Page("buzzer/index_line.res");
    
    // final bits and pieces
    
    File base = new File(BASE_PATH+"buzzer");
    
    ArrayList<File> directories = new ArrayList<File>();
    
    for (File f: base.listFiles()){
	if (f.isDirectory()){
	    directories.add(f);
	}
    } 
    
    Collections.sort(directories, new Comparator<File>(){
    
	public int compare(File f1, File f2){
	    String s1 = f1.getName();
	    String s2 = f2.getName();

	    int i1 = 0;
	    int i2 = 0;
	    
	    try{
		i1 = Integer.parseInt(s1.substring(0, s1.indexOf('_')));
	    }
	    catch (Exception e){
		// ignore
	    }	    

	    if (i1<=0)
		return 1;

	    try{
		i2 = Integer.parseInt(s2.substring(0, s2.indexOf('_')));
	    }
	    catch (Exception e){
		// ignore
	    }
	    
	    if (i2<=0)
		return -1;
		
	    return i2 - i1;
	}
    
    });
    
    for (File f: directories){
	pLine.modify("f", f.getName());
	p.append(pLine);
    }

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    Utils.logRequest("/caf/cafquota.jsp", baos.size(), request);
%>