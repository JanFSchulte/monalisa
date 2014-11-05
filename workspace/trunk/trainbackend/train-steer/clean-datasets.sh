#!/bin/bash

# cleans datasets not used for 2 months

date

TRAIN_WORKDIR=$HOME/train-workdir

cd $TRAIN_WORKDIR/testdata

for I in `ls *.txt`
do
  AGE=`stat -c %X $I`
  NOW=`date +%s`
  let AGE=$NOW-$AGE
  if [ "$AGE" -lt "2592000" ] # 1 month
  #if [ "$AGE" -lt "1296000" ] # 1/2 month
  then
    echo "Keeping $I due to age ($AGE)"
    continue
  fi
  echo "Removing $I (age $AGE)"
  DIRNAME=`basename $I .txt` #`echo $I | awk -F\. '{ print $1 }'`
#   echo $DIRNAME

  rm -rf $DIRNAME
  rm -rf $DIRNAME.txt
#   exit
done
