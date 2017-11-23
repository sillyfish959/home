#!/bin/bash

if [ $# != 1 ]; then
  echo
  echo usage: e.g. ./server_check.sh tspsit5
  echo
  exit 1
fi

HostPortList="../connections/SIT_HostPort.csv"
ServerList="../connections/SIT_Server.csv"
ENV="$1"
HP_STRING="${ENV}_HostPort"
HOST=`cat $HostPortList |grep $HP_STRING |awk -F ',' '{print $2}'`
SERVER_STRING=`cat $ServerList |grep $HOST`
echo $ENV
echo $SERVER_STRING

ssh $SERVER_STRING -o "PasswordAuthentication no" -o "StrictHostKeyChecking no" exit 2>/dev/null
if [ $? != 0 ]; then
  echo $SERVER_STRING not connected! 
  exit 1
fi

DB_FILE1="/app/TSPSG/$ENV/fs/public/mxres/common/dbconfig/dbsource.mxres"
DB_FILE2="/app/CCR/$ENV/fs/public/mxres/common/dbconfig/dbsource.mxres"
rm -rf DB_FILE1 DB_FILE2
scp $SERVER_STRING:$DB_FILE1 ./DB_FILE1 1>/dev/null 2>/dev/null
scp $SERVER_STRING:$DB_FILE2 ./DB_FILE2 1>/dev/null 2>/dev/null

if [ -e DB_FILE1 ]; then 
  DB_FILE="DB_FILE1"
  elif [ -e DB_FILE2 ]; then 
    DB_FILE="DB_FILE2"
  else
    echo "Can't find $SERVER_STRING:$DB_FILE1 or $SERVER_STRING:$DB_FILE2" 
    exit 1
fi

DbUser=`xmllint --format $DB_FILE |grep DbUser |awk -F '[<>]' '{print $3}'`
DbPassword=`xmllint --format $DB_FILE |grep DbPassword |awk -F '[<>]' '{print $3}'`
DbHostName=`xmllint --format $DB_FILE |grep DbHostName |awk -F '[<>]' '{print $3}'`
DbServerPortNumber=`xmllint --format $DB_FILE |grep DbServerPortNumber |awk -F '[<>]' '{print $3}'`
DbServerOrServiceName=`xmllint --format $DB_FILE |grep DbServerOrServiceName |awk -F '[<>]' '{print $3}'`

echo DbUser=$DbUser
echo DbPassword=$DbPassword
echo DbHostName=$DbHostName
echo DbServerPortNumber=$DbServerPortNumber
echo DbServerOrServiceName=$DbServerOrServiceName

java -jar enctest.jar -d $DbPassword 1>Password 2>>Password
Password=`cat Password |awk -F '\r\n' '{print $1}' `

echo Password=$Password
rm -f Password $DB_FILE DB_FILE1 DB_FILE2
echo "${ENV}_Database,${DbUser}/${Password}@$DbHostName:$DbServerPortNumber/$DbServerOrServiceName"
