<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript">

var alsoCheck = new Array();

<<:alsocheck:>>

/** Find out the form element that has a given value */
function getElementByValue(value){
    var frm = document.form1.elements;
    
    for (idx in frm){
	element = frm[idx];
	
	if (element.value==value){
	    return element;
	}
    }
    
    return null;
}

/** Look in the alsoCheck array for package dependencies and check/uncheck them too */
function checkDeps(chkbox){
    if (alsoCheck[chkbox.id] && alsoCheck[chkbox.id].length){
	platform = chkbox.value.split(" ")[2];
    
	for (i=0; i<alsoCheck[chkbox.id].length; i++){
	    obj = getElementByValue(alsoCheck[chkbox.id][i]+" "+platform);
	    
	    if (obj){
		obj.checked = chkbox.checked;
		
		checkDeps(obj);
	    }
	}
    }
}

/** Check all the elements on one line */
function checkAll(chkbox){
  try{
    var checked = chkbox.checked;

    var frm = document.form1.elements;
    
    for (idx in frm){
	element = frm[idx];
	
	if (element.id==chkbox.value){
	    element.checked = checked;
	    
	    checkDeps(element);
	}
    }    
  }
  catch (ex){
    alert(ex);
  }
}
</script>
<table border=0 cellspacing=0 cellpadding=0 width=100%><tr><td align=center valign=top>
<form name="form1" action="packageinstall.jsp" method=POST onSubmit="return confirm('Are you sure you want to do this?');">
<table cellspacing=0 cellpadding=2 border=0 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Install packages</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header" rowspan=2 width=150><b>Package name</b></td>
		    <td class="table_header" colspan=<<:platforms_count:>>><b>Platforms</b></td>
		    <td class="table_header" rowspan=2 width=60><b>Install all</b></td>
		    <td class="table_header" rowspan=2 width=60><b>Email</b></td>
		</tr>
		<tr height=25>
		    <<:platforms:>>
		</tr>
		<<:continut:>>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=right>
	    <input type="submit" name="submit" value="Install selected packages" class="input_submit">
	</td>
    </tr>
</table>
</form>
</td>
<td align=center valign=top>
<form name="form2" action="packageinstall.jsp" method=POST onSubmit="return confirm('Are you sure you want to do this?');">
<input type=hidden name="isremove" value="true">
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Remove installed packages</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 width=100%>
		<tr height=25>
		    <td class="table_header" width=150><b>Package name</b></td>
		    <td class="table_header" width=60><b>Remove</b></td>
		</tr>
		<<:installedvo:>>
		<<:installed:>>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=right>
	    <input type="submit" name="submit" value="Remove selected packages" class="input_submit">
	</td>
    </tr>
</table>
</form>

</td></tr></table>
