<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,alien.daq.*,java.util.concurrent.atomic.*,utils.IntervalQuery,java.sql.*"%><%
    RequestWrapper rw = new RequestWrapper(request);

    int run = rw.geti("run");

    DB db = new DB("SELECT * FROM configuration_history WHERE run="+run+" ORDER BY changedon ASC;");
    
    if (!db.moveNext())
	return;

    Page p = new Page("configuration/history.res");
    
    Page pLine = new Page("configuration/history_line.res");

    ResultSetMetaData meta = db.getMetaData();
    
    p.fillFromDB(db);
    
    HashMap<String, String> oldValues = new HashMap<String, String>();

    do{
	pLine.fillFromDB(db);
	
	int iChanges = 0;
	
	for (int i=1; i<=meta.getColumnCount(); i++){
	    String sKey = meta.getColumnName(i);
	    
	    if (sKey.equals("run") || sKey.equals("changedon") || sKey.equals("changedby"))
		continue;
	    
	    String sValue = db.gets(i);
	    
	    String sOldValue = oldValues.get(sKey);
	    
	    if (sValue.length()>0){
	    	if (sValue.equals(sOldValue))
		    continue;

		pLine.append("<dd>"+sKey+" : "+sValue+"</dd>");
		oldValues.put(sKey, sValue);
		
		iChanges++;
	    }
	}

	if (iChanges==0)
	    pLine.reset();
	else
	    p.append("content", pLine, true);
    }
    while (db.moveNext());
    
    out.println(p.toString());
%>