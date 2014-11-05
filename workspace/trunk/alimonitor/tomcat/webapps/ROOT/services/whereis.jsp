<%@ page import="lazyj.*,alien.catalogue.*,java.util.*,alien.se.*,lazyj.cache.*" %><%!
    private static final ExpirationCache<String, String> cache = new ExpirationCache<String, String>(10240);
%><%
    final RequestWrapper rw = new RequestWrapper(request);

    final String sLFN = rw.gets("lfn");

    response.setContentType("text/plain");

    String sresponse = cache.get(sLFN);
    
    if (sresponse!=null){
	out.println(sresponse);
	return;
    }

    final LFN lfn = LFNUtils.getLFN(sLFN);
    
    final Set<PFN> whereis = lfn.whereisReal();
    
    final StringBuilder sb = new StringBuilder();
    
    if (whereis!=null){
	for (final PFN pfn: whereis){
	    final SE se = SEUtils.getSE(pfn.seNumber);
	    
	    if (se==null)
		continue;

	    if (sb.length()>0)
		sb.append(',');
		
	    sb.append(se.seName);
	}
    }
    
    sresponse = "Size:"+lfn.size+"\nType:"+lfn.getType()+"\nSEs:"+sb.toString();
    
    out.println(sresponse);
    
    cache.put(sLFN, sresponse, 1000*60*15);
%>