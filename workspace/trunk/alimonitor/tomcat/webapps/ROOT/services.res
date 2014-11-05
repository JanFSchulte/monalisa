<script type="text/javascript" src="/js/window/prototype.js"> </script>
<script type="text/javascript" src="/js/window/window.js"> </script> 
<script type="text/javascript" src="/js/window/windowutils.js"> </script> 
<!-- Add this to have a specific theme--> 
<link href="/js/window/default.css" rel="stylesheet" type="text/css"></link>
<link href="/js/window/mac_os_x.css" rel="stylesheet" type="text/css"></link>
	
<table cellspacing=0 cellpadding=5 class="table_content">
    <tr height=25>
	<td style="background-color: #F0F0F0"><a href="/services.jsp" class="menu_link_active"><b>Services management</b></a></td>
	<td style="border-left: 1px solid #C0D5FF;"><a href="/centralservices/" class="menu_link_active"><b>Central services management</b></a></td>
	<td style="border-left: 1px solid #C0D5FF;"><a href="/admin/services.jsp" class="menu_link_active"><b>Autorestart &amp; notifications</b></a></td>	
	<td style="border-left: 1px solid #C0D5FF;"><a href="/admin/subscribers.jsp" class="menu_link_active"><b>Alert Subscribers</b></a></td>		
    </tr>
</table>

<script type="text/javascript">

function checkSites(){
    var fields = document.form1.s;
    
    var ref = document.getElementById('check_ref').checked;
    
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

var versionStates = new Array();

function selectVer(version){
    if (version.length==0)
	return false;

    var fields = document.form1.s;

    var ref = ! versionStates[version];

    versionStates[version] = ref;

    if (fields){
        if (fields.length && fields.length>0){
            for (i=0; i<fields.length; i++)
                if (fields[i].id == version)
		    fields[i].checked=ref;
        }
        else{
            try{
        	if (fields.id==version)
        	    fields.checked=ref;
            }
            catch (Ex){
            }
        }
    }

    return false;
}

function doReinstall(){
    if (confirm("Are you sure that you want to reinstall AliEn on the selected sites?")){
	document.getElementById('command').value = '(wget --no-cache http://alien.cern.ch/alien-installer -O alien-installer && chmod 755 ./alien-installer && ./alien-installer -type vobox -install-dir ${ALIEN_ROOT%/*}/alien -restart -batch) &>alien-upgrade.log &';
	document.getElementById('notifyadmin').value = 'true';
	return true;
    }
    else{
	return false;
    }
}

function doRestart(){
    if (confirm("Are you sure that you want to restart AliEn on the selected sites?")){
	document.getElementById('command').value = '($LCG_SITE || $AliEnCommand proxy-init -valid 700:0 2>&1; $(dirname ${ALIEN_ROOT})/alien/etc/rc.d/init.d/aliend restart) &>/dev/null </dev/zero &';
	return true;
    }
    else{
	return false;
    }
}

function doConsole(){
    document.getElementById('command').value = '';
}

</script>

<br>
<table cellspacing=0 cellpadding=3 class="table_content" align="left">
    <tr height=25>
	<td class="table_title"><b>Site services management</b></td>
    </tr>
    <tr>
	<td>
	    <form name="form1" action="admin/multiconsole.jsp" method=GET target=_blank>
	    <input type=hidden name=command id=command value="">
	    <input type=hidden name=notifyadmin id=notifyadmin value="false">
	    <table cellspacing=1 cellpadding=2  class="sortable">
		<thead>
		<tr class="table_header">
		    <td class=table_header style="border-bottom: 0px;">&nbsp;</td>
		    <td colspan=6 align=center class="table_header" style="border-bottom: 0px;">
			Services
		    </td>
		</tr>
		<tr class="table_header">
		    <td align=left width=110 class="table_header" style="border-top: 0px;">
			Site name
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			CE
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			PackMan
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			Monitor
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			MonaLisa
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			<div style="float: left; padding-top: 5px; padding-left: 20px">Global services </div>
			<div style="float: right; padding-top: 5px; padding-right: 0">
			    <input type=checkbox name=checkall class="input_checkbox" id="check_ref" onChange="checkSites()" onMouseOver="overlib('Select all')" onMouseOut="nd()">
			</div>
		    </td>
		    <td align=center class="table_header" style="border-top: 0px;">
			AliEn version
		    </td>
		</tr>
		</thead>
		<tbody>
		<<:continut:>>
		</tbody>
		<tfoot>
		<tr>
		    <td class=table_header colspan=7 align=right>
			<div align=right>
			    <input type=submit name=submit onClick="return doReinstall()" value="Reinstall AliEn on selected sites" class="input_submit">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <input type=submit name=submit onClick="return doRestart()" value="Restart AliEn on selected sites" class="input_submit">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <input type=submit name=submit onClick="doConsole()" value="Multi-site console" class="input_submit">
			</div>
		    </td>
		</tr>
		</tfoot>
	    </table>
	    </form>
	</td>
    </tr>
</table>
