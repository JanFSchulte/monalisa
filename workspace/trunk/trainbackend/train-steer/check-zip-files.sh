#!/bin/bash

if [ -z "$1" ]
then
  echo "Arguments: <file list>"
  exit 1
fi

INPUTFILE="$1"
OUTPUTFILE="$INPUTFILE.tmp"
COUNT=0
OK=0

rm -f $OUTPUTFILE

echo
echo "Testing files in $INPUTFILE"
echo

for I in `cat $INPUTFILE` 
do
  FILENAME=`echo $I | awk -F\# '{print $1}'`
  unzip -t $FILENAME
  if [ "$?" -eq "0" ] 
  then
    echo $I >> $OUTPUTFILE
    let OK=OK+1
  fi
  let COUNT=COUNT+1
done

mv $OUTPUTFILE $INPUTFILE
echo
echo "$OK out of $COUNT files are OK."
echo

if [ "$OK" -eq "0" ]
then
  rm $INPUTFILE
fi
