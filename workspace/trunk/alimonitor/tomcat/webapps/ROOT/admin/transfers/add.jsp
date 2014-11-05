<%@ page import="lazyj.*,alien.managers.*,lia.Monitor.Store.Fast.DB" %><%
    final RequestWrapper rw = new RequestWrapper(request);
    
    final String sTargetSE = rw.gets("se");
    final String sDataSet = rw.gets("path");
    final boolean bSkipIfPreviousllyTransferredOK = rw.getb("skip", false);
    
    if (sTargetSE.length()==0 || sDataSet.length()==0){
%>
	<form action=add.jsp method=post>
	    <table border=0 cellspacing=10 cellpadding=0>
		<tr>
		    <td>AliEn path:</td>
		    <td><input type=text name=path value="" class=input_text style="width:350px"></td>
		    <td>Folder, collection, or path|filter in `find` style, or VO::SE::NAME</td>
		</tr>
		<tr>
		    <td>Target SE name:</td>
		    <td><select name=se class=input_select>
		    <%
			final DB db = new DB("select se_name from list_ses ;");
			while (db.moveNext()){
			    String s = Format.escHtml(db.gets(1));
			    out.println("<option value='"+s+"'>"+s+"</option>");
			}
		    %>
		    </select></td>
		</tr>
		<tr>
		    <td>Skip known files:</td>
		    <td><input type=checkbox value=1 name=skip checked class=input_checkbox></td>
		    <td>if the same files were previously transferred using this interface, skip checking</td>
		</tr>
		<tr>
		    <td>&nbsp;</td>
		    <td><input type=submit value="Add request..." class=input_text>
		</tr>
	    </table>
	</form>
<%
	return;
    }
    
    final int id = TransferManager.getInstance().insertTransferRequest(sTargetSE, sDataSet, bSkipIfPreviousllyTransferredOK);
    
    out.println("New transfer ID : "+id);
%>