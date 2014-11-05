if [ -z "$1" ]
then
  echo "Arguments: [--local-aliroot] <Train folder>"
else

  LOCALALIROOT=0
  if [ "$1" == "--local-aliroot" ]
  then
    shift
    LOCALALIROOT=1
  fi

  TRAIN_FOLDER="$1"

  export TRAIN_STEER=$HOME/train-steer
  export TRAIN_WORKDIR=$HOME/train-workdir
  export TRAIN_TESTDATA=$TRAIN_WORKDIR/testdata

  # configuration
  source $TRAIN_WORKDIR/$TRAIN_FOLDER/config/env.sh

  ALIROOT_VERSION_SHORT=`echo "$ALIROOT_VERSION" | awk -FAliRoot\:\: '{print $2}'`
  export ALIROOT_VERSION_SHORT

  if [ "$LOCALALIROOT" -eq "1" ] 
  then
    source $HOME/local-env.sh
  else
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

  source /tmp/gclient_env_$UID

  # fix lib path for gdb
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:$LD_LIBRARY_PATH
fi
