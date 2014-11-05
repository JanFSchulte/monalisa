# Where are the log files and the status for each backend
LOGDIR="/home/monalisa/MLrepository/replication"

# Available backends
BACKENDS="pcalimonitor3 pcalimonitor2"

# Configuration for each
localhost_script="pgsql_console_localhost.sh"
localhost_ip="127.0.0.1"

aliendb9_script="pgsql_console_aliendb9.sh"
aliendb9_ip="137.138.47.222"

pcalimonitor2_script="pgsql_console_pcalimonitor2.sh"
pcalimonitor2_ip="137.138.47.215"

pcalimonitor3_script="pgsql_console_pcalimonitor3.sh"
pcalimonitor3_ip="137.138.47.226"

# @param 1 DB backend name
# @return 0 if online, 1 if not
function isOnline(){
    name="$1"

    varname=${name}_ip
    
    IP=${!varname}
    
    DIR="$LOGDIR/$IP:5432:mon_data"
    
    STATUS=`cat "$DIR/status" 2>/dev/null`
    
    if [ "$STATUS" == "1" ]; then
	return 0
    fi
    
    return 1
}

# @param 1 DB backend name
# @return path to the complete file name that should contain the log
function getLogFile(){
    varname=${name}_ip
    
    IP=${!varname}
    
    DIR="$LOGDIR/$IP:5432:mon_data"

    LASTFILE=`cat "$DIR/last_script_file"`
    
    NEW="YES"
    
    if [ ! -z "$LASTFILE" -a -f "$DIR/$LASTFILE" ]; then
	if [ `stat -c %s "$DIR/$LASTFILE"` -lt 10000000 ]; then
	    NEW=""
	fi
    fi

    if [ ! -z "$NEW" ]; then
	NANO=`date +%s%N`
	LASTFILE=${NANO:0:${#NANO}-6}
	echo "$LASTFILE" > "$DIR/last_script_file"
    fi
    
    echo "$DIR/$LASTFILE"
}

# @param 1 DB backend name
# @param 2 query to log
# @return 0 if ok, 1 if error
function logQuery(){
    ESCQUERY=`$WHEREAMI/urlencode <<< $2`

    filename=`getLogFile "$DB"`
    
    echo "$ESCQUERY" >> "$filename"
}
