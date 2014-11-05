<%@ page import="lazyj.*,java.util.*,java.io.*,alien.io.protocols.*"%><%
    response.setContentType("text/plain");

    for (File f: TempFileManager.getLockedFiles()){
	out.println(f.getAbsolutePath());
    }
%>