<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /PWG/index.jsp", 0, request);

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "Production requests from PWGs");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    // -------------------
    
    final HashMap<String, String> hmFiles = new HashMap<String, String>();
    
    hmFiles.put("CheckESD.C", "checkesd");
    hmFiles.put("Config.C", "config");
    hmFiles.put("rec.C", "rec");
    hmFiles.put("sim.C", "sim");
    hmFiles.put("simrun.C", "simrun");
    hmFiles.put("tag.C", "tag");
    hmFiles.put("JDL", "jdl");
    
    final String sFilesPath = BASE_PATH+"PWG/files/";
    
    Page p = new Page(null, "PWG/index.res");
    Page pLine = new Page(null, "PWG/index-line.res");
    
    p.modify("checklist", new Page(null, "PWG/checklist.res"));

    RequestWrapper rw = new RequestWrapper(request);

    int sort = rw.geti("sort", 1);

    // ------- ** -------
    //                   0           1              2          3         4           5          6           7            8          9         10
    String sColumn[] = {"p_id", "lower(pg_name)", "p_pp", "p_energy", "p_reqev", "p_prodev", "p_prio", "p_reqdate", "p_expdate", "p_tag IS NULL, length(p_tag)=0, p_tag", "jt_field2 IS NULL, jt_field2"};
    String sOrders[] = {"asc", "desc"};
    
    String sSortColumn = sColumn[sort/2];
    String sSortOrder = sOrders[sort%2];

    for (int i=0; i<sColumn.length; i++){
	int sens = sort/2==i ? 1-sort%2 : 0;
    
	p.modify("sort_"+i, i*2 + sens);
	
	if (sort/2==i){
	    p.modify("arrow_"+i, "<img border=0 src=/img/"+sOrders[sens]+".gif>");
	}
    }
    // ------- ** -------

    DB db = new DB();
    db.query("SELECT * FROM pwg_view ORDER BY "+sSortColumn+" "+sSortOrder+";");
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	boolean bAllOk = true;
	
	pLine.modify("energy", lia.web.utils.DoubleFormat.size(db.getd("p_energy"), "G", true));
	
	for (Map.Entry<String, String> me: hmFiles.entrySet()){
	    File f = new File(sFilesPath+db.gets("p_id")+"/"+me.getKey());
	    
	    boolean bFile = (f.exists() && f.isFile() && f.canRead() && f.length()>0);
	    
	    pLine.comment("com_"+me.getValue(), bFile);

	    bAllOk = bAllOk && bFile;	    
	}
	
	pLine.modify("bgcolor", bAllOk ? "#EEFFEE" : "#FFEEEE");
	
	if("Running".equals(db.gets("jt_field2")))
	    pLine.modify("statusbgcolor", "#54E715");
	    
	String sType = db.gets("jt_field2");

	if("Pending".equals(sType) || sType.startsWith("Quality") || sType.startsWith("Macros") || sType.startsWith("Software") || sType.startsWith("Technical") )
	    pLine.modify("statusbgcolor", "yellow");

	if("Completed".equals(db.gets("jt_field2")))
	    pLine.modify("statusbgcolor", "#A1EBFF");
	
	pLine.comment("com_publish", bAllOk && db.gets("p_tag").length()>0);
	
	pLine.comment("com_savannah", db.gets("p_savannah").length()>0);
	
	p.append(pLine);
    }
    
    pMaster.append(p);
    
    // -------------------
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/PWG/index.jsp", baos.size(), request);
%>
