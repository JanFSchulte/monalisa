<%@ page import="alien.taskQueue.*,lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*,alien.pool.*,lazyj.commands.*,java.util.regex.*,alien.catalogue.*,alien.repository.*,alien.repository.IOStats.FileAggregation,alien.repository.IOStats.SiteAggregation"%><%!

private static Map<String, Double> ROOTMARKS_CACHE = null;

private static long lastRootmarksCheck = 0;

private static synchronized Map<String, Double> getRootmarks(){
    if (System.currentTimeMillis() - lastRootmarksCheck > 1000*60*60*24){
	final Map<String, Double> newMap = new HashMap<String, Double>();
    
	final DB db = new DB("select site,sum(rootmarks_avg * hosts)/sum(hosts) from (select site,avg(rootmarks) as rootmarks_avg,count(distinct hostname) as hosts from rootmarks_view group by site,cpumodel, cachesize) x group by site;");
	
	while (db.moveNext()){
	    newMap.put(db.gets(1).toUpperCase(), db.getd(2) / 189.567);
	}
	
	db.query("select sum(rootmarks_avg * hosts)/sum(hosts) from (select site,avg(rootmarks) as rootmarks_avg,count(distinct hostname) as hosts from rootmarks_view group by site,cpumodel, cachesize) x;");
	
	newMap.put("TOTAL", db.getd(1) / 189.567);
	
	ROOTMARKS_CACHE = newMap;
	
	lastRootmarksCheck = System.currentTimeMillis();
    }
    
    return ROOTMARKS_CACHE;
}

private static final class SiteWrapper implements Comparable<SiteWrapper>{
    public final String name;
    public final SiteAggregation data;
    
    public final FileAggregation localFiles;
    public final FileAggregation remoteFiles;
    
    public final FileAggregation totalFiles;

    public SiteWrapper(final String name, final SiteAggregation data){
	this.name = name;
	this.data = data;
	
	localFiles = new FileAggregation();
	remoteFiles = new FileAggregation();
	
	totalFiles = new FileAggregation();
	
	final String search = "::"+name+"::";
	
	for (final Map.Entry<String, FileAggregation> entry: data.files.entrySet()){
	    final String seName = entry.getKey();
	    
	    final FileAggregation files = entry.getValue();
	    
	    if (seName.indexOf(search)>=0)
		localFiles.merge(files);
	    else
		remoteFiles.merge(files);
	}
	
	totalFiles.merge(localFiles);
	totalFiles.merge(remoteFiles);
    }
    
    public int compareTo(final SiteWrapper other){
	return other.data.count - this.data.count;
    }
}

private static final class SEWrapper implements Comparable<SEWrapper>{
    public final String name;
    public final FileAggregation localFiles;
    public final FileAggregation remoteFiles;
    public final FileAggregation totalFiles;
    
    public SEWrapper(final String name){
	this.name = name;
	localFiles = new FileAggregation();
	remoteFiles = new FileAggregation();
	totalFiles = new FileAggregation();
    }
    
    public void addFiles(final FileAggregation files, final boolean local){
	if (local)
	    localFiles.merge(files);
	else
	    remoteFiles.merge(files);
	    
	totalFiles.merge(files);
    }
    
    public int compareTo(final SEWrapper other){
	final double d = other.totalFiles.readSize - this.totalFiles.readSize;
	
	if (d<0)
	    return -1;
	if (d>0)
	    return 1;
	return 0;
    }
}

public static String getPercentage(final double d, final double t){
    if (t>0)
	return " ("+Format.point(d*100 / t)+"%)";
    
    return "";
}

public static String getCell(final FileAggregation files, final FileAggregation total){
    return getCell(files, total, false);
}

public static String getCell(final FileAggregation files, final FileAggregation total, final boolean showSize){
    if (files.count<=0)
	return "&nbsp;";

    final StringBuilder sb = new StringBuilder();
    
    sb.append(files.count);
    
    if (files!=total)
	sb.append(getPercentage(files.count, total.count));
    else
	sb.append(" files");

    sb.append("<BR>");
    
    sb.append(Format.size(files.getThroughput(), "M")+"/s");
    
    if (showSize){
	sb.append("<BR>").append(Format.size(files.readSize, "M"));
    }
    
    return sb.toString();
}

