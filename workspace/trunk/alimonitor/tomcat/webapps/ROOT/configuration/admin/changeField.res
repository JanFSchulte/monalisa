<html>
<head>

<script type="text/javascript" src="/overlib/overlib.js"></script>
<script type="text/javascript" src="/overlib/overlib_crossframe.js"></script>
<script type="text/javascript" src="/js/tooltips.js"></script>
<link type="text/css" rel="StyleSheet" href="/style/style.css" />

<style>
a:link,
a:active,
a:visited{
	color: #3A6C9A;
	text-decoration: none
}

a:hover{
	color: #3A6C9A;
	text-decoration: underline
}                                                
</style>

</head>
<body class=text>
    <table border=0 cellspacing=2 cellpadding=0 class=text>
	<form name=form2>
	<input type=hidden name=run value="<<:run esc:>>">
	<input type=hidden name=field value="<<:field esc:>>">
	<input type=hidden name=pass value="<<:pass esc:>>">
	<tr>
	    <td>Run range:</td>
	    <td><input class=input_text type=text name=runrange value="<<:run esc:>>"></td>
	</tr>
	<tr>
	    <td><<:field:>> value:</td>
	    <td><input class=input_text type=text name=value value="<<:value esc:>>"></td>
	</tr>
	<tr>
	    <td></td>
	    <td><input type=submit name=s class=input_submit value="Update configuration"></td>
	</tr>
	</form>
    </table>
</body>
</html>
