<%@page import="lazyj.*"%><%
    response.setHeader("Expires", "0");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Connection", "keep-alive");
    response.setContentType("text/html; charset=UTF-8");
    response.setHeader("Content-Language", "en");                                                                                                    

    String sFile = request.getParameter("file");
%>

<html>
<head>
    <title>Watching <%=Format.escHtml(sFile)%></title>

<style type="text/css">
.text{
    font-family: Verdana, Arial, Tahome;
    font-size: 11px;
    font-weight: normal;
    text-decoration: none;
}

td.table_title{
    background: #FFFFFF;
    color: #000000;
    font-size: 12px;
    padding: 10px;
    text-align: center;
}
                    
tr.table_header{
    background: #CCCCCC;
    font-weight: bold;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 11px;
    text-align: center;
}
                                        
td.table_header{
    border-bottom: 1px solid #CCCC99;
    border-top: 1px solid #CCCC99;
}

td.table_row{
    border-bottom: 1px solid #D9D9D9;
    font-family: Verdana, Arial, Helvetica, sans-serif; 
    font-size: 11px;
}

.whitetextsmall{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	font-weight: bold;
	color: #FFFFFF;
}

.whitetextlarge{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 22px;
	font-weight: bold;
	color: #FFFFFF;	
}

a.menu_link:link,
a.menu_link:active,
a.menu_link:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #67674D;
	text-decoration: none
}

a.menu_link:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #67674D;
	text-decoration: underline
}                                                

a.menu_link_active:link,
a.menu_link_active:active,
a.menu_link_active:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 13px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: none
}

a.menu_link_active:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 13px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: underline
}                                                

a.link:link,
a.link:active,
a.link:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: none
}

a.link:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: underline
}                                                

a.link_buton_start:link,
a.link_buton_start:active,
a.link_buton_start:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: none;
	border: solid 1px #CCCCCC;
	background-color: #DFF3E4;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;
}

a.link_buton_start:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: underline;
	border: solid 1px #CCCCCC;
	background-color: #DFF3E4;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;

}                                                

a.link_buton_stop:link,
a.link_buton_stop:active,
a.link_buton_stop:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: none;
	border: solid 1px #CCCCCC;
	background-color: #FFE7E7;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;
}

a.link_buton_stop:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: underline;
	border: solid 1px #CCCCCC;
	background-color: #FFE7E7;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;

}                                                

a.link_buton_tail:link,
a.link_buton_tail:active,
a.link_buton_tail:visited{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: none;
	border: solid 1px #CCCCCC;
	background-color: #E8F0FF;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;
}

a.link_buton_tail:hover{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
	color: #3A6C9A;
	text-decoration: underline;
	border: solid 1px #CCCCCC;
	background-color: #E8F0FF;
	padding-left: 5px;
	padding-right: 5px;	
	padding-top: 0px;
	padding-bottom: 0px;

}                                                


input.input_text{
	    font-family: Verdana, Arial, Tahome;
	    font-size: 11px;
	    font-weight: normal;
	    text-decoration: none;
	    text-align: right;
	    border: solid 1px #CCCC99;
	    background: #FFFFFF;
}

input.input_submit{
	    font-family: Verdana, Arial, Tahome;
	    font-size: 11px;
	    color: #4F4F3B;
	    font-weight: normal;
	    text-decoration: none;
	    border: solid 1px #CCCC99;
	    background: #F6F6F6;
}

select.input_select{
	    font-family: Verdana, Arial, Tahome;
	    font-size: 11px;
	    color: #4F4F3B;
	    font-weight: normal;
	    text-decoration: none;
	    border: solid 1px #CCCC99;
	    background: #F6F6F6;
}

</style>

