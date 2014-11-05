<%@ page import="java.util.*,java.io.*,lazyj.*,alien.taskQueue.*,alien.catalogue.*,alien.io.*"%><%
    final RequestWrapper rw = new RequestWrapper(request);
    
    final int pid = rw.geti("pid");
    
    if (pid==0)
	return;
	
    final JDL j;
    
    try{
	j = new JDL(pid);
    }
    catch (IOException ioe){
	out.println("JDL of "+pid+" could not be read any more");
	return;
    }
    catch(NullPointerException npe){
	out.println("JDL of "+pid+" could not be read any more");
	return;	
    }
    
    List<String> inputData = j.getInputData();
    
    if (inputData!=null && inputData.size()>0){
	final XmlCollection collection = new XmlCollection();
	
	for (final String f: inputData){
	    final LFN l = LFNUtils.getLFN(f);
	    
	    if (l!=null)
    		collection.add(l);
	}
	
	collection.setCommand("http://alimonitor.cern.ch/jobs/xmlof.jsp?pid="+pid);
	collection.setName("wn.xml");
	collection.setOwner("MonALISA");
	
	response.setContentType("text/xml");
	response.setHeader("Content-Disposition", "attachment; filename=\"wn.xml\"");
	
	out.println(collection.toString());
	
	return;
    }
    
    inputData = j.getInputList(true, "InputDataCollection");
    
    if (inputData!=null && inputData.size()>0){
	final String content = IOUtils.getContents(inputData.get(0));
	
	if (content!=null){
	    response.setContentType("text/xml");
	    response.setHeader("Content-Disposition", "attachment; filename=\""+inputData.get(0).substring(inputData.get(0).lastIndexOf('/')+1)+"\"");
	    
	    out.println(content);
	    
	    return;
	}
	
	out.println("Could not fetch the content of : "+inputData.get(0));
    }
    
    out.println("No XML for this job");
%>