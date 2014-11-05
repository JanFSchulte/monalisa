    <tr>
	<td align=center valign=top bgcolor=white style="height:100%" onDblClick="window.open('gantt.jsp?pid=<<:pid js esc:>>&run=<<:runno js esc:>>', '_blank');">
	    <table border=0 cellspacing=0 cellpadding=2 width=100% style="height:100%">
		<tr>
		<td style="padding-right:20px" align=left valign=top>
    		    <a class="link_header" style="text-decoration:none" href="#" onClick="return openLive(<<:pid js esc:>>)" onMouseOver="jobDetails(<<:pid js esc:>>);" onMouseOut="nd();"><<:pid esc:>></a>
    		</td>
    		<td align=right valign=top>
		    <table style="width:<<:jobssize:>>px;height:12px" border=0 cellspacing=1 cellpadding=0 onClick="return openLive(<<:pid js esc:>>)" onMouseOver="jobDetails(<<:pid js esc:>>);" onMouseOut="nd();">
			<tr>
			    <td style="width:<<:jobsred:>>%" bgcolor=red></td>
			    <td style="width:<<:jobsyellow:>>%" bgcolor=yellow></td>
			    <td style="width:<<:jobsgreen:>>%" bgcolor=green></td>
			</tr>
		    </table>
		</td></tr>
		<tr height=100%><td colspan=2 align=center valign=top>
	    <<:jobtype_style_start:>>
	    <<:jobtype esc:>>
	    <<:jobtype_style_end:>>
	    <<:com_jdl_start:>>
		<a href="/catalogue/?path=<<:lpm_history.jdl:>>" target=_blank onMouseOver="overlib('<b><<:lpm_history.jdl:>></b> <<:lpm_history.parameters:>>', CAPTION, 'Jump to JDL and macros');" onMouseOut="nd()"><img src="/img/folderopen.gif" border=0></a>
	    <<:com_jdl_end:>>
	    <br><<:prod_comment:>></td></tr>
		    <<:com_hassize_start:>>
		    <tr valign=bottom>
		    <td align=left style="padding-top:10px">
			<<:outputsize_explicit size:>>
		    </td>
		    <td align=right>
			<table border=0 cellspacing=0 cellpadding=0 style="width:<<:width_size:>>px">
			    <tr style="height:2px">
				<td bgcolor="blue"></td>
			    </tr>
			</table>
		    </td>
		    </tr>
		    <<:com_hassize_end:>>
		    <<:com_hasevents_start:>>
		    <tr valign=bottom>
		    <td align=left style="padding-top:10px">
			<<:noevents:>> ev.
		    </td>
		    <td align=right>
			<table border=0 cellspacing=0 cellpadding=0 style="width:<<:width_events:>>px">
			    <tr style="height:2px">
				<td bgcolor="green"></td>
			    </tr>
			</table>
		    </td>
		    </tr>
		    <<:com_hasevents_end:>>
		</tr>
	    </table>
	</td>
	<<:com_children_start:>>
	<td valign=top bgcolor=white style="height:100%">
	    <table width=100% border=0 cellspacing=2 cellpadding=0 bgcolor=#999999 style="height:100%">
		<<:content:>>
	    </table>
	</td>
	<<:com_children_end:>>
	<<:!com_children_start:>>
	<td bgcolor=#EEEEEE></td>
	<<:!com_children_end:>>
    </tr>
