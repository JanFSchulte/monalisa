package utils;

import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lia.web.servlets.web.Utils;
import lia.web.utils.ThreadedPage;

/**
 * Filter out extra robots that would normally be allowed (Wget, curl)
 * 
 * @author costing
 *
 */
public class RobotsFilter {
	
	private static final List<String> illegalUAs = Arrays.asList("wget", "curl", "python", "agentname");

	/**
	 * @param request
	 * @param response
	 * @return <code>true</code> if the request is accepted, <code>false</code> if not, in which case the response is properly set
	 */
	public static boolean acceptRequest(final HttpServletRequest request, final HttpServletResponse response){
		if (!ThreadedPage.acceptRequest(request, response))
			return false;
		
		boolean bRejected = false;
		String sRejectReason = null;
	
		String sUA = request.getHeader("User-Agent");
		
		if (sUA!=null){
			sUA = sUA.toLowerCase();
			
			for (final String ua: illegalUAs){
				if (sUA.startsWith(ua)){
					bRejected = true;
					sRejectReason = "UA="+sUA;
					break;
				}
			}
		}
		
		if (bRejected){
			Utils.logRequest("reject_"+request.getRequestURI()+"?"+request.getQueryString()+"&reason="+sRejectReason, 1, request, false);
			
			try{
				response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			}
			catch (Exception e){
				// ignore
			}
			
			return false;
		}
		
		return true;
	}
	
}
