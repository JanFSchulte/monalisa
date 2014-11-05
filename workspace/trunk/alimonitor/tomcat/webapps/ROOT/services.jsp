<%@ page import="alimonitor.*,lia.web.utils.ThreadedPage,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.Monitor.monitor.Result,lia.Monitor.monitor.eResult,lia.Monitor.JiniClient.Store.Main" %><%
    lia.web.servlets.web.Utils.logRequest("START /services.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Site services admin");
    
    //menu
    pMaster.modify("class_siteservices", "_active");

    final Page p = new Page("services.res");
    
    final Page pService = new Page("services_line.res");
    
    final Page pStatus = new Page("services_detail.res");
    
    final DB db = new DB("SELECT name,ip,contact_name,contact_email FROM abping_aliases WHERE name IN (SELECT name FROM alien_sites) ORDER BY lower(name) ASC;");

    int i=0;

    final monPredicate predOnline = new monPredicate("", "MonaLisa", "localhost", -1, -1, new String[]{"CurrentParamNo"}, null);
    final monPredicate predStatus = new monPredicate("", "AliEnServicesStatus", "", -1, -1, new String[]{"Status"}, null);
    final monPredicate predMessage= new monPredicate("", "AliEnServicesStatus", "", -1, -1, new String[]{"Message"}, null);
    final monPredicate predVersion= new monPredicate("", "AliEnTestsStatus", "alien version", -1, -1, new String[]{"Message"}, null);

    final String[] vsServices = new String[]{"CE", "PackMan", "Monitor", "MonaLisa"};

    while (db.moveNext()){
	final String sSite = db.gets(1);
	
	pService.modify("name", sSite);
	
	pService.modify("contact_name", db.gets(3));
	pService.modify("contact_email", db.gets(4));
	
	pService.modify("ip", db.gets(2));
	pService.modify("ip_rev", ThreadedPage.getHostName(db.gets(2), true));
	
	pService.modify("bgcolor", i%2==0 ? "#FFFFFF" : "#EEEEEE");

	predOnline.Farm = sSite;
	predStatus.Farm = sSite;
	predMessage.Farm= sSite;
	predVersion.Farm= sSite;
		
	boolean bOnline = true;
	        
	if(Cache.getLastValue(predOnline)!=null){
	    pService.modify("on_color", "green");
	    pService.modify("on", "ON");
	}
	else{
	    pService.modify("on_color", "red");
	    pService.modify("on", "OFF");
	    
	    bOnline = false;
	}
	
	if (bOnline){
	    final boolean bCanAdmin = Main.getInstance().getControlStatus(sSite) == 0;
	    
	    //System.err.println(sSite+" - can admin : "+bCanAdmin);
	
	    for (int j=0; j<vsServices.length; j++){
		predStatus.Node = vsServices[j];
		
		Object o = Cache.getLastValue(predStatus);
		
		boolean bOK = false;
		String sMessage = null;
		boolean bNoData = false;
		
		if (o!=null && (o instanceof Result)){
		    Result r = (Result) o;
		    
		    if (r.param[0] > 0.5){
			bOK = false;
			
			predMessage.Node = vsServices[j];
			
			o = Cache.getLastValue(predMessage);
			
			if (o!=null && (o instanceof eResult))
			    sMessage = o.toString();
			else
			    sMessage = "(no message)";
		    }
		    else
			bOK = true;
		}
		else{
		    bNoData = true;
		}
		
		if (bOK){
		    pStatus.modify("statecolor", "green");
		    pStatus.modify("state", "OK");
		    
		    pStatus.comment("com_message", false);
		}
		else
		if (bNoData){
		    pStatus.modify("statecolor", "orange");
		    pStatus.modify("state", "-");
		    pStatus.modify("message", "Service not enabled");
		    
		    pStatus.comment("com_nomessage", false);
		}
		else{
		    pStatus.modify("statecolor", "red");
		    pStatus.modify("state", "DOWN");
		    pStatus.modify("message", sMessage);
		    
		    pStatus.comment("com_nomessage", false);
		}

		pStatus.modify("service", vsServices[j]);
		pStatus.modify("name", sSite);
		
		pStatus.comment("com_canadmin", bCanAdmin);
		
		if (bNoData){
		    pService.modify(vsServices[j], "&nbsp;");
		    pStatus.toString();
		}
		else{
		    pService.modify(vsServices[j], pStatus);
		}
	    }
	    
	    pService.comment(bCanAdmin ? "com_nomonalisa" : "com_monalisa", false);
	    pService.comment("com_monalisadown", false);
	}
	else{
	    for (int j=0; j<vsServices.length; j++){
		pService.modify(vsServices[j], "-");
		pService.comment("com_canadmin", false);
	    }
		
	    pService.comment("com_monalisa", false);
	}
	
	pService.modify("site", sSite);
	
	Object o = Cache.getLastValue(predVersion);
	
	if (o!=null && (o instanceof eResult)){
	    eResult er = (eResult) o;
	    
	    pService.modify("AliEnVersion", er.param[0]);
	}
	
	p.append(pService);
	
	i++;
    }

    String JSP = "admin.jsp";

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setContentType("text/html");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");

    pMaster.append(p);

    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
            
    lia.web.servlets.web.Utils.logRequest("/services.jsp", baos.size(), request);
%>