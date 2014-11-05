package utils;

import lia.Monitor.Store.Fast.DB;

import lazyj.Format;

import java.net.InetAddress;

public class IPUtils {

    public static String getAS(final String sIP){
	final WhoisEntry entry = WhoisEntry.getWhoisEntry(sIP);
	
	if (entry!=null){
	    return entry.asname;
	}
	
	return null;
    }


    public static String toIP(final String sName){
	try{
	    final InetAddress addr = InetAddress.getByName(sName);
	    
	    return addr.getHostAddress();
	}
	catch (Exception e){
	    return null;
	}
    }

    public static String getDomain(final String ip, final String name){
	final int idx = name.indexOf('.');
    
	if (name.equals(ip) || idx<0)
	    return name;
	    
	return name.substring(idx+1).toLowerCase();
    }
    
    public static String getCountry(final String ip, final String name){
	final int idx = name.lastIndexOf('.');
    
	String country = null;
    
	if (idx>0 && !ip.equals(name)){
	    country = name.substring(idx+1);
	}
	
	if (country==null || country.length()>=3){
	    final WhoisEntry entry = WhoisEntry.getWhoisEntry(ip);
	
	    if (entry!=null)
		country = entry.country;
	}

	return country;
    }

    public static double getSiteToIPRTT(final String sSite, final String ip){
	final DB db = new DB();
	
	final String sIPClass = ip.substring(0, ip.lastIndexOf('.'));
	
	db.query("select avg(hop_rtt) from fdt_speed inner join fdt_tracepath on id=test_id where site_source='"+Format.escSQL(sSite)+"' and regexp_replace(hop_ip, '.[0-9]+$'::text, ''::text)='"+Format.escSQL(sIPClass)+"';");
	
	if (!db.moveNext())
	    return -1;
	
	return db.getd(1, -1d);
    }
    
    public static double getIPDistance(final String sIP, final String ip) {
	final DB db = new DB();

	final String sIPClass = sIP.substring(0, sIP.lastIndexOf('.'));
	final String ipClass = ip.substring(0, ip.lastIndexOf('.'));
	
	String q = "select avg(abs(ft1.hop_rtt-ft2.hop_rtt)) from fdt_tracepath ft1 inner join fdt_tracepath ft2 using(test_id) where regexp_replace(ft1.hop_ip, '.[0-9]+$'::text, ''::text) = '"+Format.escSQL(sIPClass)+"' and regexp_replace(ft2.hop_ip, '.[0-9]+$'::text, ''::text)='"+Format.escSQL(ipClass)+"';";
	
	//System.err.println(q);
	
	db.query(q);

	if (db.moveNext()){
	    final double d = db.getd(1, -1d);
	    
	    if (d >= 0){
		//System.err.println("Found direct tracepath between "+sIP+" and "+ip+" : "+d);
	    
		return d;
	    }
	}	
	
	double distance = -1;
	
	db.query("SELECT name FROM abping_aliases WHERE ip='"+Format.escSQL(sIP)+"';");
	
	if (db.moveNext()){
	    distance = getSiteToIPRTT(db.gets(1), ip);
	    
	    //System.err.println("Distance (1) between site "+db.gets(1)+" and ip "+ip+" : "+distance);
	}
	
	db.query("SELECT name FROM abping_aliases WHERE ip='"+Format.escSQL(ip)+"';");
	
	if (db.moveNext()){
	    double newdistance = getSiteToIPRTT(db.gets(1), sIP);
	    
	    //System.err.println("Distance (2) between site "+db.gets(1)+" and ip "+sIP+" : "+newdistance);
	    
	    if (distance<0)
		distance = newdistance;
	    else
		if (newdistance > 0)
		    distance = Math.max(distance, newdistance);
	}
	
	return distance;
    }

}
