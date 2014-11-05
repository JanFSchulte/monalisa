#!/bin/bash

# Train daemon script
# Author: Jan Fiete Grosse-Oetringhaus

# This daemon checks for queued test runs or generation request and execute them

TRAIN_STEER=$HOME/train-steer
TRAIN_WORKDIR=$HOME/train-workdir
TRAIN_QUEUE=$TRAIN_WORKDIR/train-queue

MAX_PROCESSES=12

# check in which mode we are running
if [ -z "$1" ]
then
  echo "Arguments: --run-tests|--generate-files"
  exit 1
fi

MODE=0
if [ "$1" == "--run-tests" ]
then
  MODE=1
  SUBDIR=tests
elif [ "$1" == "--generate-files" ]
then
  MODE=2
  SUBDIR=generator
else
  echo "ERROR: Invalid arguments."
  exit 1
fi

I=0
PROCESSES=""
PROCCOUNT=0
while [ 1 ]
do
  FILES=`ls $TRAIN_QUEUE/$SUBDIR`

  for FILE in $FILES
  do
    cd $TRAIN_STEER
    TRAINDIR=`cat $TRAIN_QUEUE/$SUBDIR/$FILE`

    if [ "$PROCCOUNT" -lt "$MAX_PROCESSES" ]
    then
      EXFILE=`echo $TRAINDIR | sed 's/\//__/g'`
      EXFILE="/tmp/$EXFILE.sh"

      echo "Found file $FILE. Executing in the background in $TRAINDIR using $EXFILE"

      rm $TRAIN_QUEUE/$SUBDIR/$FILE
      cp train.sh $EXFILE
      
      $EXFILE $1 $TRAINDIR >> $TRAIN_WORKDIR/$TRAINDIR/$SUBDIR.log 2>&1 &
      PID="$!"
      PROCESSES="$PROCESSES $PID"
      let PROCCOUNT=PROCCOUNT+1

      echo "Running in $PID"
    fi
  done

  # check processes
  NEWPROCESSES=""
  PROCCOUNT=0
  for PID in $PROCESSES
  do
    kill -0 $PID > /dev/null 2>&1
    if [ "$?" -ne "0" ]
    then
      echo "$PID terminated"
    else
      NEWPROCESSES="$NEWPROCESSES $PID"
      let PROCCOUNT=PROCCOUNT+1      
    fi
  done
  PROCESSES="$NEWPROCESSES"

  let I=I+1
  if [ "$I" -eq "360" ]
  then
    echo -n "Sleeping... "
    date
    I=0
  fi
  sleep 10

  let IT="$I % 6"
  if [ "$PROCCOUNT" -gt "0" ] && [ "$IT" -eq "0" ]
  then
    echo "Running $PROCCOUNT/$MAX_PROCESSES processes, PIDs: $PROCESSES"
  fi
done
