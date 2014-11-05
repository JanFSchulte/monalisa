<%@ page import="lazyj.*,alien.catalogue.*,java.util.*,alien.se.*,lazyj.cache.*" %><%!
    private static final ExpirationCache<String, String> cache = new ExpirationCache<String, String>(10240);
%><%
    final RequestWrapper rw = new RequestWrapper(request);

    response.setContentType("text/plain");

    final String entry = rw.gets("id");

    String sresponse = cache.get(entry);
    
    if (sresponse!=null){
	out.println(sresponse);
	return;
    }

    final Set<PFN> whereis;
    
    if (GUIDUtils.isValidGUID(entry)){
	GUID guid = GUIDUtils.getGUID(UUID.fromString(entry));
    
	if (guid==null){
	    cache.put(entry, "", 1000*60);
	    return;
	}
    
	final Set<GUID> realGUIDs = guid.getRealGUIDs();
	
	whereis = new LinkedHashSet<PFN>();
	
	for (final GUID realId: realGUIDs){
	    final Set<PFN> pfns = realId.getPFNs();
			    
	    if (pfns==null)
		continue;
							
	    whereis.addAll(pfns);
	}
    }
    else{
        LFN lfn = LFNUtils.getLFN(entry);
         
        if (lfn==null){
            cache.put(entry, "", 1000*60);
            return;
        }
	
	whereis = lfn.whereisReal();
    }
    
    final StringBuilder sb = new StringBuilder();
    
    if (whereis!=null){
	for (final PFN pfn: whereis){
	    final SE se = SEUtils.getSE(pfn.seNumber);
	    
	    if (se==null)
		continue;

	    if (sb.length()>0)
		sb.append('\n');
		
	    sb.append(se.seName).append(' ').append(pfn.pfn);
	}
    }

    sresponse = sb.toString();    
    
    out.println(sresponse);
    
    cache.put(entry, sresponse, 1000*60*15);
%>