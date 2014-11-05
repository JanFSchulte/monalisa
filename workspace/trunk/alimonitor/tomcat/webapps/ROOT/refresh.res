<html>
<head>
<title>y</title>
<script type="text/javascript">
var refreshTime = <<:refreshTime:>>;

function refreshFrame(){
    window.frame1.location.reload();
    
    setTimeout('refreshFrame()', refreshTime);
}

setTimeout('refreshFrame()', refreshTime);
</script>
</head>
<frameset>
    <frame name="frame1" src="<<:path esc:>>">
</frameset>
</html>
