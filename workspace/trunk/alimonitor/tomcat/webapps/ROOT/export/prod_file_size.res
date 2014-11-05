<html>
<head>
    <script type="text/javascript" src="/overlib/overlib.js"></script>
    <title><<:pattern esc:>> size distribution in <<:path esc:>></title>
</head>
<body>
<form name=form1>
    Base path: <input type="text" name="path" value="<<:path esc:>>"> , search pattern: <input type="text" name="pattern" value="<<:pattern esc:>>"> , file size threshold: <input type=text name=threshold value="<<:threshold esc:>>">
    <input type=submit name=submit value="Display">
</form>
<<:map:>>
<img src="/display?image=<<:image:>>" usemap="#<<:image:>>" border=0><br>
<br>
Above <<:threshold size:>> : <<:above:>> files (<<:above_percentage ddot:>>%)<br>
Below <<:threshold size:>> : <<:below:>> files (<<:below_percentage ddot:>>%)
</body>
</html>
