::
::  Copyright Murex S.A.S., 2003-2013. All Rights Reserved.
::
::  This software program is proprietary and confidential to Murex S.A.S and its affiliates ("Murex") and, without limiting the generality of the foregoing reservation of rights, shall not be accessed, used, reproduced or distributed without the
::  express prior written consent of Murex and subject to the applicable Murex licensing terms. Any modification or removal of this copyright notice is expressly prohibited.
::
@ECHO OFF

REM Mx.3 Rich Client Launcher
REM Mofify this script to match your java and server environnement

setlocal

call config.cmd


SET MXJ_SITE_NAME=site1

SET MXJ_PLATFORM_NAME=MX
SET MXJ_PROCESS_NICK_NAME=MX

REM SET DSD_HTML_HELP=-DHelpURL=http://...
SET DSD_HTML_HELP=

SET PATH=%JAVAHOME%\jre\bin;%JAVAHOME%\jre\bin\client;%JAVAHOME%\bin;%PATH%
SET PATH=%PATH%;bin\
SET MXJ_JAR_FILELIST=murex.download.richclient.download
SET MXJ_POLICY=java.policy
SET MXJ_BOOT=mxjboot.jar
SET MXJ_CONFIG_FILE=client.xml

IF EXIST jar\%MXJ_BOOT% copy jar\%MXJ_BOOT% . >NUL

title %~n0 FS:%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST%  Xml:%SET MXJ_SITE_NAME=site1

java -Xmx256m -cp %MXJ_BOOT% -Dsun.java2d.noddraw=true -Declipse.product=com.murex.richclient.application.product -Djava.security.policy=%MXJ_POLICY% -Dmurex.gui.session.modal.deactivate=true -Dmurex.gui.container.family=com.murex.richclient.ui.internal.EclipseViewContainer %DSD_HTML_HELP% -Djava.rmi.server.codebase=http://%MXJ_FILESERVER_HOST%:%MXJ_FILESERVER_PORT%/%MXJ_JAR_FILELIST% murex.rmi.loader.RmiLoader /MXJ_SITE_NAME:%MXJ_SITE_NAME% /MXJ_CLASS_NAME:org.eclipse.core.launcher.Main /MXJ_PLATFORM_NAME:%MXJ_PLATFORM_NAME% /MXJ_PROCESS_NICK_NAME:%MXJ_PROCESS_NICK_NAME% /MXJ_CONFIG_FILE:%MXJ_CONFIG_FILE% %1 %2 %3 %4 %5 %6

title Command Prompt
endlocal
