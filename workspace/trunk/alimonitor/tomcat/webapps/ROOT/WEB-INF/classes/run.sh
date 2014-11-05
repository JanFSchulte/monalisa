#!/bin/bash

cd `dirname $0`

BASE=../../../../..

LIB=$BASE/lib

CP=.:$BASE/bin/alienpool:$BASE/lib/classes:$BASE/tomcat/server/lib/catalina.jar:$BASE/tomcat/common/lib/servlet-api.jar

for JAR in $LIB/*.jar; do
    CP="$CP:$JAR"
done

java -classpath ${CP} -Dlia.Monitor.ConfigURL=file:$HOME/MLrepository/JStoreClient/conf/App.properties utils.IntervalQuery
