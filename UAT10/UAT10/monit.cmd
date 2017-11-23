::
::  Copyright Murex S.A.S., 2003-2013. All Rights Reserved.
::
::  This software program is proprietary and confidential to Murex S.A.S and its affiliates ("Murex") and, without limiting the generality of the foregoing reservation of rights, shall not be accessed, used, reproduced or distributed without the
::  express prior written consent of Murex and subject to the applicable Murex licensing terms. Any modification or removal of this copyright notice is expressly prohibited.
::
@ECHO OFF

REM Mx G2000 Monitor Launcher
REM Mofify this script to match your java and server environnement

setlocal
call config.cmd

SET MXJ_SITE_NAME=site1

SET MXJ_LOGGER_FILE=public.mxres.loggers.default_logger.mxres
SET MXJ_POP_CONNECTION_TIME_OUT=60000
SET MXJ_PING_POP_GUI_DOCUMENT=1000

SET PATH=%JAVAHOME%\jre\bin;%JAVAHOME%\jre\bin\client;%JAVAHOME%\bin;%JAVAHOME%\bin\classic;%PATH%
SET PATH=%PATH%;bin\
SET MXJ_JAR_FILELIST=murex.download.monit.download
SET MXJ_POLICY=java.policy
SET MXJ_BOOT=mxjboot.jar

IF EXIST jar\%MXJ_BOOT% copy jar\%MXJ_BOOT% . >NUL

IF NOT EXIST logs MD logs >NUL
SET MTIMESTAMP=%date%%time%
SET MTIMESTAMP=%MTIMESTAMP: =%
SET MTIMESTAMP=%MTIMESTAMP:/=%
SET MTIMESTAMP=%MTIMESTAMP::=%
SET MTIMESTAMP=%MTIMESTAMP:,=%
SET MLOGFILE=logs\%~n0_%MTIMESTAMP%.log
SET MTITLE=%~n0 FS:%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST% Xml:%MXJ_SITE_NAME% %MTIMESTAMP%
title %MTITLE%

FOR /f "tokens=2 delims=," %%A IN ('TASKLIST /fo csv /v /nh /fi "IMAGENAME eq cmd.exe" ^| FIND "%MTITLE%"') DO SET MCMDPID=%%A
IF DEFINED MCMDPID SET MOOMEXIT=-XX:OnOutOfMemoryError="TASKKILL /F /T /PID %MCMDPID%"
ECHO CMDPID:%MCMDPID% - %MTITLE% > %MLOGFILE% 2>&1
IF NOT EXIST %MLOGFILE% GOTO END

ECHO logging console in %MLOGFILE%
java -showversion -Xmx256m -verbose:gc -XX:+PrintGCTimeStamps %MOOMEXIT% -cp %MXJ_BOOT% -Declipse.product=ObjectMonitor.product -Djava.security.policy=%MXJ_POLICY% -Djava.rmi.server.codebase=http://%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST% murex.rmi.loader.RmiLoader /MXJ_SITE_NAME:%MXJ_SITE_NAME% /MXJ_CLASS_NAME:murex.apps.middleware.gui.monitor.Monitor /MXJ_LOGGER_FILE:%MXJ_LOGGER_FILE% /MXJ_NEW_MONITOR /MXJ_POP_CONNECTION_TIME_OUT:%MXJ_POP_CONNECTION_TIME_OUT% /MXJ_PING_POP_GUI_DOCUMENT:%MXJ_PING_POP_GUI_DOCUMENT% /MXJ_NB_TRY_IF_FAILURE:8 /MXJ_TIME_TO_WAIT_IF_FAILURE:5000 /MXJ_PING_TIME:20000 /MXJ_PING_CHECK:60000 %1 %2 %3 %4 %5 %6 >> %MLOGFILE% 2>&1

:END
title Command Prompt
endlocal
