<<:imports:>>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="cooltree.css" rel="stylesheet" type="text/css">
<link href="dtree.css" rel="stylesheet" type="text/css" />
<link href="dtree1.css" rel="stylesheet" type="text/css" />
<link href="dtree3.css" rel="stylesheet" type="text/css" />

<link href="map2D.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/overlib/overlib.js"></script>
<script type="text/javascript" src="dtree.js"></script>
<script type="text/javascript" src="js/range.js"></script>
<script type="text/javascript" src="js/timer.js"></script>
<script type="text/javascript" src="js/slider.js"></script>
<script type="text/javascript" src="js/menu.js"></script>
<script language="JavaScript" src="calendar1.js"></script>
<link type="text/css" rel="StyleSheet" href="css/bluecurve/bluecurve.css" />



<title>ALICE Repository</title><style type="text/css">
<!--
body {
	background-color: #eaeaea;
	margin-top: 0px;
}


.checkboxmenu{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8.7px;
	color: #333;	
}

.checkboxmenu a{
	color: #000066;
	text-decoration:none;
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

.textupdate{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
}

.textmenublue{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
}


.linkmenublue{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
	text-decoration: underline;
}

.linkmenublue:active {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
	text-decoration: underline;
}

.linkmenublue:visited {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
	text-decoration: underline;
}

.linkmenublue: hover {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
	text-decoration: underline;
}

.linkmenublue:link {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #053887;	
	font-weight: bold;
	text-decoration: underline;
}

.style1 {font-size: 9px}
-->
</style>

<SCRIPT language="text/javascript" type="text/JavaScript">
	var IMG_WIDTH=800;
	var IMG_HEIGHT=IMG_WIDTH/2;
	var d3d=0;
	var a3d=90;
	var dx3d=.1;
	var first=1;	

	var posX=-1, posY=-1, lastX, lastY, theimage;
	//theimage = "lupa.gif" //the 2nd image to be displayed
	//Browser checking and syntax variables
	var docLayers = (document.layers) ? true:false;
	var docId = (document.getElementById) ? true:false;
	var docAll = (document.all) ? true:false;
	var docbitK = (docLayers) ? "document.layers['":(docId) ? "document.getElementById('":(docAll) ? "document.all['":"document."
	var docbitendK = (docLayers) ? "']":(docId) ? "')":(docAll) ? "']":""
	var stylebitK = (docLayers) ? "":".style"
	var showbitK = (docLayers) ? "show":"visible"
	var hidebitK = (docLayers) ? "hide":"hidden"
	var ns6=document.getElementById&&!document.all;
	var sit_home="http://alimonitor.cern.ch/";
	//Variables used in script
	
	var MAX_Y=8;
	var MAX_X=16;
	var width=5.6;
	var zoom_factor=1;//poate varia intre 0.01 si 1
	var height=width/2;
	var x=-1.53;//-16;
	var y=6;//8;
	var image2;
	var pred=1;
	var show_links=1;
	
	var click_action=1;//action for mouse left click on image
	
	function positionID(x,y,id) {
		eval(docbitK + id + docbitendK + stylebitK + ".left = " + x);
		eval(docbitK + id + docbitendK + stylebitK + ".top = " + y);
	}
	function showID(id) {
		eval(docbitK + id + docbitendK + stylebitK + ".visibility = '" + showbitK + "'");
	}
	function hideID(id) {
		eval(docbitK + id + docbitendK + stylebitK + ".visibility = '" + hidebitK + "'");
	}	
    
	function showLinks(){
            if(document.getElementById("links_checkbox").checked)
                show_links=1;
            else
                show_links=0;
            zoom(0);
        }



        function map_changed()
        {

                dimensiune_obj = document.getElementById("map");
                valoare=dimensiune_obj.options[dimensiune_obj.selectedIndex].value;
                if(valoare.charAt(0)==2){
                    width=32;
                    height=width/2;
                    x=-16;
                    y=8;
                    zoom(0);
                }
                if(valoare.charAt(0)==3){
                    width=5.6;
                    height=width/2;
                    x=-1.53;
                    y=6;
                    zoom(0);
                }
                if(valoare.charAt(0)==1){
                    width=4.91;
                    height=width/2;
                    x=-11;
                    y=4.4;
                    zoom(0);
                }
                if(valoare.charAt(0)==4){
                    width=10.6;
                    height=width/2;
                    x=-11;
                    y=0.95;
                    zoom(0);
                }
                if(valoare.charAt(0)==5){
                    width=10.6;
                    height=width/2;
                    x=3.54;
                    y=6.16;
                    zoom(0);
                }
       }
 
        
        function windowChanged(){
                var winW;
                if(document.layers || ns6)
                    winW=window.innerWidth;
                else{
                        winW=document.body.offsetWidth;
                }
                IMG_WIDTH=winW - 250;
                if(IMG_WIDTH < 400)
                    IMG_WIDTH = 400;
                IMG_HEIGHT=IMG_WIDTH*.5;
                document.getElementById('test').width=0.97*winW;
                document.getElementById('Map2D').width=winW - 250;
                if(document.getElementById('Map2D').width < 400)
                    document.getElementById('Map2D').width = 400;
                document.getElementById('Map2D').height=document.getElementById('Map2D').width/2;
                document.getElementById('adaptive').selected=true;
                zoom(0);
        }
   

	function dimensiune_changed()
	{
		dimensiune_obj = document.getElementById("dimensiune");
		valoare=dimensiune_obj.options[dimensiune_obj.selectedIndex].value;
		new_w=0;
		i=0;
		for ( ; i< valoare.length; i++) {
			car = valoare.charAt(i);
			if  ( car>='0' && car <= '9' ) {
				new_w=new_w*10+(car-'0');
			} else if ( car=='x' ) {
				i++;//pass over 'x'
				break;
			}
			//else ignore
		};
		new_h=0;
		for ( ; i< valoare.length; i++) {
			car = valoare.charAt(i);
			if  ( car>='0' && car <= '9' )
				new_h=new_h*10+(car-'0');
			//else ignore
		};
		if ( new_w>0 && new_h>0 ) {
			IMG_WIDTH=new_w;
			IMG_HEIGHT=IMG_WIDTH*.5;
			document.getElementById("Map2D").width=new_w;
			document.getElementById("Map2D").height=new_w*.5;
			zoom(0);
		}
	}
	
	function findPosX(obj)
	{
	var curleft = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
		curleft += obj.offsetLeft
		obj = obj.offsetParent;
		}
	}
	else if (obj.x)
		curleft += obj.x;
	return curleft;
	}
	function findPosY(obj)
	{
	var curtop = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
		curtop += obj.offsetTop
		obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;
	return curtop;
	}


	function position_zoom(zoomdir,lastx, lasty, imagex, imagey)
	{
		//lastX=lastx;
		//lastY=lasty;
		posX=lastx;
		posY=lasty;
		click_action=zoomdir;
		image = document.getElementById("Map2D");
//		text="<br>x ant="+x+" and y ant="+y;
		if ( click_action==1 || click_action==-1 ) {
		    imageX = imagex;//findPosX(image);
		    imageY = imagey;//findPosY(image);
			if ( d3d>0 ) {
				//clicked on 3d map, so change coordinates
				//gresit!!!...
				ctg=1/Math.tan(a3d*Math.PI/180);
				extraX = (lasty-0.66*IMG_HEIGHT)*ctg;
				lastx = (lastx+extraX)/(IMG_WIDTH+2*extraX)*IMG_WIDTH;
				while ( lastx < imageX )
    				    lastx+=IMG_WIDTH;
				while ( lastx > imageX+IMG_WIDTH )
    				    lastx-=IMG_WIDTH;
			}
			//document.getElementById("debug").innerHTML="x="+x+" y="+y+" w="+width+" h="+height+" lastX="+lastx+" lastY="+lasty+" imageX="+imageX+"imageY="+imageY;
			x += (lastx - imageX)*width/IMG_WIDTH - width*.5;
			y += -(lasty - imageY)*height/IMG_HEIGHT + height*.5;
    		};
		zoom(click_action);
	}
	function zoom(dir)
	{
		dir=(dir?(dir<0?-1:1):0);
		//limit zoom out
		if(width==32 && dir<0)
			return;
		if ( width*(dir?(dir<0?(1+zoom_factor):1/(1+zoom_factor)):1)>2*MAX_X && dir<0 ){
			//return;
			var stop_zoom_out=1;
		}
		//limit zoom in
		if (width<MAX_X/16 && dir >0)
			return;
		//text+="<br>width="+width+" and height="+height;
		//text+="<br>x="+x+" and y="+y;
		//compute new widhts
		ww = width*(dir?(dir<0?(1+zoom_factor):1/(1+zoom_factor)):1);
		hh = height*(dir?(dir<0?(1+zoom_factor):1/(1+zoom_factor)):1);
		//text+="<br>new width="+ww+" and new height="+hh;
		//recompute new position
		
		//text+="<br>new x="+x+" and new y="+y;
		//set new widths
		if(stop_zoom_out==1){
		width=32;
		height=16;
		
		}
		else{
		x+=(width-ww)*.5;
		y+=(hh-height)*.5;
		width=ww;
		height=hh;
		}
		//height checking to limit map
		if ( y > MAX_Y )
			y = MAX_Y;
		if ( y < -MAX_Y+height )
			y = -MAX_Y+height;
		//text+="<br>new y after correction="+y;
		//document.getElementById("mesaje").innerHTML=text;
		setImageForLoad();
		//document.getElementById("Map2D").src="http://wn1.rogrid.pub.ro:8080/Map2D?page=wmap&w="+width+"&h="+height+"&x="+x+"&y="+y+"&d3d="+(d3d+0)+"&a3d="+a3d+"&dx3d="+dx3d;
	}
	function setImageForLoad()
	{
		hideID("div_tools");
		showID("div_load");
		
		document.getElementById("Map2D").src="/FarmMap?page=wmap1&w="+width+"&h="+height+"&x="+x+"&y="+y+"&d3d="+(d3d+0)+"&a3d="+a3d+"&dx3d="+dx3d+"&_W="+IMG_WIDTH+"&p="+pred+"&ckShowLinks="+show_links;
		hideID("div_load");
		showID("div_tools");
		//checkLoad();
	}
	
	function move(dirx, diry)
	{
		//miscarea se face cu un sfert din poza pe directia de miscare
		dirx=(dirx!=0?(dirx<0?-1:1):0);
		diry=(diry!=0?(diry<0?-1:1):0);
		//text="";
		//text+="<br>move before x="+x+" and y="+y;
		x+=dirx*width*zoom_factor/4;
		y+=diry*height*zoom_factor/4;
		//text+="<br>move after x="+x+" and y="+y;
		//height checking to limit map
		if ( y > MAX_Y )
			y = MAX_Y;
		if ( y < -MAX_Y+height )
			y = -MAX_Y+height;
		//text+="<br>move after2 x="+x+" and y="+y;
		//document.getElementById("mesaje").innerHTML=text;
		setImageForLoad();
		
	}
	function rotate(dir)
	{
		step=10;
		if ( dir>0 ) {
			if ( 90-a3d>=step )
				a3d+=step;
			else {
				a3d=90;
				d3d=0;
			}
		} else if ( dir<0 ) {
			if ( 90-a3d<6*step ) {
				d3d=1;
				a3d-=step;
			};
		};
		document.getElementById("angle3d").value=a3d;
		zoom(0);
	}
	
	function checkLoad()
	{
		image = document.getElementById("Map2D");
		if ( image.width==IMG_WIDTH ) {
			//image.src=image2.src;
			hideID("div_load");
			showID("div_tools");
			return;
		};
		setTimeout("checkLoad();",200);
	}
	function startUp()
	{
		zoom(0);
		hideID("load_legend");
		showID("total_jobs_legend");
		//showID("jobs_vo_legend");
		//capturebegin();
	}

	function toggleBox(szDivID, iState) // 1 visible, 0 hidden
	{
    		if(document.layers)	   //NN4+
    		{
       		document.layers[szDivID].visibility = iState ? "show" : "hide";
    		}
    		else if(document.getElementById)	  //gecko(NN6) + IE 5+
    		{
        	var obj = document.getElementById(szDivID);
        	obj.style.visibility = iState ? "visible" : "hidden";
    		}
    		else if(document.all)	// IE 4
    		{
        	document.all[szDivID].style.visibility = iState ? "visible" : "hidden";
    		}
	}


	function changeWidth()
        {
                    var winW;
                    if(document.layers || ns6)
                        winW=window.innerWidth;
                    else{
                        winW=document.body.offsetWidth;
                    }
                    IMG_WIDTH=winW - 250;//780;
                    IMG_HEIGHT=IMG_WIDTH/2;
                    document.getElementById('test').width=0.97*winW;
                    document.getElementById('Map2D').width=winW - 250;
                    document.getElementById('Map2D').height=(winW - 250)/2;
                    //alert(document.getElementById('Map2D').width);
        }


	
	function switchToAlternate(page){
    document.form1.page.value=page;
    document.form1.submit();
}
	    
