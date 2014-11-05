<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,lazyj.commands.*,alien.catalogue.AliEnFile,java.util.Date,alien.pool.AliEnPool,alien.catalogue.*,alien.user.*,java.io.*"%><%!
    final String CASTOR_SE_PREFIX = "root://voalice10.cern.ch/";
    
    final String CASTOR_SE = "ALICE::CERN::T0ALICE";
    
    final String PATH_PREFIX = "/alice/data";
    
    final boolean USE_JAPI = true;
    
    private static PrintWriter pwLog = null;
    
    private static final Object lock = new Object();

    private static final synchronized void logMessage(final String message){
	final Date d = new Date();
    
	if (pwLog==null){
	    try{
		pwLog = new PrintWriter(new FileWriter("/home/monalisa/MLrepository/logs/daqreg.log", true));
	    }
	    catch (Exception e){
		// ignore
	    }
	}
	
	boolean logged = false;
    
	if (pwLog!=null){
	    try{
		pwLog.println(d+": "+message);
	        pwLog.flush();
	        
	        logged = true;
	    }
	    catch (Exception e){
		pwLog = null;
	    }
	}

	if (!logged)
	    System.err.println("daqreg.jsp: "+d+" : "+message);
    }
    
    private static final AliEnPrincipal OWNER = UserFactory.getByUsername("alidaq");
    
%><%
    if (!request.getRemoteAddr().equals("137.138.116.73") && !request.getRemoteAddr().equals("128.141.144.178") &&
	!request.getRemoteAddr().equals("137.138.116.74")
    ){
	lia.web.servlets.web.Utils.logRequest("/work/daqreg.jsp?DENIED", 0, request);
	out.println("err:access denied");
	return;
    }

    lia.web.servlets.web.Utils.logRequest("START /work/daqreg.jsp", 0, request);
    
    response.setContentType("text/plain");
    
    final RequestWrapper rw = new RequestWrapper(request);

    final long lSize = rw.getl("size");
    final String surl = rw.gets("surl");
    final long ctime = rw.getl("ctime");
    final String run = rw.gets("run");
    final String partition = rw.gets("meta:accPeriod");
    final String md5 = rw.gets("md5");
    final String guid = rw.gets("guid").trim();
    
    // sanity check
    
    if (lSize <= 0 || surl.length() == 0 || ctime <= 0 || run.length() <= 0 || partition.length() <= 0 || md5.length() <= 0){
	out.println("err:wrong parameters");
	return;
    }
    
    final int year = new Date().getYear() + 1900;
    
    final String sDir = PATH_PREFIX+"/"+year+"/"+partition+"/"+run+"/raw";

    final AliEnFile fDir = new AliEnFile(sDir);
    
    if (!fDir.exists()){
	if (!fDir.mkdir(OWNER)){
	    log("daqreg.jsp : cannot create directory : "+sDir);
	    out.println("err:cannot create directory");
	    return;
	}
    }

    // make sure the catalogue is ok

    final String sFile = sDir+surl.substring(surl.lastIndexOf('/'));

    final AliEnFile f = new AliEnFile(sFile);
    
    if (f.exists()){
	out.println("ok:file was already registered");
    }
    else{
	boolean done = false;
    
	if (USE_JAPI){
	    try{
		synchronized(lock){
		    done = Register.register(sFile, CASTOR_SE_PREFIX+surl, guid, md5, lSize, CASTOR_SE, OWNER);
		}
	    }
	    catch (Throwable t){
		logMessage("caught exception : "+t+" ("+t.getMessage()+")");
		t.printStackTrace();
	    }
	    
	    if (!done){
		logMessage("Registering by JAPI failed for:\nFile : "+sFile+"\nPFN: "+CASTOR_SE_PREFIX+surl+"\nGUID: "+guid+"\nMD5: "+md5+"\nSize: "+lSize+"\nSE: "+CASTOR_SE);
	    }
	    else{
		logMessage("Successfuly registered by JAPI : "+sFile+", "+CASTOR_SE_PREFIX+surl+", "+guid+", "+md5+", "+lSize+", "+CASTOR_SE);
	    }
	    
	    f.refresh();
	    
	    if (f.exists()){
		if (!done){
		    done = true;
		
		    out.println("ok:file was concurrently inserted by somebody else maybe ?");
		    logMessage("was registered in parallel : "+sFile+", "+CASTOR_SE_PREFIX+surl+", "+guid+", "+md5+", "+lSize+", "+CASTOR_SE);
		}
		else{
		    out.println("ok: successfully registered");
		}
	    }
	    else{
		out.println("err:could not register the file");
            }
	}
        else{   
	    final String sCommand = "register "+sFile+" "+CASTOR_SE_PREFIX+surl+" "+lSize+" "+CASTOR_SE+" "+guid+" -md5 "+md5;
    
	    logMessage("falling back to registering via AliEn : "+sCommand);
    
	    final CommandOutput co = AliEnPool.executeCommand("alidaq", sCommand, true);
	
	    if (co!=null){
		if (co.stdout.indexOf(" inserted in the catalog")>=0){
		    out.println("ok:file registered successfully");
		}
		else{
		    f.refresh();
		
		    if (f.exists()){
			out.println("ok:file was concurrently inserted by somebody else");
		    }
		    else{
			out.println("err:could not register the file");
			logMessage("could not register the file because : "+co);
			out.println(co);
		    }
		}
	    }
	    else{
		logMessage("null output trying to execute : "+sCommand);
	    }
	}
    }
    
    if (sFile.endsWith(".0.tag.")){
	out.println("repository:will not insert this file");
	return;
    }
    
    // then update the repository database accordingly
    final DB db = new DB();
    
    if (!db.query("SELECT 123 FROM rawdata WHERE lfn='"+Format.escSQL(sFile)+"';")){
	out.println("repository:cannot query database");
	return;
    }
    
    int code = 0;
    
    if (db.geti(1) == 123){
	final String q = "UPDATE rawdata SET size="+lSize+", pfn='"+Format.escSQL(surl)+"', addtime="+ctime+" WHERE lfn='"+Format.escSQL(sFile)+"' AND (size IS NULL OR size!="+lSize+" OR pfn IS NULL OR pfn!='"+Format.escSQL(surl)+"' OR addtime IS NULL OR addtime!="+ctime+");";
	
	//System.err.println(q);
	
	if (db.syncUpdateQuery(q)){
	    if (db.getUpdateCount()==0){
		out.println("repository:file existed with all details");
		code = 1;
	    }
	    else{
		out.println("repository:file existed but was updated");
		code = 2;
	    }
	}
	else{
	    out.println("repository:cannot update the existing file");
	    code = 3;
	}
    }
    else{
	if (db.syncUpdateQuery("INSERT INTO rawdata (lfn, addtime, size, pfn) VALUES ('"+Format.escSQL(sFile)+"', "+ctime+", "+lSize+", '"+Format.escSQL(surl)+"');")){
	    if (db.getUpdateCount()==0){
		out.println("repository:cannot insert new file");
		code = 4;
	    }
	    else{
		out.println("repository:new file successfully inserted");
		code = 5;
	    }
	}
	else{
	    out.println("repository:cannot insert new file");
	    code = 6;
	}
    }
    
    lia.web.servlets.web.Utils.logRequest("/work/daqreg.jsp?lfn="+sFile+"&pfn="+surl+"&size="+lSize, code, request);
%>