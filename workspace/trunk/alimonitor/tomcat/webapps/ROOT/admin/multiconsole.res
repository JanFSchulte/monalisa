<html>
    <head>
	<title>Multiconsole</title>
	<link href="multiconsole.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="../js/htmlsuite/ajax.js"></script>
	<script type="text/javascript">
	    var DHTML_SUITE_THEME = 'light-cyan';	// SPecifying gray theme
	</script>
	<script type="text/javascript" src="../js/htmlsuite/dhtml-suite-for-applications-without-comments.js"></script>
	<script src="../js/prototype.js" type="text/javascript"></script>
	<script type="text/javascript" src="multiconsole.js"></script>
	
	<script type="text/javascript">
	    function execOnLoad(){
		<<:initial_command:>>
	    }
	</script>
	
    </head>
    <body bgcolor=white onLoad="execOnLoad()">
	<div id="northContent">
	    <<:divs:>>
	</div>
	<div id="southContent">
	    <table width="100%" cellspacing="0" cellpadding="0" border="0" style="font-family:Arial,Verdana,Helvetica;font-size:12px" class="text">
		<tr height="40">
		    <td colspan=4 style="padding-left: 10px; padding-right: 10px;color: #67674D; font-weight: bold">
		        <form name="command_executor" action="multiconsole.jsp" onSubmit="return executeCommand();">
			    <input type=text id="console_command" class="input_text" style="text-align: left;width: 100%">
			</form>
		    </td>
		</tr>
		<tr bgcolor="#FFFFE5" height=30>
		    <td nowrap align=left  style="padding: 5px; color: #67674D; font-weight: bold">
			Actions : <input id="button_pause" type=button value="Pause scroll" onClick="pause();" class="input_submit" style="font-weight: bold"> <input type=button value="Clear window" onClick="clearWin();" class="input_submit" style="font-weight: bold">
		    </td>
		    <td align=center nowrap style="padding: 5px; color: #67674D; font-weight: bold">
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
		    <td align=center nowrap style="padding: 5px; color: #67674D; font-weight: bold">
			<a href="javascript:increaseFontSize();"><img src="/img/font/font-inc2.gif" border=0 alt="Increase font size"></a>
			<a href="javascript:decreaseFontSize();"><img src="/img/font/font-dec2.gif" border=0 alt="Decrease font size"></a>
		    </td>
		    <form name="highlight_executor" action="multiconsole.jsp" onSubmit="return highlight();">
		      <td nowrap align=right style="padding: 5px; color: #67674D; font-weight: bold">
		        Highlight text:
		        <input id="highlight_text" type="text" name="highlight_text" value="" class="input_text" style="text-align: left; color: #FF9966; font-weight: bold">
		        <input type=button value="&raquo;" onClick="highlight()" class="input_submit" style="font-weight: bold">
		      </td>
		    </form>
		</tr>
	    </table>
	</div>
	
	<script type="text/javascript">

	    var vSites = new Array();

	    /* STEP 1 */
	    /* Create the data model for the panes */
	    var paneModel = new DHTMLSuite.paneSplitterModel( { collapseButtonsInTitleBars:true } );
	    DHTMLSuite.commonObj.setCssCacheStatus(false)

	    var paneSouth = new DHTMLSuite.paneSplitterPaneModel( 
		{ 
		    position : "south", 
		    id:"southPane",
		    size:108,
		    minSize:108,
		    maxSize:108,
		    resizable:false,
		    closable:false
		} 
	    );
	    paneSouth.addContent( new DHTMLSuite.paneSplitterContentModel( { id:"southContent",htmlElementId:'southContent',title:'Command',closable:false } ) );

	    var paneCenter = new DHTMLSuite.paneSplitterPaneModel( 
		{
		    position : "center", 
		    id:"centerPane",
		    size:150,
		    minSize:100,
		    maxSize:200,
		    callbackOnTabSwitch:'callbackFunction'
		}
	    );
	    <<:panes:>>

	    paneModel.addPane(paneSouth);
	    paneModel.addPane(paneCenter);

	    /* STEP 2 */
	    /* Create the pane object */
	    var paneSplitter = new DHTMLSuite.paneSplitter();
	    paneSplitter.addModel(paneModel);	// Add the data model to the pane splitter
	    paneSplitter.init();	// Add the data model to the pane splitter
    
	    DHTMLSuite.configObj.resetCssPath();
	    
	    // -------------
	    var cmdObj = document.getElementById('console_command');
	    cmdObj.focus();
	    
	    var visibleSite = vSites[0];
	</script>
    </body>
</html>
