::
::  Copyright Murex S.A.S., 2003-2014. All Rights Reserved.
::
::  This software program is proprietary and confidential to Murex S.A.S and its affiliates ("Murex") and, without limiting the generality of the foregoing reservation of rights, shall not be accessed, used, reproduced or distributed without the
::  express prior written consent of Murex and subject to the applicable Murex licensing terms. Any modification or removal of this copyright notice is expressly prohibited.
::
@ECHO OFF

REM Mx.3 Client Launcher
REM Modify this script to match your java and server environment

setlocal

call config.cmd

SET MXJ_SITE_NAME=site1

SET MXJ_PLATFORM_NAME=MX
SET MXJ_PROCESS_NICK_NAME=MX

SET MXJ_PING_POP_GUI_DOCUMENT=1
SET MXJ_POP_CONNECTION_TIME_OUT=60000

SET PATH=%JAVAHOME%\jre\bin;%JAVAHOME%\jre\bin\client;%JAVAHOME%\bin;%PATH%
SET PATH=%PATH%;bin\
SET MXJ_JAR_FILELIST=murex.download.guiclient.download
SET MXJ_POLICY=java.policy
SET MXJ_BOOT=mxjboot.jar
SET MXJ_CONFIG_FILE=client.xml

IF EXIST jar\%MXJ_BOOT% copy jar\%MXJ_BOOT% . >NUL

title %~n0 FS:%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST%  Xml:%SET MXJ_SITE_NAME=site1

start javaw -Xbootclasspath/p:jar/xercesImpl-2.9.1.jar;jar/xml-apis-1.3.04.jar;jar/xalan-2.7.1m1.jar;jar/serializer-2.7.1m.jar -Xmx256M -XX:MaxPermSize=100M -cp %MXJ_BOOT% -Dsun.java2d.noddraw=true -DJINTEGRA_NATIVE_MODE -Djava.security.policy=%MXJ_POLICY% -Djava.rmi.server.codebase=http://%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST% -jar %MXJ_BOOT% /MXJ_MLC_SERVICE:MXMLC.SESSION /MXJ_SITE_NAME:%MXJ_SITE_NAME% /MXJ_CLASS_NAME:murex.gui.xml.XmlGuiClientBoot /MXJ_PLATFORM_NAME:%MXJ_PLATFORM_NAME% /MXJ_PROCESS_NICK_NAME:%MXJ_PROCESS_NICK_NAME% /MXJ_CONFIG_FILE:%MXJ_CONFIG_FILE% /MXJ_PING_POP_GUI_DOCUMENT:%MXJ_PING_POP_GUI_DOCUMENT% /MXJ_POP_CONNECTION_TIME_OUT:%MXJ_POP_CONNECTION_TIME_OUT% %1 %2 %3 %4 %5 %6

title Command Prompt
endlocal
