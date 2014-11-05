<head>
<script type="text/javascript">
function setBookmark(name){
  var url = window.location.toString().split("#");
  url[0] +="#"+name;
  window.location = url[0];
  
  return true;
}
</script>
</head>

<script type=text/javascript>
var obs = {
    onClose: function(eventName, win){
        modify();
    }
};

function fitIntoScreen(max, xOry){
    var w = window,
	d = document,
	e = (d) ? d.documentElement : 0,
	g = (d && d.getElementsByTagName('body')) ? d.getElementsByTagName('body')[0] : 0,
	x = ((w) ? w.innerWidth : 0) || ((e) ? e.clientWidth : 0) || ((g) ? g.clientWidth : 0) || (max+50),
	y = ((w) ? w.innerHeight : 0) || ((e) ? e.clientHeight : 0) || ((g) ? g.clientHeight : 0) || (max+70);
	
    x -= 50;
    y -= 70;
	
    if (x > max)
      x = max;
      
    if (y > max)
      y = max;

    return (xOry == true) ? x : y;
}

function editHandler(name){
    x = fitIntoScreen(950, true);
    y = fitIntoScreen(500, false);

    showIframeWindowSize('admin/train_edit_handler.jsp?train_id=<<:train_id db esc:>>&handler_name='+escape(name), name.length>0 ? 'Editing handler <b>'+name+'</b>' : 'Creating new handler', x, y);
}

function editWagon(name){
    x = fitIntoScreen(950, true);
    y = fitIntoScreen(700, false);

    showIframeWindowSize('admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name='+escape(name), name.length>0 ? 'Editing wagon <b>'+name+'</b>' : 'Creating new wagon', x, y);
}

function editPeriod(name){
    x = fitIntoScreen(950, true);
    y = fitIntoScreen(500, false);

    showIframeWindowSize('admin/train_edit_period.jsp?train_id=<<:train_id db esc:>>&mc=<<:train_type db esc:>>&period_name='+escape(name), name.length>0 ? 'Editing dataset <b>'+name+'</b>' : 'Creating new dataset', x, y);
}

function editGroup(){
    x = fitIntoScreen(800, true);
    y = fitIntoScreen(400, false);

    showIframeWindowSize('admin/train_edit_group.jsp?train_id=<<:train_id db esc:>>', 'Editing groups', x, y);
}

function editRun(id){
    x = fitIntoScreen(950, true);
    y = fitIntoScreen(700, false);

    showIframeWindowSize('admin/train_edit_run.jsp?train_id=<<:train_id db esc:>>&id='+escape(id), id>0 ? 'Editing run <b>'+id+'</b>' : 'Creating new run', x, y);
    
// JF: not needed here, because reload is triggered by save action
//     Windows.addObserver(obs);
}

function checkCopy(){
if(objById("period_enable").value=="all datasets"){
   alert("You cannot copy from all datasets. Please choose a single dataset.");
   return false;
}

return confirm('This changes the activation status of all wagons in the choosen group. Are you sure?');

}

</script>

