<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<link rel="stylesheet" href="/js/grid/tabber.css" TYPE="text/css" MEDIA="screen">
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>
<script>var currentTab;</script>
<script type="text/javascript" src="/js/grid/tabber.js"></script>
<script type=text/javascript>
function check_submit()
{
  if (objById("name").value.length < 5 || objById("macro_path").value.length < 5)
  {
    alert("Please provide a name as well as macro path of at least 5 characters.");
    return false;
  }
  if (objById("name").value.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in wagon name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }

  var highest = parseInt(objById("highest_subwagon").value);
  var activated = false;
  for(i = 1; i<=highest; i++){
    var subwagon_name = objById("subwagon_"+i+"_name").value;

    if (subwagon_name.length < 1){
      alert("Please provide a name for subwagon "+i+".");
      return false;
    }

    if (subwagon_name.match(/[^a-zA-Z0-9_]/)){
      alert("Invalid characters in subwagon name "+subwagon_name+". Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
      return false;
    }

    for(j = i+1; j<=highest;j++){
      if(subwagon_name==objById("subwagon_"+j+"_name").value){
        alert("Please use different names for different subwagons.");
        return false;
      }
    }
    if(objById("subwagon_"+i+"_checkbox").checked)
      activated = true;
  }
  if(highest>0 && !activated){
    alert("Please activate at least one subwagon.");
    return false;  
  }
    
  return true;
}

function sortlist()
{
    var cl = objById("dependencies")
    var clTexts = new Array();

    for(i = 0; i < cl.length; i++)
    {
	clTexts[i] =
	    cl.options[i].text.toUpperCase() + "###" +
	    cl.options[i].text + "###" +
	    cl.options[i].value + "###" +
	    ((cl.options[i].selected) ? "1" : "0");
    }

    clTexts.sort();

    for(i = 0; i < cl.length; i++)
    {
	var parts = clTexts[i].split('###');
	
	cl.options[i].text = parts[1];
	cl.options[i].value = parts[2];
	cl.options[i].selected = (parts[3] == "1");
    }
} 

function read_subwagon(list, highest, variable, suffix, notRead)
{
  var list_index = 1;
  for(i = 1; i<= highest;i++){
    if(i!=notRead)
      list[list_index++] = objById(variable+i+suffix).value;
  }
  return list;
}

function read_subwagon_checked(list, highest, notRead)
{
  var list_index = 1;
  for(i = 1; i<= highest;i++){
    if(i!=notRead)
      list[list_index++] = objById("subwagon_"+i+"_checkbox").checked;
  }
  return list;
}

function write_subwagon(list, highest, variable, suffix)
{
  for(i = 1; i<= highest;i++){
    objById(variable+i+suffix).value = list[i];
  }
  return list;
}

function write_subwagon_checked(list, highest)
{
  for(i = 1; i<= highest;i++){
    objById("subwagon_"+i+"_checkbox").checked = list[i];
  }
  return list;
}

function add_subwagon()
{
  var wagon_list = objById("wagon_configs");
  var highest = parseInt(objById("highest_subwagon").value);

  old_value_list = new Array(highest);
  old_value_name = new Array(highest);
  old_value_checked = new Array(highest);
  old_value_list = read_subwagon(old_value_list, highest, "subwagon_", "", 0);
  old_value_name = read_subwagon(old_value_name, highest, "subwagon_", "_name", 0);
  old_value_checked = read_subwagon_checked(old_value_checked, highest, 0);

  highest = highest + 1;
  var name = "subwagon_"+highest;
  objById("highest_subwagon").value = highest;

  var new_wagon = objById("wagon_configs_copy").innerHTML;
  for(i = 1; i<=6; i++){
    new_wagon = new_wagon.replace("subwagon_0", name);
  }
  var new_wagon = new_wagon.replace("XXX", highest);
  var new_wagon = new_wagon.replace("XXX", highest);
  var new_wagon = new_wagon.replace("remove_subwagon('0')", "remove_subwagon('"+highest+"')");

  wagon_list.innerHTML += new_wagon;

  write_subwagon(old_value_list, highest-1, "subwagon_", "");
  write_subwagon(old_value_name, highest-1, "subwagon_", "_name");
  write_subwagon_checked(old_value_checked, highest-1);

  if(highest==1)
     add_subwagon();

  return false;
}


function remove_subwagon(subwagon_list_id)
{
  var highest = parseInt(objById("highest_subwagon").value);
  if(highest==0){
    alert('There is no subwagon to delete.');
    return false;
  }


  var subwagon_name = objById("subwagon_"+subwagon_list_id+"_name").value;

  if(!confirm('Do you really want to delete the subwagon '+subwagon_name+'?')){
    return false;
  }

  if(highest==1){
    objById("wagon_configs").innerHTML = ' ';
    objById("highest_subwagon").value = 0;
    return false;
  }

  old_value_list = new Array(highest);
  old_value_name = new Array(highest);
  old_value_checked = new Array(highest);
  old_value_list = read_subwagon(old_value_list, highest, "subwagon_", "", subwagon_list_id);
  old_value_name = read_subwagon(old_value_name, highest, "subwagon_", "_name", subwagon_list_id);
  old_value_checked = read_subwagon_checked(old_value_checked, highest, subwagon_list_id);



  var old = objById("wagon_configs").innerHTML;
  var old_split = old.split("<br> <br>");
  var newHTML = "";

  for(i = 0; i< highest-1; i++){
    newHTML += old_split[i]+"<br> <br>";
  }
  objById("wagon_configs").innerHTML = newHTML;
  highest = highest-1;

  objById("highest_subwagon").value = highest;
  write_subwagon(old_value_list, highest, "subwagon_", "");
  write_subwagon(old_value_name, highest, "subwagon_", "_name");
  write_subwagon_checked(old_value_checked, highest);

  return false;
}

</script>

<STYLE type="text/css">
 td { padding-bottom:1em; vertical-align:top; }
</STYLE>

</head>
<body>
<form name=form1 id=form1 method=post action="train_edit_wagon.jsp">
<input type="hidden" name="train_id" value="<<:train_id db esc:>>">
<input type="hidden" name="old_name" value="<<:old_name esc:>>">
<input type="hidden" name="op" value="1">
<input type="hidden" name="highest_subwagon" id="highest_subwagon" value="<<:highest_subwagon:>>">

<div style="float: right;">
  <a class=link href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains#wagon" target="_blank">Click here for documentation</a>
</div>

<div class="tabber" id="tab1">
<div class="tabbertab">
<h2><a name="basic"><em>Basic settings</em></a></h2>

<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
	<td>Wagon name</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=30 name="wagon_name" id="name" value="<<:wagon_name db esc:>>" class=input_text>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:wagon_name db esc:>>
	    <<:!com_edit_end:>>
	    <br>
	    NB. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) allowed.
	</td>
    </tr>
   <<:com_train_operator_start:>>
    <tr>
	<td>Wagon owner</td>
	<td>
	    <select name=wagonowner class=input_select>
		<<:wagonowner_list:>>
	    </select>
	    Only users who have a wagon in some train are displayed.
	</td>
    </tr>
    <<:com_train_operator_end:>>
    <<:com_edit_start:>>
    <tr>
	<td>Wagon group</td>
	<td>
	    <select name=wagongroup class=input_select>
		<<:wagongroup_list:>>
	    </select>
	</td>
    </tr>
    <<:com_edit_end:>>
    <tr>
	<td>Macro path</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=100 name="macro_path" id = "macro_path" value="<<:macro_path db esc:>>" class=input_text><br>
	    Example: PWG4/macros/AddTaskPhiCorrelations.C
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:macro_path db esc:>>
	    <<:!com_edit_end:>>
	    <br>
	    <input type="checkbox" name="addtask_needs_alien" value="1" <<:com_addtask_needs_alien_start:>>checked<<:com_addtask_needs_alien_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> AddTask macro needs AliEn connection
	</td>
    </tr>
    <tr>
	<td>Macro parameters</td>
	<td>
	    <<:com_edit_start:>>
	      <textarea rows=<<:number_rows_parameters:>> cols=98 class=input_textarea name="parameters" onkeypress="if(event.keyCode==13){return false;}"><<:parameters db esc:>> </textarea><br>
	    Example: kTRUE, "param"
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:parameters db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Macro customization<br><br>
	<<:com_has_subwagons_start:>><b>Subwagons are<br>activated!</b><<:com_has_subwagons_end:>></td>
	<td>
	    <<:com_edit_start:>>
		<textarea rows=4 cols=98 class=input_textarea name="macro_body"><<:macro_body db esc:>></textarea><br>
		Note: you get access to the created task by using the variable <i>__R_ADDTASK__</i>. <br>
		Do not forget the semicolon (;) at the end of the lines.<br>
		Example: __R_ADDTASK__->SelectCollisionCandidates(AliVEvent::kAnyINT);
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<textarea rows=4 cols=98 class=input_textarea name="macro_body" disabled><<:macro_body db esc:>></textarea><br>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Libraries</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=100 name="libraries" value="<<:libraries db esc:>>" class=input_text><br>
	    Note: separate libraries with comma (,); do not specify <i>lib</i> in front<br>
	    Example: CORRFW,EMCALUtils
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:libraries db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
</table>

