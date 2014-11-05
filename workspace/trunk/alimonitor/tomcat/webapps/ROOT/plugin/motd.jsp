<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /plugin/motd.jsp", 0, request);

    RequestWrapper.setCacheTimeout(response, 600);
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/plain; charset=UTF-8");
    response.setHeader("Content-Language", "en");                                                                                                    

    final DB db = new DB("SELECT ps_key,ps_value FROM plugin_settings;");

    while (db.moveNext()){
	final String sKey = db.gets(1);
	final String sValue = db.gets(2);
	
	if (sKey.equals("href")){
	    if (sValue.length()>0){
		out.println("class text-link");
		out.println("href "+sValue);
	    }
	    else{
		out.println("class text");
	    }
	    
	    continue;
	}
	
	if (sKey.equals("color")){
	    String sColor = sValue.length() == 0 ? "#555555" : sValue;
	    out.println("style font-size:10px;color:"+sColor);
	    continue;
	}

	// just dump an other setting
	if (sValue.length()>0)
	    out.println(sKey+" "+sValue);
    }
    
    lia.web.servlets.web.Utils.logRequest("/plugin/motd.jsp", 0, request);    
%>