<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /work/flavor.jsp", 0, request);

    new Thread(){
	public void run(){
	    final String sExec = "exec lia.app.monc.AppMonC:monc.conf ";

	    final String[] files = new String[]{"/etc/redhat-release", "/etc/debian_version", "/etc/slackware-version", "/etc/gentoo-release", "/etc/*-release"};

	    final Main m = Main.getInstance();

	    //final DB db = new DB("SELECT name FROM abping_aliases WHERE name IN ('SARA');");
	    final DB db = new DB("SELECT name FROM abping_aliases ORDER BY lower(name);");
	    
	    final DB db2 = new DB();
	    
	    final String[] vsCommands = new String[files.length+1];
		
	    vsCommands[0] = sExec+Format.encode("lsb_release -d | cut -d: -f2-");
		
	    for (int i=0; i<files.length; i++)
	        vsCommands[i+1] = sExec+Format.encode("cat "+files[i]);

	    int iSite = 0;

	    while (db.moveNext()){
	        final String sSite = db.gets(1);

		iSite ++;
	    
		final List l = m.executeCommands(db.gets(1), vsCommands);
	    
	        if (l==null){
	    	    //System.err.println("Cannot execute commands on "+sSite);
		}
		else{
		    int i = 0;
		
		    for (Iterator it = l.iterator(); it.hasNext(); ){
    		        final CommandResult cr = (CommandResult) it.next();            
            
    			if (cr.output!=null && cr.output.length()>0){
    			    String s = cr.output.substring(cr.output.indexOf("\n")+1, cr.output.lastIndexOf("\n")).trim();
    	    
    			    s = s.substring(0, s.lastIndexOf("."));
    			
    			    s = s.replaceAll("^\\s+", "");
    			    
    			    s = s.replaceAll("\\s+$", "");
    			
    			    s = s.trim();
    			
    			    if (s.length()>0){
    				//System.err.println("Flavor: "+iSite+". "+db.gets(1)+", command "+i+", output "+s);

    				if (i==2)
    				    s = "Debian "+s;
    			    
    				final String q = "UPDATE vobox_stats SET linuxflavor='"+Format.escSQL(s)+"' WHERE name='"+Format.escSQL(sSite)+"';";
    			    
    				//System.err.println(q);
    			    
    			        db2.syncUpdateQuery(q);
    			    
    				if (db2.getUpdateCount()==0){
    				    db2.syncUpdateQuery("INSERT INTO vobox_stats (name, linuxflavor) VALUES ('"+Format.escSQL(sSite)+"', '"+Format.escSQL(s)+"');");
    				}
    				
    				break;
    			    }
			}
			
			i++;
		    }
		}
	    }
	    
	    //System.err.println("Flavor gathering ends");
	    
	    db.query("VACUUM FULL ANALYZE vobox_stats;");
	}
    }.start();
    
    response.sendRedirect("https://alimonitor.cern.ch/admin/linux.jsp");
    
    lia.web.servlets.web.Utils.logRequest("/work/flavor.jsp", 0, request);
%>