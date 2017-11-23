#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo usage:
    echo e.g.
    echo ./export_WF.sh ../../Public/WF/Exchange.xml
    echo
    exit 1
else
    WF_INPUT="$1"
    WF_OUTPUT=`echo ${WF_INPUT}|rev|cut -f 1 -d"/"|rev |cut -f 1 -d"."`
    WF_OUTPUT="${WF_OUTPUT}.zip"
fi

#set local from config.cmd
cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
##########

MXJ_CLASS_NAME=murex.xml.server.xmlflow.exchange.scripts.ExchangeExportWorkflowScript
MXJ_BOOT=mxjboot.jar
MXJ_POLICY=java.policy
MXJ_JAR_FILELIST=murex.download.guiclient.download
MXJ_SITE_NAME=site1
MXJ_PLATFORM_NAME=MX
MXJ_PROCESS_NICK_NAME=MXMLEXCHANGE
MXJ_CONFIG_FILE=$WF_INPUT
MXJ_EXPORT_FILE=$WF_OUTPUT

java -cp $MXJ_BOOT -Djava.security.policy=$MXJ_POLICY -Djava.rmi.server.codebase=http://$MXJ_FILESERVER_HOST:$MXJ_FILESERVER_PORT/$MXJ_JAR_FILELIST murex.rmi.loader.RmiLoader /MXJ_CLASS_NAME:$MXJ_CLASS_NAME /MXJ_SITE_NAME:$MXJ_SITE_NAME /MXJ_PLATFORM_NAME:$MXJ_PLATFORM_NAME /MXJ_PROCESS_NICK_NAME:$MXJ_PROCESS_NICK_NAME /MXJ_CONFIG_FILE:$MXJ_CONFIG_FILE /MXJ_EXPORT_FILE:$MXJ_EXPORT_FILE
