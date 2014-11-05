<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*,lia.Monitor.JiniClient.Store.*,java.net.*,lazyj.*,alien.managers.*"%><%
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::FZK::SE", "/alice/data/2013/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CNAF::SE", "/alice/data/2013/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CCIN2P3::SE", "/alice/data/2013/OCDB", true));

    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::FZK::SE", "/alice/data/2012/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CNAF::SE", "/alice/data/2012/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CCIN2P3::SE", "/alice/data/2012/OCDB", true));

    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::FZK::SE", "/alice/data/2011/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CNAF::SE", "/alice/data/2011/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CCIN2P3::SE", "/alice/data/2011/OCDB", true));

    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CNAF::SE", "/alice/simulation/2008/v4-15-Release", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::LEGNARO::SE", "/alice/simulation/2008/v4-15-Release", true));

/*
//    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::LEGNARO::SE", "/alice/data/2010/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::NIHAM::FILE", "/alice/data/2010/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::FZK::SE", "/alice/data/2010/OCDB", true));
    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CNAF::SE", "/alice/data/2010/OCDB", true));
//    out.println(TransferManager.getInstance().insertTransferRequest("ALICE::CCIN2P3::SE", "/alice/data/2010/OCDB", true));
*/
%>