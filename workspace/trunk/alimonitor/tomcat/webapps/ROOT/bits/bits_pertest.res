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
    document.forms[formName]['filter_state'].selectedIndex = 0;
    
    document.forms[formName].submit();
}

</script>
<table border=0 cellspacing=0 cellpadding=0>
    <tr>
	<td align=center style="padding-bottom:10px;font-family:Tahoma,Arial;font-size:16px">
	    <b>AliRoot benchmarks - per test results</b>
	</td>
    </tr>
<<:continut:>>
</table>
