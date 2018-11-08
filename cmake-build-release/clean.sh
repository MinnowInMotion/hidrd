#!/bin/sh
srcdir=`dirname $0`
test -z "$srcdir" && srcdir=. 

THEDIR=`pwd`
rm -r .deps
cd $srcdir
rm CMakeCache.txt  
rm *.cmake 
rm -r ../build ../dist
rm -r CMakeFiles 
rm *.so
rm Makefile 
rm install_manifest.txt
#cmake .. -DCMAKE_C_COMPILER=/home/anthony/Android/Sdk/ndk-bundle/i686-none-linux-android21/bin/i686-linux-android-gcc -DCMAKE_INSTALL_PREFIX=/usr
