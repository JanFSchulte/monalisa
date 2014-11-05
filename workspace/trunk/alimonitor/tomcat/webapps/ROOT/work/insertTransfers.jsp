<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*,alien.catalogue.*,alien.managers.*,java.util.regex.*"%><%!
%><%
    response.setContentType("text/plain");

    String[] ses = new String[]{"ALICE::FZK::TAPE", "ALICE::CCIN2P3::SE", "ALICE::CNAF::SE", "ALICE::NDGF::DCACHE"};
    
    Random r = new Random(System.currentTimeMillis());
    
//    for (String run: "101498,101500,104065,104044,104068,104070,104073,104080,104083,104155,104157,104159,104160,104315,104316,104320,104321,104439,104618,104792,104793,104799,104800,104801,104802,104803,104821,104824,104825,104841,104845,104849,104852,104864,104865,104867,104876,104878,104879,104890,104892,105054,105057".split(",")){
    for (String run: "101498,101500".split(",")){
	String sSE1 = ses[r.nextInt(4)];
	
	String sSE2 = ses[r.nextInt(4)];
	
	while (sSE2 == sSE1){
	    sSE2 = ses[r.nextInt(4)];
	}
	
	out.println(run+" - "+sSE1 +" - "+sSE2);
	
	//TransferManager.getInstance().insertTransferRequest(sSE1, "/alice/data/2009/LHC09c/000"+run+"/collection");
	//TransferManager.getInstance().insertTransferRequest(sSE2, "/alice/data/2009/LHC09c/000"+run+"/collection");
    }
%>