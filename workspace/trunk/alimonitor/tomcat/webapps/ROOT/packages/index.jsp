<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.DB" %><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /packages/index.jsp", 0, request);

    RequestWrapper rw = new RequestWrapper(request);
    
    String sBookmark = "/packages/index.jsp";

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.modify("title", "Grid installed packages and dependencies");
    pMaster.modify("comment_refresh", "//");
    pMaster.modify("bookmark", sBookmark);
  
    Page p = new Page("packages/index.res");
    Page pLine = new Page("packages/index_line.res");
    
    // -------------------
    
    DB db = new DB("SELECT * FROM packages_dependencies ORDER BY name ASC;");
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	String sDef = "Packages = {<br>&nbsp;&nbsp;&nbsp;&nbsp;&quot;"+db.gets("name")+"&quot;";
	
	final StringTokenizer st = new StringTokenizer(db.gets("dependencies"), ",");
	
	final List<String> deps = new ArrayList<String>(3);
	
	while (st.hasMoreTokens()){
	    deps.add(st.nextToken());
	}
	
	Collections.sort(deps);
	
	for (String s: deps){
	    sDef += ",<br>&nbsp;&nbsp;&nbsp;&nbsp;&quot;"+s+"&quot;";
	}
	
	sDef += "<br>};";
	
	pLine.modify("def", sDef);
	
	p.append(pLine);
    }
  
    // -------------------

    pMaster.append(p);

    response.setContentType("text/html");
    pMaster.write();   
    
    String s = new String(baos.toByteArray());
    out.println(s);
	    
    lia.web.servlets.web.Utils.logRequest("/packages/index.jsp", baos.size(), request);		
%>