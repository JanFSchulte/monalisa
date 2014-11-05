<%@ page import="alimonitor.*,utils.*,lazyj.cache.*,java.net.*,lia.web.utils.ThreadedPage,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*" %><%!
    private static final int CACHE_LIST = 1000 * 2;
    
    private static String getDomain(final String ip, final String name){
	final int idx = name.indexOf('.');
    
	if (name.equals(ip) || idx<0)
	    return name;
	    
	return name.substring(idx+1).toLowerCase();
    }
    
    private static String getCountry(final String ip, final String name){
	final int idx = name.lastIndexOf('.');
    
	String country = null;
    
	if (idx>0 && !ip.equals(name)){
	    country = name.substring(idx+1);
	}
	
	if (country==null || country.length()>=3){
	    final WhoisEntry entry = WhoisEntry.getWhoisEntry(ip);
	
	    if (entry!=null)
		country = entry.country;
	}

	return country;
    }

    private static final class IPClass {
	public String sIP;
	public String sIPCut;
	public String sName;
	public String sDomain;
	
	public String sAS;
	public String sCountry;
	public String sContinent;
	
	public IPClass (final String ip, final String name, final String sAS){
	    this.sIP = ip;
	    this.sName = name;
	    this.sAS = sAS;
	    
	    this.sIPCut = sIP.substring(0, sIP.lastIndexOf('.'));
	    this.sDomain = getDomain(ip, name);
	    this.sCountry = getCountry(ip, name);
	    
	    this.sContinent = CountryMap.getContinent(this.sCountry);
	}

	public double getDistance(final String ip){
	    // same network
	    if (similarTo(ip)){
		return 0;
	    }
	    	
	    final String hostname = ThreadedPage.getHostName(ip).toLowerCase();
	    
	    final String domain = getDomain(ip, hostname);
	    
	    // same domain
	    if (sDomain.endsWith(domain) || domain.endsWith(sDomain)){
		return 0.1;
	    }
	    
	    // same AS
	    final String as = getAS(ip);
	    
	    if (sAS!=null && sAS.equals(as)){
		return 0.15;
	    }
	
	    final double asDistance = WhoisEntry.getASDistance(sAS, as);
	    	    
	    // same country
	    final String country = getCountry(ip, hostname);
	    
	    if (sCountry.equals(country)){
		if (asDistance<20)
		    return 0.2;
		    
		if (asDistance<50)
		    return 0.25;
		    
		return 0.3;
	    }

	    if (asDistance > 0){
		return 0.3 + Math.min(asDistance / 1000, 0.2);
	    }
	    
	    // same continent
	    final String continent = CountryMap.getContinent(country);
	    
	    if (sContinent.equals(continent))
		return 0.5;
	
	    if (asDistance > 0)
		return 0.5 + asDistance/10;
	    
	    // default case: far far away
	    return 0.9;
	}
	
	public boolean similarTo(final String sIP){
	    return sIPCut.equals(sIP.substring(0, sIP.lastIndexOf('.')));
	}
	
	public String toString(){
	    return sIP+"/"+sName+"/"+(sAS!=null ? sAS : "");
	}
    }
    
    private static final class StorageElement implements Comparable<StorageElement>{
	public final String name;
	
	public double weight;
	
	public Set<String> tags;
	
	public Collection<IPClass> ips;
	
	public boolean bDisk = false;
	
	public boolean bTape = false;
	
	public StorageElement(final String seName, final String tags, final Collection<IPClass> ips, final double seWeight){
	    this.name = seName;
	    this.tags = new HashSet<String>();
	    this.weight = seWeight;
	    
	    if (tags!=null && tags.length()>0){
	        final StringTokenizer st = new StringTokenizer(tags, ",");
	        
	        final String sTag = st.nextToken().trim().toLowerCase();
	        
	        if (sTag.length()>0)
		    this.tags.add(sTag);
	    }
	    
	    final StringTokenizer st = new StringTokenizer(seName, ":");
	    
	    if (st.countTokens() >= 3){
	        final String sOrg = st.nextToken();
		final String sSite = st.nextToken();
	        final String sSEName = st.nextToken();
	    
		try{	    
		    final Set<String> sSEQoS = auth.LDAPHelper.checkLdapInformation("name="+sSEName, "ou=SE,ou=Services,ou="+sSite+",ou=Sites,", "QoS");
	    	    
		    for (String s: sSEQoS){
			if (s.equalsIgnoreCase("disk"))
			    bDisk = true;
			else
			if (s.equalsIgnoreCase("tape"))
			    bTape = true;
		    }
		}
		catch (Exception e){
		    // ignore
		}
	    }
	    
	    if (! (bTape || bDisk) ){
		bTape = name.toLowerCase().indexOf("tape")>=0;
	    
		bDisk = !bTape;
	    }
	    
	    this.ips = ips;
	}
	
	public StorageElement(final StorageElement copySE){
	    this.name = copySE.name;
	    this.weight = copySE.weight;
	    this.tags = copySE.tags;
	    this.ips = copySE.ips;
	    this.bDisk = copySE.bDisk;
	    this.bTape = copySE.bTape;
	}
	
	@Override
	public String toString(){
	    return toString(false);
	}
	
	public String toString(final boolean bDebug){
	    if (!bDebug)
		return name;
	
	    return name+" (weight="+weight+")";
	}
	
	public boolean isTape(){
	    return bTape;
	}
	
	public boolean isDisk(){
	    return bDisk;
	}
	
	@Override
	public int compareTo(final StorageElement se){
	    final double diff = weight - se.weight;
	    
	    if (diff<0)
		return 1;
		
	    if (diff>0)
		return -1;
		
	    return 0;
	}
	
	@Override
	public boolean equals(final Object o){
	    return this.name.equals( ((StorageElement) o).name );
	}
	
	@Override
	public int hashCode(){
	    return this.name.hashCode();
	}
    }
    
    private static List<StorageElement> activeSEsCache;
    
    private static long lActiveSEsCacheTimestamp;
    
    private static List<StorageElement> copyList(final List<StorageElement> original){
	final List<StorageElement> ret = new ArrayList<StorageElement>(original.size());
	
	for (StorageElement se: original){
	    ret.add(new StorageElement(se));
	}
	
	return ret;
    }
    
    private static String toIP(final String sName){
	try{
	    final InetAddress addr = InetAddress.getByName(sName);
	    
	    return addr.getHostAddress();
	}
	catch (Exception e){
	    return null;
	}
    }
    
    private static synchronized List<StorageElement> getActiveSEs(){
	if (System.currentTimeMillis() - lActiveSEsCacheTimestamp < CACHE_LIST && activeSEsCache!=null){
	    return copyList(activeSEsCache);
	}
    
	activeSEsCache = new ArrayList<StorageElement>();
	
	final DB db = new DB("SELECT list_ses.se_name,tags,ips,weight FROM list_ses "+
			    "LEFT OUTER JOIN se_testing ON list_ses.se_name=se_testing.se_name AND se_test='ADD' "+
			    "LEFT OUTER JOIN se_info ON list_ses.se_name=se_info.name "+
			"WHERE testtime>extract(epoch from now()-'1 week'::interval)::int AND status=0 AND list_ses.se_name not ilike '%sink';");
	
	while (db.moveNext()){
	    final String sSE = db.gets(1);
	    
	    final String tags = db.gets(2);
	
	    final String ips = db.gets(3);
	    
	    final double weight = db.getd(4, 1);
	    
	    final Collection<IPClass> iplist = new ArrayList<IPClass>();
	    
	    if (ips.length()==0){
		// we have to discover the IP addresses used by a given SE name
		
		final DB db2 = new DB("select distinct split_part(mi_key,'/',3) from monitor_ids "+
		    "where mi_key ilike '%/"+Format.escSQL(sSE)+"_xrootd_Nodes/%' and mi_lastseen>extract(epoch from now()-'1 week'::interval)::int and split_part(mi_key,'/',3)!='_TOTALS_';");
		
		while (db2.moveNext()){
		    final String sName = db2.gets(1);
		    
		    final String sIP = toIP(sName);
		    
		    if (sIP==null)
			continue;
		    
		    boolean bFound = false;
		    
		    // only take one IP of each class for a given SE
		    for (IPClass ip: iplist){
			if (ip.similarTo(sIP)){
			    bFound = true;
			    break;
			}
		    }
		    
		    if (bFound)
			continue;
		    
		    final String sAS = getAS(sIP);
		    
		    iplist.add(new IPClass(sIP, sName, sAS));
		}
		
		String sSite = sSE.substring(7);
		sSite = sSite.substring(0, sSite.indexOf(':')).toLowerCase();
		
		// include the C class of the vobox if it's not already there
		db2.query("SELECT ip FROM abping_aliases WHERE lower(name)='"+Format.escSQL(sSite)+"';");
		
		if (db2.moveNext()){
		    boolean bFound = false;
		
		    String sIP = db2.gets(1);
		
		    for (IPClass ip: iplist){
			if (ip.similarTo(sIP)){
			    bFound = true;
			    break;
			}
		    }
		    
		    if (!bFound)
			iplist.add(new IPClass(sIP, ThreadedPage.getHostName(sIP).toLowerCase(), getAS(sIP)));
		}
		
		if (iplist.size()>0){
		    String sIPs = "";
		    
		    for (IPClass ip: iplist){
			sIPs = sIPs+ ( sIPs.length()>0 ? "," : "" ) + ip;
		    }
		
		    final String sQuery = "UPDATE se_info SET ips='"+Format.escSQL(sIPs)+"' WHERE name='"+Format.escSQL(sSE)+"';";
		
		    db2.query(sQuery);
		    
		    if (db2.getUpdateCount()==0)
			db2.query("INSERT INTO se_info (name, ips) VALUES ('"+Format.escSQL(sSE)+"', '"+Format.escSQL(sIPs)+"');");
		}
	    }
	    else{
		// the information in cached in the database
		final StringTokenizer st = new StringTokenizer(ips,",");
		
		while (st.hasMoreTokens()){
		    final StringTokenizer st2 = new StringTokenizer(st.nextToken(), "/");
		    
		    if (!st2.hasMoreTokens()) continue;
		    
		    final String sIP = st2.nextToken();
		    
		    String sHost = null;
		    String sAS = null;
		    
		    if (st2.hasMoreTokens()){
			sHost = st2.nextToken();
		    }
		    else{
			sHost = ThreadedPage.getHostName(sIP).toLowerCase();
		    }
		    
		    if (st2.hasMoreTokens()){
			sAS = st2.nextToken();
		    }
		    else{
			sAS = getAS(sIP);
		    }
		    
		    final IPClass ip = new IPClass(sIP, sHost, sAS);
		    
		    iplist.add(ip);
		}
	    }
	
	    final StorageElement se = new StorageElement(db.gets(1), db.gets(2), iplist, weight);
	    
	    activeSEsCache.add(se);
	}
	
	lActiveSEsCacheTimestamp = System.currentTimeMillis();
	
	return copyList(activeSEsCache);
    }

    private static String getAS(final String sIP){
	final WhoisEntry entry = WhoisEntry.getWhoisEntry(sIP);
	
	if (entry!=null){
	    return entry.asname;
	}
	
	return null;
    }
    
    private static void cleanList(final List<StorageElement> ses){
	final Iterator<StorageElement> it = ses.iterator();
	
	while (it.hasNext()){
	    final StorageElement se = it.next();
	    
	    if (se.weight<0)
		it.remove();
	}
    }
    
    /**
     * Get the distance between the given SE and some IP. The return values are between 0 (closest) to 1 (another planet).
     * @return 
     *   0 : same site
     *       same computing centre
     *       same ip class
     *       same suffix of the reverse IP
     *   0.2 : same AS
     *   0.3 : same country
     *   0.5 : same continent
     *   0.9 : other continent
     *   + [0 .. 0.1) = RTT(seconds)/10
     */
    private double getDistance(final StorageElement se, final String sIP){
	double distance = 1;
    
	for (IPClass ip: se.ips){
	    distance = Math.min(distance, ip.getDistance(sIP));
	    
	    if (distance<0.05)
		return distance;
	}
    
	return distance;
    }
    
    public double getASDistance(final String as1Name, final String as2Name){
	if (as1Name==null || as2Name==null || as1Name.length()==0 || as2Name.length()==0)
	    return -1;
	
	final String as1 = as1Name.toLowerCase();
	final String as2 = as2Name.toLowerCase();
    
	final String sKey = as1+"/"+as2;
    
	final List<String> addrA1 = new ArrayList<String>();
	final List<String> addrA2 = new ArrayList<String>();

	double d;

	try{
	    final BufferedReader br = new BufferedReader(new FileReader("/home/monalisa/MLrepository/bin/getBestSE/list.txt"));
	    
	    String sLine;
	    
	    while ( (sLine = br.readLine()) != null ){
		StringTokenizer st = new StringTokenizer(sLine.toLowerCase(), ",");
		
		if (st.countTokens()==3){
		    String sClass = st.nextToken();
		    String sCountry = st.nextToken();
		    String sAS = st.nextToken();
		    
		    if (sAS.equals(as1))
			addrA1.add(sClass);
		    if (sAS.equals(as2))
			addrA2.add(sClass);
		}
	    }
	    
	    br.close();
	}
	catch (Exception e){
	    System.err.println("Cannot read list.txt : "+e);
	}
	
	if (addrA1.size()==0 || addrA2.size()==0){
	    return -1;
	}
	
	String sIP1 = "";
	
	for (String sClass: addrA1){
	    sIP1 += (sIP1.length()>0 ? "," : "") + "'"+Format.escSQL(sClass)+"'";
	}

	String sIP2 = "";
	
	for (String sClass: addrA2){
	    sIP2 += (sIP2.length()>0 ? "," : "") + "'"+Format.escSQL(sClass)+"'";
	}
	
	String q = "select avg(abs(ft2.hop_rtt-ft1.hop_rtt)) from fdt_tracepath ft1 inner join fdt_tracepath ft2 on ft1.test_id=ft2.test_id "+
	    "and regexp_replace(ft1.hop_ip,'\\.[0-9]+$','') in ("+sIP1+") and regexp_replace(ft2.hop_ip,'\\.[0-9]+$','') in ("+sIP2+");";
	
	DB db = new DB(q);
	
	//System.err.println(q);
	
	d = -1d;
	
	if (db.moveNext())
	    d = db.getd(1, -1);
	    
	return d;
    }

    
%><%
    final RequestWrapper rw = new RequestWrapper(request);
    
    rw.setNotCache(response);
    response.setContentType("text/plain");
    
    final List<StorageElement> activeSEs = getActiveSEs();

    final String sUser = rw.gets("username");
    
    final boolean bDumpAll = rw.getb("dumpall", false);
    
    final boolean bSort = rw.getb("sort", false);

    final boolean bDebug = rw.getb("debug", false);

    // adjust weights based on list of SEs specified by the user

    utils.SEUtils.cleanup();

    String asCERN = getAS("137.138.170.204");
    
    String asFZK = getAS("194.190.165.169");
    
    out.println("CERN AS : "+asCERN);
    out.println("FZK AS : "+asFZK);
    
    out.println("Distance : "+getASDistance(asCERN, asFZK));
    
    out.flush();
%>