</div>
<div class="tabbertab">
<h2><a name="advanced"><em>Advanced settings</em></a></h2>

<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
	<td>Dependencies<<:com_edit_start:>><br>(Select more than one<br> by pressing <i>CTRL</i>)<br><a href='javascript:sortlist();'>Sort alphabetically</a><<:com_edit_end:>></td>
	<td>
	    <<:com_edit_start:>>
	    <select name=dependencies id=dependencies multiple size=10 class=input_select>
		<<:dependencies_opt:>>
	    </select>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:dependencies db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
	<td>Output file</td>
	<td>
	    <<:com_edit_start:>>
	    <select name=outputfile size=4 class=input_select>
		<<:outputfile_opt:>>
	    </select>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:outputfile db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
      <td>
	Configuration
      </td>
      <td colspan=2>
	<input type="checkbox" name="wagon_no_skip_processing" value="1" onMouseOver="overlib('If enabled, train runs with this wagon and the activated \'skip processing per run\' feature produce a warning. Only enable if absolutely needed. If in doubt contact the train operator.');" onMouseOut="nd();" <<:com_wagon_no_skip_processing_start:>>checked<<:com_wagon_no_skip_processing_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> This wagon cannot process several runs within the same job
      </td>
    </tr>
    <tr>
	<td>Terminate File</td>
	<td>
	    <<:com_edit_start:>>
	    <input type=text size=70 name="terminatefile" value="<<:terminatefile db esc:>>" class=input_text><br>
	    Only needed when files are produced in Terminate()<br>
	    Example: event_stat.root
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
		<<:terminatefile db esc:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <<:com_edit_start:>>
    <tr>
	<td>Copy from other wagon</td>
	<td colspan=3>
	    <select name=copywagon class=input_select>
		<option value=''>- no copy -</option>
		<option value='showmywagons'>- show only my wagons - &nbsp;&nbsp;&nbsp; press copy --&gt;</option>
		<option value='showallwagons'>- show wagons from all trains - &nbsp;&nbsp;&nbsp; press copy --&gt;</option>
		<<:copy_list:>>
	    </select>
	    <input type=submit name=submit value="Copy" class=input_submit>
	    WARNING: This overwrites all settings in the current entry.
	</td>
    </tr>
    <<:com_edit_end:>>
