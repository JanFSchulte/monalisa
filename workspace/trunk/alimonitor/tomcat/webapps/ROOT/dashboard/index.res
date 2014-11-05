<form name="form1" action="/dashboard/" method=POST>
    <input type=hidden name="tab" value="0">
</form>

<script type="text/javascript">
    var intervalTimes = new Array();
    var intervalNames = new Array();
    
    intervalTimes[0] = 3600000;
    intervalNames[0] = '1 hour';
    
    intervalTimes[1] = 21600000;
    intervalNames[1] = '6 hours';
    
    intervalTimes[2] = 43200000;
    intervalNames[2] = '12 hours';
    
    intervalTimes[3] = 86400000;
    intervalNames[3] = '1 day';

    intervalTimes[4] = 172800000;
    intervalNames[4] = '2 days';
    
    intervalTimes[5] = 604800000;
    intervalNames[5] = '1 week';

    var defaultTab = <<:tab:>>;
    
    var chartWidth = 300;
    var chartHeight = 240;
    
    var tabDefName = new Array();
    var tabDefURL = new Array();
    
    var tabDefCounter = 0;
    
    function registerTab(name, url){
	tabDefName[tabDefCounter] = name;
	tabDefURL[tabDefCounter] = url;
	
	tabDefCounter ++;
    }
    
    function runDetails(run){
	overlib('<iframe src="/raw/rawrun_details.jsp?run='+run+'" border=0 width=100% height=230 frameborder=0 marginwidth=0 marginheight=0 scrolling=no align=absmiddle vspace=0 hspace=0></iframe>');
    }

</script>

<table class=text cellspacing=10>
    <tr>
	<td align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:registrationsummary:>>
	</td>
	<td align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:registration:>>
	</td>
	<td align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:castor2x:>>
	</td>
    </tr>
    <tr>
	<td width=350 align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:shuttle:>>
	</td>
	<td width=300 align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:ftd:>>
	</td>
	<td width=300 align=left valign=top style="border: solid 1px #C0D5FF">
	    <<:ses:>>
	</td>
    </tr>
</table>

<script type="text/javascript">

function changeTab(modifier, baseURL, id){
    objById('chart'+modifier).src = baseURL + intervalTimes[id];

    for (i=0; i<intervalTimes.size(); i++){
	var x=objById('tab'+modifier+i);

	if (i==id){
	    x.bgColor='#6A86D0';
	    x.style.color='#FAFF96';
	    x.style.fontWeight='bold';
	    x.style.border = "1px #A1A1A1 solid";
	}
	else{
	    x.bgColor='#E6E6FF';
	    x.style.color='#000000';
	    x.style.fontWeight='normal';
	    x.style.border = "0px #A1A1A1 solid";
	}
    }
}

function changeTabs(id){
    if (id<0 || id>=intervalTimes.size())
	id = 0;

    for (iTab=0; iTab<tabDefCounter; iTab++){
	try{
	    changeTab(tabDefName[iTab], tabDefURL[iTab], id);
	}
	catch (e){
	    alert(i+' - '+e);
	}
    }
    
    document.form1.tab.value=id;
}

changeTabs(defaultTab);

</script>
