<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.Date"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/comments.jsp", 0, request);
%>
<html>
<head>
    <link type="text/css" rel="StyleSheet" href="/style/style.css" />
</head>
<body bgcolor=white class="text">
<script type="text/javascript">
    var hiddenDisplayed = false;

    function showHidden(){
	var d = document.getElementsByTagName("div");
	
	for (i=0; i<d.length; i++){
	    if (d[i].id=='type0')
	        d[i].style.display = hiddenDisplayed ? 'none' : 'inline';
	}
	
	hiddenDisplayed = !hiddenDisplayed;
    }
</script>
<a href="javascript:void(0);" onClick="return showHidden();" class="link">Show/hide system log</a><br>
<%
    DB db = new DB("SELECT * FROM pwg_comments WHERE pg_pid="+Integer.parseInt(request.getParameter("id"))+" ORDER BY pg_time DESC;");
    
    while (db.moveNext()){
	Date d = lazyj.Format.parseDate(db.gets("pg_time"));
    
	out.println("<div id='type"+db.geti("pg_type")+"' style='display: "+(db.geti("pg_type")==0 ? "none" : "inline")+"'>");
	out.println("<b>Author</b>: <a title='"+db.gets("pg_dn")+"'>"+db.gets("pg_author")+"</a><BR>");
	out.println("<b>Date</b>: <a title='"+d+"'>"+new lia.web.utils.MailDate(d)+"</a><BR>");
	out.println("<b>Comment</b>:<br>");
	out.println("<div style='padding-left: 10px'><div>"+db.gets("pg_comment")+"</div></div>");
	out.println("<HR size=1>");
	out.println("</div>");
    }
%>
<a href="javascript:void(0);" onClick="return showHidden();" class="link">Show/hide system log</a><br>
</body>
</html><%
    lia.web.servlets.web.Utils.logRequest("/PWG/comments.jsp", 0, request);
%>