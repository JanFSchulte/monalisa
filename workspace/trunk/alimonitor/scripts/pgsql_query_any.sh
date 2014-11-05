#!/bin/bash

# Execute a query on any of the online backends. To be used ONLY FOR READ-ONLY (SELECT) queries!

WHEREAMI=$(cd `dirname $0`; pwd)

. $WHEREAMI/pgsql_functions.sh

if [ -z "$1" ]; then
    exit 1
fi

for DB in $BACKENDS; do
    if isOnline "$DB"; then
	varname="${DB}_script"
	
	script=${!varname}

	exec "$WHEREAMI/$script" -A -t -c "$@"
    fi
done
