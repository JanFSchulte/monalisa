<table cellspacing=0 cellpadding=2 class="table_content" width=725>
    <tr height=25>
	<td class="table_title" colspan=2>
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=center class=text>
			<<:path:>>
		    </td>
		</tr>
		<tr>
		    <td align=right class=text>
			<<:auth_start:>>
			Welcome <span onMouseOver="overlibIframe('/users/quota.jsp', CAPTION, 'Quota', WIDTH, 440)" onMouseOut="nd()"><<:account:>></span> (<a class=link href="/catalogue/?path=<<:account_home enc:>>">~</a>)
			<<:com_roles_start:>>
			with role <a class=link href="javascript:void(0);" onMouseOver="overlibIframe('/users/quota.jsp?u=<<:role enc:>>', CAPTION, 'Quota', WIDTH, 440)" onMouseOut="nd()" onClick="chooseRole();"><<:role:>></a> (<a class=link href="/catalogue/?path=<<:role_home enc:>>">~</a>)
			<<:com_roles_end:>>
			<<:auth_end:>>
			<<:!auth_start:>>
			<a class=link href="https://alimonitor.cern.ch/catalogue/?path=<<:folder enc:>>">Login</a>
			<<:!auth_end:>>
		    </td>
		</tr>
	    </table>
	</td>
    </tr>
    <<:com_folders_start:>>
    <tr>
	<td colspan=2>
	
<table border=0 cellspacing=1 cellpadding=2 align=left class="sortable" width=100% debug="true" id='folders_table'>
    <thead>
    <tr>
    <td class=table_header>Permissions</td>
    <td class=table_header>Owner</td>
    <td class=table_header>Timestamp</td>
    <td class=table_header>Name</td>
    </tr>
    </thead>

    <tbody>
    <<:folders:>>
    </tbody>
</table>
	</td>
    </tr>
    <tr>
	<td align=right style="padding-bottom:10px">
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		<td align=left>
		    <<:auth_start:>>
		    &nbsp;<a href="javascript:void(0)" onClick="createFolder()" class=link><b>Create new folder</b></a>
		    <<:auth_end:>>
		</td>
		<td align=right>
		    <b><<:folderscount:>> folder<<:s_folders:>></b>
		</td>
		</tr>
	    </table>
	</td>
    </tr>
    <<:com_folders_end:>>

    <<:com_collections_start:>>
    <tr>
	<td colspan=2>
	    <table border=0 cellspacing=1 cellpadding=2 align=left class="sortable" width=100% id='collections_table'>
		<thead>
		  <tr>
		    <td class=table_header>Permissions</td>
		    <td class=table_header>Owner</td>
		    <td class=table_header>Timestamp</td>
		    <td class=table_header>Size</td>
		    <td class=table_header>No. of files</td>
		    <td class=table_header>Name</td>
		  </tr>
		</thead>
		<tbody>
		    <<:collections:>>
		</tbody>
	    </table>
	</td>
    </tr>
    <tr>
	<td align=right style="padding-bottom:10px">
	    <b><<:collectionscount:>> collection<<:s_collections:>></b>
	</td>
    </tr>
    <<:com_collections_end:>>

    <<:com_files_start:>>    
    <tr>
	<td colspan=2>

<table border=0 cellspacing=1 cellpadding=2 align=left class="sortable" width=100% id='filelist'>
    <thead>
    <tr>
    <td class=table_header>Permissions</td>
    <td class=table_header>Owner</td>
    <td class=table_header>Timestamp</td>
    <td class=table_header>Size</td>
    <td class=table_header>Filename</td>
    </tr>
    </thead>

    <tbody>
    <<:content:>>
    </tbody>
</table>

	</td>
    </tr>
    <tr>
	<td align=left>
	    <<:auth_start:>>
	    &nbsp;<a href="javascript:void(0)" onClick="createFile()" class=link><b>Edit new file</b></a>
	    <<:auth_end:>>
	</td>
	<td align=right style="padding-bottom:10px">
	    <b><<:size size:>> in <<:count:>> file<<:s_files:>></b>
	</td>
    </tr>
    <<:com_files_end:>>
    
    <<:auth_start:>>
    <tr>
	<td colspan=2>

<form action=/users/upload.jsp method=post enctype="multipart/form-data">
<input type=hidden name=path value="<<:folder esc:>>">
<table border=0 cellspacing=1 cellpadding=2 align=left width=100% id='fileupload'>
    <tbody>
	<tr>
	    <td colspan=2 class=table_header align=left>Upload a new file in this folder</td>
	</tr>
	<tr>
	    <td class=table_row><input name=file class=input_text type=file size=60></td>
	    <td class=table_row align=right><input type=submit name=submit class=input_submit value="Upload..."></td>
	</tr>
	<<:!com_folders_start:>>
	<tr>
	    <td style="height:10px">
	    </td>
	</tr>
	<tr>
	    <td colspan=2 class=table_header align=left>Create subfolder</td>
	</tr>
	<tr>
	    <td class=table_row colspan=2>
		    &nbsp;<a href="javascript:void(0)" onClick="createFolder()" class=link><b>Create new folder</b></a>
	    </td>
	</tr>
	<<:!com_folders_end:>>
        <<:!com_files_start:>>
	<tr>
	    <td colspan=2 class=table_header align=left>Create files</td>
	</tr>
	<tr>
	    <td class=table_row colspan=2>
		&nbsp;<a href="javascript:void(0)" onClick="createFile()" class=link><b>Edit new file</b></a>
	    </td>
	</tr>
	<<:!com_files_end:>>
    </tbody>
</table>
</form>

	</td>
    </tr>
	<<:auth_end:>>
</table>
