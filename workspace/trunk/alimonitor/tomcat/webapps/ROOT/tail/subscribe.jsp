<%@page import="lia.web.utils.*,lia.Monitor.monitor.*,java.util.*,lazyj.commands.*,java.io.*"%><%
    response.setHeader("Expires", "0");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/html; charset=UTF-8");
    response.setHeader("Content-Language", "en");

    String sFile    = request.getParameter("file");

    File f = new File(sFile);
    
    if (!f.exists() || !f.isFile() || !f.canRead())
	return;

    Cookie[] cookies = request.getCookies();

    long lLastLine = -1;
    
    if (cookies != null){
	for (int i = 0; i < cookies.length; i++) {
    	    if (cookies[i].getName().equals("subscribe-"+sFile)){
    		try{
		    long lTemp = Long.parseLong(cookies[i].getValue());

		    if (lTemp > lLastLine)
			lLastLine = lTemp;
		}
		catch (Exception e){
		}
		
        	break;
            }
        }
    }
    
    if (lLastLine<0){
	// nothing yet, so tail the last 100 lines
	CommandOutput co = SystemCommand.bash("wc -l "+sFile);
	
	if (co==null || co.stdout.length()==0){
	    return;
	}
	
	try{
	    StringTokenizer st = new StringTokenizer(co.stdout);
	    lLastLine = Integer.parseInt(st.nextToken());
	}
	catch (NumberFormatException nfe){
	    return;
	}
	
	lLastLine -= 100;
	
	if (lLastLine<=0)
	    lLastLine = 1;
    }

    CommandOutput co = SystemCommand.bash("tail -n+"+lLastLine+" "+sFile);

    if (co==null || co.stdout.length()==0)
	return;

    BufferedReader br = co.reader();
    
    String sLine;

    StringBuilder sb = new StringBuilder();

    while ( (sLine=br.readLine())!=null ){
	sb.append(HtmlColorer.logLineColorer(sLine)).append("<br>");
	
	lLastLine ++;
    }
    
    Cookie c = new Cookie("subscribe-"+sFile, ""+lLastLine);
    response.addCookie(c);

    out.print(sb.toString());
    out.flush();
%>