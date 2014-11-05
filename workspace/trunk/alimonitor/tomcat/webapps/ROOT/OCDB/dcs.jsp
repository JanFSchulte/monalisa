<%@ page import="lazyj.*,alimonitor.*,lia.Monitor.Store.Fast.DB,auth.*,java.security.cert.*,java.io.*,java.util.*" %><%!
    // functions
%><%
    // code
    lia.web.servlets.web.Utils.logRequest("START /OCDB/dcs.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "DCS Test");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    // -------------------

    final RequestWrapper rw = new RequestWrapper(request);

    File f = new File("/tmp/ocdb");
    
    f.mkdirs();

    final String sPath = rw.gets("path").trim();
    final String sRunRange = rw.gets("runrange").trim();
    final String sDestination = rw.gets("destinationuri").trim();
    
    Page p = null;
    
    if (rw.gets("instance").length()>0){
	String instance = rw.gets("instance");
	
	if (!instance.equals("prod") && !instance.equals("prod2") && !instance.equals("prod3") && !instance.equals("test"))
	    return;
    
	String det = rw.gets("detector");
	
	if (!det.matches("^[A-Z0-9]{3}$"))
	    return;
	
	int verbose = rw.geti("verbose", -1);
	
	if (verbose!=0 && verbose!=1)
	    return;
	
	String start_time = rw.gets("start_time");
	String end_time = rw.gets("end_time");
	
	Date start_date = Format.parseDate(start_time);
	Date end_date = Format.parseDate(end_time);
	
	if (start_date.getTime() > end_date.getTime()){
	    Date d = start_date;
	    start_date = end_date;
	    end_date = d;
	}
	
	int field = rw.geti("numeric_field");
	
	// call script and display output
	
	p = new Page("OCDB/dcs_result.res", false);
	
	Process child = lia.util.MLProcess.exec(new String[]{"/home/monalisa/MLrepository/bin/ocdb/dcs.sh", instance, det, ""+start_date.getTime()/1000, ""+end_date.getTime()/1000, ""+field, ""+verbose}, 1000*60*30);

	final OutputStream child_out = child.getOutputStream();
	child_out.close();
    
	BufferedReader br = new BufferedReader(new InputStreamReader(child.getInputStream()));
	String sLine;
    
	try{
	    while ( (sLine=br.readLine())!=null ){
		p.append(lia.web.utils.HtmlColorer.logLineColorer(sLine)+"<BR>");
	    }
	}
	catch (Exception e){
	    // stream closed abruptly (kill ?)
	    out.println("Exception: calling dcs.sh failed: "+e.getMessage());
	    return;
	}
	finally{
	    try{
		br.close();
	    }
	    catch (Exception e){
	    }
	}
	
	br = null;
	
	try{
    	    br = new BufferedReader(new InputStreamReader(child.getErrorStream()));
	    while ( (sLine=br.readLine())!=null ){
		p.append(lia.web.utils.HtmlColorer.logLineColorer("stderr: "+sLine)+"<BR>");
	    }
	}
	catch (Exception e){
	    out.println("Calling dcs.sh failed: "+e.getMessage());
	    return;
	}
	finally{
	    if (br!=null){
	        try{
		    br.close();
		}
		catch (Exception e){
		}
	    }
	}
    
	child.waitFor();
    }
    else{
	p = new Page("OCDB/dcs.res", false);
    }

    pMaster.append(p);

    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/OCDB/dcs.jsp", baos.size(), request);
%>