<script type="text/javascript">
function openFiles(id){
    sHTML = '<iframe src="/productions/train/index.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    showCenteredWindow(sHTML, 'Train '+id);
    return false;
}
function openDownload(id){
    sHTML = '<iframe src="/productions/train/download.jsp?id='+id+'" border=0 frameborder="0" marginwidth="0" marginheight="0" scrolling="auto" align="absmiddle" vspace="0" hspace="0" width=98% height=95%></iframe>';
    showCenteredWindowSize(sHTML, 'Output of train '+id, 600, 400);
    return false;
}
</script>
<table cellspacing=0 cellpadding=2 class="table_content" align="left" height="500" width="100%">
    <tr height="25">
	<td class="table_title"><b>PRODUCTION CYCLES</b></td>
    </tr>
    <tr height="25">
	<td>
	    <table border=0 cellspacing=0 cellpadding=0 width=100%>
		<tr>
		    <td align=right><a class=link target=_blank href="/admin/job_types.jsp">Manage productions &raquo;</a></td>
		</tr>
	    </table>
	</td>
    </tr>
    <tr>
	<td valign="top">
	    <form name=form1 method=post action="/prod/">
	    <input type=hidden name=t value="<<:t:>>">
	    <table cellspacing=1 cellpadding=2 width="100%" class=sortable>
		<thead>
		<<:com_analysis_start:>>
		<tr class="table_header">
		    <td class="table_header" colspan=7 align=left>Production type: 
			<select class=input_select name=prod_type onChange="modify()">
			    <option value="FILTER" <<:prod_type_FILTER:>>>AOD</option>
			    <option value="QA" <<:prod_type_QA:>>>QA</option>
			    <option value="PWGCF" <<:prod_type_PWGCF:>>>PWGCF</option>
			    <option value="PWGLF" <<:prod_type_PWGLF:>>>PWGLF</option>
			    <option value="PWGHF" <<:prod_type_PWGHF:>>>PWGHF</option>
			    <option value="PWGUD" <<:prod_type_PWGUD:>>>PWGUD</option>
			    <option value="PWGDQ" <<:prod_type_PWGDQ:>>>PWGDQ</option>
			    <option value="PWGJE" <<:prod_type_PWGJE:>>>PWGJE</option>
			    <option value="PWGGA" <<:prod_type_PWGGA:>>>PWGGA</option>
			    <option value="PWGPP" <<:prod_type_PWGPP:>>>PWGPP</option>
			    <option value="ALL" <<:prod_type_ALL:>>>- All -</option>
			</select>
		    </td>
		    <td class="table_header" colspan=12></td>
		</tr>
		<<:com_analysis_end:>>
		<tr class="table_header">
		    <td class="table_header" colspan=7>Production info</td>
		    <td class="table_header" colspan=4>Jobs status</td>
		    <td class="table_header" colspan=3 align=right></td>
		    <td class="table_header" colspan=1 align=right></td>
		    <td class="table_header" colspan=1 align=right><input type=submit class=input_submit name=s value="&raquo;"></td>
		    <td class="table_header" colspan=2 align=right>Timing</td>
		    <td class="table_header" colspan=1 align=right>Output</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=jt_id style="width:100%" value="<<:jt_id esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=jt_field1 style="width:100%" value="<<:jt_field1 esc:>>"></td>
		    <td class="table_header">
			<!--
			<select name=jt_field2 class=input_select onChange="modify()">
			    <option value="">- Any -</option>
			    <<:opt_jt_field2:>>
			</select>
			-->
		    </td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=completion style="width:100%" value="<<:completion esc:>>"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text name=total_jobs style="width:100%" value="<<:total_jobs esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text name=done_jobs style="width:100%" value="<<:done_jobs esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text name=running_jobs style="width:100%" value="<<:running_jobs esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);"  class=input_text name=waiting_jobs style="width:100%" value="<<:waiting_jobs esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=nr_runs style="width:100%" value="<<:nr_runs esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=train_passed style="width:100%" value="<<:train_passed esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=train_output style="width:100%" value="<<:train_output esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=jt_type style="width:100%" value="<<:jt_type esc:>>"></td>
		    <td class="table_header"><input type=text onFocus="focusText(this, 100);" onBlur="blurText(this);" class=input_text name=comment style="width:100%" value="<<:comment esc:>>"></td>
		    <td class="table_header" colspan=3>(done jobs only)</td>
		</tr>
		<tr class="table_header">
		    <td class="table_header">ID</td>
		    <td class="table_header">Tag</td>
		    <td class="table_header">Status</td>
		    <td class="table_header">Done%</td>
		    <td class="table_header">Cfg</td>
		    <td class="table_header">Out</td>
		    <td class="table_header">Links</td>
		    <td class="table_header">Total</td>
		    <td class="table_header">Done</td>
		    <td class="table_header">Active</td>
		    <td class="table_header">Waiting</td>
		    <td class="table_header">Runs</td>
		    <td class="table_header">Output<br>events</td>
		    <td class="table_header">Filtered<br>events</td>
		    <td width=70% class="table_header">Production description</td>
		    <td width=30% class="table_header">Comment</td>
		    <td class="table_header">Running</td>
		    <td class="table_header">Saving</td>
		    <td class="table_header">Size</td>
		</tr>
		</thead>
		<tbody>
		<<:continut:>>
		</tbody>
		<tfoot>
		<tr class="table_header">
		    <td class="table_header" colspan=2><<:cnt esc:>> productions</td>
		    <td class="table_header"></td>
		    <td class="table_header" bgcolor="<<:rate_bgcolor:>>"><<:tcompletion:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:ttotal_jobs:>></td>
		    <td class="table_header"><<:tdone_jobs:>></td>
		    <td class="table_header"><<:trunning_jobs:>></td>
		    <td class="table_header"><<:twaiting_jobs:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"><<:ttrain_passed ddot:>></td>
		    <td class="table_header"><<:ttrain_output ddot:>></td>
		    <td class="table_header"></td>
		    <td class="table_header"></td>
		    <td class="table_header" nowrap><<:wall_time intervalh:>></td>
		    <td class="table_header" nowrap><<:saving_time intervalh:>></td>
		    <td class="table_header" nowrap><<:outputsize size:>></td>
		</tr>
		</tfoot>
	    </table>
	    </form>
	</td>
    </tr>
</table>
