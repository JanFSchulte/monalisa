#!/bin/bash

cd `dirname $0`

BASE=../../../../..

LIB=$BASE/lib

CP=.:$BASE/bin/alienpool:$BASE/lib/classes:$BASE/tomcat/lib/catalina.jar:$BASE/tomcat/lib/servlet-api.jar

for JAR in $LIB/*.jar; do
    CP="$CP:$JAR"
done

find . -name \*.java | xargs `cat ../../../../../conf/env.JAVA_HOME`/bin/javac -classpath "$CP"
