#!/bin/bash

for ID in `../pgsql_query_any.sh "select pid from lpm_history where jdl like '%32_20111211-1422/lego_train%' and status=0;"`; do
#for ID in `../pgsql_query_any.sh "select pid from lpm_history where jdl like '%32_20111211-1422/lego_train%';"`; do
    (
	date +"%s"
	/opt/alien/bin/alien login -exec "masterJob $ID" 2>&1 | grep "Subjobs in "
    ) >> $ID.log
done
