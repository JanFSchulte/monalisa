<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type=text/javascript>
function fitIntoScreen(max, xOry){
    var w = window,
	d = document,
	e = (d) ? d.documentElement : 0,
	g = (d && d.getElementsByTagName('body')) ? d.getElementsByTagName('body')[0] : 0,
	x = ((w) ? w.innerWidth : 0) || ((e) ? e.clientWidth : 0) || ((g) ? g.clientWidth : 0) || (max+50),
	y = ((w) ? w.innerHeight : 0) || ((e) ? e.clientHeight : 0) || ((g) ? g.clientHeight : 0) || (max+70);
	
    x -= 50;
    y -= 70;
	
    if (x > max)
      x = max;
      
    if (y > max)
      y = max;

    return (xOry == true) ? x : y;
}

function editRun(train_id, id){
    x = fitIntoScreen(950, true);
    y = fitIntoScreen(700, false);

    showIframeWindowSize('train_edit_run.jsp?train_id='+escape(train_id)+'&id='+escape(id), id>0 ? 'Editing run <b>'+id+'</b>' : 'Creating new run', x, y);
    
// JF: not needed here, because reload is triggered by save action
     //Windows.addObserver(obs);
}
</script>
</head>
<body>

<form name=form2 method=post>
  <table border=0 cellspacing=0 cellpadding=3 class=text>
    <tr>
      <td colspan=2>
	x axis:
	<input type=text size=30 name="maxShownRunningTime" value="" class=input_text>
	y axis:
	<input type=text size=30 name="maxY_value" value="" class=input_text>
      </td>
      <td>
	<input type=submit name=submit value="Apply" class=input_submit>
      </td>
    </tr>
    <tr>
      <td colspan=2>
	show statistics only for train
	<select name=available_train_ids class=input_select onChangex="javascript: document.forms['form1'].submit();">
	  <<:available_train_id:>>
      </td>
    </tr>
    <tr>
      <td>
	xaxis:
	<select name=xvalue_statistics class=input_select onChangex="javascript: document.forms['form1'].submit();">
	  <<:xvalue_statistics:>>
      </td>
      <td>
	yaxis:
	<select name=yvalue_statistics class=input_select onChangex="javascript: document.forms['form1'].submit();">
	  <<:yvalue_statistics:>>
      </td>
      <td>
	<<:percentage_shown ddot1:>>% of the points are shown
      </td>
    </tr>
    <tr>
      <td>
	<input type=submit name=submit value="Export points" class=input_submit>
      </td>
    </tr>
    <tr>
      <td colspan=3>
	<<:map_time:>><img src="/display?image=<<:statistics_time:>>" usemap="#<<:statistics_time:>>" border=0>
      </td>
    </tr>  
  </table>
  
  <table border=0 cellspacing=0 cellpadding=3 class=text>
    <tr>
      <td colspan=3>
	<span class="title_content">find critical trains</span><br>
	<select name=find_error_state class=input_select>
	  <<:found_errors:>>
      </td>
    </tr>
    <tr>
      <td colspan=5>
	Number of accepted last train runs
	<input type=text size=10 name="lastRuns" value=<<:lastRuns_size:>> class=input_text> 
	<input type=submit name=submit value="Apply" class=input_submit> 
	<br>
      </td>
    </tr>
    <tr class="table_header">
      <td class="table_header_stats">
	train_id
      </td>
      <td class="table_header_stats">
	id
      </td>
      <td class="table_header_stats">
	jobs
      </td>
      <td class="table_header_stats">
	total jobs
      </td>
      <td class="table_header_stats">
	percentage
      </td>
      <td class="table_header_stats">
	final merge
      </td>
    </tr>
    <<:found_errors_ids:>>
  </table>

<<:statistics_points:>>
      
</form>
</body>
</html>
