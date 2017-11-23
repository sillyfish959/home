#!/bin/bash


HostPortList="../connections/SIT_HostPort.csv"
DatabaseList="../connections/SIT_Database.csv"

rm -f db.log
while read line; do 
  env=`echo $line|awk -F '_' '{print $1}'`
  echo ./SIT_db_check.sh $env |sh;
  echo 
done < $HostPortList | tee -a db.log

strings db.log |grep "_Database"

read -p "Update $DatabaseList? (y/n): " Confirm
if [ "$Confirm" == 'y' ]; then
  echo updating $DatabaseList
  strings db.log |grep "_Database" > $DatabaseList
else
  echo Skip Updating $DatabaseList
fi


rm -f db.log