<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.Format,java.io.*,java.util.*,java.security.cert.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/work/edit.jsp", 0, request);

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
    
    lazyj.RequestWrapper rw = new lazyj.RequestWrapper(request);
    com.oreilly.servlet.MultipartRequest mpRequest = rw.initMultipartRequest("/tmp", 100*1024*1024);

    //System.err.println("mpRequest = "+mpRequest);

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
    
    int iID = rw.geti("id");
    
    DB db = new DB();
    
    String sError = "";

    // if the request is secure, get the principal
    auth.AlicePrincipal principal = null;
    
    String sDN = null;
    
    boolean bIsAdmin = false;
    
    if (request.isSecure()){
	X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

    	if (cert!=null && cert.length>0){
	    sDN = cert[0].getSubjectDN().getName();
	    
	    principal = new auth.AlicePrincipal(sDN);

	    auth.LdapCertificateRealm realm = new auth.LdapCertificateRealm();
	    
	    bIsAdmin = realm.hasRole(principal, "pwgadmin");
	}
    }
    
    db.query("SELECT p_tag FROM pwg WHERE p_id="+iID+";");
    
    if (db.moveNext() && db.gets(1).length()>0 && !bIsAdmin){
	response.sendRedirect("../");
	return;
    }
    
    p.comment("com_prodtag", bIsAdmin);

    // is save operation?
    if (rw.gets("save").length()>0){
	boolean bInsert = false;
    
	if (iID==0){
	    db.query("SELECT max(p_id) FROM pwg;");
	    iID = db.geti(1)+1;
	    
	    bInsert = true;
	}
	
	int iGroup = rw.geti("p_group");
	int iEnergy = rw.geti("p_energy");
	int iReqEv = rw.geti("p_reqev");
	String sExpDate = rw.esc("p_expdate");
	String sTag = rw.esc("p_tag");
	String sSavannah = rw.esc("p_savannah");
	String sCollision = rw.esc("p_collision");
	
	boolean bOk;
	
	if (bInsert){
	    bOk = db.syncUpdateQuery("INSERT INTO pwg (p_id, p_group, p_collision, p_energy, p_reqev, p_expdate, p_tag, p_savannah) VALUES ("+iID+", "+iGroup+", '"+sCollision+"', "+iEnergy+", "+iReqEv+", '"+sExpDate+"', '"+sTag+"', '"+sSavannah+"');");
	}
	else{
	    bOk = db.syncUpdateQuery("UPDATE pwg SET p_group="+iGroup+", p_collision='"+sCollision+"', p_energy="+iEnergy+", p_reqev="+iReqEv+", p_expdate='"+sExpDate+"', p_tag='"+sTag+"', p_savannah='"+sSavannah+"' WHERE p_id="+iID+";");
	}
	
	if (bOk){
	    db.syncUpdateQuery("DELETE FROM pwg_responsibles WHERE pr_pid="+iID+";");
	    
	    for (String s: rw.getValues("responsibles")){
		db.syncUpdateQuery("INSERT INTO pwg_responsibles (pr_pid, pr_puid) VALUES ("+iID+", "+Integer.parseInt(s)+");");
	    }
	    
	    // ----
	    
	    String sUsername = null;
	    
	    if (principal!=null)
		sUsername = principal.getName();
    
	    db.syncUpdateQuery("INSERT INTO pwg_comments (pg_type, pg_pid, pg_comment, pg_author, pg_dn) VALUES (0, "+iID+", '"+(bInsert ? "Initial request" : "Successfully edited") +"', '"+Format.escSQL(sUsername)+"', '"+Format.escSQL(sDN)+"');");
	    
	    // ----
	    
	    String sComment = rw.esc("comment");
	    
	    if (sComment.length()>0){
		db.query("SELECT pg_comment FROM pwg_comments WHERE pg_type=1 AND pg_pid="+iID+" ORDER BY pg_id DESC LIMIT 1;");
		
		if (!db.gets(1).equals(sComment))
		    db.syncUpdateQuery("INSERT INTO pwg_comments(pg_type, pg_pid, pg_comment, pg_author, pg_dn) VALUES (1, "+iID+", '"+sComment+"', '"+Format.escSQL(sUsername)+"', '"+Format.escSQL(sDN)+"');");
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
	    
		String sFile = mpRequest.getFilesystemName(me.getValue()+"_file");

		if (sFile!=null){
		    if (!lazyj.Utils.copyFile("/tmp/"+sFile, f.getAbsolutePath())){
			sFile = null;
		    }
		}
		
		if (sFile==null){
		    // no uploaded file or error copying the file to the destination
		    String s = rw.gets(me.getValue());
		    
		    if (s.length()>0){
			FileOutputStream fos = new FileOutputStream(f);
		    
			fos.write(s.getBytes());
			fos.flush();
			fos.close();
		    }
		}
	    }
	}
	
	response.sendRedirect("../");
    }
    
    int iGroup = 0;
    String sTag = "";
        
    if (iID > 0){
	db.query("SELECT * FROM pwg WHERE p_id="+iID+";");

	iGroup = db.geti("p_group");
	
	p.modify("opt_collision_"+db.gets("p_collision"), "selected");
	
	p.fillFromDB(db);
    }

    db.query("SELECT pg_id,pg_name FROM pwg_groups WHERE pg_id>10 OR pg_id="+iGroup+" ORDER BY lower(pg_name) ASC;");
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
    
    db.query("SELECT distinct jt_field1 FROM job_types;");
    while (db.moveNext()){
	p.append("opt_tag", "<option value='"+db.gets(1)+"' "+(db.gets(1).equals(sTag) ? "selected" : "")+">"+db.gets(1)+"</option>");
    }
    
    db.query("select pu_id, pu_username, pg_name from pwg_users inner join pwg_groups on pu_group=pg_id order by lower(pg_name) asc, lower(pu_username) asc;");
    while (db.moveNext()){
	p.append("opt_responsibles", "<option value='"+db.gets(1)+"' "+(hsUsers.contains(db.geti(1)) ? "selected" : "")+">"+db.gets(2)+" ("+db.gets(3)+")</option>");
    }

    db.query("SELECT pg_comment FROM pwg_comments WHERE pg_type=1 AND pg_pid="+iID+" ORDER BY pg_id DESC LIMIT 1;");
    p.modify("comment", db.gets(1));
    
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
    
    lia.web.servlets.web.Utils.logRequest("/PWG/work/edit.jsp", baos.size(), request);
%>
