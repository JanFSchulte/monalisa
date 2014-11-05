<<:!com_header_start:>>
<td class=table_row align=center>
  <<:com_wagon_start:>>
    <<:com_enabled_start:>>
      <<:com_canedit_start:>><a href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name=<<:wagon_name db esc:>>&period_name=<<:period_name db esc:>>&op=3" onMouseOver="overlib('Disable wagon <<:wagon_name db esc:>> for dataset <<:period_name db esc:>>. The wagon was activated on the <<:run_date db esc:>>.');" onMouseOut="nd()"><<:com_canedit_end:>><img src="/img/trend_ok.png" border=0><<:com_canedit_start:>></a><<:com_canedit_end:>>
    <<:com_enabled_end:>>
    <<:!com_enabled_start:>>
     <<:com_canedit_start:>><a href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name=<<:wagon_name db esc:>>&period_name=<<:period_name db esc:>>&op=4" onMouseOver="overlib('Enable wagon <<:wagon_name db esc:>> for dataset <<:period_name db esc:>>');" onMouseOut="nd()"><<:com_canedit_end:>><img src="/img/trend_stop.png" border=0><<:com_canedit_start:>></a><<:com_canedit_end:>>
    <<:!com_enabled_end:>>
    <<:com_canedit_start:>> 
      <input type="checkbox" name="wagon_enabled_<<:wagon_name db esc:>>_<<:period_name db esc:>>" value="1" <<:com_enabled_start:>>checked<<:com_enabled_end:>> > 
      <input type="hidden" name="wagon_enabled_<<:wagon_name db esc:>>_<<:period_name db esc:>>_hidden" value=<<:com_enabled_start:>>"1"<<:com_enabled_end:>><<:!com_enabled_start:>>"0"<<:!com_enabled_end:>> > 
    <<:com_canedit_end:>> 
  <<:com_wagon_end:>>
  <<:!com_wagon_start:>>
    <<:com_admin_start:>>
      <a class=link href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&period_name=<<:period_name db esc:>>&group_name=<<:group_name db esc:>>&op=6" onMouseOver="overlib('Enable all wagons in the group <<:group_name db esc:>>');" onMouseOut="nd()" onClick="return confirm('This enables all wagons in the group <<:group_name db esc:>>. Are you sure?');" >Enable</a>
      <a class=link href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&period_name=<<:period_name db esc:>>&group_name=<<:group_name db esc:>>&op=5" onMouseOver="overlib('Disable all wagons in the group <<:group_name db esc:>>');" onMouseOut="nd()" onClick="return confirm('This disables all wagons in the group <<:group_name db esc:>>. Are you sure?');">Disable</a> 
    <<:com_admin_end:>>
  <<:!com_wagon_end:>>
</td>
<<:!com_header_end:>>
<<:com_header_start:>>
<td class=table_header_stats onMouseOver="overlib('<<:period_name db esc:>>');" onMouseOut="nd()"><<:period_name db cut12 esc:>></td>
<<:com_header_end:>>
