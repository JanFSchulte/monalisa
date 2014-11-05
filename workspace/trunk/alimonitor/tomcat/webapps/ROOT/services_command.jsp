<%@ page import="lia.Monitor.Store.*,java.io.*,java.util.*,java.net.*,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.JiniClient.Store.*" %><%
    lia.web.servlets.web.Utils.logRequest("START /services_command.jsp", 0, request);
%><html>
<body bgcolor=white leftmargin=0 topmargin=0>
<span style="font-face: Arial,Verdana,Helvetica,sans; font-size: 11px">
<%

    String sSite = request.getParameter("site");
    String sService = request.getParameter("service");
    String sCommand = request.getParameter("command");
    
    if (sSite==null || sSite.length()==0 || sService==null || sService.length()==0 || sCommand==null || sCommand.length()==0){
	out.println("Illegal parameters: site="+sSite+", service="+sService+", command="+sCommand);
    
	return;
    }

    if (
	!sService.equals("CE") && 
	!sService.equals("SE") && 
	!sService.equals("PackMan") && 
	!sService.equals("Monitor") && 
	!sService.equals("FTD") && 
	!sService.equals("MonaLisa") &&
	!sService.equals("ALL")
    ){
	out.println("service should be one of [CE, SE, PackMan, Monitor, FTD, MonaLisa, ALL], not '"+sService+"'");
	return;
    }

    sCommand = sCommand.toLowerCase();
    
    if (
	!sCommand.equals("start") && 
	!sCommand.equals("stop") &&
	!sCommand.equals("restart")
    ){
	out.println("command should be one of stop/start/restart");
	return;
    }

    Main m = Main.getInstance();

    String cmd1_1 = URLEncoder.encode("$LCG_SITE || $AliEnCommand proxy-init -valid 700:0 2>&1");
    
    String cmd1_2 = URLEncoder.encode("$AliEnCommand proxy-info | grep timeleft");

    String cmd1_3 = URLEncoder.encode("$LCG_SITE && vobox-proxy --vo alice query |grep 'Proxy Time Left'");
    
    String cmd1_4 = URLEncoder.encode("$LCG_SITE && vobox-proxy --vo alice query |grep 'Myproxy Time Left'");
    
    String cmd2;
    
    if (sService.equals("ALL")){
	cmd2 = "$(dirname ${ALIEN_ROOT})/alien/etc/rc.d/init.d/aliend "+sCommand+" &>aliend_restart.log </dev/zero &";
    }
    else{
	cmd2 = "$AliEnCommand " + (sCommand.equals("stop") ? "Stop" : "Start") + sService;
	
	if (sService.equals("MonaLisa")){
	    cmd2 += " &>monalisa_restart.log </dev/zero &";
	}
	else{
	    cmd2 += " 2>&1";
	}
    }
    
    cmd2 = URLEncoder.encode(cmd2);
    
    final String sExec = "exec lia.app.monc.AppMonC:monc.conf ";
    
    String[] commands;
    
    if (sCommand.equals("stop")){
	commands = new String[] {sExec+cmd2};
    }
    else{
	commands = new String[] {
	    sExec+cmd1_1,
	    sExec+cmd1_2,
	    sExec+cmd1_3,
	    sExec+cmd1_4,
	    sExec+cmd2
	};
    }
    
    List l = m.executeCommands(sSite, commands);
    
    final char[] tagChars     = new char[]  {    '&',    '<',    '>',      '"',     '\''};
    final String[] tagStrings = new String[]{"&amp;", "&lt;", "&gt;", "&quot;", "&apos;"};
	    
    
    if (l==null){
	out.println("Could not execute commands on "+sSite);
    }
    else{
	for (Iterator it = l.iterator(); it.hasNext(); ){
    	    CommandResult cr = (CommandResult) it.next();
            
            String s = URLDecoder.decode(cr.command.substring(sExec.length()));
            
    	    out.println("<b>"+Formatare.replaceChars(s, tagChars, tagStrings)+"</b><br>");
    	    
    	    if (cr.output!=null){
    		s = cr.output.substring(cr.output.indexOf("\n")+1, cr.output.lastIndexOf("\n"));
    	    
    		s = s.substring(0, s.lastIndexOf("."));
    		
    		s = Formatare.replaceChars(s, tagChars, tagStrings);
    	    }
    	    else{
    		s = "<i>Command didn't return.</i>";
    	    }
    	    
    	    out.println("<pre>"+s+"</pre><hr><br>");
	}
    }
%>
</span>
</body>
</html>
<%
    lia.web.servlets.web.Utils.logRequest("/services_command.jsp", 0, request);
%>