#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo usage:
    echo e.g. 
    echo ./export_DD.sh ../../Public/DD/INTF_Phase2B_MW_Formulae.mxres
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

MXJ_JAR_FILELIST=murex.download.guiclient.download
MXJ_CLASS_NAME=murex.apps.datalayer.client.dictionary.importexport.DDExportScript
MXJ_CONFIG_FILE=murex.mxres.mxdictionary.client.datadictionaryconfig.mxres
MXJ_TEMPLATE_CONFIG_FILE=murex.mxres.mxtemplates.client.templatesconfig.mxres

java -cp mxjboot.jar -Djava.rmi.server.codebase=http://$MXJ_FILESERVER_HOST:$MXJ_FILESERVER_PORT/$MXJ_JAR_FILELIST murex.rmi.loader.RmiLoader /MXJ_CLASS_NAME:${MXJ_CLASS_NAME} /MXJ_CONFIG_FILE:${MXJ_CONFIG_FILE} /MXJ_TEMPLATE_CONFIG_FILE:${MXJ_TEMPLATE_CONFIG_FILE} /MXJ_EXPORT_CONFIG_FILE:${DD_INPUT} /MXJ_EXPORT_FILE:${DD_OUTPUT} /MXJ_CREATE_ZIP:Y /MXJ_ERROR_POLICY:FAIL_ON_ERROR /MXJ_DD_VERSION:MX.3 /MXJ_DATASOURCE_TYPE:1 /MXJ_DATASOURCE_LOCATION: /MXJ_SITE_NAME:site1 /MXJ_PLATFORM_NAME:MX /MXJ_PROCESS_NICK_NAME:MXDICTIONARY.SPACES
