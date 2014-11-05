<%@ page import="java.util.*,java.io.*,java.text.SimpleDateFormat,java.awt.Color,lia.web.utils.*,lia.Monitor.Store.Fast.DB,lia.web.servlets.web.*,lia.web.utils.*,lia.Monitor.monitor.*,lia.Monitor.Store.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /PWG/admin/users.jsp", 0, request);

    String server = 
	request.getScheme()+"://"+
	request.getServerName()+":"+
	request.getServerPort()+"/";	
    
    ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final String BASE_PATH=SITE_BASE+"/";
    
    final String RES_PATH=SITE_BASE+"/PWG";
    
    ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    Page pMaster = new Page(baos, BASE_PATH+"/WEB-INF/res/masterpage/masterpage.res");
    Page pIndex = new Page(RES_PATH+"/admin/index.res");

    DB db = new DB();
    
    pMaster.modify("title", "Physics Working Group - Users Admin");
    
    // -------------------
    
    String sMethod = request.getMethod().toLowerCase();
    String sAction = request.getParameter("action") == null ? "1" : request.getParameter("action");
    
    
    if("get".equals(sMethod)){
	//groups
	if("1".equals(sAction)){
	    Page pGroups = new Page(RES_PATH+"/admin/groups.res");	    
	    Page pAddGroup = new Page(RES_PATH+"/admin/add_group.res");	    
	    
	    String sGroupId = request.getParameter("gid") == null ? "" : request.getParameter("gid");
	
	    //edit group
	    if(sGroupId.length() > 0){
		String sQuery = "SELECT * FROM pwg_groups WHERE pg_id="+sGroupId;
		db.query(sQuery);
		
		pAddGroup.modify("pg_id", sGroupId);
		pAddGroup.modify("pg_name", db.gets("pg_name"));
	    }	
    
	    pGroups.append(pAddGroup);
	    
	    //listing
	    Page pGroupsEl = new Page(RES_PATH+"/admin/groups_el.res");
	    
	    String sQuery = "SELECT * FROM pwg_groups ORDER BY pg_id DESC;";
	    db.query(sQuery);
	    
	    int iCnt = 0;
	    
	    while(db.moveNext()){
		if(!sGroupId.equals(db.gets("pg_id"))){
		    pGroupsEl.modify("pg_id", db.geti("pg_id"));
		    pGroupsEl.modify("pg_name", db.gets("pg_name"));
		
		    pGroupsEl.modify("color", iCnt%2 == 0 ? "#FFFFFF" : "#F0F0F0");
		    iCnt++;
		
		    pGroups.append(pGroupsEl);
		}
	    }
	    
	    pIndex.modify("groups", "_active");
	    pIndex.append(pGroups);
	}
    
	//users
	if("2".equals(sAction)){
	    Page pUsers = new Page(RES_PATH+"/admin/users.res");
	    Page pAddUser = new Page(RES_PATH+"/admin/add_user.res");	    
	    
	    
	    String sUserId = request.getParameter("uid") == null ? "" : request.getParameter("uid");
	
	    //edit user
	    
	    int iGroupId = 0;
	    
	    if(sUserId.length() > 0){
		String sQuery = "SELECT * FROM pwg_users WHERE pu_id="+sUserId;
		db.query(sQuery);
		
		pAddUser.fillFromDB(db);	
		
		iGroupId = db.geti("gu_group");
	    }	

	    String sQuery = "SELECT * FROM pwg_groups ORDER BY pg_name";
	    db.query(sQuery);
		
	    String sSelect = "";
		
	    while(db.moveNext()){
	        sSelect = "<option value="+db.geti("pg_id")+" "+(iGroupId == db.geti("gp_id") ? "" : "selected")+">"+db.gets("pg_name")+"</option>";
	        pAddUser.append("group", sSelect);
	    }
    
	    pUsers.append(pAddUser);

	    //listing
	    Page pUsersEl = new Page(RES_PATH+"/admin/users_el.res");

	    sQuery = "SELECT * FROM pwg_users INNER JOIN pwg_groups ON pu_group=pg_id ORDER BY pu_id DESC";
	    db.query(sQuery);
	    	    
	    int iCnt = 0;
	    
	    while(db.moveNext()){
		if(!sUserId.equals(db.gets("pu_id"))){
	     
		    pUsersEl.fillFromDB(db);
		
		    pUsersEl.modify("color", iCnt%2 == 0 ? "#FFFFFF" : "#F0F0F0");
		    iCnt++;
		                                        
		    pUsers.append(pUsersEl);
		}	
	    }
	    
	    pIndex.modify("users", "_active");
	    pIndex.append(pUsers);
	}
	
	//delete group
	if("3".equals(sAction)){
	    String sGroupId = request.getParameter("gid") == null ? "" : request.getParameter("gid"); 
	    String sQuery = "SELECT COUNT(1) AS cnt FROM pwg_users WHERE pu_group="+Formatare.mySQLEscape(sGroupId);
	    
	    db.query(sQuery);
	    
	    //only if we do not have users
	    if(db.geti("cnt") == 0){
		sQuery = "DELETE FROM pwg_groups WHERE pg_id="+Formatare.mySQLEscape(sGroupId);
		db.query(sQuery);
	    }
	    
	    response.sendRedirect("/PWG/admin/users.jsp?action=1");
	    return;

	}
	
	//delete user
	if("4".equals(sAction)){
	    String sUserId = request.getParameter("uid") == null ? "" : request.getParameter("uid");
	    
	    String sQuery = "DELETE FROM pwg_users WHERE pu_id="+Formatare.mySQLEscape(sUserId);
	    db.query(sQuery);
	        
	    response.sendRedirect("/PWG/admin/users.jsp?action=2");
	    return;
	}
    }
    
    if("post".equals(sMethod)){
	//groups
	if("1".equals(sAction)){
	    String sGroupId = request.getParameter("gid") == null ? "" : request.getParameter("gid");
	    String sGroupName = request.getParameter("group") == null ? "" : request.getParameter("group");
	
	    String sQuery;
	    
	    if(sGroupId.length() == 0)
		sQuery = "INSERT INTO pwg_groups (pg_name) VALUES ('"+Formatare.mySQLEscape(sGroupName)+"')";
	    else
		sQuery = "UPDATE pwg_groups SET pg_name='"+Formatare.mySQLEscape(sGroupName)+"' WHERE pg_id="+sGroupId;
	
	    db.query(sQuery);
	    
	    response.sendRedirect("/PWG/admin/users.jsp?action=1");
	    return;
	}

	if("2".equals(sAction)){
	    String sUserId = request.getParameter("uid") == null ? "" : request.getParameter("uid");
	    String sUserGroup = request.getParameter("group") == null ? "" : request.getParameter("group");
	    String sUserRole = request.getParameter("role") == null ? "" : request.getParameter("role");
	    String sUserName = request.getParameter("username") == null ? "" : request.getParameter("username");
	    String sUserEmail = request.getParameter("email") == null ? "" : request.getParameter("email");
	    
	    String sQuery;
	    
	    if(sUserId.length() == 0){
		sQuery = "INSERT INTO pwg_users (pu_group, pu_username, pu_email) VALUES "+
			" ("+Formatare.mySQLEscape(sUserGroup)+", '"+Formatare.mySQLEscape(sUserName)+"', "+
			" '"+Formatare.mySQLEscape(sUserEmail)+"')";
	    }
	    else{
		sQuery = "UPDATE pwg_users SET pu_group="+Formatare.mySQLEscape(sUserGroup)+", pu_username='"+Formatare.mySQLEscape(sUserName)+"', "+
				" pu_email='"+Formatare.mySQLEscape(sUserEmail)+"' WHERE pu_id="+Formatare.mySQLEscape(sUserId);
	    }
	    
	    db.query(sQuery);

            response.sendRedirect("/PWG/admin/users.jsp?action=2");
            return;
	    
	}
    }
    // -------------------
    
    pMaster.append(pIndex);
    
    pMaster.comment("com_alternates", false);    
    pMaster.modify("comment_refresh", "//");
    
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/PWG/admin/users.jsp", baos.size(), request);
%>
