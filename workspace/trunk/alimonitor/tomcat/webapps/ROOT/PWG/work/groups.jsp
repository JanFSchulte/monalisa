<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/work/groups.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/empty_page.res");

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    lazyj.RequestWrapper rw = new lazyj.RequestWrapper(request);
    
    int iGroup = rw.geti("group");
    int iRequest = rw.geti("request");

    if(iGroup >0 ){  
        DB db = new DB();      
        DB db1 = new DB();      

	String sQuery;
	
	ArrayList al = new ArrayList();
	
	if(iRequest > 0){
	    sQuery = "SELECT * FROM pwg_responsibles WHERE pr_pid="+iRequest;
	    db1.query(sQuery);    
	    
	    while(db1.moveNext()){
		al.add(db1.geti("pr_puid"));
	    }
	}
	
	sQuery = "SELECT * FROM pwg_users INNER JOIN pwg_groups ON pu_group=pg_id WHERE pu_group="+iGroup;
	db.query(sQuery);
	
	while(db.moveNext()){
	    pMaster.append("optionUser = new Option('"+db.gets("pu_username")+" ("+db.gets("pg_name")+") "+"','"+db.geti("pu_id")+"');\n");
	    
	    if(al.contains(db.geti("pu_id"))){
		pMaster.append("optionUser.selected = true;\n");
	    }
	
	    pMaster.append("obj.options[obj.options.length] = optionUser;\n");
	}
    }
        
    pMaster.write();    
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/PWG/work/groups.jsp", baos.size(), request);
%>
