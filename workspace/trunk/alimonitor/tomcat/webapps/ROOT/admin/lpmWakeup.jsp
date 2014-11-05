<%
    for (String user: new String[]{"aliprod", "alitrain", "alidaq", "pwg_pp", "pwg_cf", "pwg_dq", "pwg_ga", "pwg_hf", "pwg_je", "pwg_lf", "pwg_ud"}){
	alien.managers.LPMManager.getInstance(user).wakeup();
    }
%>