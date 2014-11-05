<form name=form1 action=display method=post>
    <input type=hidden name=page value="<<:page:>>">
</form>
<map name=imgmap>
<<:map:>>
</map>
<table width=600 cellspacing=0 cellpadding=0>
<tr><th><font style="font-family:Verdana,Helvetica,Arial;font-size:16px"><<:title:>></font></th></tr>
<tr><td><img src="display?image=<<:image:>>" usemap=#imgmap border=0></td></tr>
<tr><td align=left>
    <br>
    <br>
    <font style="font-family:Verdana,Helvetica,Arial;font-size:10px">
	<<:description:>>
    </font>
</td></tr>
</table>
