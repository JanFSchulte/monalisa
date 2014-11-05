		  <a class=link target="_blank" href="/jobs/details.jsp?pid=<<:final_merge_job_id db enc:>>" onMouseOver="overlib('runlist: <<:runlist db esc:>>');" onMouseOut="nd()">Runlist <<:name_runlist:>>: Status of final merging job</a> 
<<:!com_error_submitting_start:>>
(<a href="/jobs/details.jsp?pid=<<:final_merge_last_id enc:>>" target=_blank class=link><font color=<<:final_merge_stage_status:>>>stage <<:final_merge_stage:>></font></a>) | 
		  <a class=link target="_blank" href="/catalogue/?path=/alice/cern.ch/user/a/alitrain/<<:test_path db enc:>>/merge<<:merge_dir:>>">merged files in FC</a>
<<:!com_error_submitting_end:>>
<<:com_error_submitting_start:>>
(<font color=red>Error submitting</font>)
<<:com_error_submitting_end:>>
<br>
