package alimonitor;

import lazyj.page.BasePage;
import java.io.OutputStream;

public class LazyPage extends BasePage {

    protected String getResDir(){
	return "/home/monalisa/MLrepository/tomcat/webapps/ROOT";
    }

    public LazyPage(){
	super();
    }
    
    public LazyPage(final String sTemplateFile){
	super(sTemplateFile);
    }
    
    public LazyPage(final OutputStream osOut, final String sTemplateFile){
	super(osOut, sTemplateFile);
    }

    public LazyPage(final OutputStream osOut, final String sTemplateFile, final boolean bCached){
	super(osOut, sTemplateFile, bCached);
    }

    public LazyPage(final String sTemplateFile, final boolean bCached){
	super(null, sTemplateFile, bCached);
    }

}
