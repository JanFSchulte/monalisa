<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.*,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*,lazyj.*,lazyj.mail.*" buffer="none" %><%
    lia.web.servlets.web.Utils.logRequest("START /admin/packageinstall.jsp", 0, request);

    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");
    response.setHeader("Admin", "Costin Grigoras <costin.grigoras@cern.ch>");
    
    /* --------- */
    
    final RequestWrapper rw = new RequestWrapper(request);

    final boolean bText = rw.getb("text", false);

    response.setContentType(bText ? "text/plain" : "text/html");
    
    String[] vsPackages = request.getParameterValues("install");
    
    if (vsPackages==null){
	out.println("Nothing to do! Go back and select something first.");
	out.flush();
	return;
    }
    
    String sMessage = "Installing";
    
    String sScript = "/home/monalisa/MLrepository/bin/packages/install.sh";
    
    if (request.getParameter("isremove")!=null){
	sScript = "/home/monalisa/MLrepository/bin/packages/remove.sh";
	sMessage = "Removing";
    }
  
    //install name should contain all this information
    String sPackageName;
    String sPackageVersion;
    String sPackagePlatform;
    String sAutomaticEmail;

    //get available platforms   
    URL urlServerList = new URL("http://alienbuild.cern.ch:8889/BitServers");
    
    URLConnection conn = urlServerList.openConnection();
    
    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    
    ArrayList<String> alPlatformNames = new ArrayList<String>();
    ArrayList<String> alPlatformURLs = new ArrayList<String>();
    
    String sLine;
    
    while ( (sLine=br.readLine()) != null ){
	
	StringTokenizer st = new StringTokenizer(sLine, "|");
	
	if (st.countTokens()>=2){
	    if (st.countTokens()>=3)
		st.nextToken();
	    
	    String sPlatformName = st.nextToken().trim();
	    String sURL = st.nextToken().trim();
	    
	    alPlatformNames.add(sPlatformName);
	    alPlatformURLs.add(sURL);
	}
    }
    
    br.close();    
    //end availables platforms
    
    for (String sPackage: vsPackages){
	
	if (bText)
	    out.println(sMessage+" : "+sPackage);
	else
	    out.println(sMessage+" : <B>"+sPackage+"</B> ... <BR>");
	    
	out.flush();
    
	try{
	    Process child = lia.util.MLProcess.exec(new String[]{sScript, sPackage}, 1000*60*5);
    
	    OutputStream child_out = child.getOutputStream();
	    child_out.close();
    
	    br = new BufferedReader(new InputStreamReader(child.getInputStream()));
	
	    while ( (sLine=br.readLine())!=null ){
		if (bText)
		    out.println(sLine);
		else
	    	    out.println(HtmlColorer.logLineColorer(sLine)+"<BR>");
	    	    
		out.flush();
		response.flushBuffer();
	    }
	    br.close();
	}
	catch (Exception e){
	    if (bText)
		out.println("Exception: "+e+" ("+e.getMessage()+")");
	    else
		out.println("<i>Exception: "+e+" ("+e.getMessage()+")</i><BR>");
		
	    out.flush();
	}
	
	
	String[] pkginfo = sPackage.split(" ");
	
	if(pkginfo.length  != 3){

	    if (bText)
		out.println(sMessage+" : "+sPackage+" incorrect packaname. Disabling automatic email");
	    else
		out.println(sMessage+" : <B>"+sPackage+" incorrect packaname. Disabling automatic email</B> ... <BR>");
	    
	    out.flush();
	
	}else{
	    sPackageName = pkginfo[0];
	    sPackageVersion = pkginfo[1];
	    sPackagePlatform = pkginfo[2];
	    
	    sAutomaticEmail = lazyj.Utils.readFile("/var/packages_spool/emails."+sPackageVersion);
	    
	    //we need to check if all platforms are installed
	    if(sAutomaticEmail != null && sAutomaticEmail.length() > 0){
		try{
		
		    //first check if an email was already sent, if yes then we need to inform that we don't send  the email
		    DB db = new DB();
		    
		    db.query("SELECT * FROM register_package_email WHERE package_name='"+Format.escSQL(sPackageName+" "+sPackageVersion)+"';");
		    
		    if(!db.moveNext()){
		    	
			String s = "/home/monalisa/MLrepository/bin/packages/manage_alien_package.sh show_package_platforms "+sPackageName+" "+sPackageVersion;

			Process child = lia.util.MLProcess.exec(s, 1000*60*5);
    
			OutputStream child_out = child.getOutputStream();
			child_out.close();
    
			br = new BufferedReader(new InputStreamReader(child.getInputStream()));
	
			int iPlCnt=0;
			ArrayList<String> allInstalledPlatforms = new ArrayList<String>();
	    
			while ( (sLine=br.readLine())!=null ){
			    if (bText)
				out.println(sLine);
			    else
	    			out.println(HtmlColorer.logLineColorer(sLine)+"<BR>");
	    	    
	    		    allInstalledPlatforms.add(sLine);
			    out.flush();
			    response.flushBuffer();
			
			    iPlCnt ++;
			}
		    
			br.close();
		        
		        if(allInstalledPlatforms.contains("Linux-i686") && allInstalledPlatforms.contains("Linux-x86_64") && allInstalledPlatforms.contains("Ubuntu-x86_64")){
			    out.println("Sending email to "+sAutomaticEmail);
			    out.flush();
			
			    String sToEmail = "alina.gabriela.grigoras@cern.ch";
			
			    Mail mMail = new Mail();
			
			    mMail.sFrom = "Alina.Gabriela.Grigoras@cern.ch";
			    mMail.sTo = sAutomaticEmail;
			    mMail.sSubject = sPackageName+"::"+sPackageVersion+" on the Grid";
			    mMail.sHTMLBody = "Dear all, <br/><br/>";
			    mMail.sHTMLBody += sPackageName+"::"+sPackageVersion+" was registered to AliEn and it is ready to be used. <br/><br/>";
			    mMail.sHTMLBody += "Packages = {<br/>";
			    mMail.sHTMLBody +=	    "&nbsp;&nbsp;&nbsp;&nbsp;VO_ALICE@"+sPackageName+"::"+sPackageVersion;

			    s = "/home/monalisa/MLrepository/bin/packages/manage_alien_package.sh show_package_dependencies "+sPackageName+" "+sPackageVersion;
			
			    child = lia.util.MLProcess.exec(s, 1000*60*5);
    
			    child_out = child.getOutputStream();
			    child_out.close();
    
			    br = new BufferedReader(new InputStreamReader(child.getInputStream()));
	
			    sLine=br.readLine();
			    if (bText)
				out.println(sLine);
			    else
	    			out.println(HtmlColorer.logLineColorer(sLine)+"<BR>");
	    	    
			    out.flush();
		    
			    br.close();
			
			    if(!sLine.equals("")){
				mMail.sHTMLBody += ",<br />&nbsp;&nbsp;&nbsp;&nbsp;"+sLine.replace(",", ",<br />&nbsp;&nbsp;&nbsp;&nbsp;");
			    }
			
			    mMail.sHTMLBody += "<br />}<br/><br />";
			    
			    String sOtherBody = lazyj.Utils.readFile("/var/packages_spool/text."+sPackageVersion);
			    
			    if(sOtherBody != null && sOtherBody.length() > 0){
				mMail.sHTMLBody += sOtherBody;
				mMail.sHTMLBody += "<br /><br />";
			    }
			    
			    mMail.sHTMLBody += "Have fun, <br />Alina" ;

			    Sendmail sSendMail = new Sendmail("Alina.Gabriela.Grigoras@cern.ch", "cernmx.cern.ch");
			    
			    if(sSendMail.send(mMail)){
				db.query("INSERT INTO register_package_email (package_name) values ('"+Format.escSQL(sPackageName+" "+sPackageVersion)+"');");
			    }
			    else{
			    
				if (bText)
				    out.println("Error sending email!");
				else
				    out.println("<font color=\"red\">Error sending email</font><BR>");
		
				out.flush();

			    }
			
			}
		    }
		    else{		    
			if (bText)
			    out.println("An email was already sent! We don't need to spam!");
			else
			    out.println("<font color=\"red\">An email was already sent! We don't need to spam!</font><BR>");
		
			out.flush();
		    }
		}
		catch (Exception e){
		    if (bText)
			out.println("Exception: "+e+" ("+e.getMessage()+")");
		    else
			out.println("<i>Exception: "+e+" ("+e.getMessage()+")</i><BR>");
		
		    out.flush();
		}
	    }
	}   

	if (bText)
	    out.println("_____________________________________________________________________________________________________________________\n");
	else
	    out.println("<HR size=1>");
	    
	out.flush();

    }
    
    if (bText){
	out.println("DONE");
    }
    else{
	out.println("<B>DONE</B><BR>");
	//out.println("<script type=\"text/javascript\"> function winclose() { if (window.opener) { if (window.opener.refresh) window.opener.refresh(); else window.opener.reload(); } else alert('cannot refresh'); window.close();} </script>");
	out.println("<a href=packagemanager.jsp>Back to the management page</a>");
    }
    
    out.flush();
    
    /* --------- */
    
    alien.managers.InstalledPackagesUpdater.asyncUpdate();
    
    lia.web.servlets.web.Utils.logRequest("/admin/packageinstall.jsp?message="+sMessage, 1, request);
%>