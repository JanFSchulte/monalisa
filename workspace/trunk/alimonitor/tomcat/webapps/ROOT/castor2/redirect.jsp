<%
    final String clusterName = request.getParameter("cluster");
    
    if (clusterName.matches("^[A-Z0-9]+$"))
	response.sendRedirect("/display?page=xrootdse%2FSEs&plot_series=ALICE%3A%3ACERN%3A%3A"+clusterName+"_xrootd_Nodes");
%>
