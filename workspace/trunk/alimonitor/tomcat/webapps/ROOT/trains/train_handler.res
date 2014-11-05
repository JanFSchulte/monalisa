			    <tr class=table_row>
				<td class=table_row>
				    <a href="javascript:void(0)" class=link onClick="editHandler('<<:handler_name db esc:>>')"><<:handler_name db esc:>></a>
				</td>
				<td class=table_row>
				    <<:macro_path db esc:>>
				    ( <<:parameters db esc:>> )
				</td>
				<td class=table_row onClick="showCenteredWindow('<div align=left>&lt;pre&gt;<<:macro_body db esc js:>>&lt;/pre&gt;</div>', '<<:hander name db esc js:>>');" onMouseOver="overlib('<div align=left><pre><<:macro_body db esc js:>></pre></div>')" onMouseOut="nd()">
				    <<:macro_body db cut30 esc:>>
				</td>
				<td class=table_row align=center>
				  <<:com_enabled_start:>>
				    <<:com_admin_start:>><a href="admin/train_edit_handler.jsp?train_id=<<:train_id db esc:>>&handler_name=<<:handler_name db enc:>>&op=3" onMouseOver="overlib('Disable handler <<:handler_name db esc:>>');" onMouseOut="nd()"><<:com_admin_end:>><img src="/img/trend_ok.png" border=0><<:com_admin_start:>></a><<:com_admin_end:>>
				  <<:com_enabled_end:>>
				  <<:!com_enabled_start:>>
				    <<:com_admin_start:>><a href="admin/train_edit_handler.jsp?train_id=<<:train_id db esc:>>&handler_name=<<:handler_name db enc:>>&op=4" onMouseOver="overlib('Enable handler <<:handler_name db esc:>>');" onMouseOut="nd()"><<:com_admin_end:>><img src="/img/trend_stop.png" border=0><<:com_admin_start:>></a><<:com_admin_end:>>
				  <<:!com_enabled_end:>>
				</td>
				<td class=table_row align=right>
				    <<:com_admin_start:>><a href="admin/train_edit_handler.jsp?train_id=<<:train_id db esc:>>&handler_name=<<:handler_name db enc:>>&op=2" onClick="return confirm('Are you sure you want to delete this handler?');" onMouseOver="overlib('Delete this handler');" onMouseOut="nd()"><img src=/img/trash.gif border=0></a><<:com_admin_end:>>
				</td>
			    </tr>
