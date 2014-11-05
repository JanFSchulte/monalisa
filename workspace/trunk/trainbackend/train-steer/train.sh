#!/bin/bash

export TRAIN_STEER=$HOME/train-steer
export TRAIN_WORKDIR=$HOME/train-workdir
export TRAIN_TESTDATA=$TRAIN_WORKDIR/testdata

function output()
{
    echo "Module $1: (pid $BASHPID) $2" >> test_summary
}

function execute_test()
{
    MODULE=$1
    cd $MODULE

    output $MODULE "Files created. Executing test..."

    VALIDATED=0

    # for MC generation testing
    export ALIEN_PROC_ID=12345678

    # execute test
    bash ./lego_train.sh > stdout 2> stderr
    bash ./lego_train_validation.sh > validation.log 2>&1
    if [ "$?" -eq "0" ]
    then
      output $MODULE "Validated!"
      touch validated
      VALIDATED=1
    else
      output $MODULE "Validation failed!"
    fi

    #test merging
    if [ $VALIDATED -eq 1 ]
    then
	if [ "$MODULE" == "__BASELINE__" ]
	then
	    touch mergeNoFile
	else
	    mkdir merge_test
	    mv lego_train_{merge.C,merge.sh,validation_merge.sh} merge_test
	    cp lego_train.root merge_test
	    
	    #number of files which are used to test the merging
	    MAXMERGE=2
	    if [ "$MODULE" == "__ALL__" ]
	    then
		MAXMERGE=10
	    fi

	    OUTPUTFILES=('*.root')
	    NOFILES=0               #needed to know if zero files are tried to merge

	    for ((i=1; i<$MAXMERGE+1; i++))
	    do
		mkdir merge_test/mg$i
		echo "$PWD/merge_test/mg$i">>merge_test/files_to_merge.txt
		for OUTPUTFILE in $OUTPUTFILES
		do
		    if [ $OUTPUTFILE != "lego_train.root" ] && [ $OUTPUTFILE != "syswatch.root" ]
                    then
			if [[ "$EXCLUDE_FILES" != *"$OUTPUTFILE"* ]] # skip files excluded for JDL storing
			then
			  ln -s ../../$OUTPUTFILE merge_test/mg$i/$OUTPUTFILE
			  let NOFILES=NOFILES+1
			fi
		    fi
		done
	    done

	    cd merge_test

	    #remove merging if no files available to merge, else test merging
	    if [ $NOFILES == "0" ]
	    then
		cd ..
		touch mergeNoFile
		rm -rf merge_test
	    else
		bash ./lego_train_merge.sh files_to_merge.txt 0  > stdout 2> stderr
		bash ./lego_train_validation_merge.sh > mergevalidation.log 2>&1

		cd ..
		if [ "$?" -eq "0" ]
		then
		    output $MODULE "Merge validated!"
		    touch merge_test/validated
		else
		    output $MODULE "Merge validation failed!"
		fi
	    fi
	    
	fi
    fi

    # extract data from syswatch
    
    aliroot -b -q -l $TRAIN_STEER/extract_syswatch.C > extract_syswatch.out 2>&1
    grep MLTRAIN extract_syswatch.out > syswatch.stats

    cd ..
}

PROCCOUNT=0
PROCESSES=""

function check_processes()
{
  # check processes
  NEWPROCESSES=""
  PROCCOUNT=0
  for PID in $PROCESSES
  do
    kill -0 $PID > /dev/null 2>&1
    if [ "$?" -ne "0" ]
    then
      true 
      #echo "$PID terminated"
    else
      NEWPROCESSES="$NEWPROCESSES $PID"
      let PROCCOUNT=PROCCOUNT+1      
    fi
  done
  PROCESSES="$NEWPROCESSES"
}

if [ -z "$2" ]
then
  echo "Arguments: [--skip-download] --run-tests|--generate-files|--redo-file-generation <Train folder>"
  # Train folder: e.g. PWG4/PbPb_LHC10h_p2_esd/20110623/
  # Full example: ./run-tests.sh --skip-download PWG2/Devel_2/1_20111004-1409
  exit 1
fi

source /tmp/gclient_env_$UID

DOWNLOAD=1
if [ "$1" == "--skip-download" ]
then
  shift
  DOWNLOAD=0
fi

RUN_TESTS=0
GENERATE_FILES=0 # this name is historic, and means actually that already generated files are copied
REDO_FILES=0
if [ "$1" == "--run-tests" ]
then
  RUN_TESTS=1
