<%@ page import="java.security.cert.*, java.util.StringTokenizer" %><%
    lia.web.servlets.web.Utils.logRequest("START /testuser.jsp", 0, request);

    X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

    String sUser = null;

    if (cert!=null && cert.length>0){
	//out.println("Issuer DN : " + cert[0].getSubjectDN().getName());
	
	StringTokenizer st = new StringTokenizer(cert[0].getSubjectDN().getName(), " ,=");
	
	st.nextToken();
	sUser = st.nextToken();
    }
    
    out.println("User: "+sUser);
    
    lia.web.servlets.web.Utils.logRequest("/testuser.jsp", 0, request);
%>