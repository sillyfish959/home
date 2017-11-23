#!/bin/bash


sudo -u owntspsg cat /app/TSPSG/tspuat1/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT1 HOST "$2 }' >/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat2/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT2 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat3/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT3 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat4/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT4 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat5/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT5 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat6/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT6 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat7/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT7 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat8/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT8 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat9/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT9 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat10/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT10 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat11/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT11 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat12/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT12 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat13/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT13 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat14/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT14 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat15/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT15 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat16/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT16 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat17/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT17 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat18/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT18 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat19/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT19 HOST "$2 }' >>/tmp/Hostname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat20/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_HOST= |awk -F '=' '{print "UAT20 HOST "$2 }' >>/tmp/Hostname.txt

sudo -u owntspsg cat /app/TSPSG/tspuat1/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT1 PORT "$2 }' >/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat2/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT2 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat3/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT3 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat4/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT4 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat5/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT5 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat6/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT6 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat7/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT7 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat8/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT8 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat9/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT9 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat10/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT10 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat11/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT11 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat12/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT12 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat13/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT13 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat14/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT14 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat15/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT15 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat16/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT16 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat17/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT17 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat18/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT18 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat19/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT19 PORT "$2 }' >>/tmp/Portname.txt
sudo -u owntspsg cat /app/TSPSG/tspuat20/mxg2000_settings.sh 2>/dev/null |grep MXJ_FILESERVER_PORT= |awk -F '=' '{print "UAT20 PORT "$2 }' >>/tmp/Portname.txt

paste /tmp/Hostname.txt /tmp/Portname.txt