<form name=form1 method=post>
</form>
<form name=form2 method=post>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center colspan=2>
			<b>Analysis train : <<:train_name db esc:>></b>
		    </td>
		</tr>
		<tr>
		    <td align=left class=text>
		    	Jump to:&nbsp;&nbsp;&nbsp;<a class=link href="#handlers">Handlers</a>&nbsp;&nbsp;&nbsp;<a class=link href="#wagons">Wagons</a>&nbsp;&nbsp;&nbsp;<a class=link href="#datasets">Datasets</a>&nbsp;&nbsp;&nbsp;<a class=link href="#Configuration">Configuration</a>&nbsp;&nbsp;&nbsp;<a class=link href="#runs">Runs</a>
		    </td>
		    <td align=right class=text>
			Welcome <b><<:account:>></b> - <a class=link  href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains" target="_blank">Help<a/><br>
			(<a class=link href="/trains">back to all trains</a>)
		    </td>
		</tr>

	    </table>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=3 width=100%>
		<tr class=table_row>
		    <td valign=top align=left class=table_row>
			<b>Name</b>
		    </td>
		    <td valign=top align=left class=table_row>
			<<:train_name db esc:>> (<a class=link target="_blank" href="<<: backend_url :>>/train-workdir/PWG<<:wg_no db esc:>>/<<:train_name db esc:>>">train temporary file dir</a>)
			&nbsp;&nbsp;&nbsp;<<:com_mc_gen_start:>>MC on the fly generation train<<:com_mc_gen_end:>>
		    </td>
		</tr>
		
		<tr class=table_row>
		    <td valign=top align=left class=table_row>
			<b>PWG</b>
		    </td>
		    <td valign=top align=left class=table_row>
			<<:wg_no db esc:>>
		    </td>
		</tr>
		
		<tr class=table_row>
		    <td valign=top align=left class=table_row>
			<b>Description</b>
		    </td>
		    <td valign=top align=left class=table_row>
			<textarea rows=5 cols=50 class=input_textarea name="description" <<:!com_admin_start:>>disabled<<:!com_admin_end:>>><<:description db esc:>></textarea>
			<<:com_admin_start:>><input type=submit name=submit value="Save &raquo;" class=input_submit><<:com_admin_end:>>
		    </td>
		</tr>
		
		<tr>
		    <td valign=top align=left class=table_row>
		      <a name="handlers">
			<b>Handlers</b>
		      </a>
		      <br><br><img src="handlers_small.jpg" width=120>
		    </td>
		    <td valign=top align=right class=table_row style="padding-bottom:7px">
			<table border=0 cellspacing=0 cellpadding=2 class="table_content sortable" width=100%>
			    <tr>
				<td class=table_header_stats>
				    Name
				</td>
				<td class=table_header_stats>
				    Macro path ( parameters )
				</td>
				<td class=table_header_stats>
				    Body
				</td>
				<td class=table_header_stats>
				    Enabled
				</td>
				<td class=table_header_stats>
				    Actions
				</td>
			    </tr>
			    <<:handlers:>>
			</table>
			<<:com_admin_start:>><a href="javascript:void(0)" onClick="editHandler('')" class=link>Add new handler &raquo;</a><<:com_admin_end:>>
		    </td>
		</tr>
		
		<tr>
		    <td valign=top align=left class=table_row>
		      <a name="wagons">
			<b>Wagons</b><br><br>
		      </a>
		      <img src="wagon_small.jpg" width=120> <br> <br> <br>
		      <u>Filters:</u> <br> <br>
		      <a href="#" onClick="Set_Cookie('lastval_<<:div_showOnlyMyWagons:>>', '<<:div_showOnlyMyWagons_value:>>', 365, '/', '', ''); setBookmark('wagons'); modify(); return false;" onMouseOver="overlib('Show only my wagons.');" onMouseOut="nd()" class=link><img <<:com_check_box_myWagon_ok_start:>>src=/img/check_box.png<<:com_check_box_myWagon_ok_end:>><<:!com_check_box_myWagon_ok_start:>>src=/img/check_box_empty.png<<:!com_check_box_myWagon_ok_end:>> border=0 align=top> My wagons</a><br> <br>
		      <a href="#" onClick="Set_Cookie('lastval_<<:div_showOnlyActiveWagons:>>', '<<:div_showOnlyActiveWagons_value:>>', 365, '/', '', ''); Set_Cookie('lastval_<<:div_showOnlyActivatedWagons:>>', '0', 365, '/', '', ''); setBookmark('wagons'); modify(); return false;" onMouseOver="overlib('Show only active wagons.');" onMouseOut="nd()" class=link><img <<:com_check_box_activeWagon_ok_start:>>src=/img/check_box.png<<:com_check_box_activeWagon_ok_end:>><<:!com_check_box_activeWagon_ok_start:>>src=/img/check_box_empty.png<<:!com_check_box_activeWagon_ok_end:>> border=0 align=top> Active wagons (used in the last month or activated)</a><br><br>
		      <a href="#" onClick="Set_Cookie('lastval_<<:div_showOnlyActivatedWagons:>>', '<<:div_showOnlyActivatedWagons_value:>>', 365, '/', '', ''); Set_Cookie('lastval_<<:div_showOnlyActiveWagons:>>', '0', 365, '/', '', ''); setBookmark('wagons'); modify(); return false;" onMouseOver="overlib('Show only activated wagons.');" onMouseOut="nd()" class=link><img <<:com_check_box_activatedWagon_ok_start:>>src=/img/check_box.png<<:com_check_box_activatedWagon_ok_end:>><<:!com_check_box_activatedWagon_ok_start:>>src=/img/check_box_empty.png<<:!com_check_box_activatedWagon_ok_end:>> border=0 align=top> Activated wagons</a><br>
		      <<:com_admin_start:>><<:com_show_warning_start:>> <br> <font color=red>Changes are still executed for all wagons</font><<:com_show_warning_end:>><<:com_admin_end:>>
		    </td>
		    <td valign=top align=right class=table_row style="padding-bottom:7px">
			<table border=0 cellspacing=0 cellpadding=2 class="table_content" width=100%>
			    <tr>
				<td class=table_header_stats>
				    Name
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_owner:>>', true, 0.3); setBookmark('wagons'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_owner:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_owner:>>" style="display: none">
					Owner
				      </div>
				      <img id="<<:div_owner:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_macro_path:>>', true, 0.3); setBookmark('wagons'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_macro_path:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_macro_path:>>" style="display: none">
					Macro path
					( parameters )
				      </div>
				      <img id="<<:div_macro_path:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_dependencies:>>', true, 0.3); setBookmark('wagons'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_dependencies:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_dependencies:>>" style="display: none">
				    Dependencies
				      </div>
				      <img id="<<:div_dependencies:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
       				</td>
        			    <<:wagonHeader:>>
				<td class=table_header_stats>
				    Last test
				</td>
				<td class=table_header_stats>
				    Last run
				</td>
				<td class=table_header_stats>
				</td>
			    </tr>
			    <<:wagons:>>
			</table>
			<br>
			<div style="float:right;" align=left>
			    <input type=submit name=submit value="Update wagon status &raquo;" class=input_submit><br><br>
			    <a href="javascript:void(0)" onClick="editWagon('');" class=link>Add new wagon &raquo;</a><br>
			</div>
			<<:com_admin_start:>>
			  <div style="float:left;" align=left>
			    <div style="border-style:solid; border-width:1px;" align=left>
			      <b>Advanced enabling/disabling of wagons:</b>
			      <table border=0>
				<tr>
				  <td valign=bottom>
				    Dataset:<br>
				    <select name=period_enable id=period_enable class=input_select>
				      <<:opt_period:>>
				    </select><br>
				    <input type=submit name=submit onclick="return confirm('This enables all wagons for the chosen dataset. Are you sure?');" value="Enable all &raquo;" class=input_submit>
				    <input type=submit name=submit onclick="return confirm('This disables all wagons for the chosen dataset. Are you sure?');" value="Disable all &raquo;" class=input_submit><br>
				  </td>
				  <td valign=bottom>
				    Comma-separated list of wagons:<br>
				    <textarea rows=1 cols=40 class=input_textarea name=wagonNames><<:wagonNames esc:>></textarea> 
				  </td>
				  <td valign=bottom>
				    <input type=submit name=submit value="Enable &raquo;" class=input_submit><br>
				    <input type=submit name=submit value="Disable &raquo;" class=input_submit>
				  </td>
				</tr>
				<tr>
				  <td colspan=3>
				    <hr>
				  </td>
				</tr>
				<tr valign=bottom>
				  <td colspan=2>
				    Copy activation status of the wagons from the above selected dataset to<br>
				    <select name=period_copy_to id=period_copy_to class=input_select>
				      <option value="">-- select target dataset --</option>
				      <<:opt_period_copy_to:>>
				    </select>
				    <input type=submit name=submit onclick="return checkCopy()" value="Copy &raquo;" class=input_submit>
				  </td>
				  <td>
				  </td>
				</tr>
			      </table>
			    </div>
			    <br>
			    <input type=submit name=submit value="Group Management &raquo;" onClick="editGroup(''); return false;" class=input_submit>			    
			  </div>
			<<:com_admin_end:>>
		    </td>
		</tr>

		<tr>
		    <td valign=top align=left class=table_row>
		      <a name="datasets">
			<b>Datasets</b><br><br>
		      </a>
		      <img src="coal_small.jpg" width=120>
		      <u>Filters:</u> <br> <br>
		      <a href="#" onClick="Set_Cookie('lastval_<<:div_showOnlyActivatedDatasets:>>', '<<:div_showOnlyActivatedDatasets_value:>>', 365, '/', '', ''); Set_Cookie('lastval_<<:div_showOnlyActiveDatasets:>>', '0', 365, '/', '', ''); setBookmark('datasets'); modify(); return false;" onMouseOver="overlib('Show only activated datasets.');" onMouseOut="nd()" class=link><img <<:com_check_box_activatedDataset_ok_start:>>src=/img/check_box.png<<:com_check_box_activatedDataset_ok_end:>><<:!com_check_box_activatedDataset_ok_start:>>src=/img/check_box_empty.png<<:!com_check_box_activatedDataset_ok_end:>> border=0 align=top> Activated datasets</a><br>
		    </td>
		    <td valign=top align=right class=table_row style="padding-bottom:7px">
			<table border=0 cellspacing=0 cellpadding=2 class="table_content sortable" width=100%>
			    <tr>
				<td class=table_header_stats>
				    Dataset name
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_refprod_dataset:>>', true, 0.3); setBookmark('datasets'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_refprod_dataset:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_refprod_dataset:>>" style="display: none">
					Reference production
				      </div> 
				      <img id="<<:div_refprod_dataset:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_runlist_dataset:>>', true, 0.3); setBookmark('datasets'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_runlist_dataset:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_runlist_dataset:>>" style="display: none">
					Run list
				      </div> 
				      <img id="<<:div_runlist_dataset:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_global_variables_dataset:>>', true, 0.3); setBookmark('datasets'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_global_variables_dataset:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_global_variables_dataset:>>" style="display: none">
					Global variables
				      </div> 
				      <img id="<<:div_global_variables_dataset:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				  <span onclick="switchDiv('<<:div_desc_dataset:>>', true, 0.3); setBookmark('datasets'); modify();"><a accesskey="s" onclick="switchDiv('<<:div_desc_dataset:>>', true, 0.3);" href="javascript:void(0);" class="menu_link">
				      <div id="<<:div_desc_dataset:>>" style="display: none">
					Description
				      </div> 
				      <img id="<<:div_desc_dataset:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
				</td>
				<td class=table_header_stats>
				    Enabled
				</td>
				<td class=table_header_stats>
				    Last analyzed
				</td>
				<td class=table_header_stats>
				    Actions
				</td>
			    </tr>
			    <<:periods:>>
			</table>
			<<:com_admin_start:>><a href="javascript:void(0)" onClick="editPeriod('');" class=link><<:!com_mc_gen_start:>>Add new dataset &raquo;<<:!com_mc_gen_end:>><<:com_mc_gen_start:>>Add MC Generator &raquo;<<:com_mc_gen_end:>></a><<:com_admin_end:>>
		    </td>
		</tr>
		
		<tr>
		    <td valign=top align=left class=table_row>
		      <a name="Configuration">
			<b>Configuration</b><br><br>
		      </a>
		      <img src="weiche_small.jpg" width=120>
		    </td>
		    <td valign=top align=left class=table_row style="padding-bottom:7px">
		      <table>
			<tr>
			  <td>DebugLevel</td>
			  <td>
			      <input type=text size=10 name=train_debuglevel value="<<:train_debuglevel db esc:>>" class=input_text <<:!com_admin_start:>>disabled<<:!com_admin_end:>>>
			  </td>
			</tr>
			<tr>
			  <td>Exclude files from saving</td>
			  <td>
			      <input type=text size=40 name=excludefiles value="<<:excludefiles db esc:>>" class=input_text <<:!com_admin_start:>>disabled<<:!com_admin_end:>>>
			  </td>
			</tr>
			<tr>
			  <td>Additional packages</td>
			  <td><table style="border-collapse: collapse;"><tr><td>
			      <input type=text size=40 name=additionalpackages value="<<:additionalpackages db esc:>>" class=input_text <<:!com_admin_start:>>disabled<<:!com_admin_end:>>>
			      </td><td>
			      Space-separated list of <a href="http://alimonitor.cern.ch/packages/" target="_blank">Grid packages</a>, e.g. boost::v1_43_0. AliROOT, ROOT and Geant3 do <b>not</b> have to be put here!
			      </td></tr></table>
			  </td>
			</tr>
			<tr>
			  <td>Global variables</td>
			  <td><table style="border-collapse: collapse;"><tr><td>
			      <textarea rows=<<:rows_globalVariables:>> cols=50 class=input_textarea name="globalvariables" <<:!com_admin_start:>>disabled<<:!com_admin_end:>>><<:globalvariables db esc:>></textarea>
			      </td><td>This field allows to define global variables which can be used by all tasks. A functionality of AliAnalysisManager is used for this purpose. Example:<br>
			      <i>AliAnalysisManager::SetGlobalDbl("kTrackEtaCut",0.9);</i></td></tr></table>
			  </td>
			</tr>
			<tr>
			  <td>Global libraries</td>
			  <td><table style="border-collapse: collapse;"><tr><td>
			      <textarea rows=3 cols=50 class=input_textarea name="globallibraries" <<:!com_admin_start:>>disabled<<:!com_admin_end:>> onkeypress="if(event.keyCode==13){return false;}"><<:globallibraries db esc:>></textarea>
			      </td><td>This field allows to define global libraries  which are loaded by all wagons. Note: separate libraries with comma (,) and do not specify lib in front. <br>
