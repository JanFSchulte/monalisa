<%@ page import="alimonitor.*,java.util.regex.*,java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.Monitor.Store.Fast.DB,lazyj.*,utils.IntervalQuery,java.util.concurrent.atomic.*"%><%!
%><%
    lia.web.servlets.web.Utils.logRequest("START /prod/du.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    final RequestWrapper rw = new RequestWrapper(request);

    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    final boolean raw = rw.getb("raw", false);

    pMaster.modify("title", "Disk usage per "+(raw ? "RAW" : "MC")+" production");
    
    final Page p = new Page("prod/du.res", false);

    final Page pLine = new Page("prod/du_el.res", false);
    
    boolean excludeLocked = rw.getb("exclude", false);

    int timeConstraint = rw.geti("lastaccesstime");

    String sWhere = "";
    
    String sBookmark = "/prod/du.jsp";
    
    if (excludeLocked){
	sWhere = IntervalQuery.cond(sWhere, "locked_by IS NULL");
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "exclude", "1");
    }
    
    String sLockedBy = rw.gets("locked_by");
    
    if (sLockedBy.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "locked_by ~* '"+Format.escSQL(sLockedBy)+"'");
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "locked_by", sLockedBy);
	
	p.modify("locked_by", sLockedBy);
    }
    
    if (timeConstraint>0){
	sWhere = IntervalQuery.cond(sWhere, "(lastaccesstime is null or lastaccesstime<extract(epoch from now()-'"+timeConstraint+" month'::interval)::int)");
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "lastaccesstime", ""+timeConstraint);

        p.modify("lastaccesstime_"+timeConstraint, "selected");
    }

    String sTag = rw.gets("tag");
    
    if (sTag.length()>0){
	sWhere = IntervalQuery.cond(sWhere, "tag ~* '"+Format.escSQL(sTag)+"'");
	
	sBookmark = IntervalQuery.addToURL(sBookmark, "tag", sTag);
	
	p.modify("tag", sTag);
    }
    
    DB db = new DB("SELECT * FROM production_"+(raw ? "raw" : "du")+" LEFT OUTER JOIN job_types ON tag=jt_field1 "+sWhere+" ORDER BY tag DESC;");
    
    p.check("exclude", excludeLocked);
    
    while (db.moveNext()){
	pLine.fillFromDB(db);
	
	pLine.modify("factor", (double) db.getl("physical_size") / db.getl("logical_size"));
	pLine.modify("aods_factor", (double) db.getl("aods_physical_size") / db.getl("aods_logical_size"));
	pLine.modify("pwgs_factor", (double) db.getl("pwgs_physical_size") / db.getl("pwgs_logical_size"));
	pLine.modify("qas_factor", (double) db.getl("qas_physical_size") / db.getl("qas_logical_size"));
	
	String locked = db.gets("locked_by");
	
	if (locked.length()>0)
	    pLine.modify("locked_by_x", Format.replace(Format.replace(locked.substring(1), "PWG-", ""), ",", ", "));
	
	p.append(pLine);
    }
    
    db.query("select count(1) as cnt, "+
	"sum(physical_count) as physical_count, sum(physical_size) as physical_size, sum(logical_count) as logical_count, sum(logical_size) as logical_size,sum(physical_size)/sum(logical_size) as factor, "+
	"sum(aods_physical_count) as aods_physical_count, sum(aods_physical_size) as aods_physical_size, sum(aods_logical_count) as aods_logical_count, sum(aods_logical_size) as aods_logical_size,sum(aods_physical_size)/sum(aods_logical_size) as aods_factor, "+
	"sum(pwgs_physical_count) as pwgs_physical_count, sum(pwgs_physical_size) as pwgs_physical_size, sum(pwgs_logical_count) as pwgs_logical_count, sum(pwgs_logical_size) as pwgs_logical_size,sum(pwgs_physical_size)/sum(pwgs_logical_size) as pwgs_factor, "+
	"sum(qas_physical_count) as qas_physical_count, sum(qas_physical_size) as qas_physical_size, sum(qas_logical_count) as qas_logical_count, sum(qas_logical_size) as qas_logical_size,sum(qas_physical_size)/sum(qas_logical_size) as qas_factor "+
	"from production_"+(raw?"raw":"du")+" LEFT OUTER JOIN job_types ON tag=jt_field1 "+sWhere);
    
    p.fillFromDB(db);
    
    pMaster.modify("bookmark", sBookmark);
    
    pMaster.append(p);
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/prod/du.jsp", baos.size(), request);
%>