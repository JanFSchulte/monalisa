<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*"%><%!
public String addToURL(final String sURL, final String sKey, final String sValue){
    String s = sURL;

    if (s.indexOf("?")<0)
	s += "?";
    else
	s += "&";

    return s+Format.encode(sKey)+"="+Format.encode(sValue);
}
%><%
    lia.web.servlets.web.Utils.logRequest("START /aliroot/index.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "AliRoot benchmarks");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    Page p = new Page("aliroot/index.res");
    Page pLine = new Page("aliroot/index_line.res");
    
    RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();
    
    db.query("select mcluster,mnode,split_part(mnode,'_',1) as rev,split_part(mnode,'_ALL_',2) as draft,min(rectime) as min_rectime,max(rectime) as max_rectime,max(rectime)-min(rectime) as duration, count(1) as count from aliroot_testing group by mcluster,mnode order by 4 asc, 3 desc;");
    
    DB db2 = new DB();
    
    final String sClusterCut = "AliRoot_MemProfile_";
    
    while (db.moveNext()){
	pLine.fillFromDB(db);

	String sCluster = db.gets("mcluster");
	
	if (sCluster.startsWith(sClusterCut));
	    sCluster = sCluster.substring(sClusterCut.length());
	
	pLine.modify("nicecluster", sCluster);
	
	String sDraft = db.gets("mnode");
	
	int idx = sDraft.indexOf('_');
	
	if (idx>0){
	    idx = sDraft.indexOf('_', idx+1);
	
	    if (idx>0){
		sDraft = sDraft.substring(idx+1);
	    }
	}
	
	pLine.modify("draft", sDraft);

	db2.query("SELECT mfunction,mval FROM aliroot_testing WHERE mcluster='"+Format.escSQL(db.gets(1))+"' AND mnode LIKE '"+Format.escSQL(db.gets(2))+"%' ORDER BY rectime DESC;");
	
	while (db2.moveNext()){
	    pLine.modify(db2.gets(1), db2.gets(2));
	}
	
	db2.query("SELECT mfunction,mval FROM aliroot_testing_strings WHERE mcluster='"+Format.escSQL(db.gets(1))+"' AND mnode LIKE '"+Format.escSQL(db.gets(2))+"%' ORDER BY rectime DESC;");
	
	while (db2.moveNext()){
	    pLine.modify(db2.gets(1), lia.Monitor.Store.Fast.Writer.deserializeFromString(db2.gets(2)));
	}
	
	p.append(pLine);
    }
    
    // -------------------
        
    pMaster.append(p);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
                    
    lia.web.servlets.web.Utils.logRequest("/raw/raw_details.jsp", baos.size(), request);
%>