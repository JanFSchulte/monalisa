<tr bgcolor="#FFB84D">
<td class=table_row colspan=3>
  <span onclick="switchDiv('<<:div_group::>>', true, 0.3);"><a accesskey="s" onclick="switchDiv('<<:div_group:>>', true, 0.3);" href="javascript:void(0);" class="menu_link"><b>Group <<:group_name db esc:>></b><img id="<<:div_group:>>_img" src="/img/dynamic/plus.jpg" width="9" height="9" border="0"></a></span>
</td>
  <td class=table_row>
  </td>
  <<:datasets_group:>>
    <td class=table_row align=middle>
      <a href="javascript:void(0)" class=link onClick="editRun(<<:last_test:>>)"><<:last_test:>></a>
    </td>
    <td class=table_row align=middle>
      <a href="javascript:void(0)" class=link onClick="editRun(<<:last_run:>>)"><<:last_run:>></a>
    </td>
  <td class=table_row>
<br><br>
  </td>
</tr>

<tbody id="<<:div_group:>>" style="display: none">

<<:group_wagons:>>

</tbody>
