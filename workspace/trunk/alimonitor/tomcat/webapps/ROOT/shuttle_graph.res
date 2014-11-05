<script type="text/javascript">
var detectors = [
	"SPD",
	"SDD",
	"SSD",
	"TPC",
	"TRD",
	"TOF",
	"PHS",
	"CPV",
	"HMP",
	"EMC",
	"MCH",
	"MTR",
	"FMD",
	"ZDC",
	"PMD",
	"T00",
	"V00",
	"GRP",
	"ACO",
	"HLT",
	"TRI"
    ];

function checkalldetectors(){
    for (i=0; i<detectors.length; i++)
        objById('detector_'+detectors[i]).checked=true;
}

function uncheckalldetectors(){
    for (i=0; i<detectors.length; i++)
        objById('detector_'+detectors[i]).checked=false;
}

function only(name){
    uncheckalldetectors();
    
    objById('detector_'+name).checked=true;
    
    document.form1.submit();
}

var calendarObjForFormMin = new DHTMLSuite.calendar(
    {
	minuteDropDownInterval:1, 
	numberOfRowsInHourDropDown:10,
	callbackFunctionOnDayClick:'getDateAndCloseMin',
	callbackFunctionOnClose:'getDateFromCalendarMin',
	isDragable:true, 
	displayTimeBar:true
    }
);

var calendarObjForFormMax = new DHTMLSuite.calendar(
    {
	minuteDropDownInterval:1, 
	numberOfRowsInHourDropDown:10,
	callbackFunctionOnDayClick:'getDateAndCloseMax',
	callbackFunctionOnClose:'getDateFromCalendarMax',
	isDragable:true, 
	displayTimeBar:true
    }
);

function getDateAndCloseMin(inputArray){
    getDateFromCalendar(inputArray, 'min');
    calendarObjForFormMin.hide();
}

function getDateAndCloseMax(inputArray){
    getDateFromCalendar(inputArray, 'max');
    calendarObjForFormMax.hide();
}

function getDateFromCalendarMin(inputArray){
    getDateFromCalendar(inputArray, 'min');
}

function getDateFromCalendarMax(inputArray){
    getDateFromCalendar(inputArray, 'max');
}

function getDateFromCalendar(inputArray,refName){
    var references = refName=='min' ? calendarObjForFormMin.getHtmlElementReferences() : calendarObjForFormMax.getHtmlElementReferences(); // Get back reference to form field.
	
    var sDate = inputArray.year + '-' + inputArray.month + '-' + inputArray.day + ' ' + inputArray.hour + ':' + inputArray.minute;
    references.myDate.value = sDate;

    return;

    var dDate = new Date();
    dDate.setFullYear(inputArray.year, inputArray.month-1, inputArray.day);
    dDate.setHours(inputArray.hour);
    dDate.setMinutes(inputArray.minute);
    dDate.setSeconds(0);
    dDate.setMilliseconds(0);
					
    var dNow = new Date();
    dNow.setMinutes(0);
    dNow.setSeconds(0);
    dNow.setMilliseconds(0);
									
    var iInterval =  dNow.getTime() - dDate.getTime();

    if(iInterval < 0)
    iInterval = -iInterval;
    document.getElementById("interval."+references.myDate.id).value = iInterval;
}

function pickDate(buttonObj,inputObject,refName){
    calendarObjForForm = refName=='min' ? calendarObjForFormMin : calendarObjForFormMax;

    calendarObjForForm.setCalendarPositionByHTMLElement(inputObject,0,inputObject.offsetHeight+2);
    
    calendarObjForForm.setInitialDateFromInput(inputObject,'yyyy-mm-dd hh:ii');
    
    calendarObjForForm.addHtmlElementReference('myDate',inputObject);

    if(calendarObjForFormMin.isVisible()){
	calendarObjForFormMin.hide();
    }
    
    if(calendarObjForFormMax.isVisible()){
	calendarObjForFormMax.hide();
    }
    
    calendarObjForForm.resetViewDisplayedMonth();	// This line resets the view back to the inital display, i.e. it displays the inital month and not the month it displayed the last time it was open.
    calendarObjForForm.display();
}

var usage_text = '<b>State names explained</b>:<br>'+
    '<table border=1 cellspacing=0 cellpadding=5 class=text width=400 style="padding-left:10px">'+
    '<tr><td align=left>Started</td><td align=left>Started</td></tr>'+
    '<tr><td align=left>DCSStarted</td><td align=left>DCS retrieval started</td></tr>'+
    '<tr><td align=left>DCSError</td><td align=left>DCS retrieval failed</td></tr>'+
    '<tr><td align=left>PPStarted</td><td align=left>Preprocessor started</td></tr>'+
    '<tr><td align=left>PPError</td><td align=left>Preprocessor exited with error state</td></tr>'+
    '<tr><td align=left>PPOutOfMemory</td><td align=left>Preprocessor out of memory</td></tr>'+
    '<tr><td align=left>PPTimeOut</td><td align=left>Preprocessor timed out</td></tr>'+
    '<tr><td align=left>PPDone</td><td align=left>Preprocessor succeeded</td></tr>'+
    '<tr><td align=left>StoreStarted</td><td align=left>Storing to Grid OCDB started</td></tr>'+
    '<tr><td align=left>StoreError</td><td align=left>Storing to Grid OCDB failed</td></tr>'+
    '<tr><td align=left>Done</td><td align=left>Done</td></tr>'+
    '<tr><td align=left>Failed</td><td align=left>Failed</td></tr>'+
    '</table>'
