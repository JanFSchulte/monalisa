<script language=javascript>
    var usage_text='<<:usage_help js:>>';
                   
    function getEditForm(runno, pid, owner, events, root, aliroot, geant, date, outputdir, jobtype){
	var frm = "<div align=center bgcolor=#EEEEFF width=100% height='400'><br clear=all><form name=frm_"+pid+" action=job_remarks.jsp method=post>";
	frm = frm + "<input type=hidden name=returnpath value='<<:return_path:>>'>";
	frm = frm + "<input type=hidden name=pid value='"+pid+"'>";
	frm = frm + "<table width=90% border=0 cellspacing=1 bgcolor=#FFFFFF style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px;'>";
	frm = frm + "<tr height=15 bgcolor=#F8FFB8><th style='padding: 3px'>Field</th><th style='padding: 3px'>Value</th></tr>";
	
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Run#</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=runno value='"+runno+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Owner</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=owner value='"+owner+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Events</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=events value='"+events+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>ROOT version</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=app_root value='"+root+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>ALIROOT version</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=app_aliroot value='"+aliroot+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>GEANT version</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=app_geant value='"+geant+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Submission date</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=date value='"+date+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Output directory</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=outputdir value='"+outputdir+"'></td>";
	frm = frm + "<tr bgcolor=#EEEEFF><td align=left style='padding: 3px'>Job type</td><td style='padding: 3px' align='left'><input style='font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; border: solid 1px #6684D1; width: 290px' type=text name=jobtype value='"+jobtype+"'></td>";
	
	frm = frm + "<tr bgcolor=#EEEEFF><td colspan=2 align=center style='padding: 5px'><input style='font-family:Helvetica;font-size:11px; color: #4D649E; font-weight: bold; border: solid 1px #6684D1; background-color: #FFFFFF; padding: 3px' type=submit name=edit_job value=Save></td></tr>";
	frm = frm + "</table></form></div>";
	
	return frm;
    }

    function doFilter(){
	document.raw_form.submit();
    }

    function checkHide(){
	var fields = document.raw_form.h;
    
	var ref = document.raw_form.hide_all.checked;
    
	if (fields){
    	    if (fields.length && fields.length>0){
    		for (i=0; i<fields.length; i++)
            	    fields[i].checked=ref;
	    }
	    else{
        	try{
            	    fields.checked=ref;
        	}
        	catch (Ex){
        	}
    	    }
	}
    }

</script>

<form name=form1 action="/job_events.jsp" method=post>
    <input type=hidden name=op value=0>
<br />

<table border=0 cellspacing=0 cellpadding=0 style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px">
<tr>
    <td align=left>
	<table border=0 cellspacing=0 cellpadding=0 style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px" width=100%>
	    <tr>
		<td align=left valign=top>
		    <a onMouseOver="overlib('Click here for a brief help')" onMouseOut='return nd();' onClick="showCenteredWindow(usage_text, 'Page usage'); return false;"><b>Usage info <img src="/img/qm.gif" border=0></a><br clear=all>&nbsp;
		</td>
		<td align=right valign=bottom>
		    <<:com_authenticated_start:>>
			<a onMouseOver="overlib('Access to administrator functions');" onMouseOut="return nd();" href="/job_remarks.jsp?returnpath=<<:return_path enc:>>"><b>Login</b>
		    <<:com_authenticated_end:>>
		</td>
	</table>
    </td>
