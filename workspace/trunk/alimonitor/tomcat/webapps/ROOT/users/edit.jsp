<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,java.util.*,alien.io.*,alien.user.*" buffer="16kb"%><%
    lia.web.servlets.web.Utils.logRequest("START /users/edit.jsp", 0, request);

    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;
    
    response.setContentType("text/html");
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/edit.jsp : User is not authenticated");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);

    final String sPath = rw.gets("path");

    final AliEnFile f = FileCache.getFile(sPath);
    
    if (f==null){
	System.err.println("users/edit.jsp : Invalid filename : "+sPath);
	return;
    }
    
    if (f.exists() && !f.isFile()){
	out.println("The specified path exists but is not a file");
	return;
    }

    final boolean bNew = rw.getb("new", false);
    
    if (!f.exists() && !bNew){
	// it really doesn't exist?
	f.refresh();
    }
    
    final String sFileName = f.getName();
    
    String l = sFileName.toLowerCase();
    
    if (l.endsWith("~"))
	l = l.substring(0, l.length()-1);

    final String sContentType = lazyj.mail.FileTypes.getMIMETypeOf(l);

    if ( (!sContentType.startsWith("text/")) && !(l.equals("post_install")) && !(l.equals("aliroot_new")) && !(l.startsWith("jdl")) && !(l.startsWith("readme")) ){
	out.println("Sorry, you can only edit text files with this tool");
	return;
    }

    String mode = "text";

    if (l.endsWith(".c") || l.endsWith("cc"))
	mode = "c_cpp";
    else if (l.endsWith(".sh") || l.endsWith(".rc"))
        mode = "sh";
    else if (l.endsWith(".html"))
        mode = "html";
    else if (l.endsWith(".xml"))
        mode = "xml";
    else if (l.endsWith("jdl"))
        mode = "python";

    
    final AliEnFile fParent = FileCache.getFile(f.getPath());
    
    if (fParent==null){
	System.err.println("users/edit.jsp : Invalid parent path : "+f.getPath());
	return;
    }
    
    if (!Users.canWrite(fParent, p)){
	out.println("Sorry, you don't have permissions to write here");
	return;
    }
    
    String sSaveContent = rw.gets("save");

    final Page pe = new Page("users/edit.res");
    
    if (sSaveContent.length()>0){
	sSaveContent = Format.replace(sSaveContent, "\r", "");
    
	final File fUp = File.createTempFile("edit-upload", null);
	
	final FileOutputStream fos = new FileOutputStream(fUp);
	
	fos.write(sSaveContent.getBytes());
	
	fos.flush();
	
	fos.close();
	
	String sOwner = fParent.getOwner();
	
	AliEnPrincipal owner = null;
    
	if (f.exists()){
	    sOwner = f.getOwner();

	    owner = UserFactory.getByUsername(sOwner);

	    if (!IOUtils.backupFile(f.getCannonicalName(), owner)){
		sOwner = fParent.getOwner();
		
		owner = UserFactory.getByUsername(sOwner);
		
		IOUtils.backupFile(f.getCannonicalName(), owner);
	    }
	    
	    AliEnFile fTilda = FileCache.getFile(f.getCannonicalName()+"~");
	    
	    fTilda.refresh();
	}

	try{
	    if (owner==null)
		owner = UserFactory.getByUsername(sOwner);
	
	    IOUtils.upload(fUp, f.getCannonicalName(), owner, 4);
	}
	catch (IOException e){
	    // ignore
	}
	
	fUp.delete();
	
	f.refresh();
	
	if (f.exists())
	    pe.modify("message", "<font color=green><b>File saved</b></font>");
	else
	    pe.modify("message", "<font color=red><b>Error saving the file</b></font>");
    }

    pe.modify("path", f.getCannonicalName());
    
    String sContent = sSaveContent.length()>0 || bNew ? sSaveContent : f.getContents(true);

    if (sContent==null){
	// cannot get the file
	
	pe.modify("message", "<font color=red><b>Sorry, I could not fetch this file</b></font>");
	
	sContent = sSaveContent;
    }
    
    pe.modify("content", sContent);

//    System.err.println("Mode: "+mode);

    pe.modify("mode", mode);
    
    out.println(pe);
    
    lia.web.servlets.web.Utils.logRequest("/users/edit.jsp?path="+sPath+"&user="+p, sContent.length(), request);
%>