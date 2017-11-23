#!/bin/bash

if [ $# != 1 ]; then
    echo e.g.:
    echo `basename $0` REP
    echo param = FIN/REP/VAR/MLC/HST
    exit 1
fi

cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
    
if [ $1 = 'FIN' ];then
  sqlline=$SQLPLUS_STRING
elif [ $1 = 'REP' ];then
  sqlline=$SQLPLUS_STRING_REP
elif [ $1 = 'VAR' ];then
  sqlline=$SQLPLUS_STRING_VAR
elif [ $1 = 'MLC' ];then
  sqlline=$SQLPLUS_STRING_MLC
elif [ $1 = 'HST' ];then
  sqlline=$SQLPLUS_STRING_HST
else
  echo "Please key in proper parameter"
  exit 1
fi

echo sqlline= $sqlline
rm -f Dev_Env

if [[ $sqlline = '' ]]; then
  echo "can not find sql string in config.cmd"
  exit 1
fi

echo "select Index_Name, Table_Name, Column_Name from all_ind_columns;" >temp.sql

sqlplus $sqlline > sql_out.txt<< EOF
	SET echo off
	SET feedback off
	SET term off
	SET pagesize 0
	SET newpage 0
	SET space 0
	set termout off;
	set verify off;
	set trimspool on;
	set linesize 200;
	set longchunksize 200000;
	set long 200000;
	set pages 0;
	COLUMN column_name FORMAT A40;
	column Index_Name format a40;
        column Table_Name format a40;
        spool myfile.csv
    	@temp.sql
	spool off
	exit;
EOF

echo
cat myfile.csv | grep -v "SQL>" > sql_out.txt
rm -rf test.sql myfile.csv
cat sql_out.txt |awk '{print $1,$2","$3}' |awk -F ',' 'NF>1{a[$1] = a[$1]","$2}; END{for(i in a){print i""a[i]}}'  |sort|tee Index.csv


