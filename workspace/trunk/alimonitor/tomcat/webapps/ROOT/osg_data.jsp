<%@ page import="alimonitor.*,lia.web.servlets.web.*,lia.web.utils.Formatare,java.util.Date,java.util.StringTokenizer,java.io.*,lia.web.utils.DoubleFormat,lia.Monitor.Store.Cache,lia.Monitor.monitor.*,lia.Monitor.Store.Fast.DB,lia.util.ntp.NTPDate,lazyj.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /map_data.jsp", 0, request);

    RequestWrapper.setNotCache(response);
    response.setHeader("Connection", "close");
    response.setHeader("Content-Language", "en");
    response.setContentType("text/xml; charset=UTF-8");

    RequestWrapper rw = new RequestWrapper(request);

    CachingStructure cs = null; //PageCache.get(request, null);
    
    if (cs!=null){
	cs.setHeaders(response);
    
	out.write(cs.getContentAsString());
	out.flush();
	
	lia.web.servlets.web.Utils.logRequest("map_data.jsp?cache=true", cs.length(), request);
	
	return;
    }

    lia.Monitor.Store.Fast.TempMemWriterInterface tmw = null;
    
    String sError = "";

    try{
        lia.Monitor.Store.TransparentStoreFast store = (lia.Monitor.Store.TransparentStoreFast) lia.Monitor.Store.TransparentStoreFactory.getStore();
	tmw = store.getTempMemWriter();
    }
    catch (Throwable t){
	sError = t.getMessage();
    }

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMap = new Page(baos, "map_data.res");
    
    String sQuery = "select * from googlemap where name in ('CERN', 'LBL', 'LLNL', 'Cloud', 'OSC', 'Houston', 'SaoPaulo');";
    DB db = new DB();

    db.query(sQuery);
    
    Page pMarker = new Page("map_data_marker.res");
    Page pLine = new Page("map_data_line.res");
    
    monPredicate predOnline  = new monPredicate("*", "MonaLisa", "localhost", -1, -1, new String[]{"CurrentParamNo"}, null);
    monPredicate predRunning = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "*", -1, -1, new String[]{"RUNNING_jobs"}, null);

    boolean bGreen = false;
    
    StringTokenizer st = new StringTokenizer(rw.gets("flags"), ",");
    
    while (st.hasMoreTokens()){
	String sFlag = st.nextToken().trim().toLowerCase();
	
	if (sFlag.equals("green"))
	    bGreen = true;
    }
    
    while(db.moveNext()){
	pMarker.modify("lat", db.gets("geo_lat"));
	pMarker.modify("long", db.gets("geo_long"));
	pMarker.modify("name", db.gets("name"));
	pMarker.modify("alias", db.gets("alias"));
	pMarker.modify("iconx", db.geti("iconx", 0));
	pMarker.modify("icony", db.geti("icony", 0));
	pMarker.modify("labelx", db.geti("labelx", 5));
	pMarker.modify("labely", db.geti("labely", -25));

	predOnline.Farm = predRunning.Node = db.gets("name");

	Result r = (Result) Cache.getLastValue(predOnline);
	
	final boolean bOnline = (r!=null && r.time > NTPDate.currentTimeMillis() - 600000) || bGreen;
	
	r = (Result) Cache.getLastValue(predRunning);
	
	final boolean bRunning = (r!=null && r.time > NTPDate.currentTimeMillis() - 600000 && r.param[0] > 0.5) || bGreen || db.gets("name").equals("NDGF");
	
	pMarker.modify("nr_jobs",  r != null ? Math.round(r.param[0])+"" : "0");
	//pMarker.modify("nr_jobs",  152);
	
	final String sImage;
	
	if (bRunning){
	    sImage = bOnline ? "green" : "orange";
	}
	else{
	    sImage = bOnline ? "yellow" : "red";
	}
	
	pMarker.modify("color", sImage);

	pMap.append("markers", pMarker);

    }
    
    String sLines = request.getParameter("lines") == null ? "false" : request.getParameter("lines");
    String sRelations = request.getParameter("relations") == null ? "false" : request.getParameter("relations");    
    
    if(sLines.equals("true")){
	db.query("select src.geo_lat as src_lat,src.geo_long as src_long,dest.geo_lat as dest_lat,dest.geo_long as dest_long from (active_xrootd_transfers inner join abping_aliases src on source=src.name) inner join abping_aliases dest on destination=dest.name;");
    
	while (db.moveNext()){
	    pLine.modify("line", "line_xrootd");
	    pLine.modify("src_lat", db.gets("src_lat"));
	    pLine.modify("src_long", db.gets("src_long"));
	
	    pLine.modify("dest_lat", db.gets("dest_lat"));
	    pLine.modify("dest_long", db.gets("dest_long"));
	
	    pLine.modify("color", "00F9F9");

	    pMap.append("lines", pLine);	
	}
    }
    
    if(sRelations.equals("true")){
	db.query("select * from site_relations_googlemap;");
    
	while (db.moveNext()){
	    pLine.modify("line", "line_relations");
	    pLine.modify("src_lat", db.gets("src_lat"));
	    pLine.modify("src_long", db.gets("src_long"));
	
	    pLine.modify("dest_lat", db.gets("dest_lat"));
	    pLine.modify("dest_long", db.gets("dest_long"));
	
	    pLine.modify("color", db.gets("color"));

	    pMap.append("lines", pLine);	
	}
    }
        
    pMap.write();
    
    cs = PageCache.put(request, null, baos.toByteArray(), 120*1000, "text/xml");
    
    cs.setHeaders(response);
    
    out.write(cs.getContentAsString());
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/map_data.jsp", cs.length(), request);
%>