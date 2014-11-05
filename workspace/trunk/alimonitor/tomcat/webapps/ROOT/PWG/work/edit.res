<script language="javascript" type="text/javascript" src="/js/tiny_mce/tiny_mce.js"></script>
<script language="javascript">
tinyMCE.init({
    mode: "exact",
    elements : "comment,p_savannah",	
    theme : "advanced",
    plugins : "table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,zoom,flash,searchreplace,print,contextmenu",
    theme_advanced_buttons1_add_before : "save,separator",
    theme_advanced_buttons1_add : "fontselect,fontsizeselect",
    theme_advanced_buttons2_add : "separator,insertdate,inserttime,preview,zoom,separator,forecolor,backcolor",
    theme_advanced_buttons2_add_before: "cut,copy,paste,separator,search,replace,separator",
    theme_advanced_buttons3_add_before : "tablecontrols,separator",
    theme_advanced_buttons3_add : "emotions,iespell,flash,advhr,separator,print",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
    plugin_insertdate_dateFormat : "%Y-%m-%d",
    plugin_insertdate_timeFormat : "%H:%M:%S",
    extended_valid_elements : "a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
});


    var calendarObjForFormMax = new DHTMLSuite.calendar({
						    callbackFunctionOnDayClick:'setExpectedDate', 
						    isDragable:true, 
						    displayTimeBar:true});

    
    var dNow = new Date();
    
    var myCalendarModel = new DHTMLSuite.calendarModel({ initialYear:dNow.getFullYear(),initialMonth:dNow.getMonth()+1, initialDay: dNow.getDate() });

    //limita de sus
    myCalendarModel.addInvalidDateRange(false, {year: dNow.getFullYear(), month: dNow.getMonth()+1, day: dNow.getDate()});
    
    calendarObjForFormMax.setCalendarModelReference(myCalendarModel);												
    
    function pickExpectedDate(buttonObj,inputObject, calendarObjForForm){
	calendarObjForForm.setCalendarPositionByHTMLElement(inputObject,0,inputObject.offsetHeight+2);	// Position the calendar right below the form input
	calendarObjForForm.setInitialDateFromInput(inputObject,'yyyy-mm-dd');	// Specify that the calendar should set it's initial date from the value of the input field.
	calendarObjForForm.addHtmlElementReference('myDate',inputObject);	// Adding a reference to this element so that I can pick it up in the getDateFromCalendar below(myInput is a unique key)
	
	if(calendarObjForForm.isVisible()){
	    calendarObjForForm.hide();
	}else{
	    calendarObjForForm.resetViewDisplayedMonth();	// This line resets the view back to the inital display, i.e. it displays the inital month and not the month it displayed the last time it was open.
	    calendarObjForForm.display();
	}		
    }	
    
    function setExpectedDate(inputArray){
	var references = calendarObjForFormMax.getHtmlElementReferences(); // Get back reference to form field.
	references.myDate.value = inputArray.year + '-' + inputArray.month + '-' + inputArray.day;
	calendarObjForFormMax.hide();	
    }
</script>

<script type="text/javascript" src="/js/htmlsuite/ajax.js"></script>
<script type="text/javascript">

var ajax = new Array();

function getUsersList(sel, initialGroup)
{
    var groupId = sel.options[sel.selectedIndex].value;
    document.getElementById('responsibles').options.length = 0;	// Empty city select box

    if(groupId.length>0){
	var index = ajax.length;
	ajax[index] = new sack();
	ajax[index].requestFile = '/PWG/work/groups.jsp?group='+groupId;	// Specifying which file to get
	ajax[index].onCompletion = function () {createUsers(index);};	// Specify function that will be executed after file has been found
	ajax[index].runAJAX();		// Execute AJAX function
    }
}

function createUsers(index)
{
    var obj = document.getElementById('responsibles');
    eval(ajax[index].response);	// Executing the response from Ajax as Javascript code	
}


function initializeGroup(initialGroup, initialRequest)
{
    document.getElementById('responsibles').options.length = 0;	// Empty city select box
    if(initialGroup.length>0){
	var index = ajax.length;
	ajax[index] = new sack();
	ajax[index].requestFile = '/PWG/work/groups.jsp?group='+initialGroup+'&request='+initialRequest;	// Specifying which file to get
	ajax[index].onCompletion = function () {createUsers(index);};	// Specify function that will be executed after file has been found
	ajax[index].runAJAX();		// Execute AJAX function
    }
}

</script>

<form name="form1" action="edit.jsp" method="POST" enctype="multipart/form-data">
    <input type="hidden" name="id" value="<<:p_id db esc:>>">
    <input type="hidden" name="save" value="true">

