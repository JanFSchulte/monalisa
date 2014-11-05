<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>
<script type=text/javascript>
function check_submit()
{
  if (objById("name").value.length < 5)
  {
    alert("Please provide a name of at least 5 characters.");
    return false;
  }
  if (objById("name").value.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in period name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }

  var highest = parseInt(objById("highest_runlist").value);
  for(i = 1; i<=highest;i++){
    var runlist = objById("runlist_"+i).value;
    if (runlist.match(/[^0-9, ]/))
    {
        alert("Invalid characters in runlist "+i+". Only numerical characters (0-9), comma (,) and the space character ( ) are allowed.");
        return false;
     }
  }

  return true;
}

function remove_runlist()
{
  var highest = parseInt(objById("highest_runlist").value);
  if(highest==1){
    alert('You cannot delete the last runlist.');
    return false;
  }
  if(!confirm('Do you really want to delete runlist '+objById("highest_runlist").value+'?')){
    return false;
  }
  old_value_list = new Array(highest);
  old_value_name = new Array(highest);
  for(i = 1; i< highest;i++){
    old_value_list[i] = objById("runlist_"+i).value;
    old_value_name[i] = objById("runlist_"+i+"_name").value;
  }

  var old = objById("period_runlists").innerHTML;
  var old_split = old.split("<br> <br>");
  var newHTML = old_split[0];

  for(i = 1; i< highest-1; i++){
    newHTML += "<br> <br>"+old_split[i];
  }
  objById("period_runlists").innerHTML = newHTML;

  objById("highest_runlist").value = highest-1;
  for(i = 1; i< highest;i++){
    objById("runlist_"+i).value = old_value_list[i];
    objById("runlist_"+i+"_name").value = old_value_name[i];
  }

  return false;
}

function add_runlist()
{
  var runlists = objById("period_runlists");
  var old = runlists.innerHTML;
  var highest = parseInt(objById("highest_runlist").value);
  old_value_list = new Array(highest);
  old_value_name = new Array(highest);
  for(i = 1; i<= highest;i++){
    old_value_list[i] = objById("runlist_"+i).value;
    old_value_name[i] = objById("runlist_"+i+"_name").value;
  }
  highest = highest + 1;
  var name = "runlist_"+highest;
  runlists.innerHTML = old + ' <br> <br>runlist name <input type=text size=20 name='+name+'_name id='+name+'_name class=input_text> <input type=checkbox name='+name+'_checkbox value=1 checked>  runlist activated <br> <td> <textarea rows=3 style="width: 450px;" class=input_textarea name='+name+' id='+name+'></textarea> </td> ';
  objById("highest_runlist").value = highest;
  for(i = 1; i< highest;i++){
    objById("runlist_"+i).value = old_value_list[i];
    objById("runlist_"+i+"_name").value = old_value_name[i];
  }

  return false;
}

function change_main_file_names()
{
  var period_refprod = document.getElementById("refprod").value;
  var period_main_file = document.getElementById("refprod_main_file");
  period_main_file.options.length = 0;

  var all_main_file_names='<<:all_main_file_names:>>';

  var main_file_names = all_main_file_names.split("||");

  for(i = 0; i < main_file_names.length; i++){
      var file_name = main_file_names[i].split("|");

      if(file_name[0]==period_refprod){
          if(file_name.length>1){
              period_main_file.options[period_main_file.options.length] = new Option(file_name[1], file_name[1], false, true);
          }
          for(var j=2; j < file_name.length; j++){
              period_main_file.options[period_main_file.options.length] = new Option(file_name[j], file_name[j], false, false);
          }
      }
  }

  var isDerivedData = period_refprod.split(":");

  if(isDerivedData[0]!="Derived Data"){
    objById("change_main_file").style.display = 'none';
    objById("aod").style.display = '';
  }else{
    objById("change_main_file").style.display = '';
    objById("aod").style.display = 'none';
  }
}

</script>
</head>
<body>
<form name=form1>
<input type="hidden" name="train_id" value="<<:train_id db esc:>>">
<input type="hidden" name="old_name" value="<<:old_name db esc:>>">
<input type="hidden" name="op" value="1">
<input type="hidden" name="highest_runlist" id="highest_runlist" value="<<:highest_runlist:>>">
<<:com_mc_gen_start:>>
  <input type="hidden" name="mc" value="1">
  <input type="hidden" name="refprod" value="__MC__">
  <input type="hidden" name="aod" value="100">
  <span class="text"><b>Note: This is a meta dataset to define MC generator settings to generate events on the fly. Please use it only with the appropriate handler.</b></span><br><br>
