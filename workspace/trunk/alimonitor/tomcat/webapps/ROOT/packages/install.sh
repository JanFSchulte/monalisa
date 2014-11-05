#!/bin/bash

PACKAGES="<<:packages:>>"

cd `dirname $0`

PACKAGES_BASE_DIR="`pwd`/packages"

mkdir -p "$PACKAGES_BASE_DIR" &>/dev/null

mkdir download &>/dev/null
cd download

export SILENT_TORRENT="true"

ALIEN_ROOT="$PACKAGES_BASE_DIR/alien"


MYARCH=`uname -m`

if [ -z "$MYARCH" ]; then
    MYARCH=`echo "$HOSTTYPE" | cut -d- -f1`
    
    if [ -z "$MYARCH" ]; then
	MYARCH=`echo "$MACHTYPE" | cut -d- -f1`
    fi
fi

SO=`uname`
PLATFORM="$SO-$MYARCH"

if [ "$SO" == "Linux" ] ; then
    if [ -z "$IGNORE_UBUNTU" ]; then
        if [ -z "$IGNORE_UBUNTU" ]; then                                                                                                                                                                                                                                           
    	    
    	    distributor=`lsb_release -i 2>/dev/null | awk '{print $3}'`
    	
    	    if [ "$distributor"  == "Ubuntu" -a "$MYARCH" == "x86_64" ] ; then
    		PLATFORM="Ubuntu-$MYARCH"
    	    elif [ "$distributor" == "ScientificCERNSLC" -o "$distributor" == "Scientific" ]; then
		slcversion=`lsb_release -r | awk '{print $2}' | awk -F\. '{print $1}'`
		if [ "$slcversion" == "6" ]; then
        	    PLATFORM="SLC6-$MYARCH"
        	fi
    	    fi
        fi 
    fi
elif [ "$SO" == "Darwin" ] ; then
    PLATFORM="Darwin-x86_64"
    MYARCH="Darwin-x86_64"
else
    echo "Unknown operating system $SO"
    exit 1
fi

echo "Installing software for platform = $PLATFORM"

if LD_LIBRARY_PATH= wget --cache=off -q "http://alien.cern.ch/alien-installer" -O alien-installer; then
    chmod a+x alien-installer

    echo "Checking alien version and updating if necessary"

    ./alien-installer -install-dir "$ALIEN_ROOT" -type user -batch -updatebin &> alien-installer.log

    echo "  done, logs are in download/alien-installer.log"
else
    echo "Could not download the alien-installer script, exiting quickly"
    exit 1
fi

if ! LD_LIBRARY_PATH= wget --cache=off -q "http://pcalirootbuild3.cern.ch:8889/BitServers" -O BitServers; then
    echo "Could not download the http://pcalirootbuild3.cern.ch:8889/BitServers file from the build servers, can't work without it, sorry"
    exit 1
fi

DOWNLOADURL=`cat BitServers | grep "$PLATFORM" | awk '{print $5}'`

if ! LD_LIBRARY_PATH= wget --cache=off -q "$DOWNLOADURL/tarballs/Packages" -O Packages; then
    echo "Could not download the Packages file from the build servers $DOWNLOADURL/tarballs/Packages, can't work without it, sorry"
    exit 1
else
    cp -f Packages $PACKAGES_BASE_DIR
fi


if uname -r | grep -q -E -e "^(3|4|5|2.6.3[0123456789])"; then
    MYARCH="${MYARCH}_new"
fi

DOWNLOADSCRIPT="$ALIEN_ROOT/torrent_client_$MYARCH/download"

if [ ! -f "$DOWNLOADSCRIPT" ]; then
    DOWNLOADSCRIPT="$HOME/alien/torrent_client_$MYARCH/download"
fi

if [ ! -f "$DOWNLOADSCRIPT" ]; then
    echo "Downloading http://alitorrent.cern.ch/torrent_client/torrent_client_$MYARCH.tar.bz2"
    if ! LD_LIBRARY_PATH= wget --cache=off -q "http://alitorrent.cern.ch/torrent_client/torrent_client_$MYARCH.tar.bz2" -O torrent_client.tar.bz2; then
	echo "Could not download the torrent client, exiting"
	exit 1
    fi
    
    LD_LIBRARY_PATH= tar -xjf torrent_client.tar.bz2

    DOWNLOADSCRIPT="torrent_client_$MYARCH/download"    
fi

#echo "Using '$DOWNLOADSCRIPT' to download the files"

for PACKAGE in $PACKAGES; do
    echo "Installing $PACKAGE"
    
    FILENAME=`cat Packages | awk '{print $1 " " $5}' | grep "$PACKAGE$" | awk '{print $1}'`
    
    if [ "$FILENAME" == "" ]; then
	echo "This package is not supported on the current platform"
	exit 1
    fi
    
    echo "Downloading file $FILENAME"

    $DOWNLOADSCRIPT "http://alitorrent.cern.ch/torrents/$FILENAME.torrent"


    FILE=${FILENAME%.tar.bz2}
    FILE=${FILE%.tar.gz}
    
    FILE="$FILE/$FILENAME"
    
    TARGET="../packages/`echo "$PACKAGE" | sed 's#@#/#g' | sed 's#::#/#g'`"
    
    mkdir -p "$TARGET"
    
    EXT=${FILENAME##*.}
    
    OPTION="z"
    
    if [ "$EXT" == "bz2" ]; then
	OPTION="j"
    fi
    
    LD_LIBRARY_PATH= tar -C "$TARGET" -x${OPTION}f "$FILE"
done

cd ..


ALIEN_BASE_DIR="$HOME/alien"

if [ -h "$HOME/bin/aliensh" ]; then
    ALIENSH=`readlink "$HOME/bin/aliensh"`
    
    if [ -f "$ALIENSH" ]; then
	ALIEN_BASE_DIR=${ALIENSH%/api/bin/aliensh}
    fi
fi



if echo "$PACKAGES" | grep -q "@AliRoot::" ; then
    rm -f env_aliroot.sh &>/dev/null

    LD_LIBRARY_PATH= wget --cache=off -q "http://alitorrent.cern.ch/env/env_aliroot.sh" -O packages/env_aliroot.sh
    
    echo "For setting up AliRoot environment you can now do"
    echo "     source $PACKAGES_BASE_DIR/env_aliroot.sh"
fi

if echo "$PACKAGES" | grep -q "@ROOT::" ; then
    rm -f env_root.sh &>/dev/null

    LD_LIBRARY_PATH= wget --cache=off -q "http://alitorrent.cern.ch/env/env_root.sh" -O packages/env_root.sh

    echo "For running ROOT only you can now do"
    echo "     source $PACKAGES_BASE_DIR/env_root.sh"
fi

for FILENAME in packages/env_aliroot.sh packages/env_root.sh; do
    if [ -f "$FILENAME" ]; then
	LD_LIBRARY_PATH= cat "$FILENAME" | sed "s#::PACKAGES_BASE_DIR::#$PACKAGES_BASE_DIR#g" | sed "s#::ALIEN_BASE_DIR::#$ALIEN_BASE_DIR#g" | sed "s#::PLATFORM::#$PLATFORM#g" | sed "s#::BUILDURL::#$DOWNLOADURL#g" > "$FILENAME.tmp" && mv "$FILENAME.tmp" "$FILENAME"
    fi
done