<div align=left>
<table border=0 cellspacing=0 cellpadding=0 class="table_content">
    <tr height=25>
	<td class="table_title" style="background-color: #E0E0E0"><b>Production Requests</b></td>
    </tr>

    <tr>
	<td>
	    <table cellspacing=1 cellpadding=5 bgcolor="#F0F0F0">
    	        <tr class="table_row">
    	    	    <td></td>
    	    	    <td><font color="#425242"><i>Fields marked with <font color="red">*</font> are required</i></font></td>    	    	    
    	        </tr>
	        <tr class="table_row">
		    <td align="left" class="pwg_row">PWG</td>
		    <td align="left">
			<select name="p_group" id="p_group" class="input_select" onchange="getUsersList(this)">
			    <<:opt_group:>>
			</select><font color="red">*</font>
		    </td>
		</tr>
		<tr class="table_row" style="display:none">
		    <td align="left" class="pwg_row">
			Responsibles<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&raquo;<a class="link" href="../admin/users.jsp?action=2">Edit users</a>
		    </td>
		    <td align="left">
			<select name="responsibles" id="responsibles" class="input_select" multiple="multiple" size="5" style="width: 200px">
			    <<:opt_responsibles:>>
			</select><font color="red">*</font><br>
			<font color="#425242"><i>(hold Ctrl to select several responsibles)</i></font>
		    </td>
		</tr>
		<tr class="table_row">
		    <td align="left" class="pwg_row">Collision system</td>
		    <td align="left">
			<select name="p_collision" class="input_select">
			    <option value="p-p" <<:opt_collision_p-p:>>>p-p</option>
			    <option value="p-A" <<:opt_collision_p-A:>>>p-A</option>
			    <option value="Pb-Pb" <<:opt_collision_Pb-Pb:>>>Pb-Pb</option>
			</select><font color="red">*</font>
		    </td>
		</tr>
		<tr class="table_row">
		    <td align="left" class="pwg_row">Energy</td>
		    <td align="left"><input type="text" name="p_energy" value="<<:p_energy db esc:>>" class="input_text">GeV
		    <font color="red">*</font>
		    </td>
		</tr>
		<tr class="table_row">
		    <td align="left" class="pwg_row">Requested no. of events</td>
		    <td align="left"><input type="text" name="p_reqev" value="<<:p_reqev db esc:>>" class="input_text">
		    <font color="red">*</font>
		    </td>
		</tr>
		<tr class="table_row">
		    <td align="left" class="pwg_row">Expected finish date</td>
		    <td align="left" valign="middle">
			<table cellpadding="0" cellspacing="0"><tr><td valign="middle"><input type="text" name="p_expdate" id="p_expdate" value="<<:p_expdate db esc:>>" class="input_text"></td>
			<td valign="middle"><a href="javascript:void(0)" onclick="nd(); pickExpectedDate(this, document.getElementById('p_expdate'), calendarObjForFormMax);" onmouseover="return overlib('Select expected finish date');" onmouseout="return nd();"><img src="/img/cal.gif" border=0 hspace=2 vspace=2 align="center" valign="middle"></a>
			<font color="red">*</font>
			</td></tr>
			</table>
			
		    </td>
		</tr>
		<<:com_prodtag_start:>>
		<tr class="table_row">
		    <td align="left" class="pwg_row">Production tag</td>
		    <td align="left">
			<select name="p_tag" class="input_select">
			    <option value=""></option>
			    <<:opt_tag:>>
			</select>
		    </td>
		</tr>
		<<:com_prodtag_end:>>
		<tr class="table_row">
		    <td align="left" class="pwg_row">
			Comment
		    </td>
		    <td align="left"><textarea cols=100 rows=10 name="comment" id="comment" class="input_textarea"><<:comment esc:>></textarea></td>
		</tr>
		<tr class="table_row">
		    <td align="left" class="pwg_row">
			Links to Savannah
		    </td>
		    <td align="left"><textarea cols=100 rows=10 name="p_savannah" id="p_savannah" class="input_textarea"><<:p_savannah esc:>></textarea></td>
		</tr>
		<tr>
		    <td colspan=2 class="table_title" style="background-color: #E0E0E0">
			<b>Files</b>
		    </td>
		</tr>
		
		<<:files:>>
		
		<tr>
		    <td colspan=2 align=right>
			<input type="submit" class="input_submit" name="submit" value="Save">
		    </td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</div>

</form>
<script>
    var initialRequest = '<<:p_id db esc:>>';
    
    //initialize the users
    var initialGroup = document.getElementById("p_group").value;
    initializeGroup(initialGroup, initialRequest);
</script>

