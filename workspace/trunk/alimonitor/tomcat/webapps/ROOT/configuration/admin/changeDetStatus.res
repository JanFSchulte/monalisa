<html>
<head>

<script type="text/javascript" src="/overlib/overlib.js"></script>
<script type="text/javascript" src="/overlib/overlib_crossframe.js"></script>
<script type="text/javascript" src="/js/tooltips.js"></script>
<link type="text/css" rel="StyleSheet" href="/style/style.css" />

<style>
a:link,
a:active,
a:visited{
	color: #3A6C9A;
	text-decoration: none
}

a:hover{
	color: #3A6C9A;
	text-decoration: underline
}                                                
</style>

<script type="text/javascript">
    var short_text = new Array();
    var long_text = new Array();
    var html_color = new Array();
    
    <<:content:>>

    function edit(){
	var value = document.form2.newstatus.options[document.form2.newstatus.selectedIndex].value;
	
	document.form1.status.value = value;
	
	var disableEdit = false;
	
	if (value==-1000){
	    document.form1.short_text.value='';
	    document.form1.long_text.value='';
	    document.form1.html_color.value='';
	    
	    document.form2.s.disabled = true;
	}
	else{
	    document.form1.short_text.value=short_text[value];
	    document.form1.long_text.value=long_text[value];
	    document.form1.html_color.value=html_color[value];
	    
	    disableEdit = value<=1;
	
	    document.form2.s.disabled = false;
	}
	
	document.form1.short_text.disabled=disableEdit;
	document.form1.long_text.disabled=disableEdit;
	document.form1.html_color.disabled=disableEdit;
	document.form1.edit_save.disabled=disableEdit;
    }
</script>

</head>
<body class=text>
    <table border=0 cellspacing=2 cellpadding=0 class=text>
	<form name=form2>
	<input type=hidden name=det value="<<:det esc:>>">
	<input type=hidden name=run value="<<:run esc:>>">
	<input type=hidden name=pass value="<<:pass esc:>>">
	<tr>
	    <td>Run range:</td>
	    <td><input class=input_text type=text name=runrange value="<<:run esc:>>"></td>
	</tr>
	<tr>
	    <td>Configuration:</td>
	    <td><select name=newstatus class=input_select onChange="edit()">
		    <<:opt_values:>>
		    <option value=-1000>-- Create new --</option>
		</select>
	    </td>
	</tr>
	<tr>
	    <td></td>
	    <td><input type=submit name=s class=input_submit value="Update configuration"></td>
	</tr>
	</form>
	<tr>
	    <td>Editor:</td>
	    <td style="padding-top:20px">
		<form name=form1>
		<input type=hidden name=det value="<<:det esc:>>">
		<input type=hidden name=run value="<<:run esc:>>">
		<input type=hidden name=status value='0'>
		Short text: <input class=input_text type=text name=short_text><br>
		Long text: <input class=input_text type=text name=long_text><br>
		Color: <input class=input_text type=text name=html_color><br>
		<input type=submit class=input_submit name=edit_save value="Save">
	    </td>
	</tr>
    </table>
    
    <script type="text/javascript">
	edit();
    </script>
</body>
</html>
