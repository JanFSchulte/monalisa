 <tr class=table_row>
  <td class=table_row>
    <a href="javascript:void(0)" class=link onClick="editWagon('<<:wagon_name db esc:>>')" onMouseOver="overlib('Macro path (parameters): <<:macro_path db esc:>> (<<:parameters db esc:>>)');" onMouseOut="nd()"><<:wagon_name db esc:>></a>
  </td>
  <td class=table_row>
    <<:com_owner_start:>>
     <<:username db esc:>>
    <<:com_owner_end:>>
    &nbsp;
  </td>
  <td class=table_row>
    <<:com_macro_path_start:>>
     <<:macro_path db esc:>>
       ( <<:parameters db esc:>> )
    <<:com_macro_path_end:>>
    &nbsp;
  </td>
  <td class=table_row>
    <<:com_dependencies_start:>>
     <<:dependencies db esc:>>
    <<:com_dependencies_end:>>
    &nbsp;
  </td>
  <<:datasets:>>
    <td class=table_row align=middle>
      <a href="javascript:void(0)" class=link onClick="editRun(<<:test_id db esc:>>)"><<:test_id db esc:>></a>
    </td>
    <td class=table_row align=middle>
      <a href="javascript:void(0)" class=link onClick="editRun(<<:run_id db esc:>>)"><<:run_id db esc:>></a>
    </td>
    <td class=table_row align=right>
      <<:com_canedit_start:>>
        <div style="width:60px;">
	  <a href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name=<<:wagon_name db esc:>>&op=8" onMouseOver="overlib('Enable wagon <<:wagon_name db esc:>> for all enabled datasets');" onMouseOut="nd()"><img src="/img/trend_ok.png" border=0></a>
	  <a href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name=<<:wagon_name db esc:>>&op=7" onMouseOver="overlib('Disable wagon <<:wagon_name db esc:>> for all enabled datasets');" onMouseOut="nd()"><img src="/img/trend_stop.png" border=0></a>
	  <a href="admin/train_edit_wagon.jsp?train_id=<<:train_id db esc:>>&wagon_name=<<:wagon_name db esc:>>&op=2" onClick="return confirm('Are you sure you want to delete the wagon <<:wagon_name db esc:>>?');" onMouseOver="overlib('Delete wagon <<:wagon_name db esc:>>');" onMouseOut="nd()"><img src=/img/trash.gif border=0></a>
	</div>
      <<:com_canedit_end:>>
    </td>
 </tr>