elif [ "$1" == "--generate-files" ]
then
  GENERATE_FILES=1
elif [ "$1" == "--redo-file-generation" ]
then
  REDO_FILES=1
else
  echo "ERROR: Invalid arguments."
  exit 1
fi
shift

TRAIN_FOLDER="$1"

if [ ! -d "$TRAIN_WORKDIR/$TRAIN_FOLDER/config" ]
then
  echo "Train configuration folder not found"
  exit 2
fi

cd $TRAIN_WORKDIR/$TRAIN_FOLDER/config

if [ ! -e "env.sh" ]
then
  echo "ERROR: env.sh not found."
  exit 3
fi

if [ ! -e "MLTrainDefinition.cfg" ]
then
  echo "ERROR: MLTrainDefinition.cfg not found."
  exit 4
fi

if [ ! -e "handlers.C" ]
then
  echo "ERROR: handlers.C not found."
  exit 5
fi

# configuration
source env.sh

ALIROOT_VERSION_SHORT=`echo "$ALIROOT_VERSION" | awk -FAliRoot\:\: '{print $2}'`
ROOT_VERSION_SHORT=`echo "$ROOT_VERSION" | awk -FROOT\:\: '{print $2}'`
GEANT_VERSION_SHORT=`echo "$GEANT_VERSION" | awk -FGEANT3\:\: '{print $2}'`
export ALIROOT_VERSION_SHORT
export ROOT_VERSION_SHORT
export GEANT_VERSION_SHORT

if [ "$DOWNLOAD" -eq "1" ]
then
  cd $TRAIN_STEER
  ./download-aliroot.sh $ALIROOT_VERSION
  source $HOME/packages/env_aliroot.sh $ALIROOT_VERSION
fi

if [ "$ADDITIONAL_PACKAGES" != "" ]
then
  echo "Downloading/enabling additional packages"
  for I in $ADDITIONAL_PACKAGES
  do
    ./download-aliroot.sh "VO_ALICE@$I"
    DIR=`echo $I | sed 's/::/\//'`
    source $HOME/packages/VO_ALICE/$DIR/.alienEnvironment $HOME/packages/VO_ALICE/$DIR
  done
fi

cd $TRAIN_WORKDIR/$TRAIN_FOLDER

if [ "$RUN_TESTS" -eq "1" ]
then
  mkdir test
  if [ ! -e "test" ]
  then
    echo "ERROR: Test folder could not be created! Exiting..."
    exit 6
  fi
fi

source /tmp/gclient_env_$UID

# loop over modules
TRAINMODULES=`grep Module.Begin config/MLTrainDefinition.cfg | awk '{print $2}'`
# special token for test of full train and final file creation

# TRAINMODULES="PhiCorr"

MODULES=""
DOWNLOADFILES="kFALSE"

if [ "$RUN_TESTS" -eq "1" ]
then
  if [ "$TEST_ONLY_FULL_TRAIN" -eq "1" ]
  then
      if [ -e "test_started" ] && [ -e "test_finished" ]
      then
	  MODULES+="$TRAINMODULES"
	  mv test_started fast_test_started
	  mv test_finished fast_test_finished
      else
	  MODULES+="__BASELINE__ __ALL__ __TRAIN__"
      fi
  else
      MODULES+="__BASELINE__ $TRAINMODULES __ALL__ __TRAIN__"
  fi
  DOWNLOADFILES="kTRUE"
  touch test_started
fi
if [ "$REDO_FILES" -eq "1" ]
then
  MODULES+="__TRAIN__"
fi

for MODULE in $MODULES
do
  echo
  echo "+++++++++++ Processing module $MODULE"
  echo 

  if [ -e "abort_test" ]
  then
    echo "Aborting test on operator request."
    break
  fi

  cd config

  # generate test files
  aliroot -b -q -l $TRAIN_STEER/generate.C'("'$TRAIN_FOLDER'", '$DOWNLOADFILES', "'$MODULE'")' 2>&1 | tee generation.log

  cd ..

  if [ "$MODULE" == "__TRAIN__" ]
  then
    if [ ! -e "config/lego_train.C" ] || [ ! -e "config/lego_train.jdl" ]
    then
      echo "ERROR: Files have not been created."
      continue
    fi

    mkdir $MODULE
    mv config/generation.log $MODULE
    mv config/lego_train.{C,root,sh} config/lego_train{,_merge,_merge_final}.jdl config/lego_train_merge.{C,sh}  config/lego_train_validation{,_merge}.sh $MODULE
    cp config/{MLTrainDefinition.cfg,env.sh,globalvariables.C,handlers.C} $MODULE
    if [ "$?" -ne  "0" ]
    then
      echo "ERROR: Files could not be moved."
      continue
    fi

    # Add lacking parameters $2 and $3 to make AliEn happy
