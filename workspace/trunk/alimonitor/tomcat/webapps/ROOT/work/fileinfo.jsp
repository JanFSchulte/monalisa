<%@ page import="java.util.*,java.io.*,lazyj.*,alien.catalogue.*,javax.servlet.jsp.JspWriter,java.util.regex.*,alien.se.*,alien.io.protocols.*"%><%!
    private static final Pattern pUUID = Pattern.compile("[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}");

    private void printLFN(final JspWriter out, final LFN lfn) throws IOException {
	out.println("<pre>");
	out.println(lfn.toString());
	out.println("</pre><br>");
    }
    
    private void printGUID(final JspWriter out, final GUID guid) throws IOException {
	out.println("<pre>");
	out.println(guid.toString());
	out.println("</pre><br>");
    }

    private void printPFN(final JspWriter out, final PFN pfn) throws IOException {
	final SE se = SEUtils.getSE(pfn.seNumber);
	
	Xrootd xrootd = new Xrootd();
	
	boolean ok = false;
	String msg;
	
	try{
	    msg = xrootd.xrdstat(pfn, false, false);
	    ok = true;
	}
	catch (IOException ioe){
	    msg = ioe.getMessage();
	    
	    ioe.printStackTrace();
	}
	
	out.println(se.seName+" : ");
	
	if (ok)
	    out.println("<span style='color:green'>");
	else
	    out.println("<span style='color:red' onMouseOver=\"overlib('"+Format.escJS(Format.escHtml(msg))+"');\">");
	    
	out.println(pfn.pfn);
	
	out.println("</span><br>");
    }
%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    String name = rw.gets("name").trim();
%>
<html>
<head>
<title>File info lookup</title>
<script type="text/javascript" src="/js/overlib.js"></script>
</head>
<form name=form1>
<input type=button name=clear onClick="document.form1.name.value='';" value="X">
<input type=text size=100 name=name value="<%=Format.escHtml(name)%>"><input type=submit value="Get info">
</form>
<%
    if (name.length()>0){
	try{
	    UUID uuid = UUID.fromString(name);
	    
	    GUID guid = GUIDUtils.getGUID(uuid);
	    
	    if (guid==null){
		out.println("GUID "+name+" was not found in the catalogue");
	    }
	    else{
		Set<LFN> lfns = guid.getLFNs();
		
		if (lfns!=null && lfns.size()>0){
		    for (LFN lfn: lfns){
			printLFN(out, lfn);
		    }
		}
		else{
		    out.println("<font color=red>No associated LFN</font>");
		}
		
		out.println("<hr size=1>");
		
		printGUID(out, guid);
		
		out.println("<hr size=1>");
		
		Set<PFN> pfns = guid.getPFNs();
		
		if (pfns!=null && pfns.size()>0){
		    for (PFN pfn: pfns){
			printPFN(out, pfn);
		    }
		}
		else{
		    out.println("<font color=red>No associated PFN</font>");
		}
	    }
	}
	catch (Exception e){
	    LFN lfn = LFNUtils.getLFN(name);
	    
	    if (lfn==null){
		out.println("LFN "+name+" doesn't exist in the catalogue");
	    }
	    else{
		printLFN(out, lfn);
		
		out.println("<hr size=1>");
		
		GUID guid = GUIDUtils.getGUID(lfn.guid);
		
		if (guid==null){
		    out.println("<font color=red>GUID details not found in the catalogue</font>");
		}
		else{
		    printGUID(out, guid);
		    
		    out.println("<hr size=1>");
		    
		    Set<PFN> pfns = guid.getPFNs();
		
		    if (pfns!=null && pfns.size()>0){
			for (PFN pfn: pfns){
			    printPFN(out, pfn);
			}
		    }
		    else{
			out.println("<font color=red>No associated PFN</font>");
		    }
		}
	    }
	}
    }
%>
<body>
</body>
</html>
