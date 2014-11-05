<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link type="text/css" rel="StyleSheet" href="/style/style.css" />
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/combined-1334673986.yui.js"></script>
</head>
<body>
<form name=form1>
<input type="hidden" name="train_id_field" value="<<:train_id_field:>>">
<input type="hidden" name="wagon_name_field" value="<<:wagon_name_field:>>">
  <table border=0 cellspacing=0 cellpadding=2 class=text>
  <tr><td>
	  <div style="border-style: solid; border-width: 1px; padding: 5px;">
	  <b>Dataset testing statistics</b><br>
	  Dataset: 
	    <select name=dataset_statistic class=input_select onChangex="javascript: document.forms['form1'].submit();">
	      <<:dataset_statistic:>>
	    </select>
	    <input type=submit name=submit value="Update" class=input_submit><br>
	    <<:map:>><img src="/display?image=<<:statistic_cpu:>>" usemap="#<<:statistic_cpu:>>" border=0>
	  </div>
  </tr></td>
  </table>
 </form>
</body>
</html>
