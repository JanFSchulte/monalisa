<%@ page import="lazyj.*,lia.Monitor.Store.Fast.*" %><%
    RequestWrapper rw = new RequestWrapper(request);
    
    String path = rw.gets("path");
    
    DB db = new DB("SELECT train_id, id FROM train_run WHERE test_path='"+Format.escSQL(path)+"' AND ((test_start>0 AND test_end IS NULL) OR (run_start>0 AND run_end IS NULL));");
    
    if (db.moveNext()){
	trains.UpdateTestStatus.update(db.geti(1), db.geti(2));
	
	out.println("Updated status for train "+db.geti(1)+", run "+db.geti(2));
    }
    else{
	out.println("No active train with this path");
    }
%>