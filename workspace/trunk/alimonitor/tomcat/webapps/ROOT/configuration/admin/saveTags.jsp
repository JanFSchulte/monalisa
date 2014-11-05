<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,utils.*,alien.runs.*,lazyj.commands.*,alien.pool.*,alien.catalogue.*,java.sql.*,alien.daq.*"%><%!

    private static final String[] DICTIONARY_FIELDS = new String[] {
	"filling_scheme", "quality",
	"field", "aco", "emc", "fmd", "hlt", "hmp", "mch", "mtr", "phs",
	"pmd", "spd", "sdd", "ssd", "tof", "tpc", "trd", "t00", "v00", "zdc"
    };
    
    private static final Set<String> dictionaryFields = new HashSet<String>(Arrays.asList(DICTIONARY_FIELDS));

private static final String displayField(final DB db, final int column, final int[] types, final String[] names){
    final String name = names[column-1];
    
    if (dictionaryFields.contains(name)){
	int value = db.geti(column, -1000);
	
	if (value == -1000)
	    return "";

	StatusDictionaryEntry sde = StatusDictionary.getInstance(name).get(value);
		
	String sStatus = "";
		
	if (sde!=null)
	    return "("+value+";\""+Format.replace(Format.escHtml(sde.getShortText()),"|","\\|")+"\";\""+Format.replace(Format.escHtml(sde.getLongText()),"|","\\|")+"\")";
	
	return ""+value;
    }
    
    switch (types[column-1]){
	case 1:		// char
	case 12:	// varchar
	case -1:	// longvarchar
	case -15:	// nchar
	case -9:	// nvarchar
	case -16:	// longnvarchar
	case 2009:	// sqlxml
	    return "\""+Format.replace(Format.escHtml(db.gets(column)),"|","\\|")+"\"";
	
	case -7:	// bit
	case -6:	// tinyint
	case 5:		// smallint
	case 4:		// integer
	case -5:	// bigint
	    return db.gets(column);
	
	case 6:		// float
	case 7:		// real
	case 8:		// double
	    return db.gets(column);
	
	case 16:	// boolean
	    return db.gets(column);
	
	case 2:		// numeric
	case 3:		// decimal
	    return db.gets(column);
	    
	case 91:	// date
	case 92:	// time
	case 93:	// timestamp
	    return "???";			// ?
	
	case -2:	// binary
	case -3:	// varbinary
	case -4:	// longvarbinary
	    return "????";

	default:	
	    return "?????";
    }
}
%><%
    final AlicePrincipal user = Users.get(request);

    response.setContentType("text/html");

    if (user==null){
	out.println("You first have to login");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/saveTags.jsp?not_authenticated", 0, request);
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);
  
    final String sHomeDir = Users.getHomeDir(user.getName());
    
    String sType = rw.gets("type");
    
    final String runlist = rw.gets("runlist");

    if (runlist.length()==0){
	out.println("Empty list of runs. First select some runs");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/saveTags.jsp?u="+user+"&empty_run_list", 0, request);
	return;
    }

    String sWhere = " WHERE sum_trigger>0 ";
    
    sWhere = IntervalQuery.cond(sWhere, IntervalQuery.numberInterval(runlist, "raw_run"));

    String sQuery = "SELECT * FROM configuration_view "+sWhere+" ORDER BY raw_run ASC;";
    
    //System.err.println(sQuery);
    
    DB db = new DB(sQuery);
    
    if (!db.moveNext()){
	out.println("Empty output from the query");
	lia.web.servlets.web.Utils.logRequest("/configuration/admin/saveTags.jsp?u="+user+"&empty_query_output", 0, request);
	return;
    }
    
    ResultSetMetaData meta = db.getMetaData();
    
    final int columns = meta.getColumnCount();
    final String[] names = new String[columns];
    final int[] types = new int[columns];

    StringBuilder sb = new StringBuilder("#");
    
    for (int i=1; i<=columns; i++){
	names[i-1] = meta.getColumnLabel(i);
	types[i-1] = meta.getColumnType(i);
	
	if (!names[i-1].equals("run")){
	    sb.append(names[i-1]);
	    
	    if (i!=columns)
		sb.append('|');
	}
    }
    
    sb.append("\n");
    
    do{
	for (int i=1; i<=columns; i++){
	    String s = names[i-1];
	    
	    if (s.equals("run"))
		continue;
	
	    String sValue = displayField(db, i, types, names);
	    
	    sb.append(sValue);
	    
	    if (i!=columns)
		sb.append('|');
	}
	
	sb.append("\n");
    }
    while (db.moveNext());
    
    response.setContentType("text/plain");
    out.println(sb.toString());
    
    lia.web.servlets.web.Utils.logRequest("/configuration/admin/saveTags.jsp?u="+user+"&runlist="+runlist, sb.length(), request);
%>