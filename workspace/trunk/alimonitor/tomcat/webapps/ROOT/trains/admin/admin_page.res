<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type=text/javascript>

function check_insert()
   {
var newName=objById("train_name").value;
   if(newName==''){
     alert('Type a new train name first.');
     return false;
   }
  if (newName.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in train name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }
  if (objById("train_id").value.match(/[^0-9]/))
  {
    alert("Invalid characters in train_id. Only numbers (0-9) are allowed.");
    return false;
  }
  if (objById("train_debuglevel").value.match(/[^0-9]/))
  {
    alert("Invalid characters in train_debuglevel. Only numbers (0-9) are allowed.");
    return false;
  }
  if (objById("train_type").value.match(/[^0-1]/))
  {
    alert("Invalid characters in train_type. Only 0 or 1 are allowed.");
    return false;
  }
 
   return true;
}
function check_change()
   {
var train=objById("trains").value;
var newName=objById("train_name").value;
   if(train==''){
     alert('Choose a train to change the settings.');
     return false;
   }
  if (newName.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in train name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }
  if (objById("train_id").value.match(/[^0-9]/))
  {
    alert("Invalid characters in train_id. Only numbers (0-9) are allowed.");
    return false;
  }
  if (objById("train_debuglevel").value.match(/[^0-9]/))
  {
    alert("Invalid characters in train_debuglevel. Only numbers (0-9) are allowed.");
    return false;
  }
  if (objById("train_type").value.match(/[^0-1]/))
  {
    alert("Invalid characters in train_type. Only 0 or 1 are allowed.");
    return false;
  }

   return true;
}

function confirmDelete(){
   return confirm('This page already contains results from a previous test. If you change settings and save, or start another test, the previous results are discarded. Are you sure?');
}

function train_selected()
{
  var train_selected=objById("trains").value;
  var train_info='<<:train_info:>>';
  var trains = train_info.split(";");

  for(i = 0; i < trains.length; i++){
     var train_setting = trains[i].split("|");
     if(train_selected==train_setting[1]){
        objById("train_id").value = train_setting[0];
        objById("train_id_show").value = train_setting[0];
	objById("train_name").value = train_setting[1];
	objById("train_type").value = train_setting[2];
        objById("train_debuglevel").value = train_setting[3];
        objById("excludefiles").value = train_setting[4];
        objById("additionalpackages").value = train_setting[5];
        objById("outputfiles").value = train_setting[6];
        objById("train_operator").value = train_setting[7];
        objById("wg_no").value = train_setting[8];
     }
  }

return true;
}
</script>
</head>
<body>

<form name=form2 method=post>
  <table border=0 cellspacing=0 cellpadding=3 class=text>
    <tr>
      <td>Trains</td>
      <td valign=center>
	<select name=trains id=trains class=input_select size=10 onChange="train_selected();">
	  <<:opt_trains:>>
	</select>
	<input disabled type=submit name=submit value="Delete &raquo;" class=input_submit onClick="return confirm('This delets the chosen train. Are you sure?')">
      </td>
    </tr>
    <tr>
      <td>train_id</td>
      <td>
	<input disabled type=text name=train_id_show id=train_id_show size=80 class=input_text>
	<input type=hidden name=train_id id=train_id>
      </td>
    </tr>
    <tr>
      <td>train_name</td>
      <td>
	<input type=text name=train_name id=train_name size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>train_type</td>
      <td>
	<input type=text name=train_type id=train_type size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>train_debuglevel</td>
      <td>
	<input type=text name=train_debuglevel id=train_debuglevel size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>excludefiles</td>
      <td>
	<input type=text name=excludefiles id=excludefiles size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>additionalpackages</td>
      <td>
	<input type=text name=additionalpackages id=additionalpackages size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>outputfiles</td>
      <td>
	<input type=text name=outputfiles id=outputfiles size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>wg_no</td>
      <td>
	<select name=wg_no id=wg_no class=input_select>
	  <<:wg_no:>>
	</select>
      </td>
    </tr>
    <tr>
      <td>train operator</td>
      <td>
	<input type=text name=train_operator id=train_operator size=80 class=input_text>
      </td>
    </tr>
    <tr>
      <td>Change train settings</td>
      <td>
	<input type=submit name=submit value="Change &raquo;" class=input_submit onClick="return check_change()">
      </td>
    </tr>
      <td>Insert new train</td>
      <td>
	<input type=submit name=submit value="Insert &raquo;" class=input_submit onClick="return check_insert()">
      </td>
    </tr>

    <tr>
      <td>Operators with at least one train</td>
      <td valign=center>
	  <<:opt_operators:>>
	</select>
      </td>
    </tr>
    <tr>
      <td>Operators which are only registered as operators</td>
      <td valign=center>
	<select name=operators2 id=operators2 class=input_select size=10>
	  <<:opt_operators2:>>
	</select>
	<input type=submit name=submit value="Remove &raquo;" class=input_submit onClick="return confirm('This removes the chosen operator from the operator list. Are you sure?')">
      </td>
    </tr>
  </table>
  
</form>
</body>
</html>
