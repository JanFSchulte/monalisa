<script type="text/javascript">
function showRuns(){
    showCenteredWindow('<<:runlist esc js:>>', 'Selected runs');
}

<<:com_authenticated_start:>>
var obs = {
    onClose: function(eventName, win){
        modify();
    }
};

function editStatus(run, det){
    nd();
    
    showIframeWindow('admin/changeDetStatus.jsp?run='+escape(run)+'&det='+escape(det), 'Change configuration of <b>'+det.toUpperCase()+'</b> for run# <b>'+run+'</b>');
    
    Windows.addObserver(obs);
}

function editStatusPerPass(run, det){
    nd();
    
    showIframeWindow('admin/changeDetStatus.jsp?run='+escape(run)+'&det='+escape(det)+'&pass=<<:pass:>>', 'Change configuration of <b>'+det.toUpperCase()+'</b> for run# <b>'+run+'</b>, pass <B><<:pass:>></B>');
    
    Windows.addObserver(obs);
}

function editField(field, run){
    nd();
    
    showIframeWindow('admin/changeField.jsp?run='+escape(run)+'&field='+escape(field), 'Change <b>'+field+'</b> of run# <b>'+run+'</b>');
    
    Windows.addObserver(obs);    
}

function editFieldPerPass(field, run){
    nd();
    
    showIframeWindow('admin/changeField.jsp?run='+escape(run)+'&field='+escape(field)+'&pass=<<:pass:>>', 'Change <b>'+field+'</b> of run# <b>'+run+'</b>, pass <B><<:pass:>></B>');
    
    Windows.addObserver(obs);    
}

function saveXML(file_type){
    showIframeWindow('admin/saveXML.jsp?runlist='+escape('<<:runlist2 js:>>')+'&type='+escape(file_type), 'Creating XML collection, please wait');
}

<<:com_authenticated_end:>>
<<:!com_authenticated_start:>>
function editStatus(run, det){
    return false;
}
function editStatusPerPass(run, det){
    return false;
}
function editField(field, run){
    return false;
}
function editFieldPerPass(field, run){
    return false;
}
<<:!com_authenticated_end:>>
</script>