<<:com_mc_gen_end:>>
<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
	<td>Dataset name</td>
	<td colspan=5>
	<<:com_edit_start:>>
	    <input type=text size=20 name="period_name" id="name" value="<<:period_name db esc:>>" class=input_text>
	<<:com_edit_end:>>
	<<:!com_edit_start:>>
	    <<:period_name db esc:>>
	<<:!com_edit_end:>>
	<a class=link  href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains#dataset" target="_blank">Click here for documentation<a/>
	</td>
    </tr>
    <<:!com_mc_gen_start:>>
    <tr>
	<td>Reference production</td>
	<td colspan=5>
	<<:com_edit_start:>>
	    <select name=refprod id=refprod class=input_select onChange="change_main_file_names();">
		<<:opt_refprod:>>
	    </select>
	<<:com_edit_end:>>
	<<:!com_edit_start:>>
	    <<:refprod_no_edit:>>
	<<:!com_edit_end:>>
	</td>
    </tr>
    <tr <<:com_hide_main_file_name_start:>> style="display:none;" <<:com_hide_main_file_name_end:>> id=change_main_file>
	<td>Main file name</td>
	<td colspan=5>
	<<:com_edit_start:>>
	    <select name=refprod_main_file id=refprod_main_file class=input_select>
		<<:opt_refprod_main_file:>>
	    </select>
	<<:com_edit_end:>>
	<<:!com_edit_start:>>
	    <<:refprod_main_file_no_edit:>>
	<<:!com_edit_end:>>
	</td>
    </tr>
    <<:com_edit_start:>>
    <tr>
	<td>Apply search on reference productions</td>
	<td colspan=5>
	  <input type=text name=period_filter value="<<:period_filter esc:>>" class=input_text>
	  <input type=submit name=submit value="Search" class=input_submit>
	</td>
    </tr>
    <<:com_edit_end:>>
    <tr>
	<td>Flags</td>
	<td colspan=5>
	  <input type="checkbox" name="pp" value="1" <<:com_pp_start:>>checked<<:com_pp_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>>pp
	  &nbsp;&nbsp;&nbsp;
	  <select <<:com_hide_aod_start:>> style="display: none;" <<:com_hide_aod_end:>> name="aod" id="aod" class=input_select <<:!com_edit_start:>>disabled<<:!com_edit_end:>>>
	    <option value="0" <<:aod_0:>> >ESD (default)</option>
	    <option value="4" <<:aod_4:>> >ESD (special wSDD production)</option>
	    <option value="1" <<:aod_1:>> >AOD production</option>
	    <option value="2" <<:aod_2:>> >AOD produced together with ESD </option>
	    <option value="3" <<:aod_3:>> >Kinematics only</option>
	    <option value="5" <<:aod_5:>> >ESD cpass1 (Barrel)</option>
	    <option value="6" <<:aod_6:>> >ESD cpass1 (Outer)</option>
	  </select>
	</td>
    </tr>
    <tr>
	<<:com_edit_start:>>
	<td>Runlist</td>
	<td>
	  <input type=submit name=submit value="add Runlist" class=input_submit onClick="return add_runlist()">
	</td>
	<td>
	  <input type=submit name=submit value="remove Runlist" class=input_submit onClick="return remove_runlist()">
	</td>
	<<:com_edit_end:>>
    </tr>
	<tr>
	  <td>Run subset of the above<br>(comma separated list of runs)</td>
	  <td id="period_runlists" colspan=5> 
	    <br>
	    <<:runlist_shown:>>
	  </td> 
	</tr>
    <tr>
	<td>Selection string</td>
	<td colspan=5>
	  <<:com_edit_start:>>
	  <input type=text style="width: 320px;" name=subselection value="<<:subselection db esc:>>" class=input_text>
	  If this field is non-empty, its content is matched against the input folders of this dataset.
	  <<:com_edit_end:>>
	  <<:!com_edit_start:>>
	  <<:subselection db esc:>>
	  <<:!com_edit_end:>>
	</td>
    </tr>
    <<:!com_mc_gen_end:>>
    <<:com_mc_gen_start:>>
    <tr>
	<td>Macro path</td>
	<td colspan=5>
	    <<:com_edit_start:>>
	      <input type=text size=50 name="gen_macro_path" value="<<:gen_macro_path db esc:>>" class=input_text><br>
	      Example: ANALYSIS/macros/train/AddMCGenHijing.C
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	      <<:gen_macro_path db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Macro parameters</td>
	<td colspan=5>
	    <<:com_edit_start:>>
		<input type=text size=50 name="gen_parameters" value="<<:gen_parameters db esc:>>" class=input_text><br>
		Example: kTRUE, "param"
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:gen_parameters db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Macro body</td>
	<td colspan=5>
	    <<:com_edit_start:>>
		<textarea rows=6 cols=50 class=input_textarea name="gen_macro_body"><<:gen_macro_body db esc:>></textarea><br>
		Note: you get access to the created handler by using the variable <i>generator</i>. <br>Do not forget the semicolon (;) at the end of the lines.
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<pre><<:gen_macro_body db esc:>></pre>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <<:com_mc_gen_end:>>
    <tr>
	<td>Description</td>
	<td colspan=5>
	<<:com_edit_start:>>
	    <textarea rows=4 style="width: 320px;" class=input_textarea name="period_desc"><<:period_desc db esc:>></textarea>
	<<:com_edit_end:>>
	<<:!com_edit_start:>>
	    <<:period_desc db esc:>>
	<<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Global variables for this dataset</td>
	<td colspan=5>
	<<:com_edit_start:>>
	    <textarea rows=4 style="width: 320px;" class=input_textarea name="globalvariables_dataset"><<:globalvariables_dataset db esc:>></textarea>
	<<:com_edit_end:>>
	<<:!com_edit_start:>>
	    <<:globalvariables_dataset db esc:>>
	<<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
      <td>
	Configuration
      </td>
      <td colspan=5>
	<input type="checkbox" name="period_no_skip_processing" value="1" onMouseOver="overlib('If enabled, train runs with this dataset and the activated \'skip processing per run\' feature produce a warning. Only enable if absolutely needed.');" onMouseOut="nd();" <<:com_period_no_skip_processing_start:>>checked<<:com_period_no_skip_processing_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> train runs with this dataset cannot process several runs within the same job
      </td>
    </tr>
    <tr>
        <<:!com_mc_gen_start:>>
	  <td>Number of files to test</td>
	<<:!com_mc_gen_end:>>
	<<:com_mc_gen_start:>>
	  <td>Number of events to test</td>
	<<:com_mc_gen_end:>>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=10 name=test_files_no value="<<:test_files_no db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:test_files_no db esc:>>
	    <<:!com_edit_end:>>
	</td>
        <<:!com_mc_gen_start:>>
	  <td>SplitMaxInputFileNumber</td>
	<<:!com_mc_gen_end:>>
	<<:com_mc_gen_start:>>
	  <td>Number of events per job</td>
	<<:com_mc_gen_end:>>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=10 name=splitmaxinputfilenumber value="<<:splitmaxinputfilenumber db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:splitmaxinputfilenumber db esc:>>
	    <<:!com_edit_end:>>
	</td>
	<<:com_mc_gen_start:>>
	  <td>Total events to be generated</td>
	  <td>
	    <<:com_edit_start:>>
	    <input type=text size=10 name=gen_total_events value="<<:gen_total_events db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:gen_total_events db esc:>>
	    <<:!com_edit_end:>>
	  </td>
	<<:com_mc_gen_end:>>
    </tr>
    <tr>
	<td>MaxMergeFiles</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=10 name=maxmergefiles value="<<:maxmergefiles db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:maxmergefiles db esc:>>
	    <<:!com_edit_end:>>
	</td>
	<td>TTL</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=10 name=ttl value="<<:ttl db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:ttl db esc:>>
	    <<:!com_edit_end:>>
	    seconds
	</td>
    </tr>
    <<:!com_mc_gen_start:>>
    <tr>
      <td>Friend chain names (only for AOD)</td>
      <td>
	  <<:com_edit_start:>>
	  <input type=text size=40 name=friendchainnames value="<<:friendchainnames db esc:>>" class=input_text>
	  <<:com_edit_end:>>
	  <<:!com_edit_start:>>
	  <<:friendchainnames db esc:>>
	  <<:!com_edit_end:>>
      </td>
      <td>Libraries for friend chains</td>
      <td>
	  <<:com_edit_start:>>
	    <input type=text size=40 name=friendchain_libraries value="<<:friendchain_libraries db esc:>>" class=input_text>
	  <<:com_edit_end:>>
	  <<:!com_edit_start:>>
	  <<:friendchain_libraries db esc:>>
	  <<:!com_edit_end:>>
      </td>
      <td></td><td></td>
    </tr>
    <<:!com_mc_gen_end:>>
    <<:com_edit_start:>>
    <tr>
	<td>Copy from other dataset</td>
	<td colspan=5>
	    <select name=copyperiod class=input_select>
		<option value=''>- no copy -</option>
		<<:opt_copyperiod:>>
	    </select>
	    <input type=submit name=submit value="Copy" class=input_submit>
	    WARNING: This overwrites all settings in the current entry.
	</td>
    </tr>
    <tr>
	<td></td>
	<td colspan=5><input type=submit name=submit value="Submit &raquo;" class=input_submit onClick="return check_submit()"></td>
    </tr>
    <<:com_edit_end:>>
</table>
</form>
<br>
<<:!com_mc_gen_start:>>
<span class=text>
Run list of the above production (<font color=green>included</font>, <font color=red>excluded</font>) (link to the <a href="http://alimonitor.cern.ch/configuration/" target="_blank">RCT<a/>):<br>
<<:runlist_all:>>
</span>
<<:!com_mc_gen_end:>>
</body>
</html>