public static String getEffColor(final double eff){
    String s = Format.point(100*eff)+"%";
    
    String color = "#FF0000";
    
    if (eff>=0.9)
	color = "#00FF00";
    else
    if (eff>=0.8)
	color = "#66FF66";
    else
    if (eff>=0.7)
	color = "#999900";
    else
    if (eff>=0.6)
	color = "#FF9900";
	
    return "<font color='"+color+"'>"+s+"</font>";
}

private static final String BR = "&lt;BR&gt;";

public static String getSiteCell(final SiteWrapper site, final SiteAggregation allSites){
    final StringBuilder sb = new StringBuilder();
    
    final double totalTime = site.data.initTime + site.data.ioMgmtTime + site.data.execTime;

    sb.append("<B>").append(site.name).append("</B><BR>");    
    
    sb.append(site.data.count).append(" jobs");
    
    if (allSites!=null)
	sb.append(getPercentage(site.data.count, allSites.count));
	
    sb.append("<BR>");

    final int len = 150;
    
    final int exec = (int) (site.data.execTime * len / totalTime);
    final int ioMgmt = (int) (site.data.ioMgmtTime * len / totalTime);
    final int init = len - (exec+ioMgmt);
    
    sb.append("<table border=0 cellspacing=0 cellpadding=0 width="+len+"px>");
    
    sb.append("<tr style='height:5px'>");
    sb.append("<td bgcolor=#5555FF style='width:").append(exec).append("px' onMouseOver='overlib(\""+
	    Format.toInterval((long)(site.data.execTime * 1000 / (site.localFiles.count + site.remoteFiles.count)))+" / file"+BR+
	    Format.toInterval((long)(site.data.execTime * 1000 / site.data.count))+" / job"+BR+
	    Format.point(site.data.execTime*100 / totalTime)+"% of the wall time"+BR+
	    Format.toInterval((long)(site.data.execTime*1000))+" in total"+
	    "\", STICKY, CAPTION, \"Tasks (user code)\")' onMouseOut='nd()'></td>");

    sb.append("<td bgcolor=#FF5555 style='width:").append(ioMgmt).append("px' onMouseOver='overlib(\""+
	    Format.toInterval((long)(site.data.ioMgmtTime * 1000 / (site.localFiles.count + site.remoteFiles.count)))+" / file"+BR+
	    Format.toInterval((long)(site.data.ioMgmtTime * 1000 / site.data.count))+" / job"+BR+
	    Format.point(site.data.ioMgmtTime*100 / totalTime)+"% of the wall time"+BR+
	    Format.toInterval((long)(site.data.ioMgmtTime*1000))+" in total"+
	    "\", CAPTION, \"IO Management (read + deserialize)\")' onMouseOut='nd()'></td>");

    sb.append("<td bgcolor=orange style='width:").append(init).append("px' onMouseOver='overlib(\""+
	    Format.toInterval((long)(site.data.initTime * 1000 / (site.localFiles.count + site.remoteFiles.count)))+" / file"+BR+
	    Format.toInterval((long)(site.data.initTime * 1000 / site.data.count))+" / job"+BR+
	    Format.point(site.data.initTime*100 / totalTime)+"% of the wall time"+BR+
	    Format.toInterval((long)(site.data.initTime*1000))+" in total"+
	    "\", CAPTION, \"Initialization (file open)\")' onMouseOut='nd()'></td>");
    sb.append("</tr></table>");

    final int eff = (int) (site.data.cpuTime * len / totalTime);

    sb.append("<table border=0 cellspacing=0 cellpadding=0 width="+len+"px>");
    sb.append("<tr style='height:5px'>");
    
    sb.append("<td bgcolor=#55BB55 style='width:").append(eff).append("px' onMouseOver='overlib(\""+
	    Format.point(site.data.cpuTime*100 / totalTime)+"% of the wall time"+BR+
	    Format.toInterval((long)(site.data.cpuTime*1000))+" CPU in total"+
	    "\", CAPTION, \"CPU usage efficiency\")' onMouseOut='nd()'></td>");
	
    sb.append("<td style='width:").append(len - eff).append("px'></td>");
    
    sb.append("</tr></table></td>");
    
    sb.append("<td align=right class=").append(allSites!=null ? "table_row" : "table_header rowspan=2").append("><B>");
    
    sb.append(getEffColor(site.data.cpuTime / totalTime));

    sb.append("</B></TD>");

    sb.append("<td align=right class=").append(allSites!=null ? "table_row_right" : "table_header rowspan=2").append(">");
    
    Double marks = getRootmarks().get(site.name);

    if (marks!=null)    
        sb.append(Format.point(marks.doubleValue()));
    
    return sb.toString();
}

