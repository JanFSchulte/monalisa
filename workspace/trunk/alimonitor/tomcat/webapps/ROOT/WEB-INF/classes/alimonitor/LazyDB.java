package alimonitor;

import lazyj.DBFunctions;
import lazyj.ExtProperties;

public class LazyDB extends DBFunctions {

    private static final ExtProperties prop = new ExtProperties("/home/monalisa/MLrepository/tomcat/webapps/ROOT/WEB-INF/classes/alimonitor", "db");

    public LazyDB(){
	super(prop);
    }
    
    public LazyDB(final String sQuery){
	super(prop, sQuery);
    }

}
