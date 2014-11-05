<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/job_types.jsp", 0, request);

    ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage_admin.res");

    pMaster.modify("title", "Site administration - Job Type");
    
    //menu
    pMaster.modify("class_jobtypes", "_active");

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    Page pTypes = new Page(BASE_PATH+"/admin/job_types.res"); 

    String sQuery = "SELECT * FROM job_types ORDER BY jt_id DESC";
    DB db = new DB();
    
    db.query(sQuery);
    
    Page pTypesEl = new Page(BASE_PATH+"/admin/job_types_el.res");
    
    int i = 0;
    
    while(db.moveNext()){
	pTypesEl.modify("id", db.gets("jt_id"));
	pTypesEl.modify("type", db.gets("jt_type"));
//	pTypesEl.modify("description", db.gets("jt_description"));
	pTypesEl.modify("field1", db.gets("jt_field1"));
	
	String sType = db.gets("jt_field2");
	if (sType.indexOf(' ')>=0)
	    sType = sType.substring(0, sType.indexOf(' '));
	
	pTypesEl.modify(db.gets("jt_field2"), "selected");
	pTypesEl.modify(sType, "selected");
	
	pTypesEl.modify("field3", db.gets("jt_field3"));
	pTypesEl.modify("known_issues", db.gets("jt_known_issues"));
	pTypesEl.modify(db.gets("jt_field4"), "selected");
	
	pTypesEl.modify("color", (i%2 == 0 ? "#FFFFFF" : "#F0F0F0"));	
	
	pTypes.append(pTypesEl);
	
	i++;
    }
    
    pMaster.append(pTypes);
    
    pMaster.write();
        
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/job_types.jsp", baos.size(), request);
%>