<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,lazyj.*"%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    lia.web.servlets.web.Utils.logRequest("START /production/job_details.jsp", 0, request);

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setCacheTimeout(response, 60);
    
    final DB db = new DB();
    
    final int run = rw.geti("run");

    db.query("select size,chunks,daq_goodflag,ontape,ont1,events,status as shuttle_status,round(rm1.rm_value::real) as rm_value_events,rm2.rm_value as caf_status,mintime,maxtime,s.runtype "+
	"from rawdata_runs rr left outer join shuttle s on s.run=rr.run and detector='SHUTTLE' and instance='PROD' "+
	"                     left outer join rawreco_messages rm1 on rm1.rm_run=s.run and rm1.rm_key='Event_count' "+
	"                     left outer join rawreco_messages rm2 on rm2.rm_run=s.run and rm2.rm_key='Status' "+
	"where rr.run="+run+";");

    if (!db.moveNext())
	return;
    
    final Page p = new Page(null, "raw/rawrun_details.res");
    p.setWriter(out);

    p.fillFromDB(db);

    p.modify("daq_goodrun", db.geti("daq_goodflag", -1)==1 ? "<font color=green>YES</font>" : db.geti("daq_goodflag", -1)==0 ? "<font color=red>NO</font>" : "N/A");
    p.modify("on_tape", db.geti("ontape")==1 ? "<font color=green>YES</font>" : "<font color=red>NO</font>");
    p.modify("on_t1", db.geti("ont1")==1 ? "<font color=green>YES</font>" : "<font color=red>NO</font>");

    String sShuttleColor = "grey";
    
    if (db.gets("shuttle_status").startsWith("Done"))
	sShuttleColor = "green";
    else
    if (db.gets("shuttle_status").equals("Processing"))
	sShuttleColor = "blue";
    
    p.modify("shuttle_color", sShuttleColor);
    
    
    String sCAFStatusColor = "black";
    
    if (db.gets("caf_status").startsWith("Started"))
	sCAFStatusColor = "yellow";
    else
    if (db.gets("caf_status").startsWith("Fail"))
	sCAFStatusColor = "red";
    else
    if (db.gets("caf_status").startsWith("Done"))
	sCAFStatusColor = "green";
    
    p.modify("caf_status_color", sCAFStatusColor);
    
    db.query("select detector,status from shuttle where run="+run+" and instance='PROD' and detector!='SHUTTLE';");
    
    
    boolean bFirst = true;
    
    while (db.moveNext()){
	if (!bFirst)
	    p.append("detectors", ", ");
	else
	    bFirst = false;
	
	final String sDetector = db.gets("detector");
	final String sStatus = db.gets("status").toLowerCase();
	
	String sColor="red";

	if (sStatus.indexOf("done")>=0)
	    sColor = "green";
	else
	if (sStatus.indexOf("skip")>=0)
	    sColor = "grey";
	else
	if (sStatus.indexOf("start")>=0 || sStatus.indexOf("pending")>=0 || sStatus.indexOf("processing")>=0 || sStatus.indexOf("delayed")>=0)
	    sColor = "blue";	
	
	p.append("detectors", "<font color="+sColor+">"+sDetector+"</font>");
    }
    
    db.query("select detector,run_quality from logbook_detectors where run="+run+" order by 1;");
    
    bFirst = true;
    
    while (db.moveNext()){
	if (!bFirst)
	    p.append("daq_detectors", ", ");
	else
	    bFirst = false;
	
	final String sDetector = db.gets(1);
	final int status = db.geti(2);
	
	String sColor;
	
	switch (status){
	    case  0: sColor = "grey"; break;
	    case  1: sColor = "green"; break;
	    case  2: sColor = "red"; break;
	    default: sColor = "orange";
	}
	
	p.append("daq_detectors", "<font color="+sColor+">"+sDetector+"</font>");
    }
    
    p.write();
    
    lia.web.servlets.web.Utils.logRequest("/production/job_details.jsp", 0, request);
%>