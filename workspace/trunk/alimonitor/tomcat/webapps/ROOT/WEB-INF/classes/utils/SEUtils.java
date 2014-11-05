package utils;

import lia.Monitor.Store.Fast.DB;

public class SEUtils {

    private static long lLastCleanup = 0;
    
    private static final long CLEANUP_INTERVAL = 1000L*60*60*24;
    
    public static synchronized void cleanup(){
	if (System.currentTimeMillis() - lLastCleanup > CLEANUP_INTERVAL){
	    DB db = new DB();
	    
	    db.syncUpdateQuery("UPDATE se_info SET ips=null;");
	    
	    lLastCleanup = System.currentTimeMillis();
	}
    }
}