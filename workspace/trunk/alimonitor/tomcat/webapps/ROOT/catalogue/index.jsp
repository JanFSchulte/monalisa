<%@ page import="lazyj.*,alien.catalogue.*,alien.transfers.*,alimonitor.*,java.util.*,java.io.*,lia.Monitor.Store.Fast.*,java.security.cert.*,auth.*" %><%!
    private static String cond(final String sPrev, final String sCond){
	if (sPrev==null || sPrev.length()==0 || sPrev.toLowerCase().indexOf(" where ")<0)
	    return " WHERE ("+sCond+")";

	return sPrev+" AND ("+sCond+")";
    }
    
    private static String openPath(final ArrayList<AliEnFile> path, final int idx){
	if (path.size()==0){
	    return "<li parentId=\"/\"><a href=\"#\">Loading...</a></li>";
	}
	
	if (idx>=path.size())
	    return "";
    
	final AliEnFile f = path.get(idx);

	final Page pFolder = new Page("catalogue/index_folder.res");

	pFolder.modify("name", f.getName());
	pFolder.modify("fullname", f.getCannonicalName());
	
	AliEnFile fNext = null;
	
	if (idx<path.size()-1){
	    fNext = path.get(idx+1);
	}

	final Page pFolderClose = new Page("catalogue/index_folder_close.res");
	
	boolean bAnyEntry = false;
	
	for (AliEnFile sub: f.list()){
	    if (!sub.isDirectory())
		continue;
	
	    bAnyEntry = true;
	
	    if (fNext==null || !sub.getCannonicalName().equals(fNext.getCannonicalName())){
		pFolderClose.modify("name", sub.getName());
		pFolderClose.modify("fullname", sub.getCannonicalName());

		pFolder.append(pFolderClose);
	    }
	    else{
		pFolder.append(openPath(path, idx+1));
	    }
	}
	
	if (!bAnyEntry){
	    pFolderClose.modify("name", f.getName());
	    pFolderClose.modify("fullname", f.getCannonicalName());
	    
	    return pFolderClose.toString();
	}
	
	return pFolder.toString();
    }
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /catalogue/index.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setNotCache(response);

    final ServletContext sc = getServletContext();
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(50000);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");


    pMaster.append("extrastyle", "<link rel=\"stylesheet\" href=\"css/folder-tree-static.css\" type=\"text/css\">");
    pMaster.append("extrastyle", "<link rel=\"stylesheet\" href=\"css/context-menu.css\" type=\"text/css\">");
    //pMaster.append("extrastyle", "<script type=\"text/javascript\" src=\"js/ajax.js\"></script>");
    pMaster.append("extrastyle", "<script type=\"text/javascript\" src=\"js/folder-tree-static.js\"></script>");
    pMaster.append("extrastyle", "<script type=\"text/javascript\" src=\"js/context-menu.js\"></script>");
    pMaster.append("extrastyle", "<link rel=\"stylesheet\" href=\"css/table.css\" type=\"text/css\">");
    pMaster.append("extrastyle", "<script type=\"text/javascript\" src=\"js/table.js\"></script>");
    
    final Page p = new Page("catalogue/index.res", false);

    String sReqPath = rw.gets("path").trim();
    
    if (sReqPath.length()<=1){
	// is it an authenticated request ?
	
	final AlicePrincipal principal = Users.get(request);
    
	if (principal!=null){
	    sReqPath = Users.getHomeDir(principal.getName());
	}
	
	if (sReqPath==null || sReqPath.length()<=1)
	    sReqPath = "/alice/data/"+((new Date()).getYear()+1900);
    }
	
    StringTokenizer st = new StringTokenizer(sReqPath, "/");
    
    String sPath = "";
    
    ArrayList<AliEnFile> path = new ArrayList<AliEnFile> ();
    
    String sDirPath = "";
    
    while (st.hasMoreTokens()){
	sPath = sPath + "/" + st.nextToken();
    
	AliEnFile f = FileCache.getFile(sPath);
	
	if (!f.isDirectory())
	    break;
	    
	sDirPath = sPath;
	    
	p.append("path_list", ",'"+f.getCannonicalName()+"'");
	
	path.add(f);
    }
    
    String sPrev = "";

    p.modify("open_path", openPath(path, 0));
    
    //p.modify("initialpath", sReqPath);
    p.modify("initialpath", sDirPath);
    
    pMaster.modify("title", "AliEn file catalogue browser - "+sDirPath);

    // ------------------------ final bits and pieces

    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);

    lia.web.servlets.web.Utils.logRequest("/catalogue/index.jsp?path="+sReqPath, baos.size(), request);
%>