%>
<html>
<head>
<script src="/js/sorttable.js"></script>
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/overlib/overlib.js"></script>
<title>IOStats</title>
</head>
<body>
<%
    final RequestWrapper rw = new RequestWrapper(request);
    
    final String[] pidList = rw.getValues("pid");
    
    final Set<Integer> pids = new HashSet<Integer>();

    final SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm");
    
    for (final String s: pidList){
	final StringTokenizer st = new StringTokenizer(s, " \t\r\n,;");
	
	while (st.hasMoreTokens()){
	    try{
		pids.add(Integer.valueOf(st.nextToken()));
	    }
	    catch (Exception e){
		// ignore
	    }
	}
    }
    
    final int[] ipids = new int[pids.size()];
    
    int pos = 0;
    
    for (final Integer i: pids)
	ipids[pos++] = i.intValue();
    
    final Map<Integer, IOStats> stats = IOStats.getCachedStats(ipids);
    
    final IOStats agg = new IOStats();
    
    for (final IOStats stat: stats.values())
	agg.merge(stat);
	
    final List<SiteWrapper> sites = new ArrayList<SiteWrapper>(agg.data.size());
    
    final List<SEWrapper> ses = new ArrayList<SEWrapper>();

    final FileAggregation allLocal = new FileAggregation();
    final FileAggregation allRemote = new FileAggregation();
    
    final SiteAggregation allSites = new SiteAggregation();
    
    for (final Map.Entry<String, SiteAggregation> siteEntry: agg.data.entrySet()){
	allSites.merge(siteEntry.getValue());
    
	final SiteWrapper sw = new SiteWrapper(siteEntry.getKey(), siteEntry.getValue());
	
	final String search = "::"+siteEntry.getKey()+"::";
	
	for (final Map.Entry<String, FileAggregation> entry: siteEntry.getValue().files.entrySet()){
	    final String seName = entry.getKey();
	    
	    SEWrapper se = null;
	    
	    for (final SEWrapper test: ses){
		if (test.name.equals(seName)){
		    se = test;
		    break;
		}
	    }
	    
	    if (se==null){
		se = new SEWrapper(seName);
		ses.add(se);
	    }
	    
	    if (seName.indexOf(search)>=0){
	        se.addFiles(entry.getValue(), true);
	        allLocal.merge(entry.getValue());
	    }
	    else{
	        se.addFiles(entry.getValue(), false);
	        allRemote.merge(entry.getValue());
	    }
	}
	
	sites.add(sw);
    }

    Collections.sort(sites);
    Collections.sort(ses);
%>
<table cellspacing=0 cellpadding=0 border=0 class="table_content">
<tr height="25">
<td class="table_title">
    IO stats for <B><%=pids.size()%></B> master jobs executed between <B><%=dateFormat.format(new Date(agg.minTimestamp*1000L))%></B> and <B><%=dateFormat.format(new Date(agg.maxTimestamp*1000L))%></B> (<B><%=Format.toInterval((agg.maxTimestamp - agg.minTimestamp)*1000)%></B>)