Example: CORRFW,EMCALUtils 
			      </td></tr></table>
			  </td>
			</tr>
			<tr>
			  <td>Output files</td>
			  <td><table style="border-collapse: collapse;"><tr><td>
			      <input type=text size=40 name=outputfiles value="<<:outputfiles db esc:>>" class=input_text <<:!com_admin_start:>>disabled<<:!com_admin_end:>>>
			      </td><td>
			      Comma-separated list of output files which can be chosen for the wagons.<br>
			      <b>IMPORTANT: Please only add output files if absolutely needed.</b> It is recommend to keep everything in one file to reduce the number of entries in the File Catalog and the SEs.
			      </td></tr></table>
			  </td>
			</tr>
			<tr>
			  <td></td><td>
			    <<:com_admin_start:>><input type=submit name=submit value="Save &raquo;" class=input_submit><<:com_admin_end:>>
			  </td>
			</tr>
		      </table>
		    </td>
		</tr>

		<tr>
		    <td valign=top align=left class=table_row>
		      <a name="runs">
			<b>Runs</b><br><br>
		      </a>
		      <img src="fulltrain_small.jpg" width=120>
		    </td>
		    <td valign=top align=right class=table_row style="padding-bottom:7px">
			<table border=0 cellspacing=0 cellpadding=2 class="table_content sortable" width=100%>
			    <thead>
			    <tr>
				<td>
				    <<:com_prevpage_start:>>
					<a class=link href="<<:bookmark esc:>>&offset=<<:prevoffset:>>#runs">&laquo; Previous &laquo;</a>
				    <<:com_prevpage_end:>>
				</td>
				<td colspan=4></td>
				<td>
				    <<:com_nextpage_start:>>
					<a class=link href="<<:bookmark esc:>>&offset=<<:nextoffset:>>#runs">&raquo; Next &raquo;</a>
				    <<:com_nextpage_end:>>
				</td>
			    </tr>
			    <tr>
				<td class=table_header_stats>
				</td>
				<td class=table_header_stats>
				    AliRoot version
				</td>
				<td class=table_header_stats>
				    Dataset
				</td>
				<td class=table_header_stats>
				    Train status
				</td>
				<td class=table_header_stats>
				    Comment
				</td>
				<td class=table_header_stats>
				    Actions
				</td>
			    </tr>
			    </thead>
			    <tbody>
			    <<:runs:>>
			    </tbody>
			    <tfoot>
			    <tr>
				<td>
				    <<:com_prevpage_start:>>
					<a class=link href="<<:bookmark esc:>>&offset=<<:prevoffset:>>#runs">&laquo; Previous &laquo;</a>
				    <<:com_prevpage_end:>>
				</td>
				<td colspan=4></td>
				<td>
				    <<:com_nextpage_start:>>
					<a class=link href="<<:bookmark esc:>>&offset=<<:nextoffset:>>#runs">&raquo; Next &raquo;</a>
				    <<:com_nextpage_end:>>
				</td>
			    </tr>
			    </tfoot>
			</table>
			<<:com_admin_start:>><a href="javascript:void(0)" onClick="editRun(0);" class=link>Start new run &raquo;</a><<:com_admin_end:>>
		    </td>
		</tr>
            </table>
        </td>
    </tr>
</table>
</form>
<script type="text/javascript">
  if(<<:no_cookie_owner:>>){
     switchDiv('<<:div_owner:>>', true, 0.3);
  }
  if(<<:no_cookie_dependencies:>>){
     switchDiv('<<:div_dependencies:>>', true, 0.3);
  }
  if(<<:no_cookie_refprod_dataset:>>){
     switchDiv('<<:div_refprod_dataset:>>', true, 0.3);
  }
  if(<<:no_cookie_runlist_dataset:>>){
     switchDiv('<<:div_runlist_dataset:>>', true, 0.3);
  }
  if(<<:no_cookie_desc_dataset:>>){
     switchDiv('<<:div_desc_dataset:>>', true, 0.3);
  }

  checkDivs([<<:div_check:>>]);
</script>
