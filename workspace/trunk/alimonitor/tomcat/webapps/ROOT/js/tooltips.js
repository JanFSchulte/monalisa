function openJDL(pid){
    nd();
    
    window.open('/jdl/'+pid+'.html', 'JDL of '+pid, 'toolbar=0,width=800,height=600,scrollbars=1,resizable=1,titlebar=1'); 
	
    return false;
}

function openLive(pid){
    nd();

    var htmlcode = '<iframe src="/jobs/details.jsp?pid='+pid+'" border=0 width=100% height=99% frameborder=0 marginwidth=0 marginheight=0 scrolling=auto align=absmiddle vspace=0 hspace=0></iframe>';

    var pidHash = pid;
    
    try{
	if (pidHash.indexOf('#')>0)
	    pidHash = pidHash.substring(0, pidHash.indexOf('#'));
    }
    catch (e){
	// ignore
    }
    
    showCenteredWindowSize(htmlcode, "Status of masterjob "+pidHash, 800, 400);

    return false;    
}
    
function jobDetails(pid){
    overlib('<iframe src="/jobs/job_details.jsp?pid='+pid+'" border=0 width=100% height=230 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>', CAPTION, 'Click for live details');
}

function runDetails(run){
    overlib('<iframe src="/raw/rawrun_details.jsp?run='+run+'" border=0 width=100% height=320 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>');
}
