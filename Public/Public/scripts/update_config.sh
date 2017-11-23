#!/bin/sh

SIT_HP_List="../connections/SIT_HostPort.csv"
SIT_DB_List="../connections/SIT_Database.csv"
UAT_HP_List="../connections/UAT_HostPort.csv"
UAT_DB_List="../connections/UAT_Database.csv"

echo reading $SIT_HP_List
echo reading $SIT_DB_List
echo
for env in ../../SIT/*; do
    ENV_NAME=`echo $env |awk -F '/' '{print tolower($NF)}'`
    ENV_STR=tsp${ENV_NAME}_HostPort
    DB_STR=tsp${ENV_NAME}_Database
    grep -q $ENV_STR $SIT_HP_List
    if [ $? == 0 ]; then
      echo "SET JAVAHOME=D:\Murex\Client\jdk1.7.0_51" > $env/config.cmd
      grep $ENV_STR $SIT_HP_List|awk -F ',' '{print "SET MXJ_FILESERVER_HOST=" $2}' >>$env/config.cmd
      grep $ENV_STR $SIT_HP_List|awk -F ',' '{print "SET MXJ_FILESERVER_PORT=" $3}' >>$env/config.cmd
      grep $DB_STR $SIT_DB_List |awk -F ',' '{print "SET SQLPLUS_STRING=" $2}' >>$env/config.cmd
      echo updating $env/config.cmd
    else 
      echo skip $env/config.cmd
    fi
done
echo
echo reading $UAT_HP_List
echo reading $UAT_DB_List
echo
for env in ../../UAT/*; do
    ENV_NAME=`echo $env |awk -F '/' '{print tolower($NF)}'`
    ENV_STR=tsp${ENV_NAME}_HostPort
    DB_STR=tsp${ENV_NAME}_Database
    grep -q $ENV_STR $UAT_HP_List
    if [ $? == 0 ]; then
      echo "SET JAVAHOME=D:\Murex\Client\jdk1.7.0_51" > $env/config.cmd
      grep $ENV_STR $UAT_HP_List|awk -F ',' '{print "SET MXJ_FILESERVER_HOST=" $2}' >>$env/config.cmd
      grep $ENV_STR $UAT_HP_List|awk -F ',' '{print "SET MXJ_FILESERVER_PORT=" $3}' >>$env/config.cmd
      grep $DB_STR $UAT_DB_List |awk -F ',' '{print "SET SQLPLUS_STRING=" $2}' >>$env/config.cmd
      echo updating $env/config.cmd
    else 
      echo skip $env/config.cmd
    fi
done