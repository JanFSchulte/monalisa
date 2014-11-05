<<:imports:>><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html  xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
<title><<:title esc:>> - ALICE Grid Monitoring with MonALISA</title>
<meta name="description" content="<<:title esc:>> - MonALISA repository for CERN ALICE Grid">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META NAME="geo.position" CONTENT="46.233086;6.051707">
<META NAME="geo.country" CONTENT="CH">
<META NAME="geo.region" CONTENT="CH-GE">
<META NAME="geo.placename" CONTENT="ALICE Grid Servers Center, CERN, Geneve, Switzerland">
<META NAME="DC.title" CONTENT="ALICE Grid Servers Center, CERN, Geneve, Switzerland">
<meta name="ICBM" content="46.233086, 6.051707">
<LINK REL="SHORTCUT ICON" HREF="/favicon.gif" type="image/gif">
<LINK REL="ICON" HREF="/favicon.gif" type="image/gif">
<link rel="alternate" type="application/atom+xml" title="ALICE - Operational log" href="/atom.jsp?set=1">
<link rel="alternate" type="application/atom+xml" title="ALICE - Central services" href="/atom.jsp?set=7">

<link rel="stylesheet" type="text/css" href="/js/combined-1298642474.yui.css">
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>

<meta name="verify-v1" content="efxkHBjQM4siIDR+4Gy5amA89U/hgtVHnvpxQJqsQUY=" />

<<:extrastyle:>>

</head>
<body onload="<<:begin:>>" onresize="<<:onresize:>>" style="background-color: #F0F0F0">

<!-- Page refresh -->
<script language=JavaScript>
    var autoReloadArmed = false;
    var autoReloadConfigured = false;

    <<:comment_refresh:>>var autoReloadTimeout = window.setTimeout("modify()", <<:refresh_time:>>*1000); autoReloadArmed = true; var refreshAfter=<<:refresh_time:>>*1000; autoReloadConfigured = true;
</script>

