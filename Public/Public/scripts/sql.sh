#!/bin/bash

cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
    

sqlline=$SQLPLUS_STRING
sqlplus $sqlline

