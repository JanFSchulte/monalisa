<%
    lia.web.servlets.web.Utils.logRequest("START /trend_tooltip.jsp", 0, request);

    final String s = request.getParameter("site");
    final int i = Integer.parseInt(request.getParameter("tab"));    
    
    long lTime = 3600000;
    if (i==2) lTime *= 6;
    if (i==3) lTime *= 12;
    if (i==4) lTime *= 24;
%>
<html>
<head>
</head>
<body leftmargin=0 topmargin=0 bgcolor=white>
<script language=JavaScript src="/js/common.js"></script>
<script language=JavaScript>
function changeTab(id){
    for (i=1; i<=4; i++){
	var x=objById('col'+i);

	if (i==id){
	    x.bgColor='#6A86D0';
	    x.style.color='#FAFF96';
	    x.style.fontWeight='bold';
	    x.style.border = "1px #A1A1A1 solid";
	}
	else{
	    x.bgColor='#E6E6FF';
	    x.style.color='#000000';
	    x.style.fontWeight='normal';
	    x.style.border = "0px #A1A1A1 solid";
	}
    }
}
</script>
<div align=center>
<table border=0 cellspacing=1 cellpadding=3 bgcolor=#A1A1A1 width=100% style="font-family:Verdana,Helvetica,Arial;font-size:10px;cursor:pointer">
    <tr>
	<td id="col4" align=center bgcolor=#<%=i==4 ? "6A86D0" : "E6E6FF"%> onClick="objById('poza').src='/display?page=reports/running_img&dont_cache=true&res_path=nomenu&interval.min=86400000&interval.max=0&plot_series=<%=s%>'; changeTab(4);">24 hours</td>
	<td id="col3" align=center bgcolor=#<%=i==3 ? "6A86D0" : "E6E6FF"%> onClick="objById('poza').src='/display?page=reports/running_img&dont_cache=true&res_path=nomenu&interval.min=43200000&interval.max=0&plot_series=<%=s%>'; changeTab(3);">12 hours</td>
	<td id="col2" align=center bgcolor=#<%=i==2 ? "6A86D0" : "E6E6FF"%> onClick="objById('poza').src='/display?page=reports/running_img&dont_cache=true&res_path=nomenu&interval.min=21600000&interval.max=0&plot_series=<%=s%>'; changeTab(2);">6 hours</td>
	<td id="col1" align=center bgcolor=#<%=i==1 ? "6A86D0" : "E6E6FF"%> onClick="objById('poza').src='/display?page=reports/running_img&dont_cache=true&res_path=nomenu&interval.min=3600000&interval.max=0&plot_series=<%=s%>'; changeTab(1);">1 hour</td>
    </tr>
</table>
<img id="poza" src="/display?page=reports/running_img&dont_cache=true&res_path=nomenu&interval.min=<%=lTime%>&interval.max=0&plot_series=<%=s%>">
</div>
</body>
</html>
<%
    lia.web.servlets.web.Utils.logRequest("/trend_tooltip.jsp?site="+s+"&tab="+i, 1, request);
%>