<%@ page import="lazyj.RequestWrapper,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/job_types_action.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);

    final ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
 
    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";
        
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final Page pMaster = new Page(baos, RES_PATH+"/masterpage/empty_page.res");

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    final String sId = rw.gets("id");
    final String sType = rw.gets("type");
//    final String sDescription = rw.gets("description");
    final String sDescription = rw.gets("type");
    final String sField1 = rw.gets("field1");
    final String sField2 = rw.gets("field2");
    final String sField3 = rw.gets("field3");
    final String sField4 = rw.gets("field4");
    final String sKnownIssues= rw.gets("known_issues");
    
    final String sDelete = rw.gets("delete");

    final DB db = new DB();

    if("1".equals(sDelete)){
	//System.err.println("delete");
	String sQuery = "DELETE FROM job_types WHERE jt_id="+sId;
	
	db.syncUpdateQuery(sQuery);
	
	pMaster.append("OK");
    }
    else{
	if(sType.length() == 0 || sDescription.length() == 0){
	    pMaster.append("Error: No Type");
	    //System.err.println("no type");
	}
	else{
	    String sQuery = "";
	
	    if("0".equals(sId)){
		//System.err.println("insert");
		db.query("SELECT max(jt_id) FROM job_types;");
		
		final int iNewId = db.geti(1)+1;

        	sQuery = "INSERT INTO job_types (jt_id, jt_type, jt_description, jt_field1, jt_field2, jt_field3, jt_field4, jt_known_issues) VALUES ("+
        	iNewId+","+
    		"'"+Formatare.mySQLEscape(sType)+"', "+
    		"'"+Formatare.mySQLEscape(sDescription)+"', "+
    		"'"+Formatare.mySQLEscape(sField1)+"', "+
    		"'"+Formatare.mySQLEscape(sField2)+"',"+
    		"'"+Formatare.mySQLEscape(sField3)+"',"+
    		"'"+Formatare.mySQLEscape(sField4)+"',"+
		"'"+Formatare.mySQLEscape(sKnownIssues)+"'"+
    		");";
	    }
	    else{
		//System.err.println("update");
        	sQuery = "UPDATE job_types SET "+
    		"jt_type = '"+Formatare.mySQLEscape(sType)+"', "+
    		"jt_description='"+Formatare.mySQLEscape(sDescription)+"', "+
    		"jt_field1='"+Formatare.mySQLEscape(sField1)+"', "+
    		"jt_field2='"+Formatare.mySQLEscape(sField2)+"',"+
    		"jt_field3='"+Formatare.mySQLEscape(sField3)+"',"+
    		"jt_field4='"+Formatare.mySQLEscape(sField4)+"',"+
    		"jt_known_issues='"+Formatare.mySQLEscape(sKnownIssues)+"' "+
    		"WHERE jt_id="+Formatare.mySQLEscape(sId)+";";
	    }
	    
	    //System.err.println(sQuery);
	
	    if(db.syncUpdateQuery(sQuery))
    		pMaster.append("OK");
    	    else
    		pMaster.append("Error: database update error");
	
	}
    }
        
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/job_types_action.jsp", baos.size(), request);
%>