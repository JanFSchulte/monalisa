<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache,java.security.cert.*,auth.*" %><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /DAQ/index.jsp", 0, request);

    // ----- init
    final RequestWrapper rw = new RequestWrapper(request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    
    final Page p = new Page("DAQ/index.res");
    final Page pLine = new Page("DAQ/index_line.res");

    // ----- masterpage settings

    pMaster.comment("com_alternates", false);
    pMaster.modify("refresh_time", "300");
    pMaster.modify("title", "DAQ RAW Data Registration - Runs summary");
    

    // ----- parameters

    final int iHours = rw.geti("time", 24);
    final String sPartitionFilter = rw.gets("partitionfilter");
    final int iStagingFilter = rw.geti("staging", 0);
    final String sRunFilter = rw.gets("runfilter");
    final int iTransferFilter = rw.geti("transfer", 0);
    final int iProcessingFilter = rw.geti("processing", 0);
    
    final Set<Integer> sPreviouslyCheckedRuns = new HashSet<Integer>();
    for (String s: rw.getValues("pfo")){
	sPreviouslyCheckedRuns.add(Integer.parseInt(s));
    }
    
    final Set<Integer> sCurrentlyCheckedRuns = new HashSet<Integer>();
    for (String s: rw.getValues("processing_flag")){
	sCurrentlyCheckedRuns.add(Integer.parseInt(s));
    }
    
    final Set<Integer> sRemovedRuns = new HashSet<Integer>(sPreviouslyCheckedRuns);
    sRemovedRuns.removeAll(sCurrentlyCheckedRuns);
    
    final Set<Integer> sAddedRuns = new HashSet<Integer>(sCurrentlyCheckedRuns);
    sAddedRuns.removeAll(sPreviouslyCheckedRuns);
    
    // ------
    pMaster.modify("bookmark", "/DAQ/?time="+iHours+
	(sPartitionFilter.length()>0 ? "&partitionfilter="+Format.encode(sPartitionFilter) : "")+
	(iStagingFilter > 0 ? "&staging="+iStagingFilter : "")+
	(sRunFilter.length()>0 ? "&runfilter="+Format.encode(sRunFilter) : "")+
	(iTransferFilter>0 ? "&transfer="+iTransferFilter : "")+
	(iProcessingFilter>0 ? "&processing="+iProcessingFilter : "")
    );
    
    // ----- See if we switched to admin mode and we have to enable some run
    boolean bAuthOK = false;

    if (request.isSecure()){
        X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");

        if (cert!=null && cert.length>0){
            AlicePrincipal principal = new AlicePrincipal(cert[0].getSubjectDN().getName());

            String sName = principal.getName();
            
            if (sName!=null && sName.length()>0){
                Set<String> sRoles = LDAPHelper.checkLdapInformation("users="+sName, "ou=Roles,", "uid");

                bAuthOK = sRoles.contains("webadmin");
            }
        }
    }

    if (bAuthOK){
	int iRun = rw.geti("run");
	
	DB db = new DB();
	
	if (iRun>0){
	    String sQuery = "UPDATE rawdata_runs SET staging_status=1 WHERE run='"+iRun+"' AND staging_status=0;";
	    
	    db.syncUpdateQuery(sQuery);
	}
	
	int iDel = rw.geti("delete");
    
	if (iDel>0){
	    String sQuery = "UPDATE rawdata_runs SET staging_status=0 WHERE run='"+iDel+"' AND staging_status=3;";

    	    db.syncUpdateQuery(sQuery);
	}
	
	/*
	for (Integer iAddedRun : sAddedRuns)
	    db.syncUpdateQuery("UPDATE rawdata_runs SET processing_flag=1 WHERE run='"+iAddedRun+"' AND processing_flag=0;");

	for (Integer iRemovedRun : sRemovedRuns)
	    db.syncUpdateQuery("UPDATE rawdata_runs SET processing_flag=0 WHERE run='"+iRemovedRun+"' AND processing_flag>0;");
	    
	if (sAddedRuns.size()>0){
	    try{
	        Process child = lia.util.MLProcess.exec(new String[]{"/home/monalisa/MLrepository/bin/processing/processing_bg.sh"});
		child.waitFor();
	    }
	    catch (Throwable t){
		System.err.println("DAQ/index.jsp : "+t+" ("+t.getMessage()+")");
		t.printStackTrace();
	    }
	}
	*/
    }

    // ----- page contents
    
    p.modify("time_"+iHours, "selected");
    p.modify("staging_"+iStagingFilter, "selected");
    p.modify("not_secure", bAuthOK ? "false" : "true");
    p.modify("runfilter", sRunFilter);
    p.modify("transfer_"+iTransferFilter, "selected");
    p.modify("processing_"+iProcessingFilter, "selected");
    
    String sCond = iHours<=0 ? "" : "WHERE mintime>extract(epoch from now()-'"+iHours+" hours'::interval)::int";
    
    if (iStagingFilter>0){
	sCond += sCond.length()>0 ? " AND " : "WHERE ";
	
	switch (iStagingFilter){
	    case 3:
		sCond+="staging_status=0";
		break;
	    case 1: 
		sCond+="staging_status=3";
		break;
	    case 2:
		sCond+="(staging_status=1 OR staging_status=2)";
		break;
	}
    }
    
    if (sRunFilter.length()>0){
	sCond += sCond.length()>0 ? " AND ( " : "WHERE (";
	
	Set<String> tsRuns = new TreeSet<String>();
	List<String> lIntervals = new LinkedList<String>();
	
	StringTokenizer st = new StringTokenizer(sRunFilter, ",");
	
	while (st.hasMoreTokens()){
	    String s = st.nextToken();
	    
	    if (s.matches("^[0-9]+$"))
		tsRuns.add(s);
	    else
	    if (s.matches("^[0-9]+-[0-9]+$"))
		lIntervals.add(s);
	}
	
	String sCond1 = "";
	
	for (String s: tsRuns){
	    sCond1 += (sCond1.length()>0 ? "," : "") + s;
	}
	
	String sCond2 = "";
	
	for (String s: lIntervals){
	    sCond2 = sCond2.length()>0 ? " OR (" : "(";
	    
	    String sMin = s.substring(0, s.indexOf("-"));
	    String sMax = s.substring(s.indexOf("-")+1);
	    
	    sCond2 += "rrd.run>="+sMin+" AND rrd.run<="+sMax;
	    
	    sCond2 += ")";
	}
	
	sCond += sCond2;
	
	if (sCond1.length()>0){
	    if (sCond2.length()>0)
		sCond += " OR ";
	
	    sCond += " rrd.run in ("+sCond1+")";
	}
	
	sCond += ")";
    }
    
    if (sPartitionFilter.length()>0){
	sCond += (sCond.length()>0 ? " AND " : "WHERE ") + "partition='"+Format.escSQL(sPartitionFilter)+"'";
    }
    
    if (iTransferFilter>0){
	sCond += (sCond.length()>0 ? " AND " : "WHERE ") + "transfer_status="+(iTransferFilter-1);
    }

    if (iProcessingFilter>0){
	sCond += (sCond.length()>0 ? " AND " : "WHERE ");
	
	if (iProcessingFilter==1)
	    sCond += " rrd.run in (select run from rawdata_processing_requests where status=1)";
	else
	    sCond += "(rrd.run in (select run from rawdata_processing_requests where status=2) AND processed_chunks>0)";
    }
    
    //sCond += sCond.length()>0 ? " AND " : " WHERE ";
    //sCond += "(pass IS NULL or pass=1)";

    String sQuery = "select * from rawdata_runs_details rrd "+sCond+" order by maxtime desc,rrd.run,pass!=1,pass!=0 desc;";

    System.err.println(sQuery);

    DB db = new DB(sQuery);
    
    int iRuns = 0;
    int iFiles = 0;
    long lTotalSize = 0;
    
    int iTransfersCompleted = 0;
    int iTransfersScheduled = 0;
    int iTransfersUnknown   = 0;
    int iTransfersFailed    = 0;    
    
    int iJobsCompleted = 0;
    int iJobsStarted   = 0;
    int iJobsUnknown   = 0;
    
    int iStagingCompleted = 0;
    int iStagingStarted   = 0;
    int iStagingUnknown   = 0;

    int iOldRun = 0;

    while (db.moveNext()){
	final int iRun = db.geti("run");
    
	if (iRun == iOldRun)
	    continue;
	    
	iOldRun = iRun;
    
	pLine.fillFromDB(db);
	pLine.comment("com_auth", bAuthOK);
	
	iRuns++;
	
	pLine.modify("counter", iRuns);
	
	iFiles += db.geti("chunks");
	lTotalSize += db.getl("size");
	
	int iTransferStatus = db.geti("transfer_status", -1);
	
	switch (iTransferStatus){
	    case -1:
	    case 0:
		iTransfersUnknown ++;
		break;
	    case 1:
		pLine.modify("transferstatus_bgcolor", "#FFFF00");
		iTransfersScheduled ++;
		break;
	    case 2:
		pLine.modify("transferstatus_bgcolor", "#00FF00");
		iTransfersCompleted ++;
		break;
	    case 3:
		pLine.modify("transferstatus_bgcolor", "#FF0000");
		iTransfersFailed ++;
		break;
	    default:
		iTransfersUnknown++;
	}
	
	int iProcessing = db.geti("status");

	if (iProcessing==1){
	    pLine.modify("processingstatus_bgcolor", "#FFFF00");
	    iJobsStarted++;
	}
	else
	if (iProcessing==2 || db.geti("processed_chunks")>0){
	    pLine.modify("processingstatus_bgcolor", "#00FF00");
	    iJobsCompleted++;
	}
	else{
	    iJobsUnknown++;
	}
	
	int iStagingStatus = db.geti("staging_status");
	
	switch (iStagingStatus){
	    case  3: iStagingCompleted++; break;
	    case  2:
	    case  1: iStagingStarted++; break;
	    default: iStagingUnknown++;
	}
	
	if (iStagingStatus>0){
	    pLine.modify("stagingstatus_bgcolor", iStagingStatus==3 ? "#00FF00" : "#FFFF00");
	}
	
	pLine.comment("com_remove", bAuthOK && iStagingStatus==3);
	pLine.comment("com_order", bAuthOK && iStagingStatus==0);
	
	String sPath = db.gets("collection_path");
	
	if (sPath.indexOf("/")>=0){
	    sPath = sPath.substring(0, sPath.lastIndexOf("/")+1) + "ESDs";
	    
	    pLine.modify("esds_path", sPath);
	}
	
	pLine.comment("com_processing_flag", iProcessing>0 || db.geti("processed_chunks")>0);
	pLine.comment("com_processing_flag_auth", iProcessing==1 && bAuthOK);

	pLine.comment("com_errorv", db.geti("errorv_count")>0);
	
	pLine.comment("com_job", db.geti("req_masterjob_id")>0);
	
	p.append(pLine);
    }
    
    p.modify("runs", iRuns);
    p.modify("files", iFiles);
    p.modify("totalsize", lTotalSize);
    
    p.modify("transfers_unknown", iTransfersUnknown);
    p.modify("transfers_scheduled", iTransfersScheduled);
    p.modify("transfers_completed", iTransfersCompleted);
    
    p.modify("jobs_unknown", iJobsUnknown);
    p.modify("jobs_started", iJobsStarted);
    p.modify("jobs_completed", iJobsCompleted);
    
    p.modify("staged_unknown", iStagingUnknown);
    p.modify("staged_started", iStagingStarted);
    p.modify("staged_completed", iStagingCompleted);
    
    String sPartQuery = "SELECT p FROM (SELECT distinct partition as p FROM rawdata_runs ";
    
    if (iHours>0)
	sPartQuery += "WHERE mintime>extract(epoch from now()-'"+iHours+" hours'::interval)::int";
    
    sPartQuery+=") AS x ORDER BY split_part(p,'_',1) DESC, p ASC";
    
    db.query(sPartQuery);

    while (db.moveNext()){
	String sPartition = db.gets(1);
    
	p.append("opt_partitions", "<option value='"+sPartition+"' "+(sPartition.equals(sPartitionFilter)?"selected":"")+">"+sPartition+"</option>");
    }

    // ----- closing
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/DAQ/index.jsp", baos.size(), request);
%>