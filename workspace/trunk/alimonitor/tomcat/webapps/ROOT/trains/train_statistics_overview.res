<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
</head>
<body>

<form name=form2 method=post>
  <table border=0 cellspacing=0 cellpadding=8 class=text>
<tr>
    <<:com_apply_start:>>
    <tr>
      <td colspan=10>
	<<:map_time:>><img src="/display?image=<<:statistics_train_time:>>" usemap="#<<:statistics_train_time:>>" border=0>
      </td>
    </tr>  
    <tr>
      <td colspan=3>
	<select name=number_train class=input_select onChangex="javascript: document.forms['form1'].submit();">
	  <<:number_train_date:>>
      </td>
      <td>
	<input type=submit name=submit value="Apply" class=input_submit>
      </td>
      <td colspan=6>
	<<:com_show_warning_start:>>
	  Many elements of the statistics are only available from March 2013
	<<:com_show_warning_end:>>
      </td>
    </tr>
    <tr>
      <td colspan=10>
	<<:statistics_start2:>> Train statistics between the <<:statistics_start nicedate:>> and <<:statistics_end nicedate:>>
	  </td>
    </tr>
    <<:com_apply_end:>>
    <tr>
      <td align=center colspan=10>
	<H2> statistics for <<:statistics_kind:>> </H2>
      </td>
    </tr>
    <<:com_normal_start:>>
    <tr class="table_header">
      <td class="table_header_stats">
	PWG
      </td>
      <td class="table_header_stats">
	Number <br> of Trains
      </td>
      <td class="table_header_stats">
	Total Wall <br> Time
      </td>
      <td class="table_header_stats">
	Total Number <br> of train runs
      </td>
      <td class="table_header_stats">
	Total Number <br> of jobs
      </td>
      <td class="table_header_stats">
	average train <br> duration (run_end)
      </td>
      <td class="table_header_stats">
	average train duration <br> (merging finished)
      </td>
      <td class="table_header_stats">
	average train duration <br>(submit to <br> masterjobs submitted)
      </td>
      <td class="table_header_stats">
	average train duration <br>(masterjobs submitted to <br> final merge submitted)
      </td>
      <td class="table_header_stats">
	average train duration <br>(final merge submitted to <br> train finished)
      </td>
    </tr>
    <<:com_normal_end:>>
    <<:!com_normal_start:>>
    <tr class="table_header">
      <td class="table_header_stats">
	PWG
      </td>
      <td class="table_header_stats">
	Total Wall <br> Time
      </td>
      <td class="table_header_stats">
	Total ESD
      </td>
      <td class="table_header_stats">
	% of total <br> for ESD
      </td>
      <td class="table_header_stats">
	Total AOD
      </td>
      <td class="table_header_stats">
	% of total <br> for AOD
      </td>
      <td class="table_header_stats">
	Total MC ESD
      </td>
      <td class="table_header_stats">
	% of total <br> for MC ESD
      </td>
      <td class="table_header_stats">
	Total MC AOD
      </td>
      <td class="table_header_stats">
	% of total <br> for MC AOD
      </td>
    </tr>
    <<:!com_normal_end:>>
    <<:Number_train:>>
  </table>
  
  
</form>
</body>
</html>
