			    <tr class=table_row>
				<td class=table_row>
				    <a href="javascript:void(0)" onClick="editRun(<<:id db esc:>>)" class=link><<:id db esc:>></a>
				</td>
				<td class=table_row>
				    <a class=link href="/packages/" target=_blank onMouseOver="overlib('<<:aliroot_available_tooltip js esc:>>');" onMouseOut="nd();"><font color="<<:aliroot_available_color esc:>>"><<:ver_aliroot_short esc:>></font></a>
				</td>
				<td class=table_row>
				    <<:dataset db esc:>>
				</td>
				<td class=table_row onMouseOver="overlib('included wagons: <<:wagon_name_list:>>');" onMouseOut="nd();">
				  <<:!com_run_started_start:>>
				    <<:test_date:>> <<:test_status:>>
				  <<:!com_run_started_end:>>
				  <<:com_run_started_start:>>
				    <<:run_date db esc:>> <<:lpm_status:>>
				  <<:com_run_started_end:>>
				</td>
				<td class=table_row onMouseOver="overlib('<<:comment db ntobr js esc:>>');" onMouseOut="nd();">
				    <<:comment db cut25 esc:>>
				</td>
				<td class=table_row align=right>
				    <<:allow_delete_start:>><<:com_admin_start:>><a href="admin/train_edit_run.jsp?train_id=<<:train_id db esc:>>&id=<<:id db enc:>>&submit=Delete" onClick="return confirm('Are you sure you want to delete run <<:id db esc:>>?');" onMouseOver="overlib('Delete run <<:id db esc:>>');" onMouseOut="nd()"><img src=/img/trash.gif border=0></a><<:com_admin_end:>><<:allow_delete_end:>>
				</td>
			    </tr>
