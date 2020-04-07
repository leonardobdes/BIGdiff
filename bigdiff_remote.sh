#!/bin/bash

# Author: Leonardo Souza
# Version: 1.0.0
# Date: 03/04/2020

# Version History
# 1.0.0 - First Version

## Variables ##
# No need to declare variables in Bash, but this is just to keep track
file="" # File with list of devices
option="" # Option to pass to BIGdiff script
username="" # Username to login to the devices
password="" # Username to login to the devices
SSHPASS="" # Password variable used by sshpass
output="" # Output from BIGdiff script
exit_code="" # Exit code from BIGdiff script
valid_options=( "--before" "--after" "--before-without" "--after-without" "--backup" "--ucs" "--qkview" "--logs" ) # Valid options to call BIGdiff script remotely
before_file="" # File to copy to perform after or aftre-without options for BIGdiff script

# Provide information about how to run the script
usage()
{
  echo "Usage: `basename $0` --option file"
  echo "option - Option that will be passed to BIGdiff script"
  echo "file - File with the list of devices, on per line, either with IP or name"
  exit 0
}
check_file()
{
  if [[ ! -f $file ]]
  then
    echo "Error: Not a valid file."
    exit 0
  fi
}
check_option()
{
  printf "%s \n" ${valid_options[@]} | fgrep -w -- $option &> /dev/null
  [[ $? != 0 ]] && echo "Error: Not a valid option." && exit 0
}
get_credentials()
{
  echo -n "Username:"
  read username
  echo -n "Password:"
  read -s password
  echo
}
copy_files()
{
  for line in ${2}
  do
    SSHPASS=$password sshpass -e scp -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${username}@${1}:${line} . &> /dev/null
    if [[ $? == 0 ]]
    then
      echo "Downloaded file ${line}"
      SSHPASS=$password sshpass -e ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${username}@${1} rm -f ${line} &> /dev/null
      [[ $? != 0 ]] && echo "Error: While deleting file ${line}." && exit 0
    else
      echo "Error: While downloading file ${line}."
    fi
  done
}
run()
{
  SSHPASS=$password sshpass -e scp -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no bigdiff.sh ${username}@${1}:~ &> /dev/null
  [[ $? != 0 ]] && echo "Error: While uploading bigdiff.sh." && exit 0
  output=`SSHPASS=$password sshpass -e ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${username}@${1} bash bigdiff.sh $option`
  exit_code=$?
  if [[ $exit_code != 0 ]]
  then
    echo "Error: While running BIGdiff."
    echo "BIGdiff error code: $exit_code"
    exit 0
  else
    if [[ $option == "--before" ]] || [[ $option == "--before-without" ]]
    then
      echo "Before file created."
      output=`printf "%s\n" ${output[@]} | grep -v -e '-before-.*txt'`
    fi
    copy_files ${1} "$output"
    if [[ $option != "--before" ]] && [[ $option != "--before-without" ]]
    then
      SSHPASS=$password sshpass -e ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${username}@${1} rm -f bigdiff.sh &> /dev/null
      [[ $? != 0 ]] && echo "Error: While deleting bigdiff.sh." && exit 0
    fi
  fi
}
devices()
{
  for line in `cat $file`
  do
    echo "Device: $line"
    run $line
  done
}
if [[ $# -eq 2 ]]
then
{
  option=$1
  file=$2
  check_file
  check_option
  get_credentials
  devices
  [[ $option == "--before" ]] && [[ $option != "--before-without" ]]
}
else
{
  usage
}
fi
exit 0