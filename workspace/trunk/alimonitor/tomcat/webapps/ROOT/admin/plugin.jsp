<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/plugin.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    RequestWrapper rw = new RequestWrapper(request);
            
    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "Firefox plugin settings");
    pMaster.modify("class_plugin", "_active");

    DB db = new DB();
    
    Page p = new Page("admin/plugin.res");

    // --------- Update
    if (rw.geti("change", 0)==1){
	for (String s: new String[]{"value", "href", "tooltiptext", "color"}){
	    db.syncUpdateQuery("UPDATE plugin_settings SET ps_value='"+rw.esc(s)+"' WHERE ps_key='"+s+"';");
	}
    }

    // --------- Display ---------

    db.query("SELECT ps_key,ps_value FROM plugin_settings;");
    while (db.moveNext()){
	p.modify(db.gets(1), db.gets(2));
    }

    // --------- Close -----------
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/plugin.jsp", baos.size(), request);
%>