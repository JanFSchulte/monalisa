#!/bin/bash

cd `dirname $0`

TARGET=/backup/pcalimonitor/DB-nondata/`date +%Y%m%d-%H%M`

mkdir -p $TARGET

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:../pgsql_store/lib
export PGLIB=../pgsql_store/lib

PSQL="./pgsql_console.sh -A -t -c"
DUMP="../pgsql_store/bin/pg_dump -h pcalimonitor2 -O -x -U monalisa mon_data"

$DUMP -s | pbzip2 -c -9 > $TARGET/schema.sql.bz2

COMPRESS="/usr/bin/lbzip2"

$PSQL "SELECT tablename FROM pg_tables WHERE tablename NOT LIKE 'w4_%' AND tablename NOT LIKE 'sql_%' AND tablename NOT LIKE 'pg_%';" | grep -v saved_bprevdata | while read table; do
     $DUMP -t $table | $COMPRESS > $TARGET/$table.sql.bz2
done
