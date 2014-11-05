#!/bin/bash

if [ -z "$3" ]
then
  echo "Syntax: create-train.sh <train-name> <pwg> <admin>"
  exit 0
fi

TRAIN_ID=`./pgsql_query_any.sh "SELECT MAX(train_id) FROM train_def"`
let TRAIN_ID=$TRAIN_ID+1
echo $TRAIN_ID
./pgsql_update_all.sh "INSERT INTO train_def (train_id, train_name, wg_no) values ($TRAIN_ID, '$1', '$2')"
./pgsql_update_all.sh "INSERT INTO train_operator values ('$3', '$2')"
./pgsql_update_all.sh "INSERT INTO train_operator_permission values ('$3', $TRAIN_ID)"