#     echo 'UselessTag = "$2 $3";' >> $MODULE/lego_train.jdl
#     echo 'UselessTag = "$2 $3";' >> $MODULE/lego_train_merge.jdl
#     echo 'UselessTag = "$2 $3";' >> $MODULE/lego_train_merge_final.jdl

    # LPM steering
#    LPMACTIVITY="86400"
    LPMACTIVITY="172800" # 48 hours
#    let TTLTWICE=$TTL*2
#    if [ "$LPMACTIVITY" -gt "$TTLTWICE" ]
#    then
#      LPMACTIVITY=$TTLTWICE
#    fi
    echo 'LPMActivity = "'$LPMACTIVITY'";' >> $MODULE/lego_train.jdl
    echo 'LPMActivity = "'$LPMACTIVITY'";' >> $MODULE/lego_train_merge.jdl
    echo 'MaxWaitingTime = "'$LPMACTIVITY'";' >> $MODULE/lego_train.jdl
    #echo 'MaxWaitingTime = "'$LPMACTIVITY'";' >> $MODULE/lego_train_merge.jdl

    echo 'LegoResubmitZombies = "1";' >> $MODULE/lego_train.jdl
    echo 'LegoResubmitZombies = "1";' >> $MODULE/lego_train_merge.jdl
    echo 'LegoResubmitZombies = "1";' >> $MODULE/lego_train_merge_final.jdl

    echo 'LPMMaxResubmissions = "1";' >> $MODULE/lego_train.jdl
    echo 'LPMMaxResubmissions = "3";' >> $MODULE/lego_train_merge.jdl
    echo 'LPMMaxResubmissions = "3";' >> $MODULE/lego_train_merge_final.jdl

    # skip TTL usage
    echo 'ProxyTTL="1";' >> $MODULE/lego_train.jdl
    echo 'ProxyTTL="1";' >> $MODULE/lego_train_merge.jdl
    echo 'ProxyTTL="1";' >> $MODULE/lego_train_merge_final.jdl
    
    # abort if more than 50% of the jobs are in a failed state or when number of resubmissions exceeds number of jobs
    echo 'MaxFailFraction = "0.5";' >> $MODULE/lego_train.jdl
    echo 'MaxResubmitFraction = "1";' >> $MODULE/lego_train.jdl

    # skip FZK (too many failures, 15.12.11; again 04.09.12), see also below
    # not for the one with DirectAccess!
    # commented 05.10.12; put back 05.11.12; commented out 10.01.13
    # put back on 31.07.13 (request Costin)
    # commented on 13.09.13 (request Latchezar)
    # echo 'Requirements = ( !member(other.CloseSE,"ALICE::FZK::SE") );' >> $MODULE/lego_train.jdl
    # echo 'Requirements = ( !member(other.CloseSE,"ALICE::FZK::SE") );' >> $MODULE/lego_train_merge_final.jdl

    # price for main JDLs
    cat $MODULE/lego_train.jdl | sed 's/Price = "[0-9]*"/Price = "10"/' > $MODULE/lego_train.jdl.new
    mv $MODULE/lego_train.jdl.new $MODULE/lego_train.jdl

    # mark the input file type
    if [ "$AOD" -eq "1" ] || [ "$AOD" -eq "2" ]
    then 
      echo 'RunOnAODs = "1";' >> $MODULE/lego_train.jdl
    elif [ "$AOD" -ge "3" ] && [ "$AOD" -le "200" ]
    then
      echo "LegoInputFileSubSelection = \"$FILE_PATTERN\";" >> $MODULE/lego_train.jdl
    fi

    if [ "$SPLITALL" -ge "1" ]
    then
	echo 'CanSpanMultipleRuns = "true";' >> $MODULE/lego_train.jdl
	if [ "$SPLITALL" -eq "2" ]
	then
	    echo "RunChunks = {$RUN_CHUNKS};" >> $MODULE/lego_train.jdl
	fi
    fi
    
    
    echo 'LegoDatasetType = "'$AOD'";' >> $MODULE/lego_train.jdl

    if [ "$SLOW_TRAIN_RUN" -ge "1" ]
    then
	echo 'ExpressTrainStage2FinalStatePercentage="100";' >> $MODULE/lego_train.jdl
    fi

    # output for merging to dedicated SEs
    cat $MODULE/lego_train.jdl | sed 's/stat@disk=2/stat@legooutput=2/' > $MODULE/lego_train.jdl.new
    mv $MODULE/lego_train.jdl.new $MODULE/lego_train.jdl

    cat $MODULE/lego_train_merge.jdl | sed 's/stat@disk=2/stat@legooutput=2/' > $MODULE/lego_train_merge.jdl.new
    mv $MODULE/lego_train_merge.jdl.new $MODULE/lego_train_merge.jdl

    # merging adjustments
    cat $MODULE/lego_train_merge.jdl | sed 's/TTL = "[0-9]*"/TTL = "7200"/' | sed 's/Price = "[0-9]*"/Price = "10000"/' | sed 's/Workdirectorysize = {"[0-9]*MB"}/Workdirectorysize = \{"20000MB"\}/' > $MODULE/lego_train_merge.jdl.new
    mv $MODULE/lego_train_merge.jdl.new $MODULE/lego_train_merge.jdl

    cat $MODULE/lego_train_merge_final.jdl | sed 's/TTL = "[0-9]*"/TTL = "10800"/' | sed 's/Price = "[0-9]*"/Price = "10000000"/' | sed 's/Workdirectorysize = {"[0-9]*MB"}/Workdirectorysize = \{"20000MB"\}/' > $MODULE/lego_train_merge_final.jdl.new
    mv $MODULE/lego_train_merge_final.jdl.new $MODULE/lego_train_merge_final.jdl

    # copy for full train merge job (this still needs the old schema)
    cp $MODULE/lego_train_merge.jdl $MODULE/lego_train_full_merge.jdl
    cp $MODULE/lego_train_merge_final.jdl $MODULE/lego_train_full_merge_final.jdl

    # skip FZK (too many failures, 15.12.11), for this one it is not yet added above
    # commented 20.08.12 # echo 'Requirements = ( !member(other.CloseSE,"ALICE::FZK::SE") );' >> $MODULE/lego_train_full_merge.jdl

    # do modifications for parentdirectory merging
    echo 'DirectAccess = "1";' >> $MODULE/lego_train_merge.jdl

    # se -> parentdirectory
    cat $MODULE/lego_train_merge.jdl | sed 's/Split = "se"/Split = "parentdirectory"/' > $MODULE/lego_train_merge.jdl.new
    mv $MODULE/lego_train_merge.jdl.new $MODULE/lego_train_merge.jdl

    # new requirement for new AliEn
    echo 'Requirements = member(other.GridPartitions, "merger");' >> $MODULE/lego_train_merge.jdl
    echo 'Requirements = member(other.GridPartitions, "merger");' >> $MODULE/lego_train_merge_final.jdl
    echo 'Requirements = member(other.GridPartitions, "merger");' >> $MODULE/lego_train_full_merge_final.jdl

    echo 'LPMHighPriority = "1";' >> $MODULE/lego_train_merge.jdl
    echo 'LPMHighPriority = "1";' >> $MODULE/lego_train_merge_final.jdl
    echo 'LPMHighPriority = "1";' >> $MODULE/lego_train_full_merge.jdl
    echo 'LPMHighPriority = "1";' >> $MODULE/lego_train_full_merge_final.jdl

