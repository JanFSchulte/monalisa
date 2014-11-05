<<:refresh_time=600:>>
<<:alternates=External links: <a class="link" href="http://alienbuild.cern.ch:8889/" target="_blank"><u>AliRoot Build System</u></a>:>>
<script type="text/javascript">

function setSelectOption(form, selectName, value){
    var select = form[selectName];

    if (selectName=='filter_state'){
	value = value.indexOf('>OK<')>0 ? '1' : '0';
    }

    for (i=0; i<select.options.length; i++){
	if (select.options[i].value==value){
	    select.selectedIndex = i;
	    form.submit();
	    break;
	}
    }
    return false;
}

function resetForm(formName){
    document.forms[formName]['filter_date'].selectedIndex = 0;
    document.forms[formName]['filter_state'].selectedIndex = 0;
    document.forms[formName]['filter_os'].selectedIndex = 0;
    document.forms[formName]['filter_arch'].selectedIndex = 0;
    
    try{
	document.forms[formName]['filter_release'].selectedIndex = 0;
    }
    catch (ex){
	document.forms[formName]['filter_build_version'].selectedIndex = 0;
    }
    
    document.forms[formName].submit();
}

function showChart(testname, testkey, parameter){
    nd();

    testkey = testkey.substring(0, testkey.lastIndexOf('.'));

    sHTML = testname+' : '+testkey+'<br>'+
	    '<iframe src="/bits/bits_chart.jsp?testname='+testname+'&testkey='+testkey+'&parameter='+parameter+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="no" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';

    showCenteredWindow(sHTML, parameter);
    
    return false;
}

</script>
<br>

<table border=0 cellspacing=0 cellpadding=0><tr><td>
<<:builds:>>

<<:com_benchmarks_start:>>
<table border=0 cellspacing=0 cellpadding=0>
    <tr>
	<td align=center style="padding-bottom:10px;font-family:Tahoma,Arial;font-size:16px">
	    <b>AliRoot benchmarks</b>
	</td>
    </tr>
<<:continut:>>
</table>
<<:com_benchmarks_end:>>
</td></tr></table>
