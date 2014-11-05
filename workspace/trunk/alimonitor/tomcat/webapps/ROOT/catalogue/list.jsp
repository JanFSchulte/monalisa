<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    final RequestWrapper rw = new RequestWrapper(request);

    final boolean bDebug = true;

    final Page p = new Page(response.getOutputStream(), "catalogue/list.res", bDebug);
    final Page pFile = new Page("catalogue/list_file.res", bDebug);
    final Page pFolder = new Page("catalogue/list_folder.res", bDebug);
    final Page pCollection = new Page("catalogue/list_collection.res", bDebug);

    long lTotalSize = 0;
    int iCount = 0;
    int iCollections = 0;
    int iFoldersCount= 0;

    final String sPath = rw.gets("path");

    p.modify("folder", sPath);

    AlicePrincipal pUser = Users.get(request);
    
    if (pUser==null){
	p.comment("auth", false);
    }
    else{
	p.comment("auth", true);
	
	p.modify("account", pUser.getName());
	p.modify("account_home", Users.getHomeDir(pUser.getName()));
	
	Set<String> all = new HashSet<String>(pUser.getNames());
	
	//System.err.println("all(1) for "+pUser.getName()+" : "+all);
	
	if (all.size()<=1){
	    Set<String> roles = pUser.getRoles();
	    
	    if (roles!=null && roles.size()>0)
		all.addAll(roles);
	}
	
	//System.err.println("all(2) for "+pUser.getName()+" : "+all);
	
	if (all.size()>1){
	    p.comment("com_roles", all.size()>1);
	    final String sRole = Users.getRole(pUser, request);
	    
	    p.modify("role_home", Users.getHomeDir(sRole));
	    
	    p.modify("role", sRole);
	}
    }

    try{
	final AliEnFile f = FileCache.getFile(sPath);
	
	//System.err.println(f);
	
	final StringTokenizer st = new StringTokenizer(sPath, "/");
	
	String sFullPath = "";
	
	boolean bFirst = true;
	
	while (st.hasMoreTokens()){
	    final String sTok = st.nextToken();
	    
	    if (bFirst){
		p.append("path", "<a class=link href=\"javascript:openFolder('/')\">/</a>");
		bFirst = false;
	    }
	    else{
		p.append("path", "/");
	    }
	
	    sFullPath += "/"+sTok;
	    
	    p.append("path", "<a class=link href=\"javascript:openFolder('"+Format.escJS(sFullPath)+"');\">"+sTok+"</a>");
	}
	
	for (AliEnFile sub : f.list()){
	    //System.err.println(sub);
	
	    if (sub.isFile()){
		pFile.modify("permissions", sub.getPermissions());
		pFile.modify("owner", sub.getOwner());
		pFile.modify("group", sub.getGroup());
		pFile.modify("filename", sub.getName());
		pFile.modify("fullname", sub.getCannonicalName());
		pFile.modify("size", sub.getSize());
		pFile.modify("filetime", sub.getDate());
		
		p.append(pFile);
		
		if (sub.isFile()){
		    iCount ++;
		    lTotalSize += sub.getSize();
		}
		
		if (sub.isCollection()){
		    pFile.modify("", "");
		    iCollections ++ ;
		}
	    }
	    else
	    if (sub.isDirectory()){
		pFolder.modify("permissions", sub.getPermissions());
		pFolder.modify("owner", sub.getOwner());
		pFolder.modify("group", sub.getGroup());
		pFolder.modify("filename", sub.getName());
		pFolder.modify("fullname", sub.getCannonicalName());
		pFolder.modify("filetime", sub.getDate());
		
		iFoldersCount ++;
		
		p.append("folders", pFolder);
	    }
	    else
	    if (sub.isCollection()){
		pCollection.modify("permissions", sub.getPermissions());
		pCollection.modify("owner", sub.getOwner());
		pCollection.modify("group", sub.getGroup());
		pCollection.modify("filename", sub.getName());
		pCollection.modify("fullname", sub.getCannonicalName());
		pCollection.modify("size", sub.getSize());
		pCollection.modify("filetime", sub.getDate());
		pCollection.modify("count", sub.list().size());
		
		p.append("collections", pCollection);
		
		iCollections ++ ;
	    }
	}
    }
    catch (Exception e){
    }
    
    p.comment("com_folders", iFoldersCount>0);
    p.comment("com_files", iCount>0);
    p.comment("com_collections", iCollections>0);
    
    p.modify("count", iCount);
    p.modify("collectionscount", iCollections);
    p.modify("size", lTotalSize);
    p.modify("folderscount", iFoldersCount);

    p.modify("s_folders", iFoldersCount>1 ? "s" : "");
    p.modify("s_collections", iCollections > 1 ? "s" :"");
    p.modify("s_files", iCount > 1 ? "s" : "");
    
    p.write();
    
    lia.web.servlets.web.Utils.logRequest("/catalogue/list.jsp?path="+sPath, 0, request);
%>