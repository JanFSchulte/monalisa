<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/check.jsp", 0, request);

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

    DB db = new DB();
    String sAction = request.getParameter("action") == null ? "1" : request.getParameter("action");    
    
    if("1".equals(sAction)){

	String sGroup = request.getParameter("group") == null ? "1" : request.getParameter("group");    
	String sGroupId = request.getParameter("gid") == null ? "" : request.getParameter("gid");    	

	if(sGroup.length() == 0){
	    pMaster.append("ERROR: No Group");
	}
	else{
	    String sQuery = "SELECT * FROM pwg_groups WHERE lower(pg_name)='"+Formatare.mySQLEscape(sGroup.toLowerCase())+"' ";
	    
	    if(sGroupId.length() != 0)
	        sQuery += "AND pg_id!="+sGroupId+";";
	        
	    db.query(sQuery);
	    
	    if(db.moveNext()){
		pMaster.append("ERROR: Group Already exists");
	    }
	    else
		pMaster.append("SUCCESS");
	}
    }
    
    if("3".equals(sAction)){
	String sGroupId = request.getParameter("gid") == null ? "" : request.getParameter("gid");
        String sQuery = "SELECT COUNT(1) AS cnt FROM pwg_users WHERE pu_group="+Formatare.mySQLEscape(sGroupId);
        
        db.query(sQuery);
        
        if(db.geti("cnt") == 0){
    	     pMaster.append("SUCCESS");
        }
        else{
    	    pMaster.append("ERROR: There are users in this group");
        }
        
    }
        
    pMaster.write();    
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/check.jsp", baos.size(), request);
%>
