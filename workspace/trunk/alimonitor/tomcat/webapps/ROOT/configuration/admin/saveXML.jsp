<%@ page import="alimonitor.*,auth.*,lazyj.*,java.io.*,java.util.*,lia.Monitor.Store.Fast.DB,utils.*,alien.runs.*,lazyj.commands.*,alien.catalogue.*,alien.user.*,alien.io.*"%><%!
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
    
    if (sType==null || sType.length()==0 || (!sType.equals("raw") && !sType.startsWith("pass")))
	sType = "pass1";
    
    final String runlist = rw.gets("runlist");
    
    final StringTokenizer runs = new StringTokenizer(runlist, ", ");
    
    final LinkedList<String> files = new LinkedList<String>();
    
    while (runs.hasMoreTokens()){
	int run;
    
	try{
	    run = Integer.parseInt(runs.nextToken());
	}
	catch (Exception e){
	    continue;
	}
	
	Run r = new Run(run);
	
	String sPath = r.getCollectionPath();
	
	if (sPath==null || sPath.length()==0 || !sPath.endsWith("/collection"))
	    continue;
	
	sPath = sPath.substring(0, sPath.lastIndexOf("/")+1);

	String sWhat = "*0.root";
	
	if (sType.equals("raw")){
	    sPath += sType;
	}
	else{
	    sPath += "ESDs/";
	    
	    if (sType.equals("pass_last")){
		DB db = new DB("select outputdir from rawdata_processing_requests inner join job_runs_details on pid=masterjob_id where run="+run+" order by pass desc limit 1;");
		
		if (db.moveNext())
		    sPath = db.gets(1);
		else
		    sPath += "pass1";
	    }
	    else{
		sPath += sType;
	    }
	    
	    sWhat = "AliESDs.root";
	}
	    
	final Collection<LFN> findResult = LFNUtils.find(sPath, sWhat, 0);
	
	for (LFN l: findResult){
	    files.add(l.getCanonicalName());
	}
    }
    
    if (files.size()==0){
	out.println("The list of files is empty");
    }
    
    File f = File.createTempFile("saveXML", null);
    
    PrintWriter pw = new PrintWriter(new FileWriter(f));
    
    pw.println("<?xml version=\"1.0\"?>");
    pw.println("<alien>");
    pw.println("  <collection name=\""+Format.escHtml(runlist)+"\">");
    
    int iCount = 0;

    Collections.sort(files);    
    
    for (String s: files){
	iCount ++;
	pw.println("    <event name=\""+iCount+"\">");
	pw.println(s);
	pw.println("    </event>");
    }
    
    long l = System.currentTimeMillis();
    
    pw.println("    <info command=\"http://alimonitor.cern.ch/configuration/?raw_run="+Format.encode(runlist)+"\" creator=\""+Format.escHtml(user.getName())+"\" date=\""+(new Date(l))+"\" timestamp=\""+(l/1000)+"\" />");
    pw.println("  </collection>");
    pw.println("</alien>");
    
    pw.flush();
    pw.close();
    
    int idx = 0;
    
    AliEnFile af = new AliEnFile(sHomeDir+"run_selection.xml");
    
    while (af.exists()){
	idx ++;
	af = new AliEnFile(sHomeDir+"run_selection_"+idx+".xml");
    }
    
    AliEnPrincipal owner = UserFactory.getByUsername(user.getName());
    
    IOUtils.upload(f, af.getCannonicalName(), owner);
    
    out.println("Collection created:\n<br><a target=_blank style='text-decoration:none' href='/catalogue/?path="+Format.encode(af.getCannonicalName())+"'>"+Format.escHtml(af.getCannonicalName())+"</a>");
    
    lia.web.servlets.web.Utils.logRequest("/configuration/admin/saveXML.jsp?u="+user+"&runlist="+runlist, (int) f.length(), request);
    
    f.delete();
%>