<form name="form1" action="index.jsp" method=GET>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" width="100%">
    <tr>
	<td class="table_title"><b>Run Condition Table</b></td>
    </tr>
    <tr>
	<td align=right valign=bottom>
	    <<:!com_authenticated_start:>>
		<a class=link href="https://alimonitor.cern.ch<<:bookmark:>>">Login</a>
	    <<:!com_authenticated_end:>>
	    <<:com_authenticated_start:>>
		Welcome <b><<:account:>></b>
	    <<:com_authenticated_end:>>
	</td>
    </tr>
    <tr>
	<td align=right>
	    <a href="javascript:void(0);" onClick="JavaScript:window.open('/doc/index.jsp?page=configuration_index', 'docwindow', 'toolbar=0,width=600,height=400,scrollbars=1,resizable=1,titlebar=1'); return false;" class="link" style="cursor:help;font-size:12px">How to select runs <img src="/img/qm.gif" border=0></a>
	</td>
    </tr>

    <tr>
	<td valign="top">
	    <table border=0 cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<tr class="table_header">
		    <td class="table_header">
			<select name=partition class=input_select onChange='modify()'>
			    <<:opt_partitions:>>
			</select>
		    </td>
	            <td class="table_header" colspan=6>Beam</td>
	            <td class="table_header" colspan=3>Bunches</td>
	            <td class="table_header" colspan=8>Triggers</td>
	            <td class="table_header" colspan=3>Quality 
	        	<select class=input_select name=pass onChange=modify()>
	        	    <option value=1 <<:pass_1:>>>Pass 1</option>
	        	    <option value=2 <<:pass_2:>>>Pass 2</option>
	        	    <option value=3 <<:pass_3:>>>Pass 3</option>
	        	    <option value=4 <<:pass_4:>>>Pass 4</option>
	        	</select>
	            </td>
	            <td class="table_header" colspan=20>Detectors configuration</td>
	            <td class="table_header"><input type=submit name=s class=input_submit value="&raquo;"></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.raw_run.value)" onMouseOut="nd()" onClick="nd()" onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=raw_run value="<<:raw_run esc:>>"></td>

	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.filling_scheme.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text style="width:100%" name=filling_scheme value="<<:filling_scheme esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.filling_config.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text style="width:100%" name=filling_config value="<<:filling_config esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.fillno.value)" onMouseOut="nd()"onClick="nd()" class=input_text onFocus="focusText(this, 100);" onBlur="blurText(this);"  style="width:100%" name=fillno value="<<:fillno esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.energy.value)" onMouseOut="nd()"onClick="nd()" class=input_text onFocus="focusText(this, 100);" onBlur="blurText(this);"  style="width:100%" name=energy value="<<:energy esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.intensity_per_bunch.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=intensity_per_bunch value="<<:intensity_per_bunch esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.mu.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=mu value="<<:mu esc:>>"></td>
	            
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.interacting_bunches.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=interacting_bunches value="<<:interacting_bunches esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.noninteracting_bunches_beam_1.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=noninteracting_bunches_beam_1 value="<<:noninteracting_bunches_beam_1 esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.noninteracting_bunches_beam_2.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=noninteracting_bunches_beam_2 value="<<:noninteracting_bunches_beam_2 esc:>>"></td>
	            
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.interaction_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=interaction_trigger value="<<:interaction_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.rate.value)" onMouseOut="nd()"onClick="nd()" class=input_text onFocus="focusText(this, 100);" onBlur="blurText(this);"  style="width:100%" name=rate value="<<:rate esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.beam_empty_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=beam_empty_trigger value="<<:beam_empty_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.empty_empty_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=empty_empty_trigger value="<<:empty_empty_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.muon_trigger.value)" onMouseOut="nd()"onClick="nd()"  onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text style="width:100%" name=muon_trigger value="<<:muon_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.high_multiplicity_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=high_multiplicity_trigger value="<<:high_multiplicity_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.emcal_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=emcal_trigger value="<<:emcal_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.calibration_trigger.value)" onMouseOut="nd()"onClick="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text style="width:100%" name=calibration_trigger value="<<:calibration_trigger esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.quality.value)" onMouseOut="nd()"onClick="nd()" class=input_text  onFocus="focusText(this, 100);" onBlur="blurText(this);"  style="width:100%" name=quality value="<<:quality esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.muon_quality.value)" onMouseOut="nd()"onClick="nd()" class=input_text  onFocus="focusText(this, 100);" onBlur="blurText(this);"  style="width:100%" name=muon_quality value="<<:muon_quality esc:>>"></td>
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.comment.value)" onMouseOut="nd()"onClick="nd()"  onFocus="focusText(this, 150);" onBlur="blurText(this);" class=input_text style="width:100%" name=comment value="<<:comment esc:>>"></td>
	            
	            <td class="table_header"><input onMouseOver="overlibnz(document.form1.field.value)" onMouseOut="nd()" onClick="nd()"  onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text style="width:100%" name=field value="<<:field esc:>>"></td>

		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_aco.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_aco value="<<:det_aco esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_emc.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_emc value="<<:det_emc esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_fmd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_fmd value="<<:det_fmd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_hlt.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_hlt value="<<:det_hlt esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_hmp.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_hmp value="<<:det_hmp esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_mch.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_mch value="<<:det_mch esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_mtr.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_mtr value="<<:det_mtr esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_phs.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_phs value="<<:det_phs esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_pmd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_pmd value="<<:det_pmd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_spd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_spd value="<<:det_spd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_sdd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_sdd value="<<:det_sdd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_ssd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_ssd value="<<:det_ssd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_tof.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_tof value="<<:det_tof esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_tpc.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_tpc value="<<:det_tpc esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_trd.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_trd value="<<:det_trd esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_t00.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_t00 value="<<:det_t00 esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_v00.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_v00 value="<<:det_v00 esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_zdc.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=det_zdc value="<<:det_zdc esc:>>"></td>
		    <td class="table_header"><input onMouseOver="overlibnz(document.form1.det_zdc.value)" onMouseOut="nd()" onFocus="focusText(this, 100);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=hlt_mode value="<<:hlt_mode esc:>>"></td>
		    
		    <td class="table_header"><input onMouseOver="overlib('Time intervals in epoch seconds');" onFocus="focusText(this, 200);" onBlur="blurText(this);" onClick="nd()" class=input_text style="width:100%" name=changedon value="<<:changedon esc:>>"></td>
		</tr>
		<tr class="table_header">
		    <td class="table_header">Run#</td>

	            <td class="table_header">Bunches</td>
	            <td class="table_header">Scheme</td>
	            <td class="table_header">Fill #</td>
	            <td class="table_header">Energy per beam</td>
	            <td class="table_header">Intensity per bunch</td>
	            <td class="table_header" onMouseOver="overlib('Average number of visible pp interactions per bunch crossing');" onMouseOut="nd()">Mu</td>
	            
	            <td class="table_header" onMouseOver="overlib('Interacting Bunches');" onMouseOut="nd()">B&nbsp;B</td>
	            <td class="table_header" onMouseOver="overlib('Non Interacting Bunches Beam 1');" onMouseOut="nd()">B&nbsp;A</td>
	            <td class="table_header" onMouseOver="overlib('Non Interacting Bunches Beam 2');" onMouseOut="nd()">B&nbsp;C</td>
	            
	            <td class="table_header">MB Interaction</td>
	            <td class="table_header">Rate (Hz)</td>
	            <td class="table_header">MB Beam-Empty</td>
	            <td class="table_header">MB Empty-Empty</td>
	            <td class="table_header">Muon Interaction</td>
	            <td class="table_header">High multiplicity trigger</td>
	            <td class="table_header">EMCAL</td>
	            <td class="table_header">Calibration</td>
	            <td class="table_header">Global quality</td>
	            <td class="table_header">Muon quality</td>
	            <td class="table_header">Comment</td>
	            
	            <td class="table_header">Field</td>
	            
	            <td class="table_header">A<br>C<br>O</td>
	            <td class="table_header">E<br>M<br>C</td>
	            <td class="table_header">F<br>M<br>D</td>
	            <td class="table_header">H<br>L<br>T</td>
	            <td class="table_header">H<br>M<br>P</td>
	            <td class="table_header">M<br>C<br>H</td>
	            <td class="table_header">M<br>T<br>R</td>
	            <td class="table_header">P<br>H<br>S</td>
	            <td class="table_header">P<br>M<br>D</td>
	            <td class="table_header">S<br>P<br>D</td>
	            <td class="table_header">S<br>D<br>D</td>
	            <td class="table_header">S<br>S<br>D</td>
	            <td class="table_header">T<br>O<br>F</td>
	            <td class="table_header">T<br>P<br>C</td>
	            <td class="table_header">T<br>R<br>D</td>
	            <td class="table_header">T<br>0<br>0</td>
	            <td class="table_header">V<br>0<br>0</td>
	            <td class="table_header">Z<br>D<br>C</td>

	            <td class="table_header">HLT<br>mode</td>
	            
	            <td class="table_header">Last change</td>
		</tr>
		</thead>
		
		<tbody>
		<<:content:>>
		</tbody>
	
		<tfoot>
		<tr class="table_header">
		    <td class="table_header" onMouseOver="overlib('<<:raw_run_count esc js:>> runs');" onMouseOut="nd()"><<:raw_run_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:filling_scheme_stats esc js:>>')" onClick="showCenteredWindow('<<:filling_scheme_stats esc js:>>', 'Filling scheme');" onMouseOut="nd()"><<:filling_scheme_count esc:>></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"></td>
	            <td class="table_header"><<:sum_interaction_trigger ddot:>></td>
	            <td class="table_header"><<:sum_rate ddot:>></td>
	            <td class="table_header"><<:sum_beam_empty_trigger ddot:>></td>
	            <td class="table_header"><<:sum_empty_empty_trigger ddot:>></td>
	            <td class="table_header"><<:sum_muon_trigger ddot:>></td>
	            <td class="table_header"><<:sum_high_multiplicity_trigger ddot:>></td>
	            <td class="table_header"><<:sum_emcal_trigger ddot:>></td>
	            <td class="table_header"><<:sum_calibration_trigger ddot:>></td>
	            
	            <td class="table_header" onMouseOver="overlibnz('<<:quality_stats esc js:>>')" onClick="showCenteredWindow('<<:quality_stats esc js:>>', 'Global quality');" onMouseOut="nd()"><<:quality_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:muon_quality_stats esc js:>>')" onClick="showCenteredWindow('<<:muon_quality_stats esc js:>>', 'Muon quality');" onMouseOut="nd()"><<:muon_quality_count esc:>></td>
	            <td class="table_header"></td>

		    <td class="table_header" onMouseOver="overlibnz('<<:field_stats esc js:>>')" onClick="showCenteredWindow('<<:field_stats esc js:>>', 'Field');" onMouseOut="nd()"><<:field_count esc:>></td>
	            
	            <td class="table_header" onMouseOver="overlibnz('<<:aco_stats esc js:>>')" onClick="showCenteredWindow('<<:aco_stats esc js:>>', 'ACO');" onMouseOut="nd()"><<:aco_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:emc_stats esc js:>>')" onClick="showCenteredWindow('<<:emc_stats esc js:>>', 'EMC');" onMouseOut="nd()"><<:emc_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:fmd_stats esc js:>>')" onClick="showCenteredWindow('<<:fmd_stats esc js:>>', 'FMD');" onMouseOut="nd()"><<:fmd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:hlt_stats esc js:>>')" onClick="showCenteredWindow('<<:hlt_stats esc js:>>', 'HLT');" onMouseOut="nd()"><<:hlt_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:hmp_stats esc js:>>')" onClick="showCenteredWindow('<<:hmp_stats esc js:>>', 'HMP');" onMouseOut="nd()"><<:hmp_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:mch_stats esc js:>>')" onClick="showCenteredWindow('<<:mch_stats esc js:>>', 'MCH');" onMouseOut="nd()"><<:mch_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:mtr_stats esc js:>>')" onClick="showCenteredWindow('<<:mtr_stats esc js:>>', 'MTR');" onMouseOut="nd()"><<:mtr_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:phs_stats esc js:>>')" onClick="showCenteredWindow('<<:phs_stats esc js:>>', 'PHS');" onMouseOut="nd()"><<:phs_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:pmd_stats esc js:>>')" onClick="showCenteredWindow('<<:pmd_stats esc js:>>', 'PMD');" onMouseOut="nd()"><<:pmd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:spd_stats esc js:>>')" onClick="showCenteredWindow('<<:spd_stats esc js:>>', 'SPD');" onMouseOut="nd()"><<:spd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:sdd_stats esc js:>>')" onClick="showCenteredWindow('<<:sdd_stats esc js:>>', 'SDD');" onMouseOut="nd()"><<:sdd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:ssd_stats esc js:>>')" onClick="showCenteredWindow('<<:ssd_stats esc js:>>', 'SSD');" onMouseOut="nd()"><<:ssd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:tof_stats esc js:>>')" onClick="showCenteredWindow('<<:tof_stats esc js:>>', 'TOF');" onMouseOut="nd()"><<:tof_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:tpc_stats esc js:>>')" onClick="showCenteredWindow('<<:tpc_stats esc js:>>', 'TPC');" onMouseOut="nd()"><<:tpc_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:trd_stats esc js:>>')" onClick="showCenteredWindow('<<:trd_stats esc js:>>', 'TRD');" onMouseOut="nd()"><<:trd_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:t00_stats esc js:>>')" onClick="showCenteredWindow('<<:t00_stats esc js:>>', 'T00');" onMouseOut="nd()"><<:t00_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:v00_stats esc js:>>')" onClick="showCenteredWindow('<<:v00_stats esc js:>>', 'V00');" onMouseOut="nd()"><<:v00_count esc:>></td>
	            <td class="table_header" onMouseOver="overlibnz('<<:zdc_stats esc js:>>')" onClick="showCenteredWindow('<<:zdc_stats esc js:>>', 'ZDC');" onMouseOut="nd()"><<:zdc_count esc:>></td>

	            <td class="table_header" onMouseOver="overlibnz('<<:hlt_mode_stats esc js:>>')" onClick="showCenteredWindow('<<:hlt_mode_stats esc js:>>', 'HLT Mode');" onMouseOut="nd()"><<:hlt_mode_count esc:>></td>
	            
	            <td class="table_header"></td>
                </tr>
                <tr class="table_header">
            	    <td class="table_header" style="text-align:left">OPTIONS</td>
            	    <td class="table_header" style="text-align:left" colspan=41>
            		<input type=button class=input_submit value="Show list of runs" onClick="showRuns();">
            		
            		<<:com_authenticated_start:>>
            		<input type=button class=input_submit value="Save XML collection of files to AliEn (Pass 1)" onClick="saveXML('pass1');">
            		<input type=button class=input_submit value="Save XML collection of files to AliEn (Pass 2)" onClick="saveXML('pass2');">
            		<<:com_authenticated_end:>>
            	    </td>
                </tr>
		</tfoot>
		
	    </table>
	</td>
    </tr>
</table>
</form>
