<%@ page import="alimonitor.*,lazyj.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.Monitor.Store.*,lia.Monitor.Store.Fast.*,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/multiconsole.jsp", 0, request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page p = new Page(baos, "admin/multiconsole.res");
    final Page pDiv = new Page(null, "admin/multiconsole_div.res");
    final Page pPane = new Page(null, "admin/multiconsole_pane.res");

    final RequestWrapper rw = new RequestWrapper(request);

    final Map<String, Set<String>> emails = new TreeMap<String, Set<String>>();

    final boolean bNotifyAdmin = rw.getb("notifyadmin", false);

    // --------------
    
    for (String s: rw.getValues("s")){
	pDiv.modify("site", s);
	pPane.modify("site", s);

	p.append("panes", pPane);
	p.append("divs", pDiv);
	
	if (bNotifyAdmin) {
	    final DB db = new DB("SELECT contact_email FROM abping_aliases WHERE name='"+Format.escSQL(s)+"';");
	    
	    if (db.moveNext()){
		final String sEmail = db.gets(1).trim();
		
		if (sEmail.length()>0){
		    Set<String> sitesPerEmail = emails.get(sEmail);
		    
		    if (sitesPerEmail==null){
			sitesPerEmail = new TreeSet<String>();
			emails.put(sEmail, sitesPerEmail);
		    }

		    sitesPerEmail.add(s);		    
		}
	    }
	}
    }
    
    // --------------

    final String sCommand = rw.gets("command");
    
    if (sCommand.length()>0){
	final Page pCmd = new Page(null, "admin/multiconsole_initialcmd.res");
	
	pCmd.modify("command", sCommand);
	p.modify("initial_command", pCmd);
    }

    p.write();
    
    out.println(new String(baos.toByteArray()));

    for (Map.Entry<String, Set<String>> account: emails.entrySet()){
	lia.util.mail.MailSender ms = lia.util.mail.DirectMailSender.getInstance();
	
	String email = account.getKey();
	Set<String> sites = account.getValue();
	
	try{
	    ms.sendMessage("monalisa@alimonitor.cern.ch", email.split(","), "Your AliEn installation is automatically updated "+sites, "This is just to let you know that the AliEn installation on your site(s) is currently upgraded automatically on "+sites+". Maybe later you can check if everything went ok. Thanks a lot for your cooperation :)");
	    System.err.println("admin/multiconsole.jsp : update notification: successfully sent email to: "+email+" "+sites);
	}
	catch (Exception e){
	    System.err.println("admin/multiconsole.jsp : update notification: failed sending email to: "+email+" "+sites);
	}
    }
    
    lia.web.servlets.web.Utils.logRequest("/admin/multiconsole.jsp", baos.size(), request);
%>