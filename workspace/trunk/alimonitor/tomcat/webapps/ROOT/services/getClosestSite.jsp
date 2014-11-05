<%@ page import="alimonitor.*,utils.*,lazyj.cache.*,java.net.*,lia.Monitor.monitor.*,lia.web.utils.ThreadedPage,lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,auth.*,java.security.cert.*,lazyj.*" %><%!
    final static CacheElement<String, String> cache = new GenericLastValuesCache<String, String>(){
	@Override
	protected int getMaximumSize(){
	    return 10000;
	}
	
	@Override
	protected String resolve(final String sIP){
	    return getClosestSite(sIP);
	}
    };
    
    public static String getClosestSite(final String sIP){
	final IPClass ip = new IPClass(sIP, ThreadedPage.getHostName(sIP), IPUtils.getAS(sIP));
	
	final DB db = new DB("select name,ip from abping_aliases natural left outer join running_jobs_cache where name in (select name from alien_sites) order by maxrunningjobs is null asc, maxrunningjobs desc;");
	
	String sClosest = null;
	double distance = 100;
	
	while (db.moveNext()){
	    final String siteName = db.gets(1);
	    final String siteIP = db.gets(2);
	
	    double d = ip.getDistance(siteIP);

	    //System.err.println("Distance between "+sIP+" to "+siteName+" ("+siteIP+") : "+d);
	    
	    if (d<distance){
		sClosest = siteName;
		distance = d;
	    }
	}
	
	return StringFactory.get(sClosest);
    }
%><%
    final RequestWrapper rw = new RequestWrapper(request);

    response.setContentType("text/plain");

    String sIP = rw.gets("ip");
    
    if (sIP.length()>0){
	try{
	    final InetAddress ia = InetAddress.getByName(sIP);
	    
	    sIP = ia.getHostAddress();
	}
	catch (Exception e){
	    sIP = null;
	}
    }

    if (sIP==null || sIP.length()==0){
	sIP = request.getRemoteAddr();
    }

    String sSite = cache.get(sIP);

    if (rw.getb("ml_ip", false)){
	DB db = new DB("SELECT ip FROM abping_aliases WHERE name='"+Format.escSQL(sSite)+"';");
	
	if (db.moveNext())
	    sSite = db.gets(1);
    }

    out.println(sSite);
    
    lia.web.servlets.web.Utils.logRequest("/services/getClosestSite.jsp?ip="+sIP+"&response="+sSite, 0, request);
%>