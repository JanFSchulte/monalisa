<%@ page import="lazyj.*,lia.Monitor.Store.Fast.*,alien.daq.*" %><%
    final RequestWrapper rw = new RequestWrapper(request);

    response.setContentType("text/plain");

    final DB db = new DB();
    
    String sPartition = rw.gets("p");
    
    if (sPartition.length()==0){
        db.query("select distinct partition from raw_details_lpm where partition not like '%\\\\_%' order by 1 desc limit 1;");
        
        sPartition = db.gets(1);
    }
	
    db.query("select run from rawdata_runs where partition='"+Format.escSQL(sPartition)+"';");
    
    while (db.moveNext()){
	//out.println(db.geti(1));
	LogbookSync.fetch(db.geti(1));
    }
%>