</table>

</div>
<div class="tabbertab">
<h2><a name="subwagon"><em>Subwagon configuration</em></a></h2>

<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
      <td>
	<b>You can run this wagon with multiple differenct configurations. For each subwagon, one wagon is created in the train. The customizations below are individually attached to the macro customization. <font color="red">Important</font>: Your AddTask macro must support this, i.e. the last parameter of your AddTask macro must be a suffix to the output container name. Please click <a href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains#user_subwagon">here</a> for more information.</b>
      </td>
    </tr>
    <tr>
	<<:com_edit_start:>>
	<td>
	  <input type=submit name=submit value="Add subwagon" class=input_submit onClick="return add_subwagon()">
	  <br> 
	</td>
	<<:com_edit_end:>>
    </tr>
    <tr>
      <td id="wagon_configs">
	<<:wagon_configurations:>>
      </td> 
      <td id="wagon_configs_copy" style="display:none">
	<<:wagon_configurations_copy:>>
      </td> 
    </tr>
</table>

</div>
<div class="tabbertab">
<h2><a name="statistics"><em>Testing statistics</em></a></h2>

  <IFRAME frameborder="0"  
	  style="width: 380; height: 430; border: margin: 0px; overflow-y: hidden; overflow-x: hidden;"  
	  src="./train_edit_wagon_statistics.jsp?train_id=<<:field_train_id:>>&wagon_name=<<:field_wagon_name:>>">
  </IFRAME>  

</div>
</div>

<br>

<<:com_edit_start:>>
<div align="center">
  <input type=submit name=submit value="Submit &raquo;" class=input_submit onClick="return check_submit();">
</div>
<<:com_edit_end:>>


</form>

</body>
</html>