<table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#F0F0F0" id="test">
    <tr>
	<td colspan="2">
	    <!-- /images/monalisa_header.gif -->
	    <table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tr bgcolor="#FFFFFF">
		    <td align="left" width="207"><a target="_blank" href="http://aliceinfo.cern.ch/" title="ALICE Experiment public pages"><img src="/images/logo_left.jpg" border="0" with="124" height="74" alt="ALICE Experiment public pages"></a></td>
		    <td align="center" style="font-family: Tahoma, Verdana, Arial; font-size: 25px; color: #0A92D0; font-weight: bold">MonALISA Repository for ALICE</td>
		    <td align="right" width="207"><a target="_blank" href="http://monalisa.caltech.edu/" title="MonALISA Grid Monitoring"><img src="/images/mona.gif" border="0" alt="MonALISA Grid Monitoring"></a></td>
		</tr>
		<tr>
		    <td height="4" bgcolor="#9FBCD1" colspan="3"><img height="1" width="1"></td>
		</tr>
		<tr>
		    <td height="2" bgcolor="#DFFFFF" colspan="3"><img height="1" width="1"></td>
		</tr>					
		<tr>
		    <td height="4" bgcolor="#FFFFFF" colspan="3"><img height="1" width="1"></td>
		</tr>
		<tr>
		    <td height="25" bgcolor="#E7EBF1" colspan="3" style="padding-left: 20px" class="text" valign="middle">
			<a href="https://alimonitor.cern.ch/users/" class="menu_link" >My jobs</a> <img src="/images/star-10.png">
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">&nbsp;&nbsp;
			<a href="https://alimonitor.cern.ch/catalogue/" class="menu_link" >My home dir</a> <img src="/images/star-10.png">
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">&nbsp;&nbsp;
			<a href="http://alimonitor.cern.ch/catalogue/" class="menu_link" >Catalogue browser</a> <img src="/images/star-10.png">
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">&nbsp;&nbsp;
			<a href="http://alimonitor.cern.ch/" class="menu_link" accesskey="h">Repository <u>H</u>ome</a>
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">&nbsp;&nbsp;
			<a href="http://alimonitor.cern.ch/admin.jsp" class="menu_link" accesskey="d">A<u>d</u>ministration Section</a> 
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">
			<a href="http://alimonitor.cern.ch/reports/" class="menu_link" accesskey="r">ALICE <u>R</u>eports</a> 
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">
			<a href="http://alimonitor.cern.ch/xml.jsp" class="menu_link" accesskey="x">Events <u>X</u>ML Feed</a> 
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">
			<a href="http://alimonitor.cern.ch/plugin/alienml.xpi" class="menu_link" onMouseOver="overlib('Install version 1.6.8 for Firefox 1.5+', CAPTION, 'AliEn ML Toolbar for Firefox');" onMouseOut="nd()">Firefox Toolbar</a>
			<img src="/images/separator_menu.gif" style="padding-left: 10px; padding-right: 10px">
			<a target="_blank" href="http://monalisa.caltech.edu/ml_client/MonaLisa.jnlp" class="menu_link" accesskey="m"><u>M</u>onaLisa GUI</a>
		    </td>
		</tr>	
		<tr>
		    <td height="2" bgcolor="#9FBCD1" colspan="3"><img height="1" width="1"></td>
		</tr>							
		<tr>
		    <td height="2" bgcolor="#DFFFFF" colspan="3"><img height="1" width="1"></td>
		</tr>							
	    </table>
	</td>
    </tr>
    <tr><td colspan="2" height="10"></td></tr>
    <tr>
	<td width="170" valign="top">
	    <table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tr>
		    <td>
			<table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#F0F5FF">
			    <tr>
				<td width="4" height="22" align="left"><img src="/images/header_left.jpg" width="4" height="22" border="0"></td>
				<td class="box_header">ALICE Repository</td>
				<td width="4" height="22" align="right"><img src="/images/header_right.jpg" width="4" height="22" border="0"></td>					
			    </tr>
			    <tr>
				<td width="4" style="border-left: solid 1px #b5b5bd"><img height="1" width="1"></td>
				<td class="text" width="100%" align="left" style="padding-top: 5px">
				<script type="text/javascript">
				    showMenu();		
        			</script>
            			<p><a href="javascript: dMLMenu.closeAll();" class="link">close all</a></p>
				</td>
				<td width="4" style="border-right: solid 1px #b5b5bd"><img height="1" width="1"></td>
			    </tr>
			    <tr>
				<td width="4" height="4" align="left"><img src="/images/table_header_bottom_left.jpg" width="4" height="4" border="0"></td>
				<td height="4"  style="border-bottom: solid 1px #b5b5bd"><img height="4" width="1"></td>
				<td width="4" height="4" align="right"><img src="/images/table_header_bottom_right.jpg" width="4" height="4" border="0"></td>
			    </tr>
			</table>	
		    </td>
		</tr>
	    </table>
	    <div class="spacer"><!-- // --></div>
    	    <script language=javascript>
    		var buri='<<:bookmark js:>>';
        	var bookmark='http://alimonitor.cern.ch'+buri;
        	
		if (buri.length>0){
	    	    showLink('ALICE Repository View', bookmark);
		}
	    </script>
	    <table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tr>
		    <td>
			<table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
			    <tr>
				<td width="4" height="22" align="left"><img src="/images/header_left.jpg" width="4" height="22" border="0"></td>
				<td class="box_header">R<u>u</u>nning jobs trend</td>
				<td width="4" height="22" align="right"><img src="/images/header_right.jpg" width="4" height="22" border="0"></td>					
			    </tr>
			    <tr>
				<td width="4" style="border-left: solid 1px #b5b5bd"><img height="1" width="1"></td>
				<td class="text" width="100%" style="padding-top: 5px; margin-top: 3px">
				    <a href="/display?page=jobStatusSites_RUNNING" accesskey="u"><img src="/simple?page=dials/jobs" id="running_jobs_dial_img" border=0 onMouseOver="overlib('Current running jobs')" onMouseOut="return nd();"></a>
				    <script type="" language="JavaScript">
				    timeout = 1000*600;
		    
				    function reloadImage(){
					img = objById('running_jobs_dial_img');
					img.src = '/simple?page=dials/jobs&random='+Math.random();
					setTimeout('reloadImage()', timeout);
				    }
			
				    setTimeout('reloadImage()', timeout);
				    </script>
				    <br clear=all>
				    <br clear=all>
				    <iframe src=/trend_small.jsp border=0 width=100% height=80 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>
				</td>
				<td width="4" style="border-right: solid 1px #b5b5bd"><img height="1" width="1"></td>
			    </tr>
			    <tr>
				<td width="4" height="4" align="left"><img src="/images/table_header_bottom_left.jpg" width="4" height="4" border="0"></td>
				<td height="4"  style="border-bottom: solid 1px #b5b5bd"><img height="4" width="1"></td>
				<td width="4" height="4" align="right"><img src="/images/table_header_bottom_right.jpg" width="4" height="4" border="0"></td>
			    </tr>
			</table>	
		    </td>
		</tr>
	    </table>

	</td>
	<td valign="top" style="padding-left: 5px;" width="100%">
	    <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
		<tr>
		    <td width="5" height="5" align="left" valign="bottom"><img src="/images/center_top_left.jpg" width="5" height="5" border="0"></td>
		    <td height="5" width="100%" style="border-top: solid 1px #b5b5bd"><img width="1" height="1"></td>
		    <td width="5" height="5" align="right" valign="bottom"><img src="/images/center_top_right.jpg" width="5" height="5" border="0"></td>					
		</tr>
		<tr>
		    <td width="5" style="border-left: solid 1px #b5b5bd"><img height="1" width="1"></td>
		    <script type="text/javascript">
    			var bDivFurat = false;
    		    </script>
		    <td style="padding: 10px" align="center">
		        <<:com_alternates_start:>>
	    		<table width=800 border=0 cellspacing=0 cellpadding=0>
	    		    <tr>
	    			<td>
	    			    <div id="d_alternate_hidden" style="display: none">
	    				<div>
            				    <table border=0 cellspacing=0 cellpadding=3 style="border-bottom: 2px solid #FFFFFF;" width="100%">
            					<tr>
            					    <td align=center>
            						<table border=0 cellspacing=0 class=alternate cellpadding=5 width="100%" bgcolor="#F0F0F0">
                    					    <tr>
                        					<td nowrap align=left class=text><b><<:alternates:>></b></td>
                    					    </tr>
                					</table>
                				    </td>
            					</tr>
            				    </table>
            				</div>
            			    </div>
            			</td>
            		    </tr>
            		</table>
            		<<:com_alternates_end:>>
			<<:continut:>>
			<script type="text/javascript">
	 		if (!bDivFurat){
	 		    var dDivulMeu = objById('d_alternate_hidden');
	 		    
	 		    if (dDivulMeu)
	 			dDivulMeu.style.display = '';
	 		}
	 		</script>
		    </td>
		    <td width="5" style="border-right: solid 1px #b5b5bd"><img height="1" width="1"></td>
		</tr>
		<tr>
		    <td width="5" height="5" align="left"><img src="/images/center_bottom_left.jpg" width="5" height="5" border="0"></td>
		    <td height="5" width="100%" style="border-bottom: solid 1px #b5b5bd"><img width="1" height="1"></td>
		    <td width="5" height="5" align="right"><img src="/images/center_bottom_right.jpg" width="5" height="5" border="0"></td>				
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td height="6">
    	    <div class="spacer"><!-- // --></div>
        </td>
    </tr>
    <tr>
	<td colspan="2">
	    <table width="100%" cellspacing="0" cellpadding="0" border="0" background="/images/monalisa_header.gif">
		<tr>
		    <td height="2" bgcolor="#DFFFFF" colspan="2"><img height="1" width="1"></td>
		</tr>					
		<tr>
		    <td height="4" bgcolor="#FFFFFF" colspan="2"><img height="1" width="1"></td>
		</tr>
		<tr>
		    <td height="25" bgcolor="#E7EBF1" colspan="2" style="padding-left: 20px" class="text" valign="middle" align="center">
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
			    <tr>
				<td align="left" nowrap width="250">&nbsp;</td>
				<td align="center">
				    <a href="/" class="linkb">Repository Home</a> &middot;
				    <a href="http://aliceinfo.cern.ch/" class="linkb" target=_blank accesskey="i">AL<u>I</u>CE Web Page</a> &middot;
				    <a href="/repositories.jsp" class="linkb" title="ALICE Clusters monitored by MonALISA" accesskey="l">ALICE C<u>l</u>usters</a> &middot;
				    <a href="/contact.jsp" class="linkb" accesskey="c"><u>C</u>ontact</a> &middot;
				    <a href="/links.jsp" class="linkb" accesskey="l"><u>L</u>inks</a>
				</td>
				<td align="right" nowrap width="250">&copy; CERN 2007 - ALICE EXPERIMENT</td>
			    </tr>	
			</table>
		    </td>
		</tr>	
		<tr>
		    <td height="1" bgcolor="#9FBCD1" colspan="2"><img height="1" width="1"></td>
		</tr>							
		<tr>
		    <td height="2" bgcolor="#DFFFFF" colspan="2"><img height="1" width="1"></td>
		</tr>							
	    </table>
	
	</td>
    </tr>
</table>

<script src="https://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-1606984-1";
urchinTracker();
</script>

</body>
</html>
