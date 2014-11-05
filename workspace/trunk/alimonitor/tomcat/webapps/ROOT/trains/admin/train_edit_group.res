<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>
<script type=text/javascript>

function check_insert()
   {
var newName=objById("group_name_new").value;
   if(newName==''){
     alert('Type a new group name first.');
     return false;
   }
  if (newName.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in group name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }
 
   return true;
}
function check_rename()
   {
var group=objById("groups").value;
var newName=objById("group_name_renamed").value;
   if(group==''){
     alert('Choose a group to rename.');
     return false;
   }
  if (newName.match(/[^a-zA-Z0-9_]/))
  {
    alert("Invalid characters in group name. Only alphanumerical characters (a-z, A-Z, 0-9) and underscore (_) are allowed.");
    return false;
  }
  if(newName=='Default'||newName=='Attic'){
     alert("You cannot rename a group to "+newName+" because this groups already exist.");
     return false;
   } 
   if(group=='Default'||group=='Attic'){
     var rename_ok=confirm('The group '+group+' cannot be renamed or removed. Would you like to create a new group with the name '+newName+' and move all wagons of '+group+' into this group?');
     return rename_ok;
   } 

   return true;
}
function check_delete()
   {
var group=objById("groups").value;
   if(group=='Default'||group=='Attic'){
     alert('The group '+group+' cannot be deleted.');
     return false;
   } 
   return confirm("The selected group will be deleted. Wagons in the group will be moved to the group Default. Continue?");
}

function define_group()
{
  objById("groups").value = objById("marked_group").value;
  if(objById("groups").value=='')
     objById("groups").value = 'Default';
}

function group_selected()
{
  var group_name = objById("groups").value;

  objById("group_name_renamed").value = group_name;

  var allow_auto_activate_wagons = '<<:auto_activate_wagons:>>';
  var groups = allow_auto_activate_wagons.split(";");

  var wagons = document.getElementById("wagons");
  wagons.options.length = 0;

  for(i = 0; i < groups.length; i++){
    var activated = groups[i].split(",");
    if(group_name==activated[0]){
      if(activated[1]=='true'){
	objById("allow_auto_activate_wagons").checked = true;
      }else if(activated[1]=='false'){
	objById("allow_auto_activate_wagons").checked = false;
      }
      for(j = 2; j < activated.length; j++){
         wagons.options[wagons.options.length] = new Option(activated[j], activated[j], false, true);
      }
      return true;
    }
  }
}
</script>
</head>
<body>

<form name=form2 method=post>
<input type="hidden" name="marked_group" id="marked_group" value="<<:marked_group:>>">
  <table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
      <td>Groups</td>
      <td valign=center>
	<<:com_edit_start:>>
	  <select name=groups id=groups class=input_select size=10 onChange="group_selected();">
	    <<:opt_groups:>>
	  </select>
        <<:com_edit_end:>>
	<input type=submit name=submit value="Delete Group &raquo;" class=input_submit onClick="return check_delete()"></td>
      <td valign=center>
	<<:com_edit_start:>>
	  <select name=wagons id=wagons class=input_select multiple size=10>	  </select>
      </td>
      <td>
	  <input type=submit name=submit value="Delete Wagons &raquo;" class=input_submit onclick="return confirm('This will delete all marked wagons. Are you sure?');">
	  <br> <br> <br>
	  <input type=submit name=submit value="Move Wagons &raquo;" class=input_submit> 
	  <br>to dataset
	  <select name="wagon_destination" class=input_select  onChange="onChangeAction();"><<:opt_groups:>></select>
      </td>
	<<:com_edit_end:>>
      </td>
    </tr>
    <tr>
      <td>Rename selected group</td>
      <td>
	<input type=text name=group_name_renamed id=group_name_renamed class=input_text>
	<input type=submit name=submit value="Rename &raquo;" class=input_submit onClick="return check_rename()">
      </td>
    <tr>
      <td>Insert new group</td>
      <td>
	<input type=text name=group_name_new id=group_name_new class=input_text>
	<input type=submit name=submit value="Insert &raquo;" class=input_submit onClick="return check_insert()">
      </td>
    </tr>
    <tr>
      <td colspan=3>
	  <input type="checkbox" name="allow_auto_activate_wagons" id="allow_auto_activate_wagons" value="1" onMouseOver="overlib('Wagons in this group are automatically activated if they are listed in the dependencies of another wagon which is activated.');" onMouseOut="nd();"> Allow automatic activation of wagons in this group <input type=submit name=submit value="Save &raquo;" class=input_submit onClick="return"> 
      </td>
    </tr>
  </table>
  
</form>
</body>
<script type=text/javascript>
  define_group()
  group_selected();
</script>
</html>
