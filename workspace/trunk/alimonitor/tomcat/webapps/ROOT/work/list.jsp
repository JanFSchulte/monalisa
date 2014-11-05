<%@ page import="lazyj.*,java.util.*"%><%
    RequestWrapper rw = new RequestWrapper(request);
    
    String list = rw.gets("list");
    
    String token = rw.gets("token");
    
    String separator = rw.gets("separator", ", ");
    
    StringTokenizer st = new StringTokenizer(list, "'\",; \t\n\r");
    
    StringBuilder sb = new StringBuilder(list.length());
    
    int cnt=0;
    
    while (st.hasMoreTokens()){
	if (sb.length()>0)
	    sb.append(separator);
	    
	sb.append(token);
	sb.append(st.nextToken());
	sb.append(token);
	
	cnt++;
    }
%>
<html>
<head>
<body>
<form name=form1 action=list.jsp method=post>
<textarea name=list rows=30 cols=100><%=Format.escHtml(list)%></textarea>
<br>
Token wrapper: <input type=text name="token" value="<%=token%>"><br>
Separator: <input type=text name="separator" value="<%=separator%>"><br>
<input type=submit>
<%=cnt%>
</form>
<br>
<%=Format.escHtml(sb.toString())%>
</body>
</html>
