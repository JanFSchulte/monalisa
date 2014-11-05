<%@ page import="alimonitor.*,auth.*,lazyj.*,alien.catalogue.*,java.io.*,alien.pool.*,java.util.*,alien.quotas.*" buffer="16kb"%><%
    lia.web.servlets.web.Utils.logRequest("START /users/quota.jsp", 0, request);

    if (!utils.RobotsFilter.acceptRequest(request, response))
	return;
    
    response.setContentType("text/html");
    
    final AlicePrincipal p = Users.get(request);
    
    if (p==null){
	System.err.println("users/quota.jsp : Not authenticated");
	return;
    }

    final RequestWrapper rw = new RequestWrapper(request);
    
    RequestWrapper.setCacheTimeout(response, 60);
    
    final String sAccount = rw.gets("u", p.getName());

    if (!p.canBecome(sAccount)){
	out.println("No privileges");
	return;
    }    
    
    final FileQuota fq = QuotaUtilities.getFileQuota(sAccount);
    
    if (fq==null)
	return;
    
%>
<table border=0 cellspacing=10 cellpadding=0 width=410 style="font-family:Verdana,Helvetica,Arial;font-size:10px">
    <tr>
	<th colspan=2>No. of files</th>
	<th colspan=2>Disk space</th>
    </tr>
    <tr>
	<td colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=10>
		    <td width="<%=(int) (100*fq.nbFiles / fq.maxNbFiles)%>%" bgcolor=red></td>
		    <td width="<%=100-(int) (100*fq.nbFiles / fq.maxNbFiles)%>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>

	<td colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=200>
		<tr height=10>
		    <td width="<%=(int)(100*fq.totalSize/fq.maxTotalSize)%>%" bgcolor=red></td>
		    <td width="<%=100-(int) (100*fq.totalSize/fq.maxTotalSize)%>%" bgcolor=green></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=left>
	    Current:<br>
	    Quota:
	</td>
	<td align=left>
	     <%=Format.showDottedLong(fq.nbFiles)%><br>
	     <%=Format.showDottedLong(fq.maxNbFiles)%>
	</td>
	
	<td align=left>
	    Current:<br>
	    Quota:
	</td>
	<td align=left>
	     <%=Format.size(fq.totalSize)%><br>
	     <%=Format.size(fq.maxTotalSize)%>
	</td>
    </tr>
</table>