#     sed -n 'H;${x;s/^\n//;s/exit .*$/cat wn.xml >> stdout\n&/;p;}' $MODULE/lego_train_validation.sh > $MODULE/dummy_file.sh
#     mv $MODULE/dummy_file.sh $MODULE/lego_train_validation.sh
 
  else
    cd test
    mkdir $MODULE
    mv ../config/generation.log $MODULE

    if [ ! -e "../config/lego_train.C" ]
    then
      echo "ERROR: Files have not been created. Skipping module."
      ln -s generation.log $MODULE/stdout
      touch $MODULE/syswatch.stats
      cd ..
      continue
    fi

    mv ../config/lego_train.{C,root,sh} ../config/lego_train_validation.sh $MODULE
    mv ../config/lego_train_{merge.C,merge.sh,validation_merge.sh} $MODULE

    #cat $MODULE/lego_train.sh | sed 's/aliroot -b -q  lego_train.C/root -b -q  lego_train.C/' > $MODULE/lego_train.sh.new
    #mv $MODULE/lego_train.sh.new $MODULE/lego_train.sh
    
    # temporary until we have a flag for the number of events in the test
    if [ "$TEST_FILES_NO" -lt "0" ]
    then
      cat $MODULE/lego_train.C | sed 's/mgr->StartAnalysis("localfile")/mgr->StartAnalysis("localfile", '${TEST_FILES_NO#-}')/' > $MODULE/lego_train.C.new
      mv $MODULE/lego_train.C.new $MODULE/lego_train.C
    fi

    echo
    echo "Tests will be executed in parallel. Test output will appear further below!"
 
    while [ "$PROCCOUNT" -ge "4" ]
    do
	check_processes
        sleep 1
    done
    execute_test $MODULE &
    PID="$!"
    PROCESSES="$PROCESSES $PID"
    let PROCCOUNT=PROCCOUNT+1

    cd ..
  fi

  echo
  echo "+++++++++++ Finished module $MODULE"
  echo
done

# wait for still running processes
echo "Waiting for still running tests..."
while [ "$PROCCOUNT" -gt "0" ]
do
    check_processes
    sleep 1
done
echo "All tests finished."

echo "Test results:"

for MODULE in $MODULES
do
  if [ "$MODULE" != "__TRAIN__" ]
  then
      cat test/$MODULE/test_summary
      rm test/$MODULE/test_summary
  fi
done

echo

if [ "$RUN_TESTS" -eq "1" ]
then
  touch test_finished
fi

if [ "$GENERATE_FILES" -eq "1" ]
then
  rm -f files_copying_failure
  rm -f files_generated

  cd __TRAIN__

  ls lego_train.{C,root,sh} lego_train{,_merge,_merge_final}.jdl lego_train_merge.{C,sh} lego_train_validation{,_merge}.sh
  if [ "$?" -ne  "0" ]
  then
    echo "ERROR: Some files are missing."
    exit 10
  fi

  echo "Copying files to AliEn (target $TRAIN_FOLDER)..."
  echo "GSHELL ROOT is $GSHELL_ROOT"

  ALIEN_TARGET_DIR="/alice/cern.ch/user/a/alitrain/$TRAIN_FOLDER"
  $GSHELL_ROOT/bin/alien_rmdir $ALIEN_TARGET_DIR
  $GSHELL_ROOT/bin/alien_mkdir -p $ALIEN_TARGET_DIR

  for FILE in `ls`
  do
    RETRY=0
    while [ "$RETRY" -le "3" ]
    do
      echo "Copying $FILE..."
      $GSHELL_ROOT/bin/alien_cp -v $FILE alien://$ALIEN_TARGET_DIR/$FILE@disk=3
      $GSHELL_ROOT/bin/alien_ls $ALIEN_TARGET_DIR/$FILE
      if [ "$?" -eq "0" ]
      then
	break
      fi
      echo "Copying failed. Retrying..."
      let RETRY=RETRY+1
    done

    # trigger mirroring
    #$GSHELL_ROOT/bin/alien_mirror $ALIEN_TARGET_DIR/$FILE ALICE::CERN::EOS
    #$GSHELL_ROOT/bin/alien_mirror $ALIEN_TARGET_DIR/$FILE ALICE::NIHAM::File
    #$GSHELL_ROOT/bin/alien_mirror $ALIEN_TARGET_DIR/$FILE ALICE::Trieste::SE
  done

  FILECOUNT=`ls | wc -l`
  FILECOUNTALIEN=`$GSHELL_ROOT/bin/alien_ls $ALIEN_TARGET_DIR | wc -l`

  cd ..

  if [ "$FILECOUNT" -eq "$FILECOUNTALIEN" ]
  then
    echo "Files copied sucessfully."
  
    touch files_generated
  else
    echo "Some file has not been copied ($FILECOUNT/$FILECOUNTALIEN)"
    echo "Local files:"
    ls __TRAIN__
    echo "Files in AliEn:"
    $GSHELL_ROOT/bin/alien_ls $ALIEN_TARGET_DIR
    touch files_copying_failure
  fi
fi

wget -O - 'http://alimonitor.cern.ch/work/updateTrainStatus.jsp?path='$TRAIN_FOLDER
