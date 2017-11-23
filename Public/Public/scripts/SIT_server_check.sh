#!/bin/bash

if [ $# != 1 ]; then
  echo
  echo usage: e.g. ./server_check.sh ownccr@lxccrtsg92
#  echo use: ssh-copy-id $user_server to copy ssh key
  echo
  exit 1
fi
user_server=$1

ssh $user_server -o "PasswordAuthentication no" -o "StrictHostKeyChecking no" exit 2>/dev/null
if [ $? != 0 ]; then
  echo $user_server not connected! 
else
  echo $user_server
  scp MxConfigChecker.py $user_server:/tmp/ 1>/dev/null 2>/dev/null
  ssh $user_server -o "PasswordAuthentication no" -o "StrictHostKeyChecking no" python /tmp/MxConfigChecker.py -l 2>/dev/null
fi

