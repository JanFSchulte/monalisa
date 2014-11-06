<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/window/prototype.js"></script>
<script type="text/javascript" src="/js/window/effects.js"></script>
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>
</head>
<body>
<form name=form_kill action="train_kill.jsp?train_id=<<:train_id db esc:>>&id=<<:id db esc:>>" method="POST">
</form>
<form name=form1>
<input type="hidden" name="train_id" value="<<:train_id db esc:>>">
<input type="hidden" name="id" value="<<:id db esc:>>">
<input type="hidden" name="show_slow_run_because_dataset" id="show_slow_run_because_dataset" value="<<:show_slow_run_because_dataset:>>">
<script type=text/javascript>
    function reload(){
	window.location = "train_edit_run.jsp?train_id=<<:train_id db esc:>>&id=<<:id db esc:>>&random="+Math.random();
    }

    function change_checkbox(op){
	window.location = "train_edit_run.jsp?train_id=<<:train_id db esc:>>&id=<<:id db esc:>>&op="+op;
    }
    
    function confirmRetest(){
	if (<<:confirm_condition:>>){
	    return confirm('This page already contains results from a previous test. If you change settings and save, or start another test, the previous results are discarded. Are you sure?');
	}
	
	return true;
    }

    function confirmStopTest(){
	if (<<:confirm_condition:>>){
	    return confirm('Testing will stop after the current wagon test. Are you sure to abort the current test?');
	}
	
	return true;
    }

    function onChangeAction(){
	if (<<:confirm_condition:>>){
	    if (objById("start_running"))
		objById("start_running").style.visibility = 'hidden';
	}

	return true;
    }

    //~ function onChangeGcc(sel){
		//~ document.getElementById('Farbbereich').style.backgroundColor = sel;
		//~ String fileName = "/opt/home/train-workdir/test.txt";
		//~ File f2 = new File(fileName);
		//~ if (!f2.exists())
		//~ f2.createNewFile();		
		//~ Runtime.getRuntime().exec("cd /opt/home/train-workdir ; ls -la > test.txt");
		//~ ProcessBuilder pb =  new ProcessBuilder("/bin/sh", "-c", "cd /opt/home/train-workdir; ls > /myfolder/logs/myscript.log");
		//~ pb.start();
		//~ PrintWriter pw = new PrintWriter(new FileOutputStream("/opt/home/train-workdir/file.txt"));// save file
		//~ pw.println(sel.val);
		//~ pw.close(); 		
		//~ FileWriter w;
	    //~ w = new FileWriter("/opt/home/train-workdir/"+System.currentTimeMillis());
	    //~ w.write(sel+"\n");
	    //~ w.flush();
	    //~ w.close(); 		
		//~ return true;
	//~ }


    function activateDerivedData(){
        onChangeAction();

        if(objById("derived_data").checked)
	   objById("slow_run_span").style.display = '';
        else if(objById("show_slow_run_because_dataset").value == 0)
           objById("slow_run_span").style.display = 'none';

        return true;
    }

    function changeWagons(){
	onChangeAction();
	
 	var periods_enabled = objById("periods");
	var period = periods_enabled.value;

	var period_wagons = document.getElementById("wagons");
	period_wagons.options.length = 0;
	periods_enabled.options.length = 0;

	var wagon_names_array='<<:period_wagon:>>';

	var periods = wagon_names_array.split(";");

	for(i = 0; i < periods.length; i++){
	    var wagon_names = periods[i].split(",");
 	    if(period==wagon_names[0]){
		periods_enabled.options[periods_enabled.options.length] = new Option(wagon_names[0], wagon_names[0], false, true);
		if(wagon_names[1]==200){
		    objById("slow_run_span").style.display = '';
		    objById("show_slow_run_because_dataset").value = 1;
		}else if(objById("derived_data").checked){
		    objById("slow_run_span").style.display = '';
		    objById("show_slow_run_because_dataset").value = 0;
                }else{
		    objById("slow_run_span").style.display = 'none';
		    objById("show_slow_run_because_dataset").value = 0;
                }

		for(j = 2; j < wagon_names.length; j++){
		    period_wagons.options[period_wagons.options.length] = new Option(wagon_names[j], wagon_names[j], false, true);
		}
	    }else if(wagon_names[0]!=""){
                periods_enabled.options[periods_enabled.options.length] = new Option(wagon_names[0]);
	    }
	}
	return true;
    }

    function confirmFinalMerge(){
	if (confirm('This submits a final merge job which merges all runs from this production. This can only be submitted once. Only those runs which have finished merging will be merged. You can check the list using the link <merging progress>.\n\nAre you sure you want to submit the job?') != true)
	  return false;

	objById("finalmerge").disabled = true;

	return true;
    }
    
    function sortlist()
    {
	var cl = objById("wagons")
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
    
    <<:reload:>>
</script>

<table border=0 cellspacing=0 cellpadding=2 class=text>
    <tr>
	<td>CMSSW version</td>
	<td colspan=3>
	    <<:com_edit_start:>>
<!--
	    <select name="ver_gcc" class=input_select  onChange="onChangeAction();">
		 <option value=" slc6_amd64_gcc472">slc6_amd64_gcc472</option>
		 <option value=" slc6_amd64_gcc480">slc6_amd64_gcc480</option>
		 <option value=" slc6_amd64_gcc481">slc6_amd64_gcc481</option>
		 <option value=" slc6_amd64_gcc490">slc6_amd64_gcc490</option>
-->
<!--
		  <option value="transparent">unsichtbar</option>
		  <option value="red">rot</option>
	      <option value="lime">grün</option>
          <option value="blue">blau</option>
-->
<!--
	    </select>
-->
<!--
	    
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	    <input type=hidden name="ver_gcc" value="<<:ver_gcc db esc:>>"><<:ver_gc db esc:>>
	    <<:!com_edit_end:>>		
	    <<:com_edit_start:>>
-->
	    <select name="ver_aliroot" class=input_select  onChange="onChangeAction();"><<:opt_aliroot_ver:>></select>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	    <input type=hidden name="ver_aliroot" value="<<:ver_aliroot db esc:>>"><<:ver_aliroot db esc:>>
	    <<:!com_edit_end:>>
	    <a class=link  href="https://twiki.cern.ch/twiki/bin/viewauth/ALICE/AnalysisTrains#testing" target="_blank">Click here for documentation</a>
	</td>
    </tr>
<!--
    <div id="Farbbereich" style="background-color:red;height:100px;width:100px;">&nbsp;</div>
-->
    <tr>
	<td>Datasets</td>
	<td>
	    <<:com_edit_start:>>
	    <select name=periods id=periods class=input_select size=10 onChange="changeWagons();">
		<<:opt_periods:>>
	    </select>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	    <<:periods_not_edit:>>
	    <<:!com_edit_end:>>
	</td>
	<td>
	  Wagons<<:com_edit_start:>> <br>(Select more<br>than one by<br>pressing <i>CTRL</i>)<br><a href='javascript:sortlist();'>Sort alphabetically</a><<:com_edit_end:>></td>
	<td>
	    <<:com_edit_start:>>
	    <select name=wagons id=wagons class=input_select multiple size=10 onChange="onChangeAction();">
		<<:opt_wagons:>>
	    </select>
	    <<:com_edit_end:>>
	    <<:!com_edit_start:>>
	    <<:wagons_not_edit:>>
	    <<:!com_edit_end:>>
	</td>
    </tr>
    <tr>
      <td>Settings</td>
      <td>
	<input type="checkbox" <<:com_edit_start:>>name="splitAll"<<:com_edit_end:>> value="1" onChange="onChangeAction();" onMouseOver="overlib('If enabled, all jobs are submitted within the same masterjob. The train is faster but the results are not available per run.');" onMouseOut="nd();" <<:com_splitAll_start:>>checked<<:com_splitAll_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> Skip processing per run
	<<:!com_edit_start:>><<:com_splitAll_start:>><input type="hidden" name="splitAll" value="1"><<:com_splitAll_end:>><<:!com_edit_end:>>
      </td>
      <td>
	<input type="checkbox" <<:com_edit_start:>>name="derived_data" id="derived_data"<<:com_edit_end:>> value="1" onChange="activateDerivedData();" onMouseOver="overlib('If enabled, this train produces derived data to be used for further analysis. The results will not be merged and can be used as input for future train runs.');" onMouseOut="nd();" <<:com_derived_data_start:>>checked<<:com_derived_data_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> Derived data production
	<<:!com_edit_start:>><<:com_derived_data_start:>><input type="hidden" name="derived_data" value="1"><<:com_derived_data_end:>><<:!com_edit_end:>>
	<span <<:!com_show_slow_run_start:>> style="display:none;" <<:!com_show_slow_run_end:>> id=slow_run_span>
	<input type="checkbox" name="slow_run" value="1" onChange="onChangeAction();" onMouseOver="overlib('If enabled, all jobs will finish. No jobs will be traded in for finishing the train run faster.');" onMouseOut="nd();" <<:com_slow_run_start:>>checked<<:com_slow_run_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> Slow train run
	</span>
      </td>
      <td>
	<<:com_show_no_clean_up_start:>>
	<input type="checkbox" name="no_clean_up" value="1" onChange="change_checkbox(1);" onMouseOver="overlib('If enabled, the intermediate output of this train run is kept and not deleted after 2 months.');" onMouseOut="nd();" <<:com_no_clean_up_start:>>checked<<:com_no_clean_up_end:>> <<:!com_admin_start:>>disabled<<:!com_admin_end:>>> Keep longer than 2 months
	<<:com_show_no_clean_up_end:>>
      </td>
    </tr>
    <tr>
      <td>Operator</td>
      <td>
	<<:operator_created db esc:>>
      </td>
    </tr>
    <tr>
	<td></td>
	<td colspan=3>
	    <<:com_edit_start:>>
	    <input type=submit name=submit onclick="return confirmRetest();" value="Save &raquo;" class=input_submit>
	    <input id="start_testing_button" type=submit name=submit onclick="return confirmRetest();" value="Start test &raquo;" class=input_submit>
	    <input id="start_fast_testing_button" type=submit name=submit onclick="return confirmRetest();" value="Start fast test &raquo;" class=input_submit>
	    <<:com_edit_end:>>
	    <<:com_stoptest_start:>>
	    <input id="stop_testing_button" type=submit name=submit onclick="return confirmStopTest()" value="Stop test &raquo;" class=input_submit>
	    <<:com_stoptest_end:>>
	    <<:com_show_clone_start:>>
	    <input type=submit name=submit value="Clone &raquo;" class=input_submit>
	    <input type=submit name=submit value="Clone &amp; enable wagons &raquo;" class=input_submit>
	    <<:com_show_clone_end:>>
	    <<:com_run_start:>>
	    <input type=submit id=start_running name=submit onclick="return confirm('This starts a full Grid production cycle for the given runs. Are you sure?');" value="Start running &raquo;" class=input_submit>
	    <<:com_run_end:>>
	    <<:com_kill_start:>>
	    <input type=button id=kill_button name=kill_button value="Kill train &raquo;" onclick="if (confirm('This KILLS all jobs in this train which are not yet in a final stage. This operation can take several minutes. Please wait patiently. Are you sure?')) { objById('kill_button').disabled = true; clearTimeout(autoReloadTimeout); document.form_kill.submit(); }" class=input_submit>
	    <<:com_kill_end:>>
	    <<:com_email_test_start:>>
	    <input type=submit name=submit value="Mail test results &raquo;" class=input_submit>
	    <<:com_email_test_end:>>
	    <<:com_email_run_start:>>
	    <input type=submit name=submit value="Mail train status &raquo;" class=input_submit>
	    <<:com_email_run_end:>>
	</td>
    </tr>
    <tr>
	<td>Comment</td>
	<td colspan=3>
	  <textarea rows=2 cols=50 class=input_textarea name="comment" onKeyPress="clearTimeout(autoReloadTimeout);" <<:!com_admin_start:>>disabled<<:!com_admin_end:>>><<:comment db esc:>></textarea>
	  <<:com_show_update_comment_start:>><input type=submit name=submit value="Update only comment field" class=input_submit><<:com_show_update_comment_end:>>
	</td>
    </tr>
    <<:com_test_status_start:>>
    <tr>
	<td>Test</td>
	<td colspan=3>Status: <b><<:test_status:>></b> <br> Tag: <<:test_path db esc:>> <<:com_show_test_events_start:>><br> <<:numberTestEvents:>> <<:com_show_test_events_end:>> <br> <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>/tests.log">testing output log<a/> | <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>">testing output dir</a> | <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>/config/MLTrainDefinition.cfg">wagon configuration<a/>
	</td>
    </tr>
    <<:com_test_status_end:>>
    <<:com_results_start:>>
    <tr>
	<td colspan=4>
	    <table border=0 cellspacing=0 cellpadding=1 class="table_content_stats" width=100%>
	    <tr><td align=center class=table_title><span onclick="switchDiv('div_testresults', true, 0.3);"><a accesskey="t" onclick="switchDiv('div_testresults', true, 0.3);" href="javascript:void(0);" class=menu_link><font class=text><b><u>T</u>est Results</b><img id="div_testresults_img" <<:!com_run_status_start:>> src="/img/dynamic/minus.jpg" <<:!com_run_status_end:>> <<:com_run_status_start:>> src="/img/dynamic/plus.jpg" <<:com_run_status_end:>> width="9" height="9" border="0"></a></span></font></td><tr>
	    
	    <tr><td>
	    <div id="div_testresults" <<:com_run_status_start:>> style="display: none;" <<:com_run_status_end:>>><div>
	    <table border=0 cellspacing=0 cellpadding=2 class=text>
		<tr class="table_header">
		    <td rowspan=2 class="table_header_stats">Wagon</td>
		    <td rowspan=2 class="table_header_stats">Status</td>
		    <td colspan=5 class="table_header_stats">Memory</td>
		    <td colspan=1 rowspan=2 class="table_header_stats">Output size</td>
		    <td colspan=4 class="table_header_stats">Timing</td>
		    <td rowspan=2 class="table_header_stats">Merging</td>
		</tr>
		<tr class="table_header_stats">
		    <td class="table_header_stats" colspan=2>Virtual</td>
		    <td class="table_header_stats">Virt. &Delta;</td>
		    <td class="table_header_stats">Resident</td>
		    <td class="table_header_stats">RSS &Delta;</td>
		    <td class="table_header_stats">Wall</td>
		    <td class="table_header_stats">Wall &Delta;</td>
		    <td class="table_header_stats">CPU</td>
		    <td class="table_header_stats">CPU &Delta;</td>
		</tr>
		<<:content:>>
	    </table>
	    </div></div>
	    </td></tr></table>
	</td>
    </tr>
    <<:com_results_end:>>
    <<:com_run_status_start:>>
    <tr>
	<td colspan=4>
	    <table border=0 cellspacing=0 cellpadding=1 class="table_content_stats">
	    <tr><td align=center class=table_header><font class=text><b>Train Run</b> (<a class=link target="_blank" href="/prod/?prod_type=PWG<<:wg_no db enc:>>&jt_field1=<<:jt_field1 enc:>>">PWG train overview</a>)</font></td><tr>
	    <tr><td>
	    <table border=0 cellspacing=0 cellpadding=2 class=text>
	      <tr><td class="table_row_stats"><b>Status</td>
		<td class="table_row_stats" width=380>Running triggered on <<:run_start db nicedate:>> <<:run_start db time:>> (<<:run_start_ago:>> ago)<br>
		<b><<:lpm_status:>>, masterjobs submitted: <<:lpm_submitted:>>, last run: <<:lpm_lastrun:>></b>
	      </td>
	      <td class="table_row_stats" rowspan=6 align=center>
		<<:com_statistics_start:>>
                <IFRAME frameborder="0"  
			style="width: 360; height: 280; border: margin: 0px; overflow-y: hidden; overflow-x: hidden;"  
			src="./running_time.jsp?lpm_id=<<:train_lpm_id:>>">
                </IFRAME>  
		<<:com_statistics_end:>>
	      </td>
	      </tr>
	      <tr><td class="table_row_stats"><b>Files</td>
		<td class="table_row_stats"><<:copying_stats:>> | <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>/generator.log">file copying log<a/> | 
		<a class=link target="_blank" href="/catalogue/?path=/alice/cern.ch/user/a/alitrain/<<:test_path db esc:>>">train files in FC</a>
	      </td></tr>
	      <tr><td class="table_row_stats"><a href="train_gantt.jsp?train_id=<<:train_id db esc:>>&id=<<:id db esc:>>" target=_blank class=link><b>Processing</b></a></td>
		<td class="table_row_stats">
			    <<:com_run_links_start:>>
<<:!com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:job_types_id:>>&outputdir=<<:test_path db enc:>>$">processing progress</a><br> 
<<:!com_mc_gen_end:>>
<<:com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:job_types_id:>>&outputdir=<<:test_path db enc:>>">processing progress</a><br> 
<<:com_mc_gen_end:>>
			    <<:processing_jobstats:>>
			    <<:com_run_links_end:>>
			    &nbsp;
		</td></tr>
	      <<:!com_derived_data_start:>>
	      <tr><td class="table_row_stats"><b>Merging</td>
		<td class="table_row_stats">
			    <<:com_run_links_start:>>
<<:!com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:final_merging_job_types_id:>>&outputdir=<<:test_path db enc:>>$"> merging progress</a>: 
<<:!com_mc_gen_end:>>
<<:com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:final_merging_job_types_id:>>&outputdir=<<:test_path db enc:>>"> merging progress</a>: 
<<:com_mc_gen_end:>>
   			    <<:merging5_jobstats:>><br>
			    intermediate merging: 
<<:!com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging1_job_types_id:>>&outputdir=<<:test_path db enc:>>/Stage_1">stage1</a> (<<:merging1_jobstats:>>)
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging2_job_types_id:>>&outputdir=<<:test_path db enc:>>/Stage_2">stage2</a> (<<:merging2_jobstats:>>)<br>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging3_job_types_id:>>&outputdir=<<:test_path db enc:>>/Stage_3">stage3</a> (<<:merging3_jobstats:>>)
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging4_job_types_id:>>&outputdir=<<:test_path db enc:>>/Stage_4">stage4</a> (<<:merging4_jobstats:>>)
<<:!com_mc_gen_end:>>
<<:com_mc_gen_start:>>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging1_job_types_id:>>&outputdir=<<:test_path db enc:>>">stage1</a> (<<:merging1_jobstats:>>)
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging2_job_types_id:>>&outputdir=<<:test_path db enc:>>">stage2</a> (<<:merging2_jobstats:>>)<br>
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging3_job_types_id:>>&outputdir=<<:test_path db enc:>>">stage3</a> (<<:merging3_jobstats:>>)
			    <a class=link target="_blank" href="/prod/jobs.jsp?t=<<:merging4_job_types_id:>>&outputdir=<<:test_path db enc:>>">stage4</a> (<<:merging4_jobstats:>>)
<<:com_mc_gen_end:>>
			    <<:com_run_links_end:>>
			    &nbsp;
		</td></tr>
	      <tr><td class="table_row_stats"><b>Final Merging</td>
		<td class="table_row_stats">
		  <<:com_final_merge_start:>>
		  <<:!com_deleted_start:>>
		  </form>
		  <form name=form2 action="train_submit_final_merging.jsp?train_id=<<:train_id db esc:>>&id=<<:id db esc:>>" method="POST" onSubmit="return confirmFinalMerge();">
		  <input type=submit id=finalmerge name=finalmerge value="Submit final merge job &raquo;" class=input_submit>
		  </form>
		  <form>
		  <<:!com_deleted_end:>>
		  <<:com_deleted_start:>>
		  <b>Intermediate output deleted (after 2 months)</b>
		  <<:com_deleted_end:>>
		  <<:com_final_merge_end:>>
		  <<:com_final_merge_job_start:>>
		  <<:final_merging_runlists:>>
		  AliEn Output dir: <a class=link target="_blank" href="/catalogue/?path=/alice/cern.ch/user/a/alitrain/<<:test_path db:>><<:merge_dir:>>">/alice/cern.ch/user/a/alitrain/<<:test_path db:>><<:merge_dir:>></a><br>
		  <<:com_final_merge_job_end:>>
		</td></tr>
                <<:!com_derived_data_end:>>
		<<:com_derived_data_start:>>
		  <tr></tr><tr></tr>
		<<:com_derived_data_end:>>
		 <tr><td class="table_row_stats"><b>Statistics</td>
		   <td class="table_row_stats">
		    <<:com_train_finished_start:>>
		     <b>Train run finished</b> at: <<:train_finished_timestamp db nicedate:>> <<:train_finished_timestamp db time:>> (train duration: <<:train_finished_timestamp_ago:>>)<br>
		    <<:com_train_finished_end:>>
		    <<:com_statistics_start:>>
		     <b>Totals:</b> running time: <<:wall_time:>> | output size: <<:size_output size:>> <br>
		     <b>Files/job</b> (for done jobs): min: <font color='green'> <<:files_job_min:>></font>, max: <font color='green'> <<:files_job_max:>></font>, average: <font color='green'><<:files_job_avg ddot1:>> </font>, standard deviation: <font color='green'> <<:files_job_standDev ddot1:>> </font> <br>
		     <b>Running time/job</b> (for done jobs): min: <font color='green'><<:running_time_min:>></font>, max: <font color='green'><<:running_time_max:>></font>, average: <font color='green'><<:running_time_avg:>></font>, standard deviation: <font color='green'><<:running_time_standDev:>></font>, 95% done after <font color='green'><<:running_time_95:>></font>
		    <<:com_statistics_end:>>
		    <<:!com_statistics_start:>>
		    <<:!com_train_finished_start:>>
		      No statistics available, yet
		    <<:!com_train_finished_end:>>
		    <<:!com_statistics_end:>>
		   </td>
		 </tr>
		 <<:com_admin_start:>>
		   <<:com_statistics_start:>>
		     <<:com_improvements_start:>>
		     <tr>
		       <td class="table_row_stats">
			 <b><font color='red'>Improvement<br>suggestions</font>
		       </td>
		       <td class="table_row_stats" colspan=2>
			 <<:train_improvements:>>
		       </td>
		     </tr>
		     <<:com_improvements_end:>>
		   <<:com_statistics_end:>> 
		 <<:com_admin_end:>>
	    </table>
	    </td></tr>
	    <tr><td>
	      <<:com_statistics_start:>>
	      <table width="100%">
		<tr>
		  <td valign=top>
		    <br>
		    <table border=0 cellspacing=0 cellpadding=2 class=text>
		      <tr class="table_header">
			<td colspan=8 class="table_header_stats">Job Overview</td>
		      </tr>
		      <tr class="table_header">
			<td rowspan=2 class="table_header_stats">State</td>
			<td rowspan=2 class="table_header_stats">Jobs</td>
			<td rowspan=2 class="table_header_stats">Files</td>
			<td rowspan=2 class="table_header_stats">Input size</td>
			<td colspan=3 class="table_header_stats">Files/job</td>
		      </tr>
		      <tr class="table_header_stats">
			<td class="table_header_stats">min</td>
			<td class="table_header_stats">max</td>
			<td class="table_header_stats">avg</td>
		      </tr>
		      <<:statistics_table:>>
		    </table>
		  </td>
		  <td width=10>&nbsp;</td>
		  <td align=right>
                    <IFRAME frameborder="0"  
			    style="width: 490; height: 280; border: margin: 0px; overflow-y: hidden; overflow-x: hidden;"  
			    src="./input_files.jsp?lpm_id=<<:train_lpm_id:>>">  
                    </IFRAME>  
		  </td>
		</tr>
	      </table>
	      <<:com_statistics_end:>>
 	    </td></tr>
	    </table>
	</td>
    </tr>
    <<:com_run_status_end:>>
</table>
</form>

</body>
</html>