;

</script>

<form action="shuttle_graph.jsp" method="post" name="form1">
    <input type=hidden name=instance value="<<:instance esc:>>">
    <table width="800" cellspacing="0" cellpadding="0" border="0" class="text">
	<tr>
	    <td align=left>
		<table border=0 cellspacing=0 cellpadding=0 width=100%>
		    <tr>
			<td align=left valign=bottom>
			    <a onMouseOver="overlib('Click here for a brief help')" onMouseOut='return nd();' onClick="showCenteredWindow(usage_text, 'Legend'); return false;"><b>Explanation of states<img src="/img/qm.gif" border=0></a><br clear=all>&nbsp;
			</td>
			<td align=right valign=bottom>
			    <a onMouseOver="overlib('<img src=/images/shuttle_states.png>', OFFSETX, -620)" onMouseOut='return nd();'><b>Transition diagram</a><br clear=all>&nbsp;
			</td>
		    </tr>
		</table>
	    </td>
	</tr>
	<tr>
	    <td height="3" bgcolor="#F0F0F0" style="border-top: solid 1px #B5B5BD"><img height="1" width="1"></td>
	</tr>
	<tr>
	    <td height="2" bgcolor="#FFFFFF"><img height="1" width="1"></td>
	</tr>

	<tr>
	    <td style="border-bottom: solid 1px #B5B5BD; padding-bottom: 5px; font-family: Verdana, Arial" bgcolor="#F0F0F0">
		<table width=100% cellspacing="0" cellpadding="0">
		    <tr>
			<td>
			    <table border=0 cellspacing=0 cellpadding=3 width=100% style="border-bottom: 2px solid #FFFFFF;">
			        <tr>
				    <td align=right style="padding:0px">
					<table border=0 cellspacing=0 cellpadding=0 width=100%>
					    <tr>
						<td align=left>
						    &nbsp;&nbsp;Detectors:
						</td>
					        <td align=right>
						    (<a class="link" href="JavaScript:checkalldetectors();" class="link">check all</a> | <a class="link" href="JavaScript:uncheckalldetectors();" class="link">uncheck all</a>)
						</td>
					    </tr>
					</table>
				    </td>
				</tr>
				<tr>
				    <td align=left class="text">
    				        <<:detectors:>>
				    </td>
				</tr>
		    	    </table>
			</td>
		    </tr>
		    <tr>
			<td align=right>
			    <table border=0 cellspacing=0 cellpadding=0 width=100%>
				<tr>
				    <td valign=bottom nowrap>
					&nbsp;&nbsp;Time interval selection : <a href="javascript:void(0)" onclick="nd(); pickDate(this, document.getElementById('min'), 'min');" onmouseover="return overlib('Select start date');" onmouseout="return nd();"><img src="/img/cal.gif" border=0 hspace=2 vspace=2 align="center"></a>
				    </td>
				    <td valign=bottom nowrap>
					<input type="text" name="interval_date_low" id="min" value="<<:time_low:>>"  size="15" class="input_text">
					&nbsp;&nbsp;-&nbsp;&nbsp;
				    </td>
				    <td valign=bottom nowrap>
					<a href="javascript: void(0);" onclick="nd(); pickDate(this, document.getElementById('max'), 'max');" onmouseover="return overlib('Select end date');" onmouseout="return nd();"><img src="/img/cal.gif" border=0 hspace=2 vspace=2 align="center"></a>
				    </td>
				    <td valign=bottom nowrap>
					<input type="text" name="interval_date_high" id="max" value="<<:time_high:>>" size=15 class="input_text">
				    </td>

				    <td align=center width=50% nowrap>
					<input type=hidden name=prevrun value="<<:run:>>">
					Run number: <input type=text name=run value="<<:run:>>" class="input_text">
				    </td>				    

				    <td align=center width=50% nowrap>
					Try number: <select name=count class="input_select" onChange="document.form1.submit();">
					    <option value=-1>- All -</option>
					    <<:sel_count:>>
					</select>
				    </td>
				    
				    <td align=right>
					<input type=submit name="submit_plot" value="Plot" class="input_submit">
				    </td>
				</tr>
			    </table>
			</td>
		    </tr>
		</table>
	    </td>
	</tr>
    </table>

<<:continut:>>
<br>
<<:map:>>
<img src="display?image=<<:image:>>" usemap="#<<:image:>>" border=0>

</form>
