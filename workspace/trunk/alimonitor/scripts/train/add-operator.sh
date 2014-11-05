#!/bin/bash

if [ -z "$3" ]
then
  echo "Syntax: add-operator.sh <train-id> <pwg> <admin>"
  exit 0
fi

./pgsql_update_all.sh "INSERT INTO train_operator values ('$3', '$2')"
./pgsql_update_all.sh "INSERT INTO train_operator_permission values ('$3', $1)"
