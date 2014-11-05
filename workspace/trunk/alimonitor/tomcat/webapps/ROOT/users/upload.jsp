<%@ page import="alimonitor.*,auth.*,lazyj.*,lazyj.commands.*,alien.catalogue.*,java.io.*,java.util.*,alien.io.*,alien.user.*" buffer="16kb"%><%
    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /users/upload.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);

    String sPath = rw.gets("path");

    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
        response.sendRedirect("/catalogue/?path="+Format.encode(sPath));
	return;
    }

    final com.oreilly.servlet.MultipartRequest mpRequest = rw.initMultipartRequest("/tmp", 100*1024*1024);

    if (mpRequest==null){
        response.sendRedirect("/catalogue/?path="+Format.encode(sPath));
	return;
    }
    
    // re-initialize because it's a multipart request
    sPath = rw.gets("path");

    String sFile = mpRequest.getFilesystemName("file");

    if (sFile==null){
	response.sendRedirect("/catalogue/?path="+Format.encode(sPath));
	return;
    }
    
    final File fDel = new File("/tmp/"+sFile);
    
    response.setContentType("text/html");
    
    final AliEnFile f = FileCache.getFile(sPath);
    
    if (f==null){
	System.err.println("users/upload.jsp : invalid path : "+sPath);
	fDel.delete();
	return;
    }
    
    String sRole = Users.getRole(p, request);
    
    if (Users.canWrite(f, p)){
	final AliEnFile f2 = FileCache.getFile(sPath+"/"+sFile);
	
	if (f2.exists()){
	    out.println("File exists, you cannot overwrite");
	    fDel.delete();
	    return;
	}
	else{
	    try{
	        IOUtils.upload(fDel, sPath+"/"+sFile, UserFactory.getByUsername(sRole), 4);
	    }
	    catch (IOException ioe){
		out.println("Upload failed with the following error message: "+ioe.getMessage());
	    }
	    
	    f2.refresh();
	}
    }
    else{
	out.println("You are not allowed to write in this directory");
	fDel.delete();
	return;
    }
    
    fDel.delete();
    
    lia.web.servlets.web.Utils.logRequest("/users/upload.jsp?file="+Format.encode(sPath+"/"+sFile), (int) (new File(sFile)).length(), request);
    
    response.sendRedirect("/catalogue/?path="+Format.encode(sPath));
%>