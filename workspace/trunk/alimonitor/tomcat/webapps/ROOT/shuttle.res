<script type="text/javascript">
    function setFilter(value){
	field = objById('filter');
	
	field.value = field.value==value ? '' : value;
	
	document.form1.submit();
	return false;
    }
    
    function stopReloading(){
	cancelAutoReload();
	document.form1.stopreloading.disabled=true;
    }
</script>

<form name=form1 action=shuttle.jsp method=get>
    <input type=hidden name=filter id=filter value="<<:filter:>>">
    <input type=hidden name=instance value="<<:instance esc:>>">

<table cellspacing=0 cellpadding=2 class="table_content" width=100%>
    <tr height=25>
	<td class="table_title">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=left>
			Monitoring for <b><<:shuttle_instance_descr:>></b> (click <a href="shuttle.jsp?instance=<<:shuttle_other_instance:>>">here</a> to go to the <<:shuttle_other_instance_descr:>>)<br>
			SHUTTLE running AliRoot version <span onMouseOver="overlib('First seen: <<:aliroot_version_timestamp:>>');" onMouseOut="nd()"><b><<:aliroot_version:>></b></span> (rev. #<<:aliroot_revision:>>)<br>
		        <b>SHUTTLE statistics</b> (current status: <<:status:>>, 
			processing run: <b><<:lastprocessed:>></b>, 
			unprocessed runs: <b><<:unprocessed:>></b>)
			<br>
			<<:com_errors_start:>><font style="color:red;font-weight:bold"><<:com_errors_end:>>
			DCS errors/last hour: <b><<:dcserrors:>></b>, 
			FXS errors/last hour: <b><<:fxserrors:>></b>,
			GRP failures/last hour: <b><<:grpfailures:>></b>,
			OCDB errors/last hour: <b><<:ocdberrors:>></b>
			<<:com_errors_start:>></font><<:com_errors_end:>>
		    </td>
		    <td align=right><input type=button class=input_submit name=stopreloading value="Stop reloading" onClick="stopReloading()"></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td>
	    <table cellspacing=1 cellpadding=2 class="text sortable">
		<thead>
		<tr height=25>
		    <td class="table_header"><b>Run#</b></td>
		    <td class="table_header"><b>Run type</b></td>
		    <td class="table_header"><b>First seen</b></td>
		    <td class="table_header"><b>Last seen</b></td>
		    <td class="table_header"><a target=_blank href="http://pcalishuttle02.cern.ch:8880/logs<<:instanceunder:>>/SHUTTLE.log" class="link"><b>SHUTTLE</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('ACO');" class="link"><b><<:under_ACO:>>ACO</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('EMC');" class="link"><b><<:under_EMC:>>EMC</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('FMD');" class="link"><b><<:under_FMD:>>FMD</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('GRP');" class="link"><b><<:under_GRP:>>GRP</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('HLT');" class="link"><b><<:under_HLT:>>HLT</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('HMP');" class="link"><b><<:under_HMP:>>HMP</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('MCH');" class="link"><b><<:under_MCH:>>MCH</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('MTR');" class="link"><b><<:under_MTR:>>MTR</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('PHS');" class="link"><b><<:under_PHS:>>PHS</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('CPV');" class="link"><b><<:under_CPV:>>CPV</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('PMD');" class="link"><b><<:under_PMD:>>PMD</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('SPD');" class="link"><b><<:under_SPD:>>SPD</b></a></td>
    		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('SDD');" class="link"><b><<:under_SDD:>>SDD</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('SSD');" class="link"><b><<:under_SSD:>>SSD</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('TOF');" class="link"><b><<:under_TOF:>>TOF</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('TPC');" class="link"><b><<:under_TPC:>>TPC</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('TRD');" class="link"><b><<:under_TRD:>>TRD</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('TRI');" class="link"><b><<:under_TRI:>>TRI</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('T00');" class="link"><b><<:under_T00:>>T00</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('V00');" class="link"><b><<:under_V00:>>V00</b></a></td>
		    <td class="table_header"><a href="javascript:void(0);" onClick="return setFilter('ZDC');" class="link"><b><<:under_ZDC:>>ZDC</b></a></td>
		</tr>

		<tr height=25>
		    <td class="table_header"><input type=text name=runrange value="<<:runrange esc:>>" class=input_text onMouseOver="overlib('Example: 12345,13000-13010,13050', 'Run range')" onMouseOut="nd()" onClick="nd()" style="width:50px"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">
			<select name=time class="input_select" onChange="modify();">
			    <!--<option value="0" <<:time_0:>>>- All -</option>-->
			    <option value="24" <<:time_24:>>>Last day</option>
			    <option value="168" <<:time_168:>>>Last week</option>
			    <!--
			    <option value="720" <<:time_720:>>>Last month</option>
			    <option value="1464" <<:time_1464:>>>Last 2 months</option>
			    <option value="2190" <<:time_2190:>>>Last 3 months</option>
			    <option value="2920" <<:time_2920:>>>Last 4 months</option>
			    <option value="4320" <<:time_4320:>>>Last 6 months</option>
			    <option value="8760" <<:time_8760:>>>Last year</option>
			    -->
			</select>
		    </td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
    		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header">&nbsp;</td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		</tr>
		</thead>
		<tbody>
		<<:continut:>>
		</tbody>
	    </table>
	</td>
    </tr>
</table>

</form>
