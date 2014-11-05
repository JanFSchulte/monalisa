<%@page import="lia.web.utils.*,lia.Monitor.monitor.*,java.util.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /subscribe.jsp", 0, request);

    response.setHeader("Expires", "0");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/html; charset=UTF-8");
    response.setHeader("Content-Language", "en");                                                                                                    

    String sFarm    = request.getParameter("site");
    String sCluster = "AliEnServicesLogs";
    String sNode    = request.getParameter("service");
    String sParam   = "line";
    
    String sIP	    = request.getRemoteAddr();

    monPredicate pred = new monPredicate(sFarm, sCluster, sNode, -1, -1, new String[]{sParam}, null);

    Cookie[] cookies = request.getCookies();

    long lLastTime = System.currentTimeMillis() - 1000*60*15;
    
    String sName = sFarm+"|"+sNode;
    
    if (cookies != null){
	for (int i = 0; i < cookies.length; i++) {
	    //System.err.println(sIP+":  Cookie: "+cookies[i].getName()+ " - "+cookies[i].getValue());
	
    	    if (cookies[i].getName().equals(sName)){
    		try{
		    long lTemp = Long.parseLong(cookies[i].getValue());

		    if (lTemp > lLastTime)
			lLastTime = lTemp;
		    
		    //System.err.println(sIP+": Found last time = "+lLastTime);
		}
		catch (Exception e){
		}
		
        	break;
            }
        }
    }

    Vector v = AsyncPredManager.getValues(pred, lLastTime);

    //System.err.println(sIP+": Results: "+v.size());

    long lMaxTime = lLastTime;

    StringBuilder sb = new StringBuilder();

    for (int i=0; i<v.size(); i++){
	Object o = v.get(i);

	if (o instanceof eResult){
	    eResult r = (eResult) o;
	    
	    sb.append(HtmlColorer.logLineColorer(r.param[0].toString())).append("<br>");
	    
	    if (r.time>=lMaxTime)
		lMaxTime = r.time+1;
	}
    }
    
    //System.err.println(sIP+": New last time : "+lMaxTime);
    
    Cookie c = new Cookie(sName, ""+lMaxTime);
    response.addCookie(c);

    out.print(sb.toString());
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/subscribe.jsp", sb.length(), request);
%>