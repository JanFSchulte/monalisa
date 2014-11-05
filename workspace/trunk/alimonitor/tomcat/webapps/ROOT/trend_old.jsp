<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.Utils,lia.Monitor.monitor.*,lia.Monitor.Store.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /trend_old.jsp", 0, request);

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";
	
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/WEB-INF/res";

    ByteArrayOutputStream baos = new ByteArrayOutputStream(20000);

    Page pMaster = new Page(baos, RES_PATH+"/masterpage/masterpage.res");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    Page p = new Page(BASE_PATH+"/trend.res");
    
    Page pLine = new Page(BASE_PATH+"/trend_line.res");
    
    DB db = new DB();
    
    db.query("select distinct split_part(mi_key,'/',1) from monitor_ids where split_part(mi_key,'/',2)='Site_Jobs_Summary' and split_part(mi_key,'/',3)='jobs' and split_part(mi_key,'/',4)='RUNNING_jobs';");
    
    monPredicate pred = new monPredicate("*", "Site_Jobs_Summary", "jobs", -1000*60*60*24, -1, new String[]{"RUNNING_jobs"}, null);
    monPredicate predServices = new monPredicate("*", "AliEnServicesStatus", "*", -1000*60*60*24, -1, new String[]{"Status"}, null);
    monPredicate predMessages = new monPredicate("*", "AliEnServicesStatus", "*", -1000*60*60*24, -1, new String[]{"Message"}, null);
    
    TransparentStoreFast store = (TransparentStoreFast) TransparentStoreFactory.getStore();
    
    DataSplitter ds = store.getDataSplitter(new monPredicate[] {pred}, 120000);
    
    final long[] lTimes = new long[] {1000*60*60, 1000*60*60*6, 1000*60*60*12, 1000*60*60*24};
    
    final long lNow = System.currentTimeMillis();
    
    int iCount = 0;
    
    int max = 0;
    
    Vector vCache = Cache.getLastValues(pred);
    
    for (int i=0; i<vCache.size(); i++){
	Object o = vCache.get(i);
	
	if (o instanceof Result){
	    Result r = (Result) o;
	    
	    if (!r.FarmName.equals("_TOTALS_") && r.param[0] > max)
		max = (int) r.param[0];
	}
    }
    
    int serv_ok = 0;
    int serv_warn = 0;
    int serv_down = 0;

    while (db.moveNext()){
	String sSite = db.gets(1);
	
	pred.Farm = sSite;
	
	Object o = Cache.getLastValue(pred);
	
	int lastValue = 0;
	
	boolean bt = sSite.equals("_TOTALS_");
	
	if (!bt){
    	    pLine.modify("color", iCount%2==0 ? "FFFFFF" : "EFEFF8");
	    iCount++;

	    pLine.modify("count", iCount);
	    pLine.modify("site", sSite);
	}
	
	if (o != null && o instanceof Result){
	    double v = ((Result) o).param[0];
	    
	    lastValue = (int) v;
	    
	    (bt ? p : pLine).modify("running", lastValue);
	}
	else{
	    (bt ? p : pLine).modify("running", "-");
	}
	
	if (!bt){
	    predServices.Farm = sSite;
	    Vector vServices = Cache.getLastValues(predServices);
	
	    if (vServices==null || vServices.size()==0){
		pLine.modify("icon", "stop");
		pLine.modify("message", "No monitoring information");
		
		serv_down++;
	    }
	    else{
		boolean ok = true;
	    
	        String sMessage = "";
	
		for (int i=0; i<vServices.size(); i++){
		    o = vServices.get(i);
		
		    if (o instanceof Result){
			Result r = (Result) o;
		    
			if (r.param[0] > 0.5){
			    ok = false;
			
			    predMessages.Farm = sSite;
			    predMessages.Node = r.NodeName;
			
			    o = Cache.getLastValue(predMessages);
			
			    sMessage += "<b>"+r.NodeName+"</b> : <br>";
			
			    if (o instanceof eResult){
				sMessage += Formatare.replace(((eResult) o).param[0].toString(), "\n", "<br>")+"<br><br>";
			    }
			}
		    }
		}
	    
		if (ok){
		    pLine.modify("icon", "ok_19");
		    pLine.modify("message", "All services are OK");
		    
		    serv_ok++;
		}
		else{
		    pLine.modify("icon", "warning");
		    pLine.modify("message", sMessage);
		    serv_warn++;
		}
	    }

	    double l = Math.sqrt(lastValue);
	    double m = Math.sqrt(max);
	
	    int r = (int) (255 - (l * 55 / m));
	    int b = 255;
	    int g = (int) (255 - (l * 55 / m));
	
	    pLine.modify("running_color", Utils.toHex(new Color(r,g,b)));
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
	
	for (int j=0; j<lTimes.length; j++){
	    if (lValues[j] >= 0){
		final int v2 = lValues[j];
		final int v1 = lastValue;
		
		(bt ? p : pLine).modify("count_"+j, "<b>"+lValues[j]+"</b>");
		
		final int width = 20;
		final int height = 20;
		
		float sloap;
		
		if (v1 == 0){
			sloap = v2==0 ? 0 : -100000;
		}
		else{
		    /*
			if (v2 > v1){
				sloap = (float) (v1 - v2) / v1;
			}
			else{
				if (v2 == 0)
					sloap = 100000;
				else
					sloap = (float) (v1 - v2) / v2;
			}
		    */
		    if ( v2==0 )
			sloap = 100000;
		    else
			sloap = (float) (v1 - v2) / v2;
		}
		
		//System.err.println("sloap = "+sloap);
		
		final float sloap_abs = (float) Math.abs(sloap);
		
		//System.err.println("sloap_abs = "+sloap_abs);
		
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
		
		final int angle_rnd = Math.round((float)angle) * (sloap < 0 ? -1 : 1);
	
		(bt ? p : pLine).modify("angle_"+j, v1==0 && v2==0 ? "x" : ""+angle_rnd);
		
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
		    
		    (bt ? p : pLine).modify("extra_"+j, "<br>variation: "+ "<font color=#"+Utils.toHex(c)+"><b>"+(percent>0 ? "+" : "") +ServletExtension.showDottedDouble(percent, 1) + "%</b></font>");
		}
	    }
	    else{
		(bt ? p : pLine).modify("count_"+j, "no");
		(bt ? p : pLine).modify("angle_"+j, "x");
	    }
	}
	
	if (!bt)
	    p.append(pLine);
    }
    
    p.modify("services_stats", "<font color=#009900>OK:</font> "+serv_ok+"<br><font color=#CCAA00>Services down:</font> "+serv_warn+"<br><font color=#DD0000>Site down:</font> "+serv_down);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/trend_old.jsp", baos.size(), request);
%>