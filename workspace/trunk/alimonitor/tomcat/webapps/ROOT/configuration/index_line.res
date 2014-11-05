<tr class=table_row_right>
    <td nowrap class="table_row" sorttable_customkey="<<:raw_run db esc:>>" align=right><a target=_blank class="link_header" style="text-decoration:none"  href="/runview/?run=<<:raw_run db enc:>>"
	onMouseOver="runDetails(<<:raw_run db js:>>);" onMouseOut="nd()" onClick="nd(); return true"
    ><<:raw_run db esc:>></a></td>
    
    <td nowrap class="table_row" sorttable_customkey="<<:filling_scheme db esc:>>" onMouseOver="overlibnz('<<:filling_scheme_longtext esc js:>>', CAPTION, 'Bunches / <<:raw_run db js esc:>>');" onMouseOut="nd()" onClick="editStatus(<<:raw_run db js esc:>>, 'filling_scheme')" align=right <<:filling_scheme_bgcolor:>>><<:filling_scheme db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:filling_config db esc:>>" onClick="editField('filling_config', <<:raw_run db js esc:>>)" align=right <<:filling_config_bgcolor:>>><<:filling_config db:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:fillno db esc:>>" onClick="editField('fillno', <<:raw_run db js esc:>>)" align=right><<:fillno db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:energy db esc:>>" onClick="editField('energy', <<:raw_run db js esc:>>)" align=right><<:energy db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:intensity_per_bunch db esc:>>" onClick="editField('intensity_per_bunch', <<:raw_run db js esc:>>)" align=right><<:intensity_per_bunch db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:mu db esc:>>" onClick="editField('mu', <<:raw_run db js esc:>>)" align=right><<:mu db ddot4:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:interacting_bunches db esc:>>" onClick="editField('interacting_bunches', <<:raw_run db js esc:>>)" align=right><<:interacting_bunches db:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:noninteracting_bunches_beam_1 db esc:>>" onClick="editField('noninteracting_bunches_beam_1', <<:raw_run db js esc:>>)" align=right><<:noninteracting_bunches_beam_1 db:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:noninteracting_bunches_beam_2 db esc:>>" onClick="editField('noninteracting_bunches_beam_2', <<:raw_run db js esc:>>)" align=right><<:noninteracting_bunches_beam_2 db:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:interaction_trigger db esc:>>" onClick="editField('interaction_trigger', <<:raw_run db js esc:>>)" align=right><<:interaction_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:rate db esc:>>" onClick="editField('rate', <<:raw_run db js esc:>>)" align=right><<:rate db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:beam_empty_trigger db esc:>>" onClick="editField('beam_empty_trigger', <<:raw_run db js esc:>>)" align=right><<:beam_empty_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:empty_empty_trigger db esc:>>" onClick="editField('empty_empty_trigger', <<:raw_run db js esc:>>)" align=right><<:empty_empty_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:muon_trigger db esc:>>" onClick="editField('muon_trigger', <<:raw_run db js esc:>>)" align=right><<:muon_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:high_multiplicity_trigger db esc:>>" onClick="editField('high_multiplicity_trigger', <<:raw_run db js esc:>>)" align=right><<:high_multiplicity_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:emcal_trigger db esc:>>" onClick="editField('emcal_trigger', <<:raw_run db js esc:>>)" align=right><<:emcal_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:calibration_trigger db esc:>>" onClick="editField('calibration_trigger', <<:raw_run db js esc:>>)" align=right><<:calibration_trigger db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:quality db esc:>>" onMouseOver="overlibnz('<<:quality_longtext esc js:>>', CAPTION, 'Global quality / <<:raw_run db js esc:>>');" onMouseOut="nd()" onClick="editStatusPerPass(<<:raw_run db js esc:>>, 'quality')" align=right <<:quality_bgcolor:>>><<:quality db ddot:>></td>
    <td nowrap class="table_row" sorttable_customkey="<<:muon_quality db esc:>>" onMouseOver="overlibnz('<<:muon_quality_longtext esc js:>>', CAPTION, 'Muon quality / <<:raw_run db js esc:>>');" onMouseOut="nd()" onClick="editStatusPerPass(<<:raw_run db js esc:>>, 'muon_quality')" align=right <<:muon_quality_bgcolor:>>><<:muon_quality db ddot:>></td>
    
    <td nowrap class="table_row" onMouseOver="overlibnz('<<:comment js esc:>>', CAPTION, 'Comment / <<:raw_run db js esc:>>');" onMouseOut="nd()" onDblClick="showCenteredWindow('<<:comment db js esc:>>', 'Comment of <<:raw_run db js esc:>>');" onClick="editFieldPerPass('comment', <<:raw_run db js esc:>>)"><<:comment db cut20 esc:>></td>
    <<:content:>>
    <td nowrap class="table_row" sorttable_customkey="<<:changedon db:>>"><a class=link onClick="showIframeWindowRight('history.jsp?run=<<:raw_run db enc:>>', 'Changelog for run <<:raw_run db js esc:>>', null, 1000);return false;" href="javascript:void(0)" onMouseOver="overlib('<<:changedon db date:>> <<:changedon db time:>>', CAPTION, '<<:changedby db js esc:>> / <<:raw_run db js esc:>>');" onMouseOut="nd();"><<:changedon db nicedate:>></a></td>
</tr>
