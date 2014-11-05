<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /console_command.jsp", 0, request);

    String sSite = request.getParameter("site");
    String sCommand = request.getParameter("command");
    
    if (sSite==null || sSite.length()==0 || sCommand==null || sCommand.length()==0){
	out.println("'site' or 'command' not given");
	return;
    }

    final String sExec = "exec lia.app.monc.AppMonC:monc.conf ";

    Main m = Main.getInstance();

    List l = m.executeCommands(sSite, new String[] {sExec+lazyj.Format.encode(sCommand)});
    
    if (l==null){
	out.println("Cannot not execute commands on "+sSite);
    }
    else{
	for (Iterator it = l.iterator(); it.hasNext(); ){
    	    CommandResult cr = (CommandResult) it.next();
            
            String s = URLDecoder.decode(cr.command.substring(sExec.length()));
            
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
    
    lia.web.servlets.web.Utils.logRequest("/console_command.jsp", 0, request);
%>