<%@ page import="lazyj.*,alimonitor.*,lia.Monitor.Store.Fast.DB,auth.*,java.security.cert.*,java.io.*" %><%!
    // functions
%><%
    // code
    lia.web.servlets.web.Utils.logRequest("START /OCDB/upload.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "Upload corrected OCDB file");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    // -------------------

    final RequestWrapper rw = new RequestWrapper(request);

    File f = new File("/tmp/ocdb");
    
    f.mkdirs();

    final com.oreilly.servlet.MultipartRequest mpRequest = rw.initMultipartRequest("/tmp/ocdb", 100*1024*1024);

    final String sPath = rw.gets("path").trim();
    final String sRunRange = rw.gets("runrange").trim();
    final String sDestination = rw.gets("destinationuri").trim();
    
    Page p = null;
    
    if (mpRequest!=null && sPath.length()>0 && sRunRange.length()>0){
	String sFile = null;
    
	if (rw.gets("sourceuri").length()>0 && rw.geti("sourceurirun")>0)
	    sFile = rw.gets("sourceuri")+"?"+rw.geti("sourceurirun");
	else
	    sFile  = "/tmp/ocdb/"+mpRequest.getFilesystemName("file");
	    
	if (sFile==null){
	    response.sendRedirect("upload.jsp");
	    return;
	}

	// call script and display output
	
	p = new Page("OCDB/upload_result.res");
	
	Process child = lia.util.MLProcess.exec(new String[]{"/home/monalisa/MLrepository/bin/ocdb/upload.sh", sPath, sRunRange, sFile, sDestination});
    
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
	}
	finally{
	    try{
		br.close();
	    }
	    catch (Exception e){
	    }
	}
    
	br = new BufferedReader(new InputStreamReader(child.getErrorStream()));
	while ( (sLine=br.readLine())!=null ){
	    p.append(lia.web.utils.HtmlColorer.logLineColorer("stderr: "+sLine)+"<BR>");
	}
	br.close();
    
	child.waitFor();
    }
    else{
	p = new Page("OCDB/upload.res");
    }

    pMaster.append(p);

    pMaster.write();
    
    final String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/OCDB/upload.jsp", baos.size(), request);
%>