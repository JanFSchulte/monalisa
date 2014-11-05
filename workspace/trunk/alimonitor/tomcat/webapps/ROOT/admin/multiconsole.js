var scrollEnabled = true;
    
function pause(){
    scrollEnabled = !scrollEnabled;
	
    document.getElementById('button_pause').value = scrollEnabled ? "Pause scroll" : "Resume scroll";
}
    
function clearWin(){
    for(i=0; i<vSites.length; i++)
	window.frames['tail_frame_'+vSites[i]].document.getElementById('console_output').innerHTML = '';
}
    
function highlight(){
    for(i=0; i<vSites.length; i++){
	var tailf = window.frames['tail_frame_'+vSites[i]].document.getElementById('console_output');

	pre = tailf.innerHTML;

	tailf.innerHTML = doHighlight(vSites[i], tailf.innerHTML, document.getElementById('highlight_text').value, true);
    }
    
    document.getElementById('highlight_text').value='';
    document.getElementById('highlight_text').focus();
    
    return false;
}

function setTabStatus(site, newText){
    paneSplitter.setContentTabTitle('tab_site_'+site, (newText?"* ":"")+site);
    paneSplitter.showContent('tab_site_'+visibleSite);
}

function highlightNewText(site, bodyText){
    if (!highlightTerms[site])
	return bodyText;

    for (i=0; i<highlightTerms[site].length; i++){
        bodyText = doHighlight(site, bodyText, highlightTerms[site][i], false);
    }
	
    return bodyText;
}

var textSizeLimit = 50000;

var counter_bytes = 0;

var startTime = (new Date()).getTime();

function addText(site, bodyText){
    var tailf = window.frames['tail_frame_'+site];

    var consolediv = tailf.document.getElementById('console_output');
	
    var newText = highlightNewText(site, bodyText);
	
    consolediv.innerHTML = consolediv.innerHTML + newText;

    if ( textSizeLimit > 0 && consolediv.innerHTML.length > textSizeLimit * 1.1 )
        consolediv.innerHTML = consolediv.innerHTML.substring( consolediv.innerHTML.length - textSizeLimit*0.9 );
        
    counter_bytes += newText.length;
	
    showMessage();
}
    
function niceSize(d){
    var sSize = "";

    while (d > 1024) {
        d /= 1024.0;

        if (!sSize || sSize=='' || sSize=='B')
	    sSize = 'K';
	else if (sSize=='K')
	    sSize = 'M';
	else if (sSize=='M')
	    sSize = 'G';
	else if (sSize=='G')
	    sSize = 'T';
	else if (sSize=='T')
	    sSize = 'P';
	else if (sSize=='P')
	    sSize = 'X';
    }

    if (d<1)
        d = Math.round(d*1000)/1000;
    else
    if (d<10)
        d = Math.round(d*100)/100;
    else
    if (d<100)
        d = Math.round(d*10)/10;
    else
        d = Math.round(d);

    return d + sSize;
}

function niceInterval(t){
    t = Math.round(t/1000);	// seconds

    if (t<60)
        return t+' sec';
    
    sec = t%60;
    t = Math.round(t/60);
	
    if (t<60)
        return t+' min '+sec+' sec';
	    
    min = t%60;
    t = Math.round( t/60 );
	
    if (t<24)
        return t+':'+min;
	    
    h = t%24;
    t = Math.round(t/24);
	
    return t+'d '+h+':'+min;
}

function showMessage(){
    var msg = document.getElementById('message');
	
    msg.innerHTML = '(received '+niceSize(counter_bytes)+' in '+niceInterval( (new Date()).getTime() - startTime )+')';
}

var lastColorIndex = [];
    
var colors   = ['blue'  , 'red' , 'yellow' , 'green' , 'cyan'    , 'magenta'];
var bgcolors = ['yellow', 'cyan', 'magenta', 'red'   , '#FF8000' , '#00FF80'];
    
var highlightTerms  = [];
    
var highlightColors = [];

