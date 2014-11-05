<%@ page import="lazyj.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.DB" %><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /packages/install.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    final String sPackage = rw.gets("package");
    
    final DB db = new DB("SELECT dependencies FROM packages_dependencies WHERE name='"+Format.escSQL(sPackage)+"';");
    
    if (!db.moveNext()){
	out.println("No such package : "+sPackage);
	return;
    }

    response.setContentType("text/x-sh");
  
    response.setHeader("Content-Disposition", "attachment; filename=\"install-"+sPackage+".sh\"");

    Page p = new Page(response.getOutputStream(), "packages/install.sh");
	
    p.modify("packages", sPackage);

    String sDeps = db.gets(1);
    
    if (sDeps.length()>0)
	p.append("packages", " "+sDeps.replace(',' , ' '));
  
    p.write();

    lia.web.servlets.web.Utils.logRequest("/packages/install.jsp?package="+sPackage, 0, request);
%>