</head>
<body>
<script type="text/javascript">
    var scrollEnabled = true;
    
    function pause(){
	scrollEnabled = !scrollEnabled;
	
	document.getElementById('button_pause').value = scrollEnabled ? "Pause scroll" : "Resume scroll";
    }
    
    function clearWin(){
	frames["tail_frame"].document.getElementById('tailf').innerHTML = '';
    }
    
    function highlight(){
	var tailf = frames["tail_frame"].document.getElementById('tailf');

	tailf.innerHTML = doHighlight(tailf.innerHTML, document.getElementById('highlight_text').value, true);
    }

    function highlightNewText(bodyText){
	for (var i=0; i<highlightTerms.length; i++){
	    bodyText = doHighlight(bodyText, highlightTerms[i], false);
	}
	
	return bodyText;
    }

    var textSizeLimit = 50000;

    var counter_bytes = 0;

    var startTime = (new Date()).getTime();

    function addText(bodyText){
	var tailf = frames["tail_frame"].document.getElementById('tailf');

	var newText = highlightNewText(bodyText);
	
	tailf.innerHTML = tailf.innerHTML + newText;
	
	if ( textSizeLimit > 0 && tailf.innerHTML.length > textSizeLimit * 1.1 )
	    tailf.innerHTML = tailf.innerHTML.substring( tailf.innerHTML.length - textSizeLimit*0.9 );
	    
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

    var lastColorIndex = -1;
    
    var colors   = ['blue'  , 'red' , 'yellow' , 'green' , 'cyan'    , 'magenta'];

    var bgcolors = ['yellow', 'cyan', 'magenta', 'red'   , '#FF8000' , '#00FF80'];
    
    var highlightTerms  = [];
    
    var highlightColors = [];

    function doHighlight(bodyText, searchTerm, incrementOnly){
	if (!searchTerm || searchTerm.length<0)
	    return bodyText;

	var iColorIndex = -1;
	
	var lcSearchTerm = searchTerm.toLowerCase();

	for (var i=0; i<highlightTerms.length; i++){
	    if (highlightTerms[i] == lcSearchTerm){
		if (incrementOnly)
		    return bodyText;
	    
		iColorIndex = highlightColors[i];
		break;
	    }
	}

	if (iColorIndex < 0){
	    if (!incrementOnly)
		return bodyText;
	
    	    lastColorIndex++;
	    
	    if (lastColorIndex >= colors.length){
		lastColorIndex = 0;
	    }
	    
	    iColorIndex = lastColorIndex;
	    
	    highlightTerms[highlightTerms.length] = lcSearchTerm;
	    highlightColors[highlightColors.length] = iColorIndex;
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

    function x(){
	alert('x');
    }

    function increaseFontSize(){
	var p = frames["tail_frame"].document.getElementById('tailf');
    
	if(p.style.fontSize) {
    	    var s = parseInt(p.style.fontSize.replace("px",""));
    	}
	else {
    	    var s = 12;
    	}
    	if(s!=max) {
    	    s += 1;
    	}
    	
	p.style.fontSize = s+"px"
    }

    function decreaseFontSize(){
	var p = frames["tail_frame"].document.getElementById('tailf');
    
	if(p.style.fontSize) {
    	    var s = parseInt(p.style.fontSize.replace("px",""));
    	}
	else {
    	    var s = 10;
    	}

    	if(s!=min) {
    	    s -= 1;
    	}
    	
	p.style.fontSize = s+"px"
    }
</script>


<table style="font-family:Arial,Verdana,Helvetica;font-size:12px" class="text" cellspacing="0" cellpadding="0" width=100% height=100%>
    <tr height=20>
	<td colspan=4 align=center style="font-size:14px" nowrap><b>Watching <%=sFile%></b></td>
    </tr>
    <tr>
	<td colspan=4  style="border: solid 1px #CCCCCC; padding: 5px;">
	    <iframe id="tail_frame" name="tail_frame" src="tail.jsp?file=<%=sFile%>" width="100%" height="100%" frameborder="0">
	    </iframe>
	</td>
    </tr>
    <tr bgcolor="#FFFFE5" height=30>
	<td nowrap align=left  style="border-top:0px;border-right:0px; border-left: solid 1px #CCCCCC;border-bottom: solid 1px #CCCCCC; padding: 5px; color: #67674D; font-weight: bold">
	    Actions : <input id="button_pause" type=button value="Pause scroll" onClick="pause();" class="input_submit" style="font-weight: bold"> <input type=button value="Clear window" onClick="clearWin();" class="input_submit" style="font-weight: bold">
	</td>
	<td align=center nowrap style="border-top:0px;border-right:0px; border-left: 0px;border-bottom: solid 1px #CCCCCC; padding: 5px; color: #67674D; font-weight: bold">
	    Max log size: 
	    <select id=logsize name=logsize onChange="textSizeLimit=this.options[this.selectedIndex].value;" class="input_select">
		<option value="10000">10K</option>
		<option value="50000" selected>50K</option>
		<option value="100000">100K</option>
		<option value="200000">200K</option>
		<option value="500000">500K</option>
		<option value="1000000">1M</option>
		<option value="10000000">10M</option>
		<option value="100000000">100M</option>
		<option value="-1">Unlimited (?!)</option>
	    </select>
	    
	    <span id="message"></span>
	</td>
	<td align=center nowrap style="border-top:0px;border-right:0px; border-left: 0px;border-bottom: solid 1px #CCCCCC; padding: 5px; color: #67674D; font-weight: bold">
	    <a href="javascript:increaseFontSize();"><img src="/img/font/font-inc2.gif" border=0 alt="Increase font size"></a>
	    <a href="javascript:decreaseFontSize();"><img src="/img/font/font-dec2.gif" border=0 alt="Decrease font size"></a>
	</td>
	<td nowrap align=right style="border-top:0px;border-left:0px; border-right: solid 1px #CCCCCC;border-bottom: solid 1px #CCCCCC; padding: 5px; color: #67674D; font-weight: bold">
	    Highlight text: <input id="highlight_text" type="text" name="highlight_text" value="" class="input_text" style="text-align: left; color: #FF9966; font-weight: bold"> <input type=button value="Highlight" onClick="highlight()" class="input_submit" style="font-weight: bold">
	</td>
    </tr>
</table>    
</body>
</html>
