<html>
<body style="font-family:Verdana,Helvetica,Times,Arial; font-size:10px">
    First seen: <<:firstseen db nicedate:>> <<:firstseen db time:>><br>
    Last seen: <<:lastseen db nicedate:>> <<:lastseen db time:>><br>
    <br>
    <b>Subjobs: <<:TOTAL:>></b><br>
    <br>
    <<:com_WAITING_start:>><font color=#AAAA00>Waiting: <<:WAITING:>> <<:WAITING_percent:>></font><br><<:com_WAITING_end:>>
    <<:com_STARTED_start:>><font color=black>Started: <<:STARTED:>> <<:STARTED_percent:>></font><br><<:com_STARTED_end:>>
    <<:com_RUNNING_start:>><font color=green>Running: <<:RUNNING:>> <<:RUNNING_percent:>></font><br><<:com_RUNNING_end:>>
    <<:com_SAVING_start:>><font color=magenta>Saving: <<:SAVING:>> <<:SAVING_percent:>></font><br><<:com_SAVING_end:>>
    <<:com_DONE_start:>><font color=blue>Done: <<:DONE:>> <<:DONE_percent:>></font><br><<:com_DONE_end:>>
    <<:com_TOTAL_ERRORS_start:>><font color=red>Errors: <<:TOTAL_ERRORS:>> <<:TOTAL_ERRORS_percent:>></font><br><<:com_TOTAL_ERRORS_end:>>
    <div style="padding-left:15px">
	<<:com_ERROR_V_start:>>ERROR_V: <<:ERROR_V:>> <<:ERROR_V_percent:>><br><<:com_ERROR_V_end:>>
	<<:com_ERROR_SV_start:>>ERROR_SV: <<:ERROR_SV:>> <<:ERROR_SV_percent:>><br><<:com_ERROR_SV_end:>>
	<<:com_ERROR_E_start:>>ERROR_E: <<:ERROR_E:>> <<:ERROR_E_percent:>><br><<:com_ERROR_E_end:>>
	<<:com_ERROR_IB_start:>>ERROR_IB: <<:ERROR_IB:>> <<:ERROR_IB_percent:>><br><<:com__end:>><<:com_ERROR_IB_end:>>
	<<:com_ERROR_VN_start:>>ERROR_VN: <<:ERROR_VN:>> <<:ERROR_VN_percent:>><br><<:com_ERROR_VN_end:>>
	<<:com_ERROR_VT_start:>>ERROR_VT: <<:ERROR_VT:>> <<:ERROR_VT_percent:>><br><<:com_ERROR_VT_end:>>
	<<:com_ERROR_EW_start:>>ERROR_EW: <<:ERROR_EW:>> <<:ERROR_EW_percent:>><br><<:com_ERROR_EW_end:>>
	<<:com_ERROR_RE_start:>>ERROR_RE: <<:ERROR_RE:>> <<:ERROR_RE_percent:>><br><<:com_ERROR_RE_end:>>
	<<:com_ERROR_SPLT_start:>>ERROR_SPLT: <<:ERROR_SPLT:>> <<:ERROR_SPLT_percent:>><br><<:com_ERROR_SPLT_end:>>
	<<:com_EXPIRED_start:>>EXPIRED: <<:EXPIRED:>> <<:EXPIRED_percent:>><br><<:com_EXPIRED_end:>>
	<<:com_ZOMBIE_start:>>ZOMBIE: <<:ZOMBIE:>> <<:ZOMBIE_percent:>><br><<:com_ZOMBIE_end:>>
    </div>
</body>
</html>