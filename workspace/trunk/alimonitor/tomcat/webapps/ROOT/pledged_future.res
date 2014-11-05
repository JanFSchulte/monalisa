<script>var currentTab;</script>
<script src="/js/grid/prototype.js" type="text/javascript"></script>
<script src="/js/grid/scriptaculous.js" type="text/javascript"></script>
<script src="/js/grid/controls.js" type="text/javascript"></script>
<script src="/js/grid/effects.js" type="text/javascript"></script>
<style>

.text_normal{
    font-family: Verdana, Arial, Tahoma;
    font-size: 11px;
    text-decoration: none;
}

form.inplaceeditor-form {
    font-family: Verdana, Arial, Tahoma;
    font-size: 11px;
    text-decoration: none;
    display: inline;
}

form.inplaceeditor-form input {
    font-family: Verdana, Arial, Tahoma;
    font-size: 11px;
    text-decoration: none;
    border: solid 1px #CCCCCC;
    width: 50px;
}

.inplaceeditor-saving {
    font-family: Verdana, Arial, Tahoma;
    font-size: 11px;
    text-decoration: none;
}

.inplaceeditor-loading{
    font-family: Verdana, Arial, Tahoma;
    font-size: 11px;
    text-decoration: none;

}

</style>
</head>
<script>

var vsSiteNames = [<<:sitenames:>>];
var border_style_changed = "1px solid #E47878"

function updateTableCols(rowElement, rowValue){
    var temp = rowElement.id;
    var sRowName  = temp.substring(0, temp.lastIndexOf('_'));
    var tablename = temp.substring(0, temp.indexOf('_'));
    var quarter   = temp.substring(temp.lastIndexOf('_')+1) * 1;
    var sitename  = temp.substring(temp.indexOf('_')+1, temp.lastIndexOf('_'));

    if (rowValue == "-")
	return;

    var affected  = [quarter];
    var aff_idx   = 1;
    
    document.getElementById(sRowName+"_"+quarter+"_row").style.border="2px solid #E47878";
    
    var limit = quarter - quarter%4 + 4;
    
    //alert('quarter='+quarter+', limit='+limit);
    
    for(i=quarter+1; i<<<:quarters:>> && i<limit; i++){
	var cell = document.getElementById(sRowName+"_"+i);
	var tbl  = document.getElementById(sRowName+"_"+i+"_row");
    
	if (cell.innerHTML != rowValue){
	    cell.innerHTML = rowValue;
	    
	    tbl.style.border=border_style_changed;
	    
	    affected[aff_idx] = i;
	    aff_idx++;
	}
    }
    
    for (aff=0; aff<affected.length; aff++){
	var total = 0;
    
	var q = affected[aff];
	
	var isset = false;
    
	for(i=0; i<vsSiteNames.length; i++){
	    var site = vsSiteNames[i];
	
	    var value = document.getElementById(tablename+"_"+site+"_"+q).innerHTML;
	
	    if(value != "-"){
		total += value*1;
		
		isset = true;
	    }
	}
	
	document.getElementById(tablename+"_TOTALROW_"+q).innerHTML = isset ? total : "-";
    }
}

var alreadyGenerated = [];

function c(id){
if (alreadyGenerated[id] != null)
    return '';
alreadyGenerated[id] = id;
return new Ajax.InPlaceEditor(id, 'pledged_future.jsp', {okButton: false, cancelLink : false, highlightcolor:"#EDEDFF" ,callback: function(form, value) { return 'value=' + escape(value)+ '&field='+id}, onComplete : function(transport, element) {updateTableCols(element, transport.responseText)}  });
}

function n(id){
if (alreadyGenerated[id] != null)
    return '';
alreadyGenerated[id] = id;
return new Ajax.InPlaceEditor(id, 'pledged_future.jsp', {okButton: false, cancelLink : false, highlightcolor:"#EDEDFF" ,callback: function(form, value) { return 'value=' + escape(value)+ '&field='+id}, onComplete : function(transport, element) {updateTableCols(element, transport.responseText)}  }).enterEditMode();
}

function showChart(resource, parameters){
    w=900;
    h=700;

    sHTML = '<iframe src="/pledged_chart.jsp?r='+resource+'&'+parameters+'&width='+(w-10)+'&height='+(h-10)+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="no" align="absmiddle" vspace="0" hspace="0" width=99% height=99%></iframe>';

    sName = 'kSI2K';
    
    if (resource==3) sName='bandwidth';
    if (resource==4) sName='disk storage';
    if (resource==5) sName='mass storage';

    showCenteredWindowSize(sHTML, 'Pledged '+sName, w, h);
    
    return false;
}

function checkAll(f){
    var chk = f.elements['all'].checked;

    for (var i=0; i < f.elements.length; i++) {
        var element = f.elements[i];
        
        if (element.name=='s')
    	    element.checked = chk;
    }
}

function genChart(resource, f){
    sParams = '';
    
    for (var i=0; i < f.elements.length; i++) {
        var element = f.elements[i];
	if (element.name=='s' && element.checked)
	    sParams = sParams + 's='+element.value+'&';
    }
    
    return showChart(resource, sParams);
}

</script>

<!-- Load the tabber code -->
<script type="text/javascript" src="/js/grid/tabber.js"></script>
<<:com_explanation_start:>>
<div class="text">To edit these resources please <a href="dologin.jsp?page=pledged_future.jsp" class="link">Login</a></div>
<<:com_explanation_end:>>

<div class="tabber" id="tab1">
    <<:continut:>>
</div>
