#!/bin/sh
#
# File:   start_gdbd.sh
# Author: Anthony Campbell
#
# Created on 11-Aug-2016, 13:04:35
#
ex=0


if [[ $# -eq 0 ]] ; then
    echo 'add  app_url <url> app_instance  <instance id>'
    ex=1
fi
#if [[ $# -eq 1 ]] ; then
  #  echo 'add app id <id>'
# ex=1
#fi
if [ $ex == 1 ] ; then
exit 0
fi

adb pull //system/xbin/daemonsu  $(dirname $0)/System  #is where app_process links
mv $(dirname $0)/System/daemonsu $(dirname $0)/System/app_process64
adb pull //system/bin/linker64  $(dirname $0)/System
adb forward tcp:5039 tcp:5039

appProcID=$(adb shell ps | grep $1 | awk '{print $2}')
echo $appProcID

if [[ $# -eq 1 ]] ; then
adb   shell   //data/local/tmp/gdbserver tcp:5039 --attach $appProcID
else
adb shell   run-as com.claydonkey.hidrd  //data/app/com.claydonkey.hidrd-"$2"/lib/arm64/gdbserver.so tcp:5039 --attach $appProcID
fi

#adb shell   //data/local/tmp/gdbserver tcp:5039 --attach $(adb shell ps | grep $1 | awk '{print $2}')
#sleep 10
# /android64/bin/gdb   $(dirname $0)/System/app_process64

#/data/app/com.claydonkey.hidrd-2/lib/arm64/
#/data/app/com.claydonkey.hidrd-1/lib/arm64/

#/storage/emulated/0/Android/data/com.claydonkey.hidrd/files/mouse_descriptor.xml
#  ./libhidrd-convert.so -i xml /storage/emulated/0/Android/data/com.claydonkey.hidrd/files/mouse_descriptor.xml
# ./libhidrd-convert.so  --help
# ./libhidrd-convert.so -i xml  rd.xml
# ./libhidrd-convert.so -i xml  mouse_descriptor.xml
