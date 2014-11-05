<div align=center>
<<:com_message_start:>>
<div style="color:<<:statecolor:>>;font-weight:bold;cursor:help" onMouseOver="nd(); overlib('<<:message js esc:>>', CAPTION, '<<:service js esc:>> @ <<:name js esc:>>');" onMouseOut="nd();" onClick="nd(); showCenteredWindow('<<:message js esc:>>', 'Service <b><<:service:>></b> running at <b><<:name:>></b>'); return false;"><<:service esc:>> : <<:state:>></div>
<<:com_message_end:>>
<<:com_nomessage_start:>>
<div style="color:<<:statecolor:>>;font-weight:bold" onMouseOver="nd();"><<:service esc:>> : <<:state:>></div>
<<:com_nomessage_end:>>
</div>
<<:com_canadmin_start:>>
<a href="javascript:void(0);" onMouseOut="nd();" onClick="nd(); if (confirm('Are you sure you want to stop the service?')) showCenteredWindow('<iframe src=\'services_command.jsp?site=<<:name enc:>>&service=<<:service enc:>>&command=stop\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>', 'Stop <<:service js esc:>> at <<:name js esc:>>');" onMouseOver="overlib('Stop <<:service js esc:>> at <<:name js esc:>>'); return false;" class="link_buton_stop">Stop</a>
<a href="javascript:void(0);" onMouseOver="overlib('(Re)start <<:service js esc:>> at <<:name js esc:>>');" onMouseOut="nd();" onClick="nd(); if (confirm('Are you sure you want to (re)start the service?')) showCenteredWindow('<iframe src=\'services_command.jsp?site=<<:name enc:>>&service=<<:service enc:>>&command=start\' width=100% height=99% vspace=0 hspace=0 marginwidth=0 marginheight=0 frameborder=0></iframe>', '(Re)start <<:service js esc:>> at <<:name js esc:>>'); return false;" class="link_buton_start">Start</a>
<<:com_canadmin_end:>>
<a href="javascript:void(0);" onMouseOver="overlib('Watch <<:service js esc:>> log at <<:name js esc:>>');" onMouseOut="nd();" class="link_buton_tail" onClick="window.open('/tail_index.jsp?site=<<:name enc:>>&service=<<:service enc:>>','<<:service:>>@<<:name:>>', 'width=1015,height=700,status=0,scrollbars=0,toolbar=0,location=0,menubar=0,directories=0');">Tail</a>
