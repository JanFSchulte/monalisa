<table border=0 cellspacing=0 cellpadding=2 bgcolor=#DDDDDD class=alternate>
    <tr>
	<td>
	    <table border=0 cellspacing=1 cellpadding=2 class="alternate" bgcolor=#9D9AAF>
		<tr bgcolor="#CCCCCC">
		    <th>ID</td>
		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(6, '')" href="javascript: void(0);">Category</a></td>
		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(1, '')" href="javascript: void(0);">Message</a></td>
    		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(2, '')" href="javascript: void(0);">Applies to</a></td>
		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(3, '')" href="javascript: void(0);">Duration</a></td>
		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(4, 'desc')" href="javascript: void(0);">Start</a><img src="/img/asc_trend.png" border="0"></td>
		    <td align="center"><a class="link" onclick="return submitfilterAnnotations(5, '')" href="javascript: void(0);">End</a></td>
		    <th>Options</td>
		</tr>
		<tr bgcolor="#FFFFFF">
		    <td></td>
		    <td><select class="input_select" name="groups" onchange="document.forms.filterAnnotations.submit();">
    			<option value="">All</option>
			</select>
		    </td>
		    <td><input type="text" name="filter_1" value="" class="input_text"></td>   
		    <td><input type="text" name="filter_2" value="" class="input_text"></td>
		    <td></td>
		    <td>
			<select name="filter_4" class="input_select" onchange="document.forms.filterAnnotations.submit();">
    			    <option value="1" >Last Day</option>	    	
    			    <option value="7" >Last Week</option>
    			    <option value="30" >Last Month</option>	    
    			    <option value="365" >Last Year</option>
    			    <option value="-1" selected>All</option>	    	    
			</select>
		    </td>
		    <td>
			<select name="filter_5" class="input_select" onchange="document.forms.filterAnnotations.submit();">
    			    <option value="0" >All</option>
    			    <option value="1" >Continues</option>	    
			</select>
		    </td>
		    <td><input type="submit" name="buton" value="Submit" class="input_submit"></td>
		</tr>
	    </table>
	</td>
    </tr>
</table>