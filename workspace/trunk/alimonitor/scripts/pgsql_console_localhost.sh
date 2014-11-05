#!/bin/bash

cd `dirname $0`/../pgsql_store

export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./lib
export PGLIB=`pwd`/lib

bin/psql -U mon_user -h 127.0.0.1 -p 5432 -d mon_data "$@"
