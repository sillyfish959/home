#!/bin/bash


ServerList="../connections/SIT_Server.csv"
HostPortList="../connections/SIT_HostPort.csv"

rm -f server.log
while read line; do 
  echo ./SIT_server_check.sh $line |sh;
done < $ServerList | tee -a server.log

grep -E "/tspsit|@" server.log > 1.txt && mv 1.txt server.log  # comment this line if consider ccr env

while read line; do 
  case "$line" in 
  *@* ) user_server=$line ;;
  *   ) dir=`echo $line|awk '{print $2}'`; echo $user_server:$dir ;;
  esac
done < server.log > live_dir.list

echo
echo Greping HOSTs and PORTs from Server...
echo

rm -f 2.txt 3.txt
while read line; do 
  rm -f 1.txt
  scp $line/mxg2000_settings.sh ./1.txt 1>/dev/null 2>/dev/null
  grep ^MXJ_FILESERVER_HOST= 1.txt |tail -1 |awk -F '=' '{print $2}' >>2.txt
  grep ^MXJ_FILESERVER_PORT= 1.txt |tail -1 |awk -F '=' '{print $2}' >>3.txt
done < live_dir.list


paste live_dir.list 2.txt 3.txt  |awk -F '/' '{print $NF}' |awk -F ' ' ' { printf "%-15s%-15s%-10s\n",$1,$2,$3 } '|sort -u |grep -E "tspsit[0-9] " > 4.txt
paste live_dir.list 2.txt 3.txt  |awk -F '/' '{print $NF}' |awk -F ' ' ' { printf "%-15s%-15s%-10s\n",$1,$2,$3 } '|sort -u |grep -E "tspsit[1-9][0-9] " >> 4.txt
cat 4.txt
echo


read -p "Update $HostPortList? (y/n): " Confirm
if [ "$Confirm" == 'y' ]; then
  echo updating $HostPortList
  cat 4.txt|awk -F ' ' ' { printf "%s_HostPort,%s,%s\n",$1,$2,$3 } ' > $HostPortList
else
  echo Skip Updating $HostPortList
fi

rm -f 1.txt 2.txt 3.txt 4.txt server.log live_dir.list

