<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/selist.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    RequestWrapper rw = new RequestWrapper(request);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "SE list management");
    pMaster.modify("class_selist", "_active");

    DB db = new DB();
    
    Page p = new Page("admin/selist.res");
    Page pSE = new Page("admin/selist_el.res");

    // ------- Operations ---------

    String sAddSE = rw.gets("se_name").trim();
    String sAddDescription = rw.gets("se_description").trim();
    
    if (sAddSE.length()>0 && sAddDescription.length()>0){
	db.syncUpdateQuery("DELETE FROM se_list WHERE lower(se_name)='"+Format.escSQL(sAddSE.toLowerCase())+"';");
	db.syncUpdateQuery("INSERT INTO se_list (se_name, se_description) VALUES ('"+Format.escSQL(sAddSE)+"', '"+Format.escSQL(sAddDescription)+"');");
    }
    
    String sDelSE = rw.gets("delete").trim();
    
    if (sDelSE.length()>0){
	db.syncUpdateQuery("DELETE FROM se_list WHERE lower(se_name)='"+Format.escSQL(sDelSE.toLowerCase())+"';");
    }
    
    // --------- Display ---------

    db.query("SELECT * FROM se_list ORDER BY lower(se_name) ASC;");
    while (db.moveNext()){
	pSE.fillFromDB(db);
	p.append("content", pSE);
    }

    // --------- Close -----------
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/selist.jsp", baos.size(), request);
%>