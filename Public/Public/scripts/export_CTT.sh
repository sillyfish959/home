#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo usage:
    echo e.g. 
    echo ./export_CTT.sh ../../Public/CTT/CONV_PHASE2B_SAPGL
    echo 
    exit 1
else
    CTT_INPUT="$1"
    CTT_NAME=`echo ${CTT_INPUT}|rev|cut -f 1 -d"/"|rev`
    echo ${CTT_NAME}
fi

#set local from config.cmd
cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
##########

MXJ_SITE_NAME=site1
MXJ_JAR_FILELIST=murex.download.guiclient.download
MXJ_POLICY=java.policy
MXJ_BOOT=mxjboot.jar
MXJ_CLASS_NAME=murex.apps.cfgtmgmt.main.ExportScriptMain

java -cp $MXJ_BOOT -Djava.security.policy=$MXJ_POLICY -Djava.rmi.server.codebase=http://$MXJ_FILESERVER_HOST:$MXJ_FILESERVER_PORT/$MXJ_JAR_FILELIST -Darguments="$CTT_NAME -u CONFIG -p CONFIG -g CONFIG" -Dfileserver.url=http://$MXJ_FILESERVER_HOST:$MXJ_FILESERVER_PORT -Dsite.name=$MXJ_SITE_NAME -Ddestination.site.name=$MXJ_DESTINATION_SITE_NAME -Dcurrent.dir="$CURRENT_PATH" murex.rmi.loader.RmiLoader /MXJ_CLASS_NAME:$MXJ_CLASS_NAME
