<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.RequestWrapper"%><%!

    private static final String sExec = "exec lia.app.monc.AppMonC:monc.conf ";

    private String command(final String sSite, final String cmd){

	final Main m = Main.getInstance();

	final String toExecute = "~/dPROOF/PoD_Package/bin/Server_PoD.sh ~/dPROOF/PoD_Package/bin "+cmd;

	final List l = m.executeCommands(sSite, new String[] {sExec+toExecute});
    
	if (l==null){
	    return "Cannot not execute commands on "+sSite;
	}
	else{
	    StringBuilder sb = new StringBuilder();
	
	    for (Iterator it = l.iterator(); it.hasNext(); ){
    		final CommandResult cr = (CommandResult) it.next();
            
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
    	    
    		sb.append("<pre>"+s+"</pre><br>\n");
	    }
	    
	    return sb.toString();
	}
    }
%><%
    lia.web.servlets.web.Utils.logRequest("START /dproof/admin/control.jsp", 0, request);
    
    RequestWrapper.setNotCache(response);

    final RequestWrapper rw = new RequestWrapper(request);
    
    String stop = rw.gets("stop");
    
    if (stop.length()>0){
	out.println(command(stop, "stop"));
    }
    
    String restart = rw.gets("restart");
    
    if (restart.length()>0){
	out.println(command(restart, "start"));
    }
%>