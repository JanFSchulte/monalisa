<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,java.security.cert.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/check_prio.jsp", 0, request);

    String sDN = null;
    String sUsername = null;

    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
	
	if (cert!=null && cert.length>0){
	    sDN = cert[0].getSubjectDN().getName();
	    
	    auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);
	    
	    sUsername = principal.getName();
	}
    }
    
    int id = Integer.parseInt(request.getParameter("id"));
    int prio = Integer.parseInt(request.getParameter("prio"));
    
    DB db = new DB("SELECT p_prio FROM pwg WHERE p_id="+id+";");
    
    int iOldPrio = db.geti(1);
    
    if (prio!=iOldPrio){
	db.query("UPDATE pwg SET p_prio="+prio+" WHERE p_id="+id+";");
    
	if (db.getUpdateCount()>0){
	    db.query("INSERT INTO pwg_comments (pg_type, pg_pid, pg_comment, pg_author, pg_dn) VALUES (0, "+id+", 'Priority changed from "+iOldPrio+" to "+prio+"', '"+Formatare.mySQLEscape(sUsername)+"', '"+Formatare.mySQLEscape(sDN)+"');");
	}
    }
    
    response.sendRedirect("../");
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/check_prio.jsp", 0, request);
%>
