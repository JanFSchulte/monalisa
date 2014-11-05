#!/bin/bash

if [ -z "$2" ]
then
  echo "reset-finalmerging.sh <train-id> <run-id>"
  exit 0
fi

./pgsql_update_all.sh "update train_run set final_merge_job_id=0 where train_id = $1 and id = $2;"
