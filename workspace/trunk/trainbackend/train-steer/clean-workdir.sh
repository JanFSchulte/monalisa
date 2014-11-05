#!/bin/bash

# cleans all folder but the last one

date

TRAIN_WORKDIR=$HOME/train-workdir
PWGLIST="PWG1 PWG2 PWG3 PWG4 PWGCF PWGDQ PWGGA PWGHF PWGJE PWGLF PWGZZ PWGPP PWGUD"

cd $TRAIN_WORKDIR
for I in $PWGLIST
do
  cd $I
  if [ "$?" -eq "0" ]
  then
    for J in `ls`
    do
      cd $J
      if [ "$?" -eq "0" ]
      then
	for K in `ls`
	do
	  NO=`echo $K | cut -d\_ -f 1`
	  echo "Checking $I $J $K"
	  FIRST=1
	  for L in `ls -r | grep ^${NO}_`
	  do
	    AGE=`stat -c %Z $L`
	    NOW=`date +%s`
	    let AGE=$NOW-$AGE
	    if [ "$FIRST" -eq "1" ]
	    then
	      FIRST=0
	      if [ "$AGE" -lt "5184000" ] # 2 months
	      then
		echo "Keeping $L"
		continue
	      fi
	      if [ -e "$L/test" ]
	      then
		echo "Cleaning only root files in output of $L (age $AGE)"
		find $L -name "*.root" -exec rm {} \;

		SIZE=`du -s $L | awk '{print $1}'`
		if [ "$SIZE" -gt "50000" ]
		then
		  echo "WARNING: Directory $I/$J/$L is larger than 50MB ($SIZE)"
		fi

		find $L -name "stdout" -exec gzip -S .ggzz {} \;
		find $L -name "generation.log" -exec gzip -S .ggzz {} \;
		gzip -S .ggzz $L/tests.log
		#exit
	      fi
	      continue
	    elif [ "$AGE" -lt "2592000" ] # 1 month
	    then
	      echo "Keeping $L due to age ($AGE)"
	      continue
	    else
	      echo "Removing $L (age $AGE)"
	      rm -rf $L
	    fi
	  done
	done
      fi
      cd ..
    done
  fi
  cd ..
#   exit
done

