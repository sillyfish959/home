#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo usage:
    echo e.g. 
    echo ./ddDependency.sh ../../Public/ddDependency/All.xml
    echo
    exit 1
else
    DD_INPUT="$1"
    DD_OUTPUT=`echo ${DD_INPUT}|rev|cut -f 1 -d"/"|rev |cut -f 1 -d"."`
    DD_OUTPUT="${DD_OUTPUT}.zip"
fi


#set local from config.cmd
cat config.cmd |awk -F ' ' ' { print $2 } ' > config.sh
source config.sh
echo HOST= $MXJ_FILESERVER_HOST
echo PORT= $MXJ_FILESERVER_PORT
rm config.sh
##########

MXJ_PLATFORM_NAME=MX
MXJ_PROCESS_NICK_NAME=MXDICTIONARY.SPACES
MXJ_CONFIG_FILE=murex.mxres.mxdictionary.client.datadictionaryconfig.mxres
MXJ_TEMPLATE_CONFIG_FILE=murex.mxres.mxtemplates.client.templatesconfig.mxres
MXJ_DEPENDENCY_SCRIPT_CONFIG=$1
MXJ_JAR_FILE=murex.download.guiclient.download
MXJ_BOOT_JAR=mxjboot.jar
MXJ_SITE_NAME=site1

java -Xmx256m -cp $MXJ_BOOT_JAR -Djava.rmi.server.codebase=http://$MXJ_FILESERVER_HOST:$MXJ_FILESERVER_PORT/$MXJ_JAR_FILE murex.rmi.loader.RmiLoader \
/MXJ_CLASS_NAME:murex.apps.datalayer.client.dictionary.dependency.script.DependencyScript /MXJ_CONFIG_FILE:$MXJ_CONFIG_FILE /MXJ_TEMPLATE_CONFIG_FILE:$MXJ_TEMPLATE_CONFIG_FILE /MXJ_DEPENDENCY_SCRIPT_CONFIG:$MXJ_DEPENDENCY_SCRIPT_CONFIG /MXJ_SITE_NAME:$MXJ_SITE_NAME /MXJ_PLATFORM_NAME:$MXJ_PLATFORM_NAME \
/MXJ_PROCESS_NICK_NAME:$MXJ_PROCESS_NICK_NAME $* 
