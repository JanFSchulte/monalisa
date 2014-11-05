<%@ page import="java.util.*,java.text.*,lia.web.utils.PDate" %><%
    lia.web.servlets.web.Utils.logRequest("START /timestamp.jsp", 0, request);

    String s = request.getParameter("epoch");

    String sDate = request.getParameter("date");
    
    String sParsedDate = "";

    if (s!=null && s.length()>0){
	try{
            long l = Long.parseLong(s.trim());

            if (l<2000000000)
                l*=1000;

            sParsedDate = sDate = (new Date(l)).toString();
        }
        catch (Exception e){
	    sParsedDate = sDate = e.toString()+" ("+e.getMessage()+")";
        }
    }
    else
    if (sDate!=null && sDate.length()>0){
	final SimpleDateFormat[] sdfFormats = new SimpleDateFormat[] {
		new SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z"), // 0
		new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"), // 1
		new SimpleDateFormat("yyyy-MM-dd"), // 2
		new SimpleDateFormat("dd.MM.yyyy HH:mm:ss Z"), // 3
		new SimpleDateFormat("dd.MM.yyyy HH:mm:ss"), // 4
		new SimpleDateFormat("dd.MM.yyyy"), // 5
		new SimpleDateFormat("MM/dd/yyyy HH:mm:ss Z"), // 6
		new SimpleDateFormat("MM/dd/yyyy HH:mm:ss"), // 7
		new SimpleDateFormat("MM/dd/yyyy"), // 8
		new SimpleDateFormat("yyyy/MM/dd HH:mm:ss Z"), // 9
		new SimpleDateFormat("yyyy/MM/dd HH:mm:ss"), // 10
		new SimpleDateFormat("yyyy/MM/dd"), // 11
		new SimpleDateFormat("MMM dd HH:mm:ss zzzz yyyy"), // 12 - Mar 14 13:04:30 CET 2007
		new SimpleDateFormat("EEE MMM dd HH:mm:ss zzzz yyyy"), // 13 - Wed Mar 14 13:04:30 CET 2007
	};
    
	Date d = null;

	try{
	    d = new Date(sDate);
	}
	catch (Exception e){
	}

	for (int i = 0; i < sdfFormats.length; i++) {
	    try {
	        d = sdfFormats[i].parse(sDate);
	        break;
    	    }
	    catch (ParseException e) {
	    }
	}
	
	final String sNew = sdfFormats[2].format(new Date()) + " " + sDate;
	    
	for (int i = 0; i < 2; i++){
	    try {
		d = sdfFormats[i].parse(sNew);
		break;
	    }
	    catch (ParseException e) {
		// ignore this too
	    }			
	}

	try{
	    s = ""+d.getTime();
	    sParsedDate = d.toString();
	}
	catch (Exception e){
	    sParsedDate = s = "cannot parse";
	}
    }
%>
<html>
    <head>
	<title>
	    Epoch-Date converter
	</title>
    </head>
    <body>
	<form name=timestmap action=timestamp.jsp method=POST>
	    Enter epoch time : <input type=text name=epoch><br>
	    or date : <input type=text name=date><br>
	    <input type=submit value="Convert">
	</form>
	<br>
	<br>
	Epoch: <%=s!=null ? s : ""%><br>
	Input date : <%=sDate!=null ? sDate : ""%><br>
	Parsed date : <%=sParsedDate%><br>
	<br>
	Request servlet: <%=request.getServletPath()%><br>
	URI : <%=request.getRequestURI()%><br>
	URL : <%=request.getRequestURL()%><br>
	QS : <%=request.getQueryString()%><br>
    </body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/timestamp.jsp", 0, request);
%>