<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,alien.pool.*,java.util.*,alien.user.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /users/newfolder.jsp", 0, request);

    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;
    
    response.setContentType("text/plain");
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/newfolder.jsp : User is not authenticated");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);

    final String sPath = rw.gets("path");

    final AliEnFile f = FileCache.getFile(sPath);

    if (f==null || !f.exists() || !f.isDirectory()){
	//System.err.println("Invalid filename : "+sPath);
	out.println("Invalid filename : "+sPath);
	return;
    }
    
    String sNewFolder = rw.gets("newfolder");
    
    if (!sNewFolder.matches("^[~a-zA-Z0-9_.:-]+( +[~a-zA-Z0-9_.:-]+)*$") || sNewFolder.length()>50 || sNewFolder.equals(".") || sNewFolder.equals("..")){
	out.println("Illegal new folder name : "+sNewFolder);
	return;
    }

    boolean bOk = false;
    String sReason = "";

    String sRole = Users.getRole(p, request);

    AliEnPrincipal owner = UserFactory.getByUsername(sRole);
    
    LFN dir = LFNUtils.getLFN(sPath);

    if (!AuthorizationChecker.canWrite(dir,owner)){
	sReason = "Sorry, you are not allowed to write in this folder";
    }
    else{
	final AliEnFile newFolder = FileCache.getFile(sPath+"/"+sNewFolder);
	
	newFolder.refresh();
	
	if (newFolder.exists()){
	    sReason = "This name already exists";
	}
	else{
	    if (newFolder.mkdir(UserFactory.getByUsername(sRole))){
		bOk = true;
	    }
	    else{
		sReason = "Could not talk to AliEn";
	    }
	}
    }
    
    if (bOk)
	out.println("OK");
    else
	out.println(sReason);
    
    lia.web.servlets.web.Utils.logRequest("/users/newfolder.jsp?path="+sPath+"&newfolder="+sNewFolder+"&ok="+bOk+"&reason="+sReason+"&user="+p, 0, request);
%>