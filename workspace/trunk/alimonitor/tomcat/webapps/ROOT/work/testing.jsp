<%@ page import="alien.jobs.*,alien.catalogue.*" %><%
    //final JDL jdl = new JDL(FileCache.getFile("/alice/cern.ch/user/a/aliprod/LHC10c7/JDL"));
    //out.println(jdl.getSplitCount());

    String sIP = "";
    hostname = "";

    String country = IPUtils.getCountry(ip, hostname);
    out.println(Utils.CountryMap.getContinent(country));

%>