function doHighlight(site, bodyText, searchTerm, incrementOnly){
    if (!searchTerm || searchTerm.length<0)
        return bodyText;

    if (!highlightTerms[site]){
	highlightTerms[site] = [];
	highlightColors[site] = [];
	lastColorIndex[site] = -1;
    }

    var iColorIndex = -1;
	
    var lcSearchTerm = searchTerm.toLowerCase();

    for (var i=0; i<highlightTerms[site].length; i++){
        if (highlightTerms[site][i] == lcSearchTerm){
	    if (incrementOnly)
	        return bodyText;
	    
	    iColorIndex = highlightColors[site][i];
	    break;
	}
    }

    if (iColorIndex < 0){
        if (!incrementOnly)
	    return bodyText;
	
    	lastColorIndex[site]++;
	    
	if (lastColorIndex[site] >= colors.length){
	    lastColorIndex[site] = 0;
	}
	    
	iColorIndex = lastColorIndex[site];
	    
	highlightTerms[site][highlightTerms[site].length] = lcSearchTerm;
	highlightColors[site][highlightColors[site].length] = iColorIndex;
    }

    var highlightStartTag = "<font style='color:"+colors[iColorIndex]+"; background-color:"+bgcolors[iColorIndex]+";'>";
	
    var highlightEndTag = "</font>";
	    
    var newText = "";
    var i = -1;
	
    var lcBodyText = bodyText.toLowerCase();
    
    while (bodyText.length > 0) {
        i = lcBodyText.indexOf(lcSearchTerm, i+1);
        if (i < 0) {
    	    newText += bodyText;
    	    bodyText = "";
	}
	else {
    	    // skip anything inside an HTML tag
    	    if (bodyText.lastIndexOf(">", i) >= bodyText.lastIndexOf("<", i)) {
    	        // skip anything inside a <script> block
    	        if (lcBodyText.lastIndexOf("/script>", i) >= lcBodyText.lastIndexOf("<script", i)) {
        	    newText += bodyText.substring(0, i) + highlightStartTag + bodyText.substr(i, searchTerm.length) + highlightEndTag;
        	    bodyText = bodyText.substr(i + searchTerm.length);
        	    lcBodyText = bodyText.toLowerCase();
        	    i = -1;
    		}
    	    }
	}
    }
  
    return newText;
}
    
var min=8;
var max=18;

function increaseFontSize(){
    for(i=0; i<vSites.length; i++){
	var p = window.frames['tail_frame_'+vSites[i]].document.getElementById('console_output');
	
	var s = 12;
    
	if(p.style.fontSize){
	    s = parseInt(p.style.fontSize.replace("px",""));
	}

        if(s!=max) {
	    s += 1;
	}
    	
	p.style.fontSize = s+"px"
    }
}

function decreaseFontSize(){
    for(i=0; i<vSites.length; i++){
	var p = window.frames['tail_frame_'+vSites[i]].document.getElementById('console_output');
	
	var s = 10;
    
	if (p.style.fontSize) {
	    s = parseInt(p.style.fontSize.replace("px",""));
	}

	if(s!=min) {
    	    s -= 1;
	}
    	
	p.style.fontSize = s+"px"
    }
}
    
function newText(req){
    if (req.responseText){
	var idx = req.responseText.indexOf('\n');
	
	site=req.responseText.substring(0, idx);
	text=req.responseText.substring(idx+1);
	
        addText(site, text);
        
        if (site!=visibleSite){
    	    setTabStatus(site, true);
        }
	else{
	    window.setTimeout('scrollPeriodic(\''+site+'\')', 10);
	}
    }
}
    
function scrollPeriodic(site){
    if (scrollEnabled){
	window.frames['tail_frame_'+site].window.scrollBy(0, 10000000);
    }
}
    
function executeCommand(){
    var cmdObj = document.getElementById('console_command');
    
    var cmd = cmdObj.value;
	
    cmdObj.value = '';
    
    var site;
    
    for (site=0; site<vSites.length; site++){
	addText(vSites[site], '&gt; <a href="javascript:void(0);" onClick="return parent.prepareCommand(\''+escape(cmd)+'\');" title="'+(new Date())+'">'+cmd+'</a><br>');
    
	var sSite = vSites[site];
    
	new Ajax.Request(
    	    'multiconsole_command.jsp',
	    {
		parameters: '?site='+escape(sSite)+'&command='+escape(cmd),
        	method: 'get',
    		asynchronous: true,
        	onSuccess: newText
    	    }
	);
    }
    
    scrollPeriodic(visibleSite);
    
    cmdObj.focus();
    
    return false;
}
    
function prepareCommand(cmd){
    var cmdObj = document.getElementById('console_command');
	
    cmdObj.value = unescape(cmd);
    cmdObj.focus();

    return false;
}

function callbackFunction(modelObj,action,contentObj){
    if (action=='tabSwitch' && contentObj){
	//site = contentObj.id.substring(contentObj.id.lastIndexOf('_')+1);
	site = contentObj.id.substring('tab_site_'.length);
	
	scrollPeriodic(site);
	
	visibleSite = site;
	
	setTabStatus(site, false);
    }
}
