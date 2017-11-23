#!/bin/bash

if [ $# != 1 ]; then
    echo 
    echo "usage:"
    echo
    echo ./env_check.sh -s      :check workflow sheets name
    echo ./env_check.sh -m      :check MQ setup in exchange sheets
    echo ./env_check.sh -a      :check AuthorizationQueue input code in Contact, Deliverable and Exchange sheets
    echo
    exit 1
fi


if [ $1 == '-m' ]; then
    rm -rf Exchange 
    cp -u ../../Public/scripts/export_WF.sh ./ 2>/dev/null
    ./export_WF.sh ../../Public/WF/Exchange.xml
    unzip -q Exchange.zip -d Exchange 
    echo
    printf " %-60s %-30s \n" "TaskName" "Queue"
    echo
    grep 'Property name="Queue"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|[:<>]' '{print $5}' > Exchange/Queue.txt
    xmllint --format Exchange/workflow |grep -E 'taskCode|XmlDocument="Y"' |grep -E 'XmlDocument="Y"' -B1 |grep taskCode |awk -F '[<>]' '{print $3}' > Exchange/mapping.txt
    cat -n Exchange/mapping.txt > Exchange/n_mapping.txt
    grep 'Property name="Queue"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|:' '{print $2}' > Exchange/list.txt
    while read line; do grep -E "^[ ]*$line[[:blank:]]" Exchange/n_mapping.txt;   done <Exchange/list.txt | awk '{print $2}' > Exchange/WorkSheet.txt
    paste Exchange/WorkSheet.txt Exchange/Queue.txt |awk -F ' ' ' { printf "%-60s%-30s\n",$1,$2 } '
    rm -f Exchange.zip
    rm -rf Exchange

fi

if [ $1 == '-e' ]; then
    rm -rf Exchange 
    cp -u ../../Public/scripts/export_WF.sh ./ 2>/dev/null
    ./export_WF.sh ../../Public/WF/Exchange.xml
    unzip -q Exchange.zip -d Exchange 
    echo
    printf " %-50s %-70s %-30s \n" "TaskName" "To" "Cc"
    echo
    grep 'Property name="To"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|[:<>]' '{print $5}' > Exchange/To.txt
    xmllint --format Exchange/workflow |grep -E 'taskCode|XmlDocument="Y"' |grep -E 'XmlDocument="Y"' -B1 |grep taskCode |awk -F '[<>]' '{print $3}' > Exchange/mapping.txt
    cat -n Exchange/mapping.txt > Exchange/n_mapping.txt
    grep 'Property name="To"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|:' '{print $2}' > Exchange/list.txt
    while read line; do grep -E "^[ ]*$line[[:blank:]]" Exchange/n_mapping.txt;   done <Exchange/list.txt | awk '{print $2}' > Exchange/WorkSheet.txt
    paste Exchange/WorkSheet.txt Exchange/To.txt >Exchange/WorkSheet2.txt
    
    grep 'Property name="Cc"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|[:<>]' '{print $5}' > Exchange/Cc.txt
    xmllint --format Exchange/workflow |grep -E 'taskCode|XmlDocument="Y"' |grep -E 'XmlDocument="Y"' -B1 |grep taskCode |awk -F '[<>]' '{print $3}' > Exchange/mapping.txt
    cat -n Exchange/mapping.txt > Exchange/n_mapping.txt
    grep 'Property name="Cc"' Exchange/workflow.document.* |awk -F 'Exchange/workflow.document.|:' '{print $2}' > Exchange/list.txt
    while read line; do grep -E "^[ ]*$line[[:blank:]]" Exchange/n_mapping.txt;   done <Exchange/list.txt | awk '{print $2}' > Exchange/WorkSheet.txt
    paste Exchange/WorkSheet2.txt Exchange/Cc.txt |awk -F ' ' ' { printf "%-50s%-70s%-30s\n",$1,$2,$3} '
    
    rm -f Exchange.zip
    rm -rf Exchange
fi

if [ $1 == '-s' ]; then
    rm -rf Exchange 
    cp -u ../../Public/scripts/export_WF.sh ./ 2>/dev/null
    ./export_WF.sh ../../Public/WF/Exchange.xml
    unzip -q Exchange.zip -d Exchange 

    xmllint.exe --format Exchange/workflow |grep 'wf:sheet Code=' | awk -F'"' '{print $2}'

    rm -f Exchange.zip
    rm -rf Exchange
fi

if [ $1 == '-a' ]; then
    rm -rf Cont_Deli_Exch_Even
    cp -u ../../Public/scripts/export_WF.sh ./ 2>/dev/null
    ./export_WF.sh ../../Public/WF/Cont_Deli_Exch_Even.xml
    unzip -q Cont_Deli_Exch_Even.zip -d Cont_Deli_Exch_Even
    xmllint --format Cont_Deli_Exch_Even/workflow |grep "<wf:taskTypeCode>AuthorizationQueue</wf:taskTypeCode>" -A 10 |grep "<wf:taskNodeCode>Input</wf:taskNodeCode>" -A2 |grep "<wf:taskNodeFilterCode>"|awk -F '[<>]' '{print $3}'
    xmllint --format Cont_Deli_Exch_Even/workflow |grep "<wf:taskTypeCode>AuthorizationQueue</wf:taskTypeCode>" -B 6 |grep "</wf:taskCode>"|awk -F '[<>]' '{print $3}'
    rm -f Cont_Deli_Exch_Even.zip
    rm -rf Cont_Deli_Exch_Even
fi
