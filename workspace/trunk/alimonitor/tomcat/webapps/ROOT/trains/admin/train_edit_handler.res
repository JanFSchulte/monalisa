<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type=text/javascript>
function check_submit()
{
  if (objById("name").value.length < 5)
  {
    alert("Please provide a name of at least 5 characters.");
    return false;
  }
  return true;
}
</script>
</head>
<body>
<form name=form1>
<input type="hidden" name="train_id" value="<<:train_id db esc:>>">
<input type="hidden" name="old_name" value="<<:old_name esc:>>">
<input type="hidden" name="op" value="1">
<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
	<td>Handler name</td>
	<td>
	    <<:com_edit_start:>><input type=text size=20 id="name" name="handler_name" value="<<:handler_name db esc:>>" class=input_text><<:com_edit_end:>>
	    <<:!com_edit_start:>><<:handler_name db esc:>><<:!com_edit_end:>>
	    <a class=link  href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains#handler" target="_blank">Click here for documentation<a/>
	</td>
    </tr>
    <tr>
	<td>Macro path</td>
	<td>
	    <<:com_edit_start:>>
	      <input type=text size=50 name="macro_path" value="<<:macro_path db esc:>>" class=input_text><br>
	      Example: ANALYSIS/macros/train/AddESDHandler.C
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	      <<:macro_path db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Macro parameters</td>
	<td>
	    <<:com_edit_start:>>
		<input type=text size=50 name="parameters" value="<<:parameters db esc:>>" class=input_text><br>
		Example: kTRUE, "param"
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:parameters db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Macro body</td>
	<td>
	    <<:com_edit_start:>>
		<textarea rows=10 cols=50 class=input_textarea name="macro_body"><<:macro_body db esc:>></textarea><br>
		Note: you get access to the created handler by using the variable <i>handler</i>. <br>Do not forget the semicolon (;) at the end of the lines.
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<pre><<:macro_body db esc:>></pre>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <<:com_edit_start:>>
    <tr>
	<td>Copy from other handler</td>
	<td colspan=3>
	    <select name=copyhandler class=input_select>
		<option value=''>- no copy -</option>
		<<:copy_list:>>
	    </select>
	    <input type=submit name=submit value="Copy" class=input_submit>
	    WARNING: This overwrites all settings in the current entry.
	</td>
    </tr>
    <tr>
	<td></td>
	<td><input type=submit name=submit value="Submit &raquo;" class=input_submit onClick="return check_submit();"></td>
    </tr>
    <<:com_edit_end:>>
</table>
</form>

</body>
</html>
