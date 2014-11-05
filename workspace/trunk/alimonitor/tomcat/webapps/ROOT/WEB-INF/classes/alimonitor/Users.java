package alimonitor;

import auth.AlicePrincipal;
import auth.LdapCertificateRealm;
import auth.LDAPHelper;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

import java.security.cert.X509Certificate;

import java.util.Set;

import alien.catalogue.AliEnFile;
import alien.users.UsersHelper;

import lazyj.RequestWrapper;

public class Users {

    private static final LdapCertificateRealm realm = new LdapCertificateRealm();

    public static AlicePrincipal get(final ServletRequest request){
	if (request.isSecure()){
	    final X509Certificate cert[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
	
	    if (cert!=null && cert.length>0)
		return (AlicePrincipal) realm.authenticate(cert);
	}
	
	return null;
    }
    
    public static String getRole(final HttpServletRequest request){
	final AlicePrincipal p = get(request);
	
	return getRole(p, request);
    }
    
    public static String getRole(final AlicePrincipal p, final HttpServletRequest request){
	if (p==null)
	    return null;

	final RequestWrapper rw = new RequestWrapper(request);
	
	final String sRole = rw.getCookie("alien_role");
	
	if (sRole==null || sRole.length()==0 || !p.canBecome(sRole))
	    return p.getName();
	
	return sRole;
    }
    
    public static String getHomeDir(final String sUsername){
	return UsersHelper.getHomeDir(sUsername);
    }
    
    public static boolean isOwner(final AliEnFile f, final AlicePrincipal user){
	if (user==null || f==null)
	    return false;
	
	final String sOwner = f.getOwner();

	return user.canBecome(sOwner);
    }
    
    public static boolean isInGroup(final AliEnFile f, final AlicePrincipal user){
	if (user==null || f==null){
	    return false;
	}

	final String sGroup = f.getGroup();

	return user.canBecome(sGroup);
    }
    
    public static int getPermissions(final AliEnFile f, final AlicePrincipal user){
	if (user==null || f==null){
	    return 0;
	}

	final Set<String> accounts = user.getNames();
	
	if (accounts!=null && accounts.contains("admin")){
	    //System.err.println("User can login as admin");
	    return 7;
	}
	
	if (user.hasRole("admin")){
	    //System.err.println("User has admin role");
	    return 7;
	}

	// -rwxr-xr-x
	final String sPermissions = f.getPermissions();
	
	if (sPermissions==null)
	    return 0;
	
	boolean r = false;
	boolean w = false;
	boolean x = false;
	
	if (isOwner(f, user)){
	    final String s = sPermissions.substring(1, 3);
	    
	    //System.err.println("Is owner and permissions are "+s);
	    
	    r = s.indexOf('r')>=0;
	    w = s.indexOf('w')>=0;
	    x = s.indexOf('x')>=0;

	    if (r && w && x)
		return 7;
	}
	
	if (isInGroup(f, user)){
	    final String s = sPermissions.substring(4, 6);

	    //System.err.println("Is in group and permissions are "+s);
	    
	    r = r || s.indexOf('r')>=0;
	    w = w || s.indexOf('w')>=0;
	    x = x || s.indexOf('x')>=0;
	    
	    if (r && w && x)
		return 7;
	}
	
	final String s = sPermissions.substring(7);
	
	//System.err.println("Is somebody in the world, permissions that apply are : "+s);
	
	r = r || s.indexOf('r')>=0;
	w = w || s.indexOf('w')>=0;
	x = x || s.indexOf('x')>=0;

	return (r ? 4 : 0) + (w ? 2 : 0) + (x ? 1 : 0);	
    }
    
    public static boolean canRead(final AliEnFile f, final AlicePrincipal user){
	return (getPermissions(f, user) & 4) == 4;
    }
    
    public static boolean canWrite(final AliEnFile f, final AlicePrincipal user){
	return (getPermissions(f, user) & 2) == 2;
    }
    
    public static boolean canExecute(final AliEnFile f, final AlicePrincipal user){
	return (getPermissions(f, user) & 1) == 1;
    }
    
}
