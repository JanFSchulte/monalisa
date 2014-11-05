<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,java.security.cert.*,auth.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;
	
    lia.web.servlets.web.Utils.logRequest("START /DAQ/list.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("DAQ/list.res");
    final Page pLine = new Page("DAQ/list_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "300");
    pMaster.modify("title", "DAQ RAW Data Runs");
  
    // ----- parameters
    
    String partition = rw.gets("partition").trim();
    
    final DB db = new DB();
    
    if (partition.length()==0){
	db.query("select distinct partition from rawdata_runs where position('_' in partition)<=0 order by partition desc limit 1;");
	
	partition=db.gets(1); 
    }
    
    db.query("SELECT distinct partition from rawdata_runs where position('_' in partition)<=0 order by partition desc;");
    
    while (db.moveNext()){
	final String s = db.gets(1);
	p.append("opt_partition", "<option value='"+Format.escSQL(s)+"'"+(s.equals(partition) ? " selected" : "")+">"+Format.escSQL(s)+"</option>");
    }
    
    // ----- content
    
    db.query("SELECT * FROM rawdata_runs WHERE partition='"+Format.escSQL(partition)+"' ORDER BY run DESC;");
    
    final StringBuilder sbRuns = new StringBuilder();
    
    while (db.moveNext()){
	final int run = db.geti("run");
	
	if (sbRuns.length()>0)
	    sbRuns.append(", ");
	sbRuns.append(run);
	
	pLine.fillFromDB(db);
	p.append(pLine);
    }
    
    p.modify("runlist", sbRuns);
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/DAQ/list.jsp", baos.size(), request);
%>