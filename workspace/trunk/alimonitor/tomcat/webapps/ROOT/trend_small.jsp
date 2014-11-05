<%@ page import="alimonitor.*,lia.web.utils.ServletExtension,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lia.Monitor.monitor.*,lia.Monitor.Store.*,lazyj.*"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /trend_small.jsp", 0, request);

    CachingStructure cs = PageCache.get(request, null);
    
    if (cs!=null){
        cs.setHeaders(response);

	out.write(cs.getContentAsString());
	out.flush();
	
	lia.web.servlets.web.Utils.logRequest("trend_small.jsp?cache=true", cs.length(), request);
	
	return;
    }

    ByteArrayOutputStream baos = new ByteArrayOutputStream(2000);
    
    Page p = new Page(baos, "trend_small.res");
    
    monPredicate pred = new monPredicate("CERN", "ALICE_Sites_Jobs_Summary", "_TOTALS_", -1000*60*60*24, -1, new String[]{"RUNNING_jobs"}, null);
    
    TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();
    
    DataSplitter ds = store.getDataSplitter(new monPredicate[] {pred}, 120000);
    
    final long[] lTimes = new long[] {1000*60*60, 1000*60*60*6, 1000*60*60*12, 1000*60*60*24};
    
    final long lNow = System.currentTimeMillis();
    
    int iCount = 0;
    
    Object o = Cache.getLastValue(pred);
	
    int lastValue = 0;
	
    if (o != null && o instanceof Result){
        double v = ((Result) o).param[0];
	    
        lastValue = (int) v;
	    
        p.modify("running", lastValue);
    }
    else{
        p.modify("running", "-");
    }
	
    Vector v = ds.get(pred);
	
    long[] lClosest = new long[] {1000*60*15, 1000*60*30, 1000*60*60, 1000*60*60*2};
    int[] lValues = new int[] {-1, -1, -1, -1};
	
    for (int i=0; i<v.size(); i++){
        o = v.get(i);
	    
        if (o instanceof Result){
	    Result r = (Result) o;
		
	    for (int j=0; j<lTimes.length; j++){
	        long lDiff = Math.abs(lNow - r.time - lTimes[j]);
		
	        if (lDiff < lClosest[j]){
		    lClosest[j] = lDiff;
		    lValues[j] = (int) r.param[0];
		}
	    }
		
	}
    }
	
    Random rnd = new Random();
	
    for (int j=0; j<lTimes.length; j++){
        if (lValues[j] >= 0){
	    final int v2 = lValues[j];
	    final int v1 = lastValue;
		
	    p.modify("count_"+j, lValues[j]);
		
	    final int width = 20;
	    final int height = 20;
		
	    float sloap;
		
	    if (v1 == 0){
	    	sloap = v2==0 ? 0 : -100000;
	    }
	    else{
	    	if (v2 > v1){
		    sloap = (float) (v1 - v2) / v1;
		}
		else{
		    if (v2 == 0)
			sloap = 100000;
		    else
			sloap = (float) (v1 - v2) / v2;
		}
	    }
		
	    final float sloap_abs = (float) Math.abs(sloap);
		
	    float dx1, dx2, dy1, dy2;
	    int x1, x2, y1, y2;
		
	    if (sloap_abs < 1){
		dx1 = 0;
		dx2 = width-1;
			
		dy1 = height/2 * (sloap+1);
		// sanity check
		if (dy1<0) dy1 = 0;
		if (dy1>=height) dy1 = height-1;
		
		dy2 = height - dy1;
	    }
	    else{
		if (sloap>0){
		    dy1 = height - 1;
		    dy2 = 0;
		}
		else{
		    dy1 = 0;
		    dy2 = height - 1;
		}
			
		dx1 = width * (sloap*sloap - 1) / (2*sloap*sloap);
		dx2 = width - dx1 -1;
			
		if (dx1 > dx2){
		    dx1 = dx2 = width/2f;
		}
			
		//System.err.println("  dx1 = "+dx1+", dx2 = "+dx2);
	    }
		
	    final float dx = dx2 - dx1;
	    final float dy = dy2 - dy1;
	    final float l = (float) Math.sqrt(dx * dx + dy * dy);
	    final float dir_x = dx / l;
	    final float dir_y = dy / l;
		
	    final double angle = Math.acos(dx/l) * 180 / Math.PI;
	    //final double angle = 2 - rnd.nextInt(3);
		
	    final int angle_rnd = Math.round((float)angle) * (sloap < 0 ? -1 : 1);
	
	    p.modify("angle_"+j, v1==0 && v2==0 ? "x" : ""+angle_rnd);
	    
	    if (v1!=0 && v2!=0){
		int r;
		int g;
		int b;
		
		if (sloap > 0){
		    r = 0;
		    g = sloap_abs > 1 ? 0 : (int) (255 * (1-sloap_abs));
		    b = sloap_abs > 1 ? 255 : (int) (255 * sloap_abs);
		}
		else{
		    r = Math.min(sloap_abs > 1 ? 255 : (int) (255 * 3 * sloap_abs), 255);
		    g = sloap_abs > 1 ? 0 : (int) (255 * (1-sloap_abs));
		    b = 0;			
		}

		Color c = new Color(r,g,b).darker();
		
		double percent = (double) (v1 - v2) / v2 * 100;
		    
		p.modify("extra_"+j, "<br>variation: "+ "<font color=#"+Utils.toHex(c)+"><b>"+(percent>0 ? "+" : "") +ServletExtension.showDottedDouble(percent, 1) + "%</b></font>");
	    }

	}
	else{
	    p.modify("count_"+j, "no");
	    p.modify("angle_"+j, "x");
	}
    }
	
    p.write();
    
    cs = PageCache.put(request, null, baos.toByteArray(), 120*1000, "text/html");
    
    cs.setHeaders(response);
    
    out.write(cs.getContentAsString());
    out.flush();
    
    lia.web.servlets.web.Utils.logRequest("/trend_small.jsp?cache=false", cs.length(), request);
%>