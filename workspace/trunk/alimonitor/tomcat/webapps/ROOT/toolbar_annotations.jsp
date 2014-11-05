<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,auth.*,java.security.cert.*,java.util.regex.*,lazyj.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /toolbar_annotations.jsp", 0, request);

    response.setContentType("text/plain");
    
    RequestWrapper rw = new RequestWrapper(request);
    
    CachingStructure cs = PageCache.get(request, null);
    
    final boolean bCache = cs!=null;

    final int set = rw.geti("set");

    final int sort = rw.geti("sort");
    
    final String sFilter = rw.gets("filter");

    if (cs==null){
	final ByteArrayOutputStream os = new ByteArrayOutputStream(5000);
	final PrintWriter pw = new PrintWriter(new OutputStreamWriter(os));
    
	final boolean bFilter = sFilter!=null && sFilter.length()>0;
    
	final DB db = new DB();
    
	if (sort==1)
	    db.query("select a_from,a_groups,a_text,a_services,a_fulldesc,get_pledged(name,2)::int as ksi2k from annotations left outer join abping_aliases on name=any(a_services) where a_to>extract(epoch from now())::int order by get_pledged(name,2) is null, ksi2k desc, a_from desc;");
	else
	    db.query("select a_from,a_groups,a_text,a_services,a_fulldesc from annotations where a_to>extract(epoch from now())::int order by a_from desc;");
    
	final HashMap<Integer, String> hmGroupLinks = new HashMap();
    
	hmGroupLinks.put(1, "http://alimonitor.cern.ch/");
	hmGroupLinks.put(2, "http://alimonitor.cern.ch/display?page=jobStatusCS_run_params");
	hmGroupLinks.put(3, "http://alimonitor.cern.ch/display?page=FTD/CS");
	hmGroupLinks.put(6, "http://alimonitor.cern.ch/stats?page=services_status");
	hmGroupLinks.put(7, "http://alimonitor.cern.ch/stats?page=machines/machines");
	hmGroupLinks.put(8, "http://alimonitor.cern.ch/stats?page=proxies");
	hmGroupLinks.put(10, "http://alimonitor.cern.ch/stats?page=SE/table");
	hmGroupLinks.put(12, "http://alimonitor.cern.ch/sam/sam.jsp");
    
	final HashMap<Integer, String> hmIcons = new HashMap();
    
	hmIcons.put(1, "chrome://alienml/content/images/favicon.gif");
	hmIcons.put(2, "chrome://alienml/content/images/vcs_status.png");
	hmIcons.put(3, "chrome://alienml/content/images/download.png");
	hmIcons.put(6, "chrome://alienml/content/images/blockdevice.png");
	hmIcons.put(7, "chrome://alienml/content/images/kdirstat.png");
	hmIcons.put(8, "chrome://alienml/content/images/unlock.png");
	hmIcons.put(10, "chrome://alienml/content/images/storage.png");
	hmIcons.put(12, "chrome://alienml/content/images/usa.png");
    
	java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM HH:mm");
    
	Pattern pattern = null;
    
	if (bFilter){
	    try{
		pattern = Pattern.compile(sFilter, Pattern.CASE_INSENSITIVE);
	    }
	    catch (Exception e){
	    }
	}
    
	while(db.moveNext()){
	    Set sGroups = Annotation.decodeGroups(db.gets("a_groups"));
	    Set ssServices = Annotation.decode(db.gets("a_services"));
	
	    String sLink = null;
	    String sImage = null;
	
	    Iterator it = sGroups.iterator();
	
	    if (set==0){
		if (sGroups.contains(Integer.valueOf(7)))
		    continue;
		
		if (pattern!=null){
	    	    boolean bFound = false;
	    	    Iterator itServices = ssServices.iterator();
	        
	    	    while (itServices.hasNext()){
			String sService = (String) itServices.next();
		    
			Matcher m = pattern.matcher(sService);
		    
			if (m.find()){
			    bFound = true;
			    break;
			}
	    	    }
	        
	    	    if (!bFound)
	    		continue;
		}
	    }
	    
	    if (set==1){
		if (!sGroups.contains(Integer.valueOf(7)))
		    continue;
	    }
	
	    Integer iGroup = null;
	
	    while (it.hasNext()){
		iGroup = (Integer) it.next();
	
		sLink = hmGroupLinks.get(iGroup);
		sImage = hmIcons.get(iGroup);
	    }
    
	    if (sLink==null)
		sLink = "http://alimonitor.cern.ch/";
    
	    String sServices = "";
    
	    it = ssServices.iterator();
	
	    while (it.hasNext()){
		sServices += (sServices.length()>0 ? ", " : "") + (String) it.next();
	    }
	
	    if (sServices.length()>0){
		if (sort==1 && db.geti(6)>0)
		    sServices += " ("+db.geti(6)+")";
		
		sServices += " : ";
	    }
    
	    String sText = db.gets("a_fulldesc");
    
	    sText = Formatare.replace(sText, "\n", "<br>");
	    if (sText.length()>50)
		sText = sText.substring(0, 50)+"...";
    
	    pw.println("group "+iGroup);
	    pw.println("label "+sServices+db.gets("a_text"));
	    pw.println("tooltiptext "+sdf.format(new Date(db.getl("a_from")*1000))+" : "+sText);
	    pw.println("oncommand AliEnML_LoadURL('"+sLink+"'); event.preventBubble();");
	
	    if (sImage!=null)
		pw.println("image "+sImage);
	
	    pw.println("commit");
	}
	
	pw.flush();
	os.flush();
	os.close();
	
	cs = PageCache.put(request, null, os.toByteArray(), 120*1000, "text/plain");
    }

    cs.setHeaders(response);
    
    out.write(new String(cs.getContent()));
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/toolbar_annotations.jsp?set="+set+"&sort="+sort+"&filter="+sFilter+"&cache="+bCache, cs.length(), request);
%>