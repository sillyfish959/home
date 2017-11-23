#!/bin/bash

if [ $# != 1 ]; then
    echo e.g.:
    echo ./getClientPW.sh CONFIG
    exit 1
fi

cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
    

sqlline=$SQLPLUS_STRING
echo sqlline= $sqlline
rm -f Dev_Env

sqlplus $sqlline > sql_out.txt << EOF
    set linesize 300
    select M_LABEL, M_PASSWORD from MX_USER_DBF where M_LABEL like '$1';
    exit;
EOF

enpw=`grep $1 sql_out.txt| awk '{print $2}'`
echo encrypted passwd= $enpw
rm -f sql_out.txt
cd ../../Public/scripts/

echo
./decrypt.bat $enpw
cd $currdir



