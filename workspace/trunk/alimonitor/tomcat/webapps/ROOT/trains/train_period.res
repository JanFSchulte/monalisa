			    <tr class=table_row>
				<td class=table_row>
				   <a href="javascript:void(0)" class=link onClick="editPeriod('<<:period_name db esc:>>')"><<:period_name db esc:>></a>
				</td>
				<td class=table_row>
				  <<:com_refprod_dataset_start:>>
				    <<:refprod db esc:>>
				  <<:com_refprod_dataset_end:>>
				</td>
				<td class=table_row>
				  <<:com_runlist_dataset_start:>>
				    <<:runlists:>>
				  <<:com_runlist_dataset_end:>>
				</td>
				<td class=table_row>
				  <<:com_global_variables_dataset_start:>>
				    <<:globalvariables_dataset db esc:>>
				  <<:com_global_variables_dataset_end:>>
				</td>
				<td class=table_row>
				  <<:com_desc_dataset_start:>>
				    <span onMouseOver="overlib('<div align=left><pre><<:period_desc db esc js:>></pre></div>');" onMouseOut="nd()" onClick="showCenteredWindow('<div align=left><pre><<:period_desc db esc js:>></pre></div>', '<<:period_name db esc js:>>');"><<:period_desc db cut20 esc:>></span>
				  <<:com_desc_dataset_end:>>
				</td>
				<td class=table_row align=center>
				  <<:com_enabled_data_start:>>
				    <<:com_admin_start:>><a href="admin/train_edit_period.jsp?train_id=<<:train_id db esc:>>&period_name=<<:period_name db esc:>>&op=3" onMouseOver="overlib('Disable dataset <<:period_name db esc:>>');" onMouseOut="nd()"><<:com_admin_end:>><img src="/img/trend_ok.png" border=0><<:com_admin_start:>></a><<:com_admin_end:>>
				  <<:com_enabled_data_end:>>
				  <<:!com_enabled_data_start:>>
				    <<:com_admin_start:>><a href="admin/train_edit_period.jsp?train_id=<<:train_id db esc:>>&period_name=<<:period_name db esc:>>&op=4" onMouseOver="overlib('Enable dataset <<:period_name db esc:>>');" onMouseOut="nd()"><<:com_admin_end:>><img src="/img/trend_stop.png" border=0><<:com_admin_start:>></a><<:com_admin_end:>>
				  <<:!com_enabled_data_end:>>
				</td>
				<td class=table_row>
				    <a href="javascript:void(0)" onClick="editRun(<<:id db esc:>>)" class=link><<:id db esc:>></a>
				</td>
				<td class=table_row align=right>
				    <<:com_admin_start:>><a href="admin/train_edit_period.jsp?train_id=<<:train_id db esc:>>&period_name=<<:period_name db enc:>>&op=2" onClick="return confirm('Are you sure you want to delete the dataset <<:period_name db esc:>>?');" onMouseOver="overlib('Delete dataset <<:period_name db esc:>>');" onMouseOut="nd()"><img src=/img/trash.gif border=0></a><<:com_admin_end:>>
				</td>
			    </tr>
