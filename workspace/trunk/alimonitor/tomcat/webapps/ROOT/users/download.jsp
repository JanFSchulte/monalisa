<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,lazyj.mail.FileTypes,java.util.*,java.security.cert.X509Certificate" buffer="16kb"%><%!
    static{
	FileTypes.registerExtension("prod", "text/plain");
	FileTypes.registerExtension("stderr", "text/plain");
	FileTypes.registerExtension("stdout", "text/plain");
	FileTypes.registerExtension("log", "text/plain");
    }

    final void highlightC(final JspWriter out, final String sFile, final String sFileName, final String sContentType) throws IOException {
	String sSyntax = "C";

	String sExt = sFileName.trim().toLowerCase();
	
	if (sFileName.indexOf('.')>=0){
	    sExt = sFileName.substring(sFileName.lastIndexOf('.')+1).trim().toLowerCase();
	}

	if (sExt.equals("jdl") || sExt.equals("jdl~") || sExt.equals("prod") || sExt.equals("aliroot_new") || sExt.equals("rc"))
	    sSyntax = "sh";
	else
	if (sExt.equals("log") || sExt.equals("stderr") || sExt.equals("stdout")){
	    out.println("<pre><font face='Courier'>");
	    
	    BufferedReader br = new BufferedReader(new FileReader(sFile));

	    String sLine;

	    while ((sLine = br.readLine())!=null){
		if (sLine.trim().startsWith("at /")){
		    String version = null;
		    String file = null;
		    String line = null;
		
		    int idx = sLine.indexOf("/AliRoot-v");
		
		    if (idx>0){
			//    at /opt/aliroot/data/src/v5-02-Rev-34/apps/aliroot/aliroot/work/AliRoot-v5-02-Rev-34/ANALYSIS/AliAnalysisSelector.cxx:163
			int idx2 = sLine.indexOf('/', idx+9);
			version = sLine.substring(idx+9, idx2);
			file = sLine.substring(idx2+1);
			
			idx2 = file.indexOf(':');
			
			if (idx2>=0)
			    file = file.substring(0, idx2);
		    }
		    
		    if (version!=null && file!=null){
			// http://alisoft.cern.ch/viewvc/tags/v5-02-Rev-34/ANALYSIS/AliAnalysisSelector.cxx?view=markup&root=AliRoot
			sLine = sLine.substring(0, idx)+"<a target='"+Format.escHtml(version+"/"+file)+"' href='http://alisoft.cern.ch/viewvc/tags/"+Format.escHtml(version)+"/"+Format.escHtml(file)+"?view=markup&root=AliRoot'><b>"+sLine.substring(idx)+"</b></a>";
		    }
		    
		    out.println(sLine);
		}
		else{
		    sLine = lia.web.utils.HtmlColorer.logLineColorer(sLine);

    		    if (sLine.indexOf("segmentation violation")>=0 || sLine.indexOf("Segmentation fault")>=0 || sLine.indexOf("*** Break ***")>=0 || sLine.indexOf("busy flag cleared")>=0 || sLine.indexOf("Floating point exception")>=0 ||
    			sLine.indexOf("Killed")>=0 || sLine.indexOf("Bus error")>=0)
    			sLine = "<font color=red><b>"+sLine+"</b></font>";
    	    
	    	    out.println(utils.CatalogueHighlight.highlight(sLine));
	    	}
	    }
	    
	    return;
	}

	//System.err.println(sFileName + " --- "+ sSyntax);
	
	try{
	    ArrayList<String> command = new ArrayList<String>();
	    command.add("/usr/bin/highlight");
	    command.add("-I");
	    command.add(sFile);
	    command.add("--syntax"); command.add(sSyntax);
	    command.add("--doc-title");
	    command.add(sFileName);
	    
	    //System.err.println(command);
	    
	    final Process p = Runtime.getRuntime().exec(command.toArray(new String[0]));
	
	    final BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
	    final BufferedReader brErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
    
	    String sLine;
    
    	    while ( (sLine=br.readLine()) != null){
    		String line = utils.CatalogueHighlight.highlight(sLine);
    	    
		out.println(line);
	    }

	    while ( (sLine=brErr.readLine()) != null){
		out.println(sLine);
	    }
    
	    br.close();
	    brErr.close();
    
	    p.waitFor();
	}
	catch (Exception e){
	}
    }
    
    final String highlightJDL(final String sFile){
	return null;
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /users/download.jsp", 0, request);
    
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;
    
    final long lStart = System.currentTimeMillis();
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/download.jsp : User is not authenticated");
	return;
    }

    if (p.getName()==null){
	System.err.println("users/download.jsp : Unknown username, name set is "+p.getNames());
	final X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
        System.err.println("  dn: "+cert[0].getSubjectDN().getName());
	return;
    }
    
    if (p.getName().equals("spahulah") || p.getName().equals("atimmins") || p.getName().equals("ddobrigk")){
	response.setContentType("text/plain");
	out.println("Please use alien's cp command for downloading files from the Grid. This account cannot download files through the web interface any more.");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);

    final String sPath = rw.gets("path");

    final AliEnFile f = FileCache.getFile(sPath);

    if (f==null){    
	System.err.println("users/download.jsp : Invalid filename : "+sPath);
	return;
    }
    
    if (!f.exists() || !f.isFile()){
	System.err.println("users/download.jsp : This is not a file : "+sPath+" : "+f);
	
	return;
    }
    
    int size = 0;
    
    if (Users.canRead(f, p)){
	final String sTempFile = f.get(null);
	
	if (sTempFile==null){
	    response.setContentType("text/html");
	    
	    out.println("I could not fetch this file for you:<br>"+sPath);
	    
	    return;
	}
    
	final String sFileName = f.getName();
    
	String sProcessedFileName = sFileName;
	
	while (sProcessedFileName.endsWith("~"))
	    sProcessedFileName = sProcessedFileName.substring(0, sProcessedFileName.length() - 1);
    
	String sContentType = sProcessedFileName.indexOf('.')>=0 ? lazyj.mail.FileTypes.getMIMETypeOf(sProcessedFileName) : lazyj.mail.FileTypes.getMIMETypeOfExtension(sProcessedFileName);

	if (sProcessedFileName.equals("aliroot_new") || sProcessedFileName.toLowerCase().startsWith("readme"))
	    sContentType = "text/html";

	if (sContentType==null)
	    sContentType = "application/octet-stream";
	
	final boolean bView = rw.getb("view", false);

	if (!bView || !sContentType.startsWith("text/")){
	    response.setContentType(sContentType);
	    response.setHeader("Content-Disposition", "inline; filename="+sFileName);
	
	    final byte[] buff = new byte[16*1024];
	
	    int count;
	
	    FileInputStream fis = null;
	
	    final OutputStream os = response.getOutputStream();
	
	    try{
		fis = new FileInputStream(sTempFile);
	
		while ( (count = fis.read(buff)) > 0 ) {
		    os.write(buff, 0, count);
		    
		    size += count;
		}
	    }
	    catch (Exception e){
		// ignore
	    }
	    finally{
		try{
		    fis.close();
		}
		catch (Exception ee){
		    // ignore
		}
	    
	        try{
		    os.flush();
		}
		catch (Exception e){
		    // ignore
		}
		
		try{
		    out.flush();
		}
		catch (Exception e){
		    // ignore
		}
	    }
	}
	else{
	    // view
	    response.setContentType("text/html");
	    
	    highlightC(out, sTempFile, sFileName, sContentType);
	}
    }
    
    lia.web.servlets.web.Utils.logRequest("/users/download.jsp?path="+sPath+"&user="+p+"&t="+(System.currentTimeMillis() - lStart)+"&view="+rw.getb("view", false), size , request);
%>