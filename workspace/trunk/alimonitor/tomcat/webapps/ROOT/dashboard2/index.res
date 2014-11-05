<script type="text/javascript">
    var messages = new Array();
    
    function overlib_ne(site){
	message = messages[site];
    
	if (message && message.length>0){
	    overlib('<div align=left>'+message+'</div>', WIDTH, 400);
	}
    }
    
    function window_ne(site){
	message = messages[site];
    
	if (message && message.length>0){
	    showCenteredWindow('<div align=left>'+message+'</div>', site);
	}	
    }
</script>

<form name="form1" action="/dashboard2/" method=POST>
    <input type=hidden name="tab" value="0">
</form>

<script type="text/javascript" src="/js/htmlsuite/rounded-corners.js"></script>

<div id="siteselection" align="center" style="width:300px;height:50px;padding-bottom:35px">
    <div class="text" style="color:#FFFFFF; font-weight:bold; font-size: 16px; padding-top:5px">
	Shifters' dashboard
    </div>
    <div class="text" align="right" style="padding-right: 15px">
	<a class="link" target=_blank href="https://twiki.cern.ch/twiki///bin/view/ALICE/OfflineShifterManual">(manual)</a>
    </div>
</div>

<STYLE TYPE="text/css" MEDIA=screen>
<!--
    .spacing {padding-bottom:10px;}
    .left {float:left; width: 51%;}
    .right {float:right; width: 49%;}
    .sublist {padding-left:20px;}
-->
</STYLE>

<div id="contentwrapper" align=center" style="width:800px;padding-bottom:30px">
    <div id="content" align="left" class="text">
	<div id="shuttle" class="left spacing">
	    <a class=link target=_blank href="/shuttle.jsp?instance=PROD" title="Click to see SHUTTLE history"><b>Shuttle</b></a>:<br>
	    <div class="sublist">
		Status: <<:shuttle_status:>><br>
		Last processed run: <<:shuttle_lastrun:>><br>
		Pending runs: <<:shuttle_pending:>><br>
		Detectors: <<:shuttle_detectors:>>
	    </div>
	</div>
	<div id="raw" class="right spacing">
	    <a class=link target=_blank href="/DAQ/" title="Click to see all registered runs"><b>RAW</b></a>:<br>
	    <div class="sublist">
		Last run: <<:raw_lastrun esc:>><br>
		Registered: <<:raw_time nicedate:>> <<:raw_time time:>><br>
		Partition: <<:raw_partition esc:>><br>
		<a class="link" target="_blank" href="https://alice-logbook.cern.ch/">DAQ Logbook</a><br>
	    </div>
	</div>
	<div id="fts" class="left spacing">
	    <a class=link target=_blank href="/display?page=FTD/SE"><b>FTD / FTS</b></a>:<br>
	    <div class="sublist">
		CERN FTD: <<:fts_cern_status:>><br>
		T1s:<br>
		<div class=sublist>
		    <<:fts_t1s:>>
		</div>
	    </div>
	</div>
	<div id="central" class="right spacing">
	    <a class=link target=_blank href="/stats?page=machines/machines"><b>Central services</b></a>:<br>
	    <div class="sublist">
		Status: <<:central_status:>><br>
		<a class=link target=_blank href="/stats?page=SE/table">Storages</a>:<br>
		<div class=sublist>
		    Castor2: <<:central_castor2_status:>><br>
		    xrootd SE: <<:central_se_status:>>
		</div>
	    </div>
	</div>
    </div>
</div>

<script type="text/javascript">
    color = '#F0F5FF';

    rC = new DHTMLgoodies_roundedCorners();
    
    rC.addTarget('siteselection',15,15,'#9FBCD1','#FFFFFF',0,'45');

    rC.addTarget('contentwrapper',10,10,color,'#FFFFFF',2,'100%');
    rC.addTarget('content',10,10,'#FFFFFF',color,5,'300');
    rC.init();
</script>