function reverse(id){
    var ch = document.getElementById(id);
    
    if (ch.checked) ch.checked=false;
    else ch.checked=true;
}

function checkall(){
    var fields = document.form1.plot_series;
    for (i=0; i<fields.length; i++)
        fields[i].checked=true;
}
	    
function uncheckall(){
    var fields = document.form1.plot_series;
    for (i=0; i<fields.length; i++)
	fields[i].checked=false;
}
function modify(){
    document.form1.submit();
}

function firsttime(){
	if(first=1){
		first=0;
		modify();
	}

}

</script>



</head>

<body onload="windowChanged();<<:begin:>>" topmargin="0" leftmargin="0" onresize="windowChanged();">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="test">
  <tbody><tr>
    <td><img src="spacer.gif" width="4" height="4"></td>
  </tr>
  <tr>
    <td><table style="border: 2px solid rgb(196, 196, 196);" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="5" height="78" width="100%">
      <tbody><tr>
        <td style="border: 2px solid rgb(196, 196, 196);" align="center" height="55" width="146"><table align="center" bgcolor="#053887" border="0" cellpadding="0" cellspacing="0" height="55" width="93%">
          <tbody><tr>
            <td class="whitetextsmall" align="center" height="55" valign="top" width="135"><br>
              MonALISA Repository<br>
              <span class="whitetextlarge">ALICE</span></td>
          </tr>
        </tbody></table></td>
        <td height="64" align="center" background="background2.gif"><a href="http://monalisa.cacr.caltech.edu" target="_blank"><img src="mona.gif" width="207" height="60" border=0></a></td>
      </tr>
    </tbody></table></td>
  </tr>
  <tr>
    <td class="whitetextsmall"><em><img src="spacer.gif" width="4" height="4"></em></td>
  </tr>
  <tr>
    <td width="100%"><table width="100%" height="90" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff" style="border: 2px solid rgb(196, 196, 196);">
      <tbody><tr>
        <td style="border-right: 2px solid rgb(196, 196, 196);" align="left" height="90" valign="top" width="153"><table border="0" cellpadding="0" cellspacing="0" width="153">
          <tbody>
            <tr>
              <td width="5" rowspan="4" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>
              <td width="185"><span class="textmenublue">                <img src="spacer.gif" width="4" height="4"><br>
                MonALISA Client <br>
                </span><span class="dtree style1">Click on the button below to<br>
                start the Monalisa Client.
                </span></td>
            </tr>
            <tr>
              <td><img src="spacer.gif" width="4" height="4"></td>
            </tr>
            <tr>
              <td><div align="center">
                <input name="Submit" type="submit" class="clientbutton" value="Client"
		onClick="JavaScript:window.location='http://monalisa.cacr.caltech.edu/newc/MonaLisa.jnlp'">
                <br>
              </div></td>
            </tr>
            <tr>
              <td style="border-bottom: 2px solid rgb(196, 196, 196);"><img src="spacer.gif" width="4" height="4"></td>
            </tr>
	    <!--
            <tr>
              <td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>
              <td class="textmenublue" style="border-bottom: 2px solid rgb(196, 196, 196);"><a href="admin.jsp" class="linkmenublue">
                ABPing Configuration
              </a></td>
            </tr>
	    -->
            <tr>
		<td>&nbsp;<td>	
	    </tr>	

	    <tr>
              <td width="5">&nbsp;</td>
              <td width="185" rowspan="7" align="left" class="dtree">
                <script type="text/javascript">
	
			showMenu();		

	      	</script>
                <p><a href="javascript: d.closeAll();">close all</a></p></td>
            </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
            <tr>
              <td width="5">&nbsp;</td>
              </tr>
          </tbody>
	  <tbody>


	  <tr>
	  	<td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>
              <td style="border-bottom: 2px solid rgb(196, 196, 196);"><img src="spacer.gif" width="4" height="4"></td>
            </tr>

            <tr>
              <td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>
              <td class="textmenublue" style="border-bottom: 2px solid rgb(196, 196, 196);"><a href="apmon" class="linkmenublue">
                ApMon Configuration
              </a></td>
            </tr>

            <tr>
              <td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>
              <td class="textmenublue" style="border-bottom: 2px solid rgb(196, 196, 196);"><a href="abping" class="linkmenublue">
                ABPing Configuration
              </a></td>
            </tr>
	    <tr>
	      <td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>	  
	      <td class="textmenublue" style="border-bottom: 2px solid rgb(196, 196, 196);"><a href="admin.jsp" class="linkmenublue">
                Site Administration
              </a></td>
            </tr>
	    <tr>
	      <td width="5" style="border-bottom: 2px solid rgb(196, 196, 196);">&nbsp;</td>	  
	      <td class="textmenublue" style="border-bottom: 2px solid rgb(196, 196, 196);"><a href="abping?function=ColorSitesList" class="linkmenublue">
                Farm Colour Configuration
              </a></td>
            </tr>
	  </tbody>
        </table></td>
        <td width="100%" align="center" valign="top" ><p></p><p>
	      <div align="center"><p><table border=0 cellspacing=0 cellpadding=2><tr><<:alternates:>></tr></table>
    
	 	<<:continut:>>
	      </div>
	</td>
		
      </tr>
       
    </tbody></table></td>
  </tr>
  <tr>
    <td><img src="spacer.gif" width="4" height="4"></td>
  </tr>
  <tr>
    <td><table style="border: 2px solid rgb(196, 196, 196);" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" height="10" width="100%">
      <tbody><tr>
        <td class="textupdate" align="center" height="15">&nbsp; </td>
      </tr>
    </tbody></table></td>
  </tr>
  <tr>
    <td><img src="spacer.gif" width="4" height="4"></td>
  </tr>
  
</tbody></table>
</body></html>
