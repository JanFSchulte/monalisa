#!/bin/bash

export TRAIN_STEER=$HOME/train-steer
export SKIP_INSTALLING_ALIEN=true

VERSION="$1"

cd $HOME

if [ -e download-aliroot-lock ]
then
  echo "Somebody else is updating AliRoot at the moment. Please wait..."
  while [ -e download-aliroot-lock ]
  do
    sleep 1
  done
fi

DIR=`echo $VERSION | sed 's/@/\//' | sed 's/::/\//'`
if [ -d packages/$DIR ]
then
  echo "Package $VERSION already exists."

  SIZE=`du -sb packages/$DIR | awk '{ print $1 }'`
  if [ "$SIZE" -lt "100000" ]
  then
    echo "Download seems to have not worked... Retrying..."
    rm -rf packages/$DIR
  else
    exit
  fi
fi

touch download-aliroot-lock

echo "Downloading $VERSION"

rm aliroot-installer.sh
wget "http://alimonitor.cern.ch/packages/install.jsp?package=$VERSION" -O aliroot-installer.sh
chmod +x aliroot-installer.sh
./aliroot-installer.sh

cd $HOME/packages
rm alien
ln -s ../alien

VO=`echo $DIR | awk -F/ '{print $1}'`
PACKAGE=`echo $DIR | awk -F/ '{print $2}'`
PACKAGEVERSION=`echo $DIR | awk -F/ '{print $3}'`

source /tmp/gclient_env_$UID
cd $HOME/packages/$VO/$PACKAGE
$GSHELL_ROOT/bin/alien_cp alien:///alice/packages/$PACKAGE/post_install post_install
cd $PACKAGEVERSION
bash ../post_install $PWD

cd $HOME
rm download-aliroot-lock

exit

if [ -z "$IGNORE_UBUNTU" ]
then
  # check success
  SIZE=`du -sb packages/$DIR | awk '{ print $1 }'`
  if [ ! -d packages/$DIR ] || [ "$SIZE" -lt "100000" ]
  then
    echo "Download seems to have not worked... Retrying with SLC version..."
    rm -rf packages/$DIR
    export IGNORE_UBUNTU=1
    $TRAIN_STEER/download-aliroot.sh $VERSION
  fi
fi
