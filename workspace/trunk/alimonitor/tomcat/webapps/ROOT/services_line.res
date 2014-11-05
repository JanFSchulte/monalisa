<tr bgcolor="<<:bgcolor:>>" class="table_row">
    <td nowrap align=left class="table_row" sorttable_customkey="<<:site esc:>>">
	<<:com_monalisadown_start:>><span onMouseOver="overlib('MonALISA not running at <<:site js:>>');" onMouseOut="nd();"><<:com_monalisadown_end:>>
	<font color="<<:on_color:>>"><b><<:name esc:>></b></font><br>
	<a class="link" href="javascript:void(0);" onMouseOver="overlib('<<:ip_rev js:>>', CAPTION, 'Click for details');" onMouseOut="nd();" onClick="nd(); showCenteredWindow('&lt;div style=\'padding-left:10px;padding-top:10px\'&gt;Name: <<:name js:>>&lt;br&gt;VoBox IP: <<:ip js:>>&lt;br&gt;Reverse IP: <<:ip_rev js:>>&lt;br&gt;Contact: <<:contact_name js:>> &amp;lt;<<:contact_email js:>>&amp;gt;&lt;/div&gt;', '<<:name js:>>'); return false;">
	    <<:ip_rev:>>
	</a>
    </td>
    <td sorttable_customkey="<<:site esc:>>" nowrap align=right class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;"><<:CE:>></td>
    <td sorttable_customkey="<<:site esc:>>" nowrap align=right class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;"><<:PackMan:>></td>
    <td sorttable_customkey="<<:site esc:>>" nowrap align=right class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;"><<:Monitor:>></td>
    <td sorttable_customkey="<<:site esc:>>" nowrap align=right class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;"><<:MonaLisa:>></td>
    <td nowrap align=center class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;" valign=bottom sorttable_customkey="<<:AliEnVersion esc:>>">
	<<:com_monalisa_start:>>
	<a onMouseOver="overlib('Start all the services from <<:site js:>>');" onMouseOut="nd();" href="javascript:showCenteredWindow('<iframe src=\'services_command.jsp?site=<<:name enc:>>&service=ALL&command=start\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>', 'Start all services at <<:name js:>>');" onMouseOver="overlib('Start all services at <<:name js:>>');"" onClick="nd(); return confirm('Are you sure you want to start all the services running at <<:site:>>?');" class="link_buton_stop">Start</a>
	<a onMouseOver="overlib('Restart all the services from <<:site js:>>');" onMouseOut="nd();" href="javascript:showCenteredWindow('<iframe src=\'services_command.jsp?site=<<:name enc:>>&service=ALL&command=restart\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>', 'Restart all services at <<:name js:>>');" onMouseOver="overlib('Restart all services at <<:name js:>>');"" onClick="nd(); return confirm('Are you sure you want to restart all the services running at <<:site:>>?');" class="link_buton_start">Restart</a>
	<a href="javascript:void(0);" onMouseOver="overlib('Open console on <<:name js:>>');" onMouseOut="nd();" class="link_buton_tail" onClick="window.open('/console.jsp?site=<<:name enc:>>','Console on <<:name:>>', 'width=1015,height=700,status=0,scrollbars=0,toolbar=0,location=0,menubar=0,directories=0');">Console</a>
	<input type=checkbox name=s value="<<:site esc:>>" class="input_checkbox" onMouseOver="overlib('Select <<:name js:>>')" onMouseOut="nd()" id="<<:AliEnVersion esc:>>">
	<<:com_monalisa_end:>>
	<<:com_nomonalisa_start:>>
	-
	<<:com_nomonalisa_end:>>
    </td>
    <td nowrap align=center class="table_row" style="padding-left: 15px; padding-right: 15px; padding-bottom: 5px;" valign=bottom sorttable_customkey="<<:AliEnVersion esc:>>">
	<a href="javascript:void(0);" onClick="return selectVer('<<:AliEnVersion js:>>');" class=link><<:AliEnVersion esc:>></a>
    </td>
</tr>
