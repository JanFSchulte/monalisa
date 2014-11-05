		<tr class="table_row">
		    <<:com_show_status_start:>>
		    <td class="table_row_stats" align=left valign=middle><a class=link href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:wagon_name db:>>/syswatch.png" target="_blank"><b><<:wagon_name_nice esc:>></b><br>
			<a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:nice_wagon_name:>>/stdout">stdout</a> | 
		        <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:nice_wagon_name:>>/stderr">stderr</a><br>
			<a class=link href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:wagon_name db:>>/syswatch.png" target="_blank">stats</a> | 
			<a class=link href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:wagon_name db:>>/" target="_blank">output</a>
		    </td>
		    <td class="table_row_stats" valign=middle align=center><b><<:status:>></b></td>
		    <td class="table_row_stats">Max<br>Avg<br>Slope</td>
		    <td class="table_row_stats" valign=top><<:com_mem_virt_toBig_start:>><font color=<<:color_mem_virt_toBig:>>><b><<:com_mem_virt_toBig_end:>><<:test_mem_virt_max db sizeM:>><<:com_mem_virt_toBig_start:>></font></b><<:com_mem_virt_toBig_end:>><br> <<:test_mem_virt db sizeM:>><br> <<:test_mem_virt_slope_sign:>><<:test_mem_virt_slope db sizeM:>>/evt</td>
		    <td class="table_row_stats" valign=top><<:com_hide_delta_start:>><<:test_mem_virt_max_delta sizeM:>><br><<:test_mem_virt_delta sizeM:>> <br> <<:com_mem_virt_slope_toBig_start:>><font color=<<:color_mem_virt_slope_toBig:>>><b><<:com_mem_virt_slope_toBig_end:>><<:test_mem_virt_slope_delta_sign:>><<:test_mem_virt_slope_delta sizeM:>>/evt<<:com_mem_virt_slope_toBig_start:>></font></b><<:com_mem_virt_slope_toBig_end:>><<:com_hide_delta_end:>>&nbsp;</td>
		    <td class="table_row_stats" valign=top><<:com_mem_rss_toBig_start:>><font color=<<:color_mem_rss_toBig:>>><b><<:com_mem_rss_toBig_end:>><<:test_mem_rss_max db sizeM:>><<:com_mem_rss_toBig_start:>></font></b><<:com_mem_rss_toBig_end:>><br> <<:test_mem_rss db sizeM:>> <br> <<:test_mem_rss_slope_sign:>><<:test_mem_rss_slope db sizeM:>>/evt</td>
		    <td class="table_row_stats" valign=top><<:com_hide_delta_start:>><<:test_mem_rss_max_delta sizeM:>><br><<:test_mem_rss_delta sizeM:>> <br> <<:com_mem_rss_slope_toBig_start:>><font color=<<:color_mem_rss_slope_toBig:>>><b><<:com_mem_rss_slope_toBig_end:>><<:test_mem_rss_slope_delta_sign:>><<:test_mem_rss_slope_delta sizeM:>>/evt<<:com_mem_rss_slope_toBig_start:>></font></b><<:com_mem_rss_slope_toBig_end:>><<:com_hide_delta_end:>>&nbsp;</td>
		    <td class="table_row_stats" valign=top><<:com_std_toBig_start:>><font color=red><b><<:com_std_toBig_end:>>log: <<:output_std_size size:>> <<:com_std_toBig_start:>></font></b><<:com_std_toBig_end:>><br>.root: <<:output_file_size size:>> </td>
		    <td class="table_row_stats" valign=top><<:test_wall_time db intervals:>> <br> <<:wall_per_event db ddot:>>ms/evt</td>
		    <td class="table_row_stats" valign=top><<:test_wall_time_delta intervals:>> <br> <<:wall_per_event_delta ddot:>>ms/evt</td>
		    <td class="table_row_stats" valign=top><<:test_cpu_time db intervals:>> <br> <<:cpu_per_event db ddot:>>ms/evt<br><<:cpu_eff:>></td>
		    <td class="table_row_stats" valign=top><<:test_cpu_time_delta intervals:>> <br> <<:cpu_per_event_delta ddot:>>ms/evt</td>
		    <<:com_show_merge_link_start:>>
		      <td class="table_row_stats" valign=middle align=center><b><<:merging:>></b> <br> <a class=link href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:wagon_name db:>>/merge_test" target="_blank">merge dir</td>
                      <<:com_show_merge_link_end:>>
			<<:!com_show_merge_link_start:>>
			  <td class="table_row_stats" valign=middle align=center><b><<:merging:>></b></td>
			  <<:!com_show_merge_link_end:>>
			    <<:com_show_status_end:>>
			      
		    <<:!com_show_status_start:>>
		    <td class="table_row_stats">
			<b><<:wagon_name_nice esc:>></b>
			<<:com_show_logfiles_start:>>
			<br>
			<a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:nice_wagon_name:>>/stdout">stdout</a> | 
		        <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path:>>/test/<<:nice_wagon_name:>>/stderr">stderr</a>
			<<:com_show_logfiles_end:>>
		      <<:com_show_trainfiles_start:>>
			<br>
			<a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>/<<:generation_dir:>>/generation.log">generation log</a>  
		        <<:com_show_trainfiles_output_start:>>| <a class=link target="_blank" href="<<:backend_url:>>/train-workdir/<<:test_path db esc:>>/__TRAIN__">output</a><br><<:com_show_trainfiles_output_end:>>
			<<:com_show_trainfiles_end:>>
		    </td>
		    <td class="table_row_stats" valign=middle align=center><b><<:status:>></b></td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <td class="table_row_stats">&nbsp;</td>
		    <<:!com_show_status_end:>>
		</tr>