</tr>
<tr><td align=center>
<table cellspacing=0 cellpadding=2 class="table_content">
    <tr height=25>
	<td class="table_title"><b>Jobs details - extracted from JDL</b></td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2>
		<tr class="table_header">
		    <td colspan="4" class="table_header" style="border-botom: 0px">
			<table cellspacing="0" cellpadding="0" border="0">
			    <tr height=25>
				<td align="right"><img src="/settings.png" width="16" height="16"></td>
				<td valign="middle" align="left"> &nbsp;Job parameters</td>
			    </tr>
			</table>    
		    </td>
		    <td colspan=3 valign="middle" align="center" height="25" class="table_header" style="border-botom: 0px">
			<table cellspacing="0" cellpadding="0" border="0">
			    <tr>
				<td align="right"><img src="/software.png" width="16" height="16"></td>
				<td valign="middle" align="left"> &nbsp;Application software</td>
			    </tr>
			</table>    
		    </td>
		    <td colspan=6 valign="middle" align="center" height="25" class="table_header" style="border-botom: 0px">
			<table cellspacing="0" cellpadding="0" border="0">
			    <tr>
				<td align="right"><img src="/details.png" width="16" height="16"></td>
				<td valign="middle" align="left"> &nbsp;Details</td>
			    </tr>
			</table>    
		    </td>
		    <td nowrap class="table_header" align=center style="border-top: 0px" colspan=2>Timings</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Output</td>
		</tr>
		<tr class="table_header" style="border-top: 0px">
		    <td nowrap class="table_header" align=center style="border-top: 0px"  height=25><a class="linkb" href=# onClick="return orderby(<<:order_0:>>);" onMouseOver="overlib('Order by run number');" onMouseOut="return nd();"><<:com_bold0_start:>><b><<:com_bold0_end:>>Run# <<:img0:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_1:>>);" onMouseOver="overlib('Order by process id');" onMouseOut="return nd();"><<:com_bold1_start:>><b><<:com_bold1_end:>>PID <<:img1:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_2:>>);" onMouseOver="overlib('Order by owner name');" onMouseOut="return nd();"><<:com_bold2_start:>><b><<:com_bold2_end:>>Owner <<:img2:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_3:>>);" onMouseOver="overlib('Order by number of events');" onMouseOut="return nd();"><<:com_bold3_start:>><b><<:com_bold3_end:>>Events <<:img3:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_4:>>);" onMouseOver="overlib('Order by ROOT version');" onMouseOut="return nd();"><<:com_bold4_start:>><b><<:com_bold4_end:>>ROOT <<:img4:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_5:>>);" onMouseOver="overlib('Order by ALIROOT version');" onMouseOut="return nd();"><<:com_bold5_start:>><b><<:com_bold5_end:>>ALIROOT <<:img5:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_6:>>);" onMouseOver="overlib('Order by GEANT version');" onMouseOut="return nd();"><<:com_bold6_start:>><b><<:com_bold6_end:>>GEANT <<:img6:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_7:>>);" onMouseOver="overlib('Order by submission date');" onMouseOut="return nd();"><<:com_bold7_start:>><b><<:com_bold7_end:>>Date <<:img7:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href="javascript:void(0);" onMouseOver="overlib('Whether or not the run is staged');" onMouseOut="return nd();">Staged</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_8:>>);" onMouseOver="overlib('Order by output directory');" onMouseOut="return nd();"><<:com_bold8_start:>><b><<:com_bold8_end:>>Output dir <<:img8:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px"><a class="linkb" href=# onClick="return orderby(<<:order_9:>>);" onMouseOver="overlib('Order by job type description');" onMouseOut="return nd();"><<:com_bold9_start:>><b><<:com_bold9_end:>>Type of job <<:img9:>></a></td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Remarks</td>
		    <td nowrap class="table_header" align=center style="border-top: 0px">Options</td>
		    <td class="table_header" nowrap>
			Running
                    </td>
		    <td class="table_header" nowrap>
			Saving
                    </td>
		    <td class="table_header" nowrap>
			size
                    </td>
		</tr>
    		<input type=hidden name=order value="<<:order:>>">
		<tr class="table_row">
		    <td class="table_row_right"><input type=text name="filter_run" value="<<:filter_run:>>" class="input_text" size=7></td>
		    <td class="table_row_right">&nbsp;</td>
		    <td class="table_row_right">
			<select name=owner class="input_select" onChange="document.form1.submit();">
			    <option value=""> - All - </option>
			    <<:opt_owner:>>
			</select>
		    </td>
		    <td class="table_row_right">&nbsp;</td>
		    <td class="table_row_right"><input type=text name="filter_root" value="<<:filter_root:>>" class="input_text" size=7></td>
		    <td class="table_row_right"><input type=text name="filter_aliroot" value="<<:filter_aliroot:>>" class="input_text" size=7></td>
		    <td class="table_row_right"><input type=text name="filter_geant" value="<<:filter_geant:>>" class="input_text" size=7></td>
		    <td class="table_row_right">
			<select name=timesel class="input_select" onChange="document.form1.submit();">
			    <option <<:opt_time_0:>> value="0"> - All - </option>
			    <option <<:opt_time_1:>> value="1">last day</option>
			    <option <<:opt_time_7:>> value="7">last week</option>
			    <option <<:opt_time_14:>> value="14">last 2 weeks</option>
			    <option <<:opt_time_31:>> value="31">last month</option>
			    <option <<:opt_time_61:>> value="61">last 2 months</option>
			    <option <<:opt_time_92:>> value="92">last 3 months</option>
			    <option <<:opt_time_365:>> value="365">last year</option>
			    <option <<:opt_time_730:>> value="730">last 2 years</option>
			    <option <<:opt_time_1095:>> value="1095">last 3 years</option>
			    <option <<:opt_time_1461:>> value="1461">last 4 years</option>
			    <option <<:opt_time_1826:>> value="1826">last 5 years</option>
			</select>
		    </td>

		    <td class="table_row_right">
			<select name=staged class="input_select" onChange="document.form1.submit();">
			    <option <<:opt_staged_0:>> value="0"> - All - </option>
			    <option <<:opt_staged_1:>> value="1">Yes</option>
			    <option <<:opt_staged_2:>> value="2">No</option>
			</select>
		    </td>
		    
		    <td class="table_row_right"><input type=text name="filter_outputdir" value="<<:filter_outputdir:>>" class="input_text" size=20></td>
		    <td class="table_row_right"><input type=text name="filter_jobtype" value="<<:filter_jobtype:>>" class="input_text" size=20></td>
		    <td class="table_row_right" align="center"><a href="job_remarks.jsp" target=_blank class="link" onMouseOver="overlib('Edit the remarks for run ranges<br><br><b>Access restricted to admins</b>');" onMouseOut="return nd();">edit</a></td>
		    <td class="table_row_right" nowrap>
			<input type=submit name=butonul value="Filter" class="input_submit">
			<<:com_admin_start:>>
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <input type=checkbox id="check_all" name="check_all" onMouseOver="overlib('Select all (visible) runs for deletion');" onMouseOut="nd();" onClick="checkAll(this);">
			    <input type=checkbox id="check_all_staging" name="check_all_staging" onMouseOver="overlib('Select all (visible) runs for staging/unstaging');" onMouseOut="nd();" onClick="checkAllStaging(this);">
			<<:com_admin_end:>>
		    </td>
		    <td class="table_row_right" nowrap>
                    </td>
		    <td class="table_row_right" nowrap>
                    </td>
		    <td class="table_row_right" nowrap>
                    </td>
		</tr>
		<<:continut:>>
		<tr class="table_header">
		    <td class="table_header" nowrap height=25><a href="javascript:void(0)" onClick="showCenteredWindow('<<:run_list esc js:>>', 'Run list');" class=link><<:TOTAL_RUNS:>> runs</a></td>
		    <td class="table_header" nowrap ><a href="javascript:void(0)" onClick="showCenteredWindow('<<:job_list esc js:>>', 'Job list')" class=link><<:TOTAL_JOBS:>> jobs</a></td>
		    <td class="table_header" nowrap ></td>
		    <td class="table_header" nowrap ><<:EVENTS:>></td>
		    <td class="table_header" nowrap  >&nbsp;</td>
		    <td class="table_header" nowrap >&nbsp;</td>
		    <td class="table_header" nowrap >&nbsp;</td>
		    <td class="table_header" nowrap >&nbsp;</td>
		    <td class="table_header" nowrap  colspan=2><a class="link" href="#" onClick="nd(); showCenteredWindow('<<:TOTAL_FOLDERS js:>>', 'Data folders'); return false;" onMouseOver="overlib('Get the list of output folders');" onMouseOut="return nd();"><b>Export folders</b></a></td>
		    <td class="table_header" nowrap >&nbsp;</td>
		    <td class="table_header" nowrap >&nbsp;</td>
		    <td class="table_header" nowrap>
			<<:com_admin_start:>>
			    <input type="button" class="input_submit" value="Delete" onMouseOver="overlib('Delete selected runs');" onMouseOut="nd();" onClick="deleteAll();"><br>
			    <input type="button" class="input_submit" value="Stage" onMouseOver="overlib('Stage selected runs');" onMouseOut="nd();" onClick="stageAll();"> / 
			    <input type="button" class="input_submit" value="Dismiss" onMouseOver="overlib('Dismiss/unstage selected runs');" onMouseOut="nd();" onClick="unstageAll();">
			<<:com_admin_end:>>
		    </td>
		    <td class="table_header" nowrap><<:wall_time intervalh:>></td>
		    <td class="table_header" nowrap><<:saving_time intervalh:>></td>
		    <td class="table_header" nowrap><<:outputsize size:>></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>
</td></tr></table>
</form>
<script language=javascript>
    function orderby(sort_order){
        document.form1.order.value = sort_order;
        document.form1.submit();
        return false;
    }
    
    function checkAll(master){
	var chk = master.checked;
	
	var chkboxes = document.getElementsByName("bulk_del");
	for (i=0; i< chkboxes.length; i++)
	    chkboxes[i].checked = chk;
    }

    function checkAllStaging(master){
	var chk = master.checked;
	
	var chkboxes = document.getElementsByName("bulk_stage");
	for (i=0; i< chkboxes.length; i++)
	    chkboxes[i].checked = chk;
    }
    
    function deleteAll(){
	try{
	    document.form1.action="/job_remarks.jsp?returnpath=<<:return_path enc:>>";
	
	    document.form1.submit();
	}
	catch (ex){
	    alert(ex);
	}
    }
    
    function stageAll(){
	document.form1.op.value=1;
	document.form1.submit();
    }
    
    function unstageAll(){
	document.form1.op.value=2;
	document.form1.submit();
    }
</script>
