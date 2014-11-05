<script type="text/javascript" src="/js/ajax-dynamic-content.js"></script>
<script type="text/javascript" src="js/context-menu.js"></script>

<script type="text/javascript">
    var isLoading = true;

    var lastOpenFolder = '';

    var obs = {
        onClose: function(eventName, win){
	    reloadFolder();
	}
    };

    function chooseRole(){
	var win = showIframeWindow("/users/role.jsp", "Your roles");

	Windows.addObserver(obs);
    }
    
    function reloadFolder(){
	openFolder(lastOpenFolder);
    }

    function lf(path){
	lastOpenFolder = path;
	ajax_loadContent('files','list.jsp?path='+escape(path),'setupContextMenu()');
    }
    
    function openFolder(path){
	isLoading = true;
	
	lastOpenFolder = path;

	expandLabels('dhtmlgoodies_tree', Array(path));
	isLoading = false;
	
	window.location.hash=path;	
	
	lf(path);
    }
    
    function whereis(path,persistent){
	if (persistent)
	    showCenteredWindow('<div align=left id=whereisfile></div>', 'List of SEs');
	else
	    overlib('<div align=left id=whereisfile></div>', CAPTION, 'List of SEs');
	
	ajax_loadContent('whereisfile', 'whereis.jsp?file='+path);
    }

    function enableHiding(){
	document.documentElement.onclick = autoHideContextMenu;
    }

    function menu(e){
        showContextMenu(e);

	window.setTimeout('enableHiding()', 10);
	        
        return true;
    }

    function resortTables(){
	try{
	    sorttable.init('true');
	}
	catch (ex){
	    //alert(ex);
	}
    }
    
    function setupContextMenu(){
	window.setTimeout('resortTables()', 500);
	
	try{
    	    var aItems = document.getElementById('filelist').getElementsByTagName('A');
	
	    for(var no=0;no<aItems.length;no++){
		aItems[no].onclick = menu;
	    }
	}
	catch (ex){
	}
    }
    
    function view(){
	window.open('/users/download.jsp?view=true&path='+escape(contextMenuObj.fullPath), '_blank');
    }
    
    function downloadFile(){
	window.open('/users/download.jsp?path='+escape(contextMenuObj.fullPath), '_blank');
    }
    
    function edit(){
	window.open('/users/edit.jsp?path='+escape(contextMenuObj.fullPath), '_blank');
    }
    
    function submitJDL(){
	var jdl = contextMenuObj.fullPath;
	var params = prompt('Arguments to provide to '+jdl);

	if (!confirm('Are you sure you want to submit '+jdl+' '+params+' ?'))
	    return;
		
	showIframeWindow('/users/submit.jsp?jdl='+escape(jdl)+'&parameters='+escape(params), 'Submitting job');
    }
    
    function deleteFile(){
	if (!confirm('Are you sure you want to delete '+contextMenuObj.fullPath+' ?'))
	    return false;
    
	var url = '/users/delete.jsp?path='+escape(contextMenuObj.fullPath);
    
	new Ajax.Request(url, {
	    method: 'get',
	    onComplete: function(transport) {
		if(transport.status == "200" || transport.status == 0){
		    //alert (transport.responseText);
		
		    if(transport.responseText.indexOf('OK') < 0){
		        alert(transport.responseText);
		        
		        return false;
		    }
		    else{
			openFolder(lastOpenFolder);
		    }
		}
		else{
		    alert("Error: "+transport.status);
		    return false;
		}
	    	
		}
	    }
	);
    }
    
    function createFolder(){
	var foldername = prompt('New folder under '+lastOpenFolder);
	
	if (!foldername)
	    return;
	
	var url = '/users/newfolder.jsp?path='+escape(lastOpenFolder)+'&newfolder='+escape(foldername);
    
	new Ajax.Request(url, {
	    method: 'get',
	    onComplete: function(transport) {
		if(transport.status == "200" || transport.status == 0){
		    //alert (transport.responseText);
		
		    if(transport.responseText.indexOf('OK') < 0){
		        alert(transport.responseText);
		        
		        return false;
		    }
		    else{
			openFolder(lastOpenFolder);
		    }
		}
		else{
		    alert("Error: "+transport.status);
		    return false;
		}
	    	
		}
	    }
	);
    }

    function createFile(){
	var filename = prompt('New text file under '+lastOpenFolder);

	if (!filename)
	    return;

	var url = '/users/edit.jsp?new=true&path='+escape(lastOpenFolder)+'/'+escape(filename);
	
	window.open(url, '_blank');
    }
    
    function getHeight() {
        if( typeof( window.innerWidth ) == 'number' ) {
	    return window.innerHeight;
        } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
            return document.documentElement.clientHeight;
        } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
            return document.body.clientHeight;
        }
        
        return 0;
    }
    
    function resizeWindow(){
	var winh = getHeight();
    
	if (winh>50){
	    document.getElementById("leftsidediv").style.height=(winh-50)+"px";
	    document.getElementById("files").style.height=(winh-50)+"px";
	}
    }
                                                      
</script>

    <table border=0 cellspacing=0 cellpadding=0 align=left>
	<tr><td align=left valign=top nowrap width=300>
	<div id="leftsidediv" style="overflow:scroll; white-space:nowrap; height: 600px; width:300px">
	<ul id="dhtmlgoodies_tree" class="dhtmlgoodies_tree_cat">
	    <<:open_path:>>
	</ul>
	</div>
	<a href="#" onclick="collapseAll('dhtmlgoodies_tree');return false" class=link>Collapse all</a>
	<script type="text/javascript">
	    initTree();
	    expandLabels('dhtmlgoodies_tree', Array('/'));
	</script>
	</td>
	<td align=left valign=top width=740>
	    <div style="overflow:auto; height:600px; width:740px;" id="files" align=center>
	    
	    </div>
	</td>
	</tr>
    </table>
<script type="text/javascript">
    openFolder('<<:initialpath js:>>');
//    lf('<<:initialpath js:>>');

    resizeWindow();
    window.onresize = resizeWindow;
</script>

<ul id="contextMenu">
    <li style="text-align:left"><a href="javascript:void(0)" onClick="view()">View</a></li>
    <li style="text-align:left" id="editOption"><a href="javascript:void(0)" onClick="edit()">Edit</a></li>
    <li style="text-align:left"><a href="javascript:void(0)" onClick="downloadFile()">Download</a></li>
    <li style="text-align:left" id="deleteOption"><a href="javascript:void(0)" onClick="deleteFile()"><hr width=100% size=1><font color=red>Delete</font></a></li>
    <li style="text-align:left" id="submitOption"><a href="javascript:void(0)" onClick="submitJDL()"><hr width=100% size=1>Submit</a></li>
</ul>
<script type="text/javascript">
initContextMenu();
</script>
