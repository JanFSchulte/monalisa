<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.Format,java.io.*,java.util.*,java.security.cert.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/work/edit1.jsp", 0, request);

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String FILES_PATH = SITE_BASE + "/PWG/files/";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "Physics Working Group");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------

    Page p = new Page(null, "PWG/work/edit.res");
    Page pFile = new Page(null, "PWG/work/edit-file.res");
    
    final TreeMap<String, String> tmFiles = new TreeMap<String, String>();
    
    tmFiles.put("CheckESD.C", "checkesd");
    tmFiles.put("Config.C", "config");
    tmFiles.put("rec.C", "rec");
    tmFiles.put("sim.C", "sim");
    tmFiles.put("simrun.C", "simrun");
    tmFiles.put("tag.C", "tag");
    tmFiles.put("JDL", "jdl");
    
    int iID = 0;
    
    try{
	iID = Integer.parseInt(request.getParameter("id"));
    }
    catch (Exception e){
    }
    
    DB db = new DB();
    
    // is save operation?
    
    String sError = "";
    
    if (request.getParameter("save") != null){
	boolean bInsert = false;
    
	if (iID==0){
	    db.query("SELECT nextval('pwg_p_id_seq');");
	    iID = db.geti(1);
	    
	    bInsert = true;
	}
	
	lazyj.RequestWrapper rw = new lazyj.RequestWrapper(request);
	
	int iGroup = rw.geti("p_group");
	boolean bPP = rw.getb("p_pp", true);
	int iEnergy = rw.geti("p_energy");
	int iReqEv = rw.geti("p_reqev");
	String sExpDate = rw.esc("p_expdate");
	
	boolean bOk;
	
	if (bInsert){
	    bOk = db.query("INSERT INTO pwg (p_id, p_group, p_pp, p_energy, p_reqev, p_expdate) VALUES ("+iID+", "+iGroup+", "+bPP+", "+iEnergy+", "+iReqEv+", '"+sExpDate+"');");
	}
	else{
	    bOk = db.query("UPDATE pwg SET p_group="+iGroup+", p_pp="+bPP+", p_energy="+iEnergy+", p_reqev="+iReqEv+", p_expdate='"+sExpDate+"' WHERE p_id="+iID+";");
	}
	
	if (bOk){
	    db.query("DELETE FROM pwg_responsibles WHERE pr_pid="+iID+";");
	    
	    String[] vsResponsibles = request.getParameterValues("responsibles");
	    if (vsResponsibles!=null){
	        for (String s: vsResponsibles){
		    db.query("INSERT INTO pwg_responsibles (pr_pid, pr_puid) VALUES ("+iID+", "+Integer.parseInt(s)+");");
		}
	    }
	    
	    // ----
	    
	    String sDN = null;
	    String sUsername = null;

	    if (request.isSecure()){
		X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
	
	    	if (cert!=null && cert.length>0){
		    sDN = cert[0].getSubjectDN().getName();
	    
		    auth.AlicePrincipal principal = new auth.AlicePrincipal(sDN);
	    
		    sUsername = principal.getName();
		}
	    }
    
	    db.query("INSERT INTO pwg_comments (pg_type, pg_pid, pg_comment, pg_author, pg_dn) VALUES (0, "+iID+", '"+(bInsert ? "Initial request" : "Successfully edited") +"', '"+Format.escSQL(sUsername)+"', '"+Format.escSQL(sDN)+"');");
	    
	    // ----
	    
	    String sComment = rw.esc("comment");
	    
	    if (sComment.length()>0){
		db.query("INSERT INTO pwg_comments(pg_type, pg_pid, pg_comment, pg_author, pg_dn) VALUES (1, "+iID+", '"+sComment+"', '"+Format.escSQL(sUsername)+"', '"+Format.escSQL(sDN)+"');");
	    }
	    
	    // ----
	    
	    for (Map.Entry<String, String> me: tmFiles.entrySet()){
		File fDir = new File(FILES_PATH+iID);
	    
		try{
		    fDir.mkdirs();
		}
		catch (Exception e){
		}
	    
		File f = new File(fDir, me.getKey());
		
		if (f.exists())
		    f.delete();

		String s = rw.gets(me.getValue());
		    
		if (s.length()>0){
		    FileOutputStream fos = new FileOutputStream(f);
		    
		    fos.write(s.getBytes());
		    fos.flush();
		    fos.close();
		}
	    }
	}
	
	response.sendRedirect("../");
    }
    
    int iGroup = 0;
        
    if (iID > 0){
	db.query("SELECT * FROM pwg WHERE p_id="+iID+";");

	iGroup = db.geti("p_group");
	
	String sPP = db.gets("p_pp").toLowerCase();
	
	boolean bPP = sPP.length()==0 || sPP.startsWith("t") || sPP.startsWith("1");
	
	p.modify("opt_pp_"+bPP, "selected");
	
	p.fillFromDB(db);
    }

    db.query("SELECT pg_id,pg_name FROM pwg_groups ORDER BY lower(pg_name) ASC;");
    while (db.moveNext()){
	p.append("opt_group", "<option value='"+db.gets(1)+"' "+(db.geti(1)==iGroup ? "selected" : "")+">"+db.gets(2)+"</option>");
    }
    
    HashSet<Integer> hsUsers = new HashSet<Integer>();
    
    if (iID > 0){
	db.query("SELECT pr_puid FROM pwg_responsibles WHERE pr_pid="+iID+";");
	
	while (db.moveNext()){
	    hsUsers.add(db.geti(1));
	}
    }
    
    db.query("select pu_id, pu_username, pg_name from pwg_users inner join pwg_groups on pu_group=pg_id order by lower(pg_name) asc, lower(pu_username) asc;");
    while (db.moveNext()){
	p.append("opt_responsibles", "<option value='"+db.gets(1)+"' "+(hsUsers.contains(db.geti(1)) ? "selected" : "")+">"+db.gets(2)+" ("+db.gets(3)+")</option>");
    }
    
    for (Map.Entry<String, String> me: tmFiles.entrySet()){
	pFile.modify("filename", me.getKey());
	pFile.modify("filename_field", me.getValue());

	if (iID>0){
	    File f = new File(FILES_PATH+iID+"/"+me.getKey());
	    
	    if (f.exists() && f.isFile() && f.canRead() && f.length()>0){
		ByteArrayOutputStream fbaos = new ByteArrayOutputStream((int) f.length());
		
		byte[] buff = new byte[10240];
		
		int count;

		FileInputStream fr = new FileInputStream(f);
		
		while ( (count=fr.read(buff)) > 0 ){
		    fbaos.write(buff, 0, count);
		}
		
		String s = new String(fbaos.toByteArray());
		
		pFile.modify("file_content", s);
	    }
	}
	
	p.append("files", pFile);
    }
    
    pMaster.append(p);

    // -------------------
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/PWG/work/edit1.jsp", baos.size(), request);
%>
