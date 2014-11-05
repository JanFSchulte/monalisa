<html>
    <head>
	<title>Choose your role</title>

	<script type="text/javascript" src="/overlib/overlib.js"></script>
	<script type="text/javascript" src="/overlib/overlib_crossframe.js"></script>
	<script type="text/javascript" src="/js/window/window.js"> </script> 
	<script type="text/javascript" src="/js/window/windowutils.js"> </script> 
	<script type="text/javascript" src="/js/window/prototype.js"> </script>

	<script type="text/javascript">
	
    var oldrole='<<:role js:>>';
	
    function changeRoleTo(newrole){
	document.getElementById(oldrole).style.fontWeight='normal';
	document.getElementById(newrole).style.fontWeight='bold';
	oldrole = newrole;
    }
	
    function switchRole(newrole){
	var url = '/users/su.jsp?role='+escape(newrole);

	new Ajax.Request(url, {
	    method: 'get',
	    onComplete: function(transport) {
		if(transport.status == "200" || transport.status == 0){
		    //alert (transport.responseText);
		
		    if(transport.responseText.indexOf('OK') < 0){
		        alert(transport.responseText);
		        
		        return false;
		    }
		    else{
			changeRoleTo(newrole);
		    }
		}
		else{
		    alert("Error: "+transport.status);
		    return false;
		}
	    	
		}
	    }
	);
	
	return false;
    }

	</script>
	
    </head>
    <body>
	<dl>
	    <dt><b>Choose your role:</b><br clear=all></dt>
	    <<:content:>>
	</dl>
	
	<<:admin_start:>>
	<form action=su.jsp>
	    <input type=hidden name=redirect value=true>
	    Any other role: <input type=text name=role> <input type=submit name=submit value="su">
	</form>
	<<:admin_end:>>
    </body>
</html>