</td>
</tr>
<tr>
<td>
<table cellspacing=1 cellpadding=2 border=0 class=sortable>
    <thead>
    <tr>
	<td class=table_header colspan=6>Site activity</td>
	<td class=table_header colspan=<%=ses.size()%>>SE access</td>
    </tr>
    <tr>
	<td class=table_header>Site</th>
	<td class=table_header>Job eff.</th>
	<td class=table_header>HepSpec06</th>
	<td class=table_header>All files</th>
	<td class=table_header>Local files</th>
	<td class=table_header>Remote files</th>
<%
    for (final SEWrapper se: ses){
	String display = se.name.substring(se.name.indexOf("::")+2);
	
	display = Format.replace(display,"::","<BR>");
	
	out.println("<td class=table_header>"+display+"</th>");
    }
%>
    </tr>
    </thead>
    <tbody>
<%
    for (final SiteWrapper site: sites){
	final String search = "::"+site.name+"::";
%>
    <tr class="table_row">
	<td nowrap align=left class=table_row sorttable_customkey=<%=site.data.count%>>
	    <%=getSiteCell(site, allSites)%>
	</td>
	<td class=table_row nowrap align=right sorttable_customkey=<%=(site.localFiles.count+site.remoteFiles.count)%>><%=getCell(site.totalFiles, site.totalFiles)%></td>
	<td class=table_row nowrap align=right sorttable_customkey=<%=site.localFiles.count%>><%=getCell(site.localFiles, site.totalFiles)%></td>
	<td class=table_row_right nowrap align=right sorttable_customkey=<%=site.remoteFiles.count%>><%=getCell(site.remoteFiles, site.totalFiles)%></td>
	
<%
	for (final SEWrapper se: ses){
	    out.println("<td class=table_row nowrap align=right");
	    
	    final FileAggregation files = site.data.files.get(se.name);
	    
	    if (files!=null){
		out.println("onMouseOver=\"overlib('Files read by &lt;B&gt;"+site.name+"&lt;/B&gt; from &lt;B&gt;"+se.name+"&lt;/B&gt;')\" onMouseOut='nd()' sorttable_customkey="+files.count+">");
		
	        if (se.name.indexOf(search)>=0)
	    	    out.println("<B>");

		out.println(getCell(files, site.totalFiles));
	    }
	    else
		out.println(">&nbsp;");
	    
	    out.println("</td>");
	}
%>
    </tr>
<%
    }
%>
    </tbody>
    <tfoot>
<%
    final FileAggregation allFiles = new FileAggregation();
    allFiles.merge(allLocal);
    allFiles.merge(allRemote);

    SiteWrapper sw = new SiteWrapper("TOTAL", allSites);

    out.println("<tr><td nowrap class=table_header rowspan=2>");
	
    out.println(getSiteCell(sw, null));
    
    out.println("</td><td class=table_header nowrap align=right rowspan=2 sorttable_customkey="+allFiles.count+">"+getCell(allFiles, allFiles, true)+"</td>");

    for (final boolean local: new boolean[]{true, false}){
	if (!local)
	    out.println("<tr>");

	if (local)
	    out.println("<td class=table_header nowrap align=right sorttable_customkey="+allLocal.count+">"+getCell(allLocal, allFiles, true)+"</td><td class=table_header></td>");
	else
	    out.println("<td class=table_header></td><td class=table_header nowrap align=right sorttable_customkey="+allRemote.count+">"+getCell(allRemote, allFiles, true)+"</td>");
	    
	for (final SEWrapper se: ses){
	    out.println("<td onMouseOver=\"overlib('"+(local ? "Local" : "Remote")+" access to "+se.name+"')\" onMouseOut='nd()' nowrap class=table_header align=right>");
	    
	    out.println(getCell(local ? se.localFiles : se.remoteFiles, local ? allLocal : allRemote, true));
	    
	    out.println("</td>");
	}
	
	out.println("</tr>");
    }
%>
    </tfoot>
</table>
</tr></td></table>
<div style="height:50px"></div>
</body>
</html>
