<html>
<body style="font-family:Verdana,Helvetica,Times,Arial; font-size:10px">
    Run stored: <<:mintime db nicedate:>> <<:mintime db time:>><br>
    Run type: <<:runtype db esc:>><br>
    <<:chunks db:>> chunks, <<:size db size:>><br>
    <br>
    Reconstructed events: <<:events db dot esc:>><br>
    CAF reconstruction status: <font color=<<:caf_status_color:>>><<:caf_status:>></font><br>
    CAF reconstructed events: <<:rm_value_events db dot esc:>><br>
    <br>
    SHUTTLE status: <font color=<<:shuttle_color:>>><<:shuttle_status db esc:>></font><br>
    DAQ good run: <<:daq_goodrun:>><br>
    DAQ QA flags: <<:daq_detectors:>><br>
    <br>
    Archived to tape: <<:on_tape:>><br>
    Transferred to T1: <<:on_t1:>><br>
    <br>
    Participating detectors:<br>
    <<:detectors:>>
</body>
</html>
