#!/bin/bash

# Execute an update query on all DB backends
# Online backends will execute the query right away, while for the offline ones the query will be added to the log

WHEREAMI=$(cd `dirname $0`; pwd)

. $WHEREAMI/pgsql_functions.sh

QUERY="$1"
ESCQUERY=""

if [ -z "$QUERY" ]; then
    exit 1
fi

for DB in $BACKENDS; do
    if isOnline "$DB"; then
	varname="${DB}_script"
	
	script=${!varname}
	
	"$WHEREAMI/$script" -A -t -c "$QUERY"
    else
	logQuery "$DB" "$QUERY" 
    fi
done
