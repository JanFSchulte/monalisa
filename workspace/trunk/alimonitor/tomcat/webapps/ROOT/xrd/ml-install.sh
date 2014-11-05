#!/bin/bash

cd `dirname $0`

myreplace(){
    a=`echo "$1" | sed 's/\//\\\\\//g'`
    b=`echo "$2" | sed 's/\//\\\\\//g'`
    sed "s/$a/$b/g"
}
                        
replace_in_file(){
    cat "$1" | myreplace "$2" "$3" > "$1.new"
    rm -f "$1"
    mv "$1.new" "$1"
}

PLATFORM=`uname -m`
JAVA_VER="java6"
WGET="wget -q "
rm -rf MonaLisa java jdk1.6.0*

INSTALLED_JAVA=`java -version 2>&1 | head -n1 | cut -d\" -f2 | cut -c1-3`

if [ "$INSTALLED_JAVA" = "1.5" -o "$INSTALLED_JAVA" = "1.6" -o "$INSTALLED_JAVA" = "1.7" ]; then
    JAVA_PATH=`dirname $(dirname $(which java))`
    echo "Using system java : $JAVA_PATH ($INSTALLED_JAVA)"
else
    # Install Java
    JAVA_KIT="$JAVA_VER-$PLATFORM.tar.bz2"
    echo "Downloading $JAVA_VER SDK for $PLATFORM..."
    $WGET http://monalisa.cern.ch/download/java/$JAVA_KIT -O $JAVA_KIT ||
	$WGET http://monalisa.cacr.caltech.edu/download/java/$JAVA_KIT -O $JAVA_KIT

    if [ ! -s "$JAVA_KIT" ] ; then
        echo "Failed to download java. Please check that you have 'wget' in PATH"
        echo "and you can access monalisa.cacr.caltech.edu or monalisa.cern.ch."
        exit 2
    fi

    tar jxf $JAVA_KIT
    rm -f $JAVA_KIT
    
    JAVA_PATH=`pwd`/java
fi

MLMAJOR=MonaLisa.v1.8
ML=$MLMAJOR.16.tar.gz

if [ ! -f "$ML" ]; then
    echo "Downloading MonaLisa"
    $WGET http://monalisa.cern.ch/download/monalisa/$ML -O $ML ||
	$WGET http://monalisa.cacr.caltech.edu/download/monalisa/$ML -O $ML

    if [ ! -s "$ML" ]; then
	echo "Failed to download MonaLisa"
	exit 3
    fi
else
    echo "Recycling the previously downloaded $ML"
fi

rm -rf $MLMAJOR

tar -xzf $ML
tar -xzf $MLMAJOR/$MLMAJOR.tar.gz
rm -f $MLMAJOR/$MLMAJOR.tar.gz $MLMAJOR/install*

mv $MLMAJOR MonaLisa

mkdir MonaLisa/Service/myFarm

FARM=MonaLisa/Service/myFarm

cat >$FARM/myFarm.conf <<EOF
*Master
>localhost
monProcLoad%30
monProcStat%30
monProcIO%30
monLMSensors%30

*ABPing{monABPing, localhost, " "}

*Tracepath{monTracepath, localhost, " "}

^monXDRUDP{ParamTimeout=900,NodeTimeout=900,ClusterTimeout=900,ListenPort=$P}%20
^monDiskIOStat{}%30
^monFDTClient{}%60
^monFDTServer{}%60
^monFDTMon{ParamTimeout=120,NodeTimeout=120,ClusterTimeout=120,port=11002}%5
^monAppTransfer{ParamTimeout=120,NodeTimeout=120,ClusterTimeout=120}%5
EOF

cat >$FARM/ml.properties <<EOF
MonaLisa.ContactName=`id -u`
MonaLisa.ContactEmail=`id -u`@`hostname -f`
MonaLisa.Location=ANYWHERE
MonaLisa.Country=ALICE
MonaLisa.LAT=0
MonaLisa.LONG=0
lia.Monitor.LUSs=monalisa.cacr.caltech.edu,monalisa.cern.ch
lia.Monitor.group=alicexrd

lia.Monitor.CLASSURLs=file:\${MonaLisa_HOME}/Service/usr_code/PBS/,file:\${MonaLisa_HOME}/Service/usr_code/FilterExamples/ExLoadFilter/
lia.Monitor.keep_history=10800
lia.Monitor.Store.TransparentStoreFast.web_writes = 0

.level = OFF
lia.level = INFO
handlers= java.util.logging.FileHandler
java.util.logging.FileHandler.formatter = java.util.logging.SimpleFormatter
java.util.logging.FileHandler.limit = 1000000
java.util.logging.FileHandler.count = 4
java.util.logging.FileHandler.append = true
java.util.logging.FileHandler.pattern = ML%g.log
EOF

IPADDR=`ifconfig  | grep "inet addr:" | cut -d: -f2 | awk '{print $1}' | grep -v ^127. | grep -v ^0. | grep -v ^255.255.255.255 | head -n1`

if [ ! -z "$IPADDR" ]; then
    echo "lia.Monitor.useIPaddress=$IPADDR" >> $FARM/ml.properties
fi

CMD=MonaLisa/Service/CMD

cat $CMD/ml_env | \
    myreplace "/usr/local/java" "$JAVA_PATH" | \
    myreplace "\${HOME}/MonaLisa.v[0-9].[0-9]" "`pwd`/MonaLisa" | \
    myreplace "#MONALISA_USER=\"monalisa\"" "MONALISA_USER=`id -u -n`" | \
    myreplace "#FARM_NAME=\"\"" "FARM_NAME=\"`hostname -f`\"" \
> $CMD/ml_env.newconfig
rm -f $CMD/ml_env
mv $CMD/ml_env.newconfig $CMD/ml_env

cat $CMD/MLD | \
    myreplace "/home/monalisa/MonaLisa.v${VERS}" "`pwd`/MonaLisa" | \
    myreplace "=monalisa" "=`id -u -n`" \
> $CMD/MLD.new
rm -f $CMD/MLD
mv $CMD/MLD.new $CMD/MLD
chmod a+x $CMD/MLD
