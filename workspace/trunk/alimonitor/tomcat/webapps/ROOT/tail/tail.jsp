<%
    lia.web.servlets.web.Utils.logRequest("START /tail.jsp", 0, request);

    response.setHeader("Expires", "0");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/html; charset=UTF-8");
    response.setHeader("Content-Language", "en");                                                                                                    

    String sFile = request.getParameter("file");
%>
                                
<html>
<head>
    <title>
        Ajax periodic request
    </title>
    <script src="/js/prototype.js" type="text/javascript"></script>
    <script language="javascript">
	function newText(req){
	    if (req.responseText){
		parent.addText(req.responseText);

		window.setTimeout('scrollPeriodic()', 10);
	    }
	}

	function refreshTailF(){
	    new Ajax.Request(
		'subscribe.jsp?file=<%=sFile%>', 
		{
		    method: 'get', 
		    asynchronous: false, 
		    onSuccess: newText
		}
	    );
	}

	new PeriodicalExecuter(refreshTailF, 2);
		
	function scrollPeriodic(){
	    if (parent.scrollEnabled){
	        window.scrollBy(0, 10000000);
	    }
	}
    </script>
</head>
<body>
<object id="body_layer">
<table>
    <tr>
	<td>
	    <div id="tailf" style="font-family: Courier, Verdana, Arial, Tahoma, sans serif; font-size: 11px;">
	    </div>
	</td>
    </tr>
</table> 
</object>   
</body>
</html>
