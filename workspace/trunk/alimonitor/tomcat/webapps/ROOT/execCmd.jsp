<%@ page import="lia.Monitor.Store.Fast.DB,lia.Monitor.Store.Cache,lia.Monitor.Store.FarmBan,lia.web.utils.Formatare,lia.Monitor.monitor.monPredicate,java.io.*,java.util.*,java.net.URLEncoder,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.JiniClient.Store.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /execCmd.jsp", 0, request);

    Main m = Main.getInstance();
    
    //List l = m.executeCommands("CERN-L", new String[] {"availablemodules", "loadedmodules", "createmodule lia.app.monc.AppMonC monc", "loadedmodules"});
    //List l = m.executeCommands("CERN-L", new String[] {"exec lia.app.monc.AppMonC:monc w"});
    
    
    String cmd1 = URLEncoder.encode("w");
    String cmd2 = URLEncoder.encode("$AliEnCommand proxy-info 2>&1");
    String cmd3 = URLEncoder.encode("$AliEnCommand proxy-info | grep timeleft 2>&1");
    
    List l = m.executeCommands(
	"CERN-L", 
	new String[] {
	    "availablemodules",
	    "loadedmodules",
	    "exec lia.app.monc.AppMonC:monc.conf "+cmd1, 
	    "exec lia.app.monc.AppMonC:monc.conf "+cmd2, 
	    "exec lia.app.monc.AppMonC:monc.conf "+cmd3
	}
    );

    for (Iterator it = l.iterator(); it.hasNext(); ){
	CommandResult cr = (CommandResult) it.next();
	
	out.println("<b>"+cr.command+"</b><br><pre>"+cr.output+"</pre><br><hr><br>");
    }    

    lia.web.servlets.web.Utils.logRequest("/execCmd.jsp", 0, request);
%>