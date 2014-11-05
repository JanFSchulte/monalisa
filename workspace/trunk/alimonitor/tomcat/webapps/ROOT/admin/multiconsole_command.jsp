<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.Format"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/multiconsole_command.jsp", 0, request);

    response.setContentType("text/plain");

    String sSite = request.getParameter("site");
    String sCommand = request.getParameter("command");
    
    if (sSite==null || sSite.length()==0 || sCommand==null || sCommand.length()==0){
	out.println("'site' or 'command' not given");
	return;
    }
    
    out.println(sSite);

    final String sExec = "exec lia.app.monc.AppMonC:monc.conf ";

    Main m = Main.getInstance();

    List l = m.executeCommands(sSite, new String[] {sExec+Format.encode(sCommand)});
    
    if (l==null){
	out.println("Cannot not execute commands on "+sSite);
    }
    else{
	for (Iterator it = l.iterator(); it.hasNext(); ){
    	    CommandResult cr = (CommandResult) it.next();
            
            String s = URLDecoder.decode(cr.command.substring(sExec.length()));
            
            //System.err.println("Response:\n"+cr);
            
    	    if (cr.output!=null){
    		s = cr.output.substring(cr.output.indexOf("\n")+1, cr.output.lastIndexOf("\n"));
    	    
    		s = s.substring(0, s.lastIndexOf("."));
    		
    		s = HtmlColorer.logColorer(s);
    		
    		s = Formatare.replace(s, "<br>\n", "\n");
    		
    		//System.err.println(s);
    	    }
    	    else{
    		s = "<i>Command didn't return.</i>";
    	    }
    	    
    	    out.println("<pre>"+s+"</pre><br>");
	}
    }
    
    lia.web.servlets.web.Utils.logRequest("/admin/multiconsole_command.jsp", 0, request);
%>