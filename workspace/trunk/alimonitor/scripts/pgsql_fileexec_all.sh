#!/bin/bash

WHEREAMI=$(cd `dirname $0`; pwd)

. $WHEREAMI/pgsql_functions.sh

FILE="$1"
ESCQUERY=""

if [ ! -s "$FILE" ]; then
    exit 1
fi

for DB in $BACKENDS; do
    if isOnline "$DB"; then
	varname="${DB}_script"
	
	script=${!varname}
	
	"$WHEREAMI/$script" -A -t < "$FILE"
    else
	cat $FILE | while read QUERY; do
	    logQuery "$DB" "$QUERY"
	done
    fi
done
