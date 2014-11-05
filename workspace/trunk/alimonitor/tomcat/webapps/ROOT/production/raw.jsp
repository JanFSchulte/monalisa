<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*,utils.*"%><%!
    private static final String[] STRING_FIELDS = new String[]{"jt_field1", "jt_description"};
%><%
    if (!lia.web.utils.ThreadedPage.acceptRequest(request, response))
	return;

    response.setHeader("Connection", "keep-alive");

    lia.web.servlets.web.Utils.logRequest("START /production/raw.jsp", 0, request);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.modify("title", "RAW data production requests");
    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    // -------------------
    
    Page p = new Page(null, "production/raw.res", false);
    Page pLine = new Page(null, "production/raw_line.res", false);
    
    RequestWrapper rw = new RequestWrapper(request);
    
    DB db = new DB();

    String sBookmark = "/production/raw.jsp";
    
    String sWhere = "";
    
    // -------------------
    
    for (final String sStringField: STRING_FIELDS){
	final String s = rw.gets(sStringField);
	
	if (s.length()>0){
	    StringTokenizer st = new StringTokenizer(s, ",");
	    
	    String sSearchFor = "";
	    String sSkip = "";
	    
	    while (st.hasMoreTokens()){
		String sValue = st.nextToken().trim();
		
		if (sValue.equals("*")){
		    sSearchFor = "length(trim("+sStringField+"))>0";
		}
		
		if (sValue.length()>0){
		    boolean bNegated = false;
		
		    if (sValue.startsWith("!")){
			sValue = sValue.substring(1);
			bNegated = true;
		    }
		
		    if (sValue.length()==0){
			if (bNegated){
			    sSkip = "length(trim("+sStringField+"))=0";
			    sSearchFor = "";
			    break;
			}
		    }
		    else{
			if (bNegated){
			    if (sSkip.length()>0)
				sSkip += " AND ";
			    
			    sSkip += sStringField+" NOT ILIKE '%"+Format.escSQL(sValue)+"%'";
			}
		        else{
		    	    if (sSearchFor.length()>0)
		    		sSearchFor += " OR ";
		    	
		    	    sSearchFor += sStringField+" ILIKE '%"+Format.escSQL(sValue)+"%'";
			}
		    }
		}
	    }
	    
	    if (sSearchFor.length()>0){
		sWhere = IntervalQuery.cond(sWhere, sSearchFor);
	    }
	    
	    if (sSkip.length()>0){
		if (sSearchFor.length()==0)
		    sSkip = sStringField+" IS NULL OR ("+sSkip+")";
		    
		sWhere = IntervalQuery.cond(sWhere, sSkip);
	    }
	    
	    p.modify(sStringField, s);
	    
	    sBookmark = IntervalQuery.addToURL(sBookmark, sStringField, s);
	}
    }

    
    db.query("select * from raw_view "+sWhere);
    
    double dWallTime = 0;
    double dSavingTime = 0;
    long lOutputSize = 0;

    //final boolean machine = rw.getb("machine", false);
    
    while (db.moveNext()){
	pLine.fillFromDB(db);

	dWallTime += db.getd("wall_time");
	dSavingTime += db.getd("saving_time");
	
	lOutputSize += db.getl("esds_size");
	
	if("Running".equals(db.gets("jt_field2")))
	    pLine.modify("bgcolor", "#54E715");
	    
	String sType = db.gets("jt_field2");

	if("Pending".equals(sType) || sType.startsWith("Quality") || sType.startsWith("Macros") || sType.startsWith("Software") || sType.startsWith("Technical") )
	    pLine.modify("bgcolor", "yellow");

	if("Completed".equals(db.gets("jt_field2")))
	    pLine.modify("bgcolor", "#A1EBFF");
	
	double dChunksPercentage = -1;
	
	if (db.geti("chunks_sum") > 0){
	    dChunksPercentage = db.getd("processed_chunks_sum")*100 / db.getd("chunks_sum");
	
	    final int iPercentage = (int) dChunksPercentage;
	    
	    String sColor = "";
	    
	    if (iPercentage>=90){
		sColor = "#00BB00";
	    }
	    else
	    if (iPercentage>=80){
		sColor = "#00FF00";
	    }
	    else
	    if (iPercentage>=70){
		sColor = "#99FF00";
	    }
	    else
	    if (iPercentage>=60){
		sColor = "#FFFF00";
	    }
	    else
	    if (iPercentage>=50){
		sColor = "#FF9900";
	    }
	    else
		sColor = "#FF0000";
	
	    pLine.modify("chunks_percentage", iPercentage+"%");
	    pLine.modify("chunks_percentage_color", sColor);
	}

	if (db.getl("raw_size") > 0 && db.getl("esds_size")>0){
	    double dSizePercentage = db.getd("esds_size")*100 / db.getd("raw_size");

	    if (dChunksPercentage > 0)
		dSizePercentage = dSizePercentage * 100 / dChunksPercentage;
	
	    final int iPercentage = (int) dSizePercentage;
	
	    String sColor = "";

	    if (iPercentage<=10){
		sColor = "#00BB00";
	    }
	    else
	    if (iPercentage<=20){
		sColor = "#00FF00";
	    }
	    else
	    if (iPercentage<=30){
		sColor = "#99FF00";
	    }
	    else
	    if (iPercentage<=40){
		sColor = "#FFFF00";
	    }
	    else
	    if (iPercentage<=50){
		sColor = "#FF9900";
	    }
	    else
		sColor = "#FF0000";
	
	    pLine.modify("size_percentage", iPercentage+"%");
	    pLine.modify("size_percentage_color", sColor);
	}
	else{
	    pLine.modify("size_percentage_color", "#EEEEEE");
	    pLine.modify("size_percentage", "-");
	}

	p.append("content", pLine);
    }
    
    p.modify("wall_time", dWallTime);
    p.modify("saving_time", dSavingTime);
    p.modify("esds_size", lOutputSize);

    // -------------------
        
    pMaster.append(p);
        
    pMaster.write();
            
    String s = new String(baos.toByteArray());
    out.println(s);
                    
    lia.web.servlets.web.Utils.logRequest("/production/raw.jsp", baos.size(), request);
%>