#!/bin/sh
# Anthony (Anthony@claydonkey.com)
# This script runs a configure script with the Android NDK toolchain
# You may need to adjust the TARGET, NDK, ARCH, HOST, PREFIX and ANDROID_API variable
# depending on your requirements.
#   

# Example: 
# $: mkdir build && cd build 
# export NDK=${HOME}/Android/ndk-bundle ../android-configure.sh
set -e
OS=
FLAGS=
BUILD_OS=
declare -A AARCH     # Create an associative array
declare -A AEABI
declare -A AMARCH
declare -A ATRIPLET
declare -A AEABISPECIFIC
declare -A AFLAGS
declare -A ACOMPILER_TRIP

ARCHS="armeabi-v7a x86 x86_64"
 
if uname -s | grep -i 'linux' &> /dev/null; then
  IS_LINUX=1
fi

if [ $IS_LINUX ]; then
  NCPU=`cat /proc/cpuinfo | grep -c -i processor`
  BUILD=x86_64-pc-linux-gnu 
  BUILD_OS=linux
else
  NCPU=8
  BUILD=x86_64-pc-mingw64 
fi


while getopts ":o:f:p:a:t:e:" opts; do
  case $opts in
    o)
      echo "-o : $OPTARG" >&2
      OS=$OPTARG
      ;;
    f)
      echo "-f : $OPTARG" >&2
      FLAGS=$OPTARG
      ;;
    p)
      echo "-p : $OPTARG" >&2
      PREFIX=$OPTARG
      ;;
    a)
      echo "-a : $OPTARG" >&2
      ANDROID_API=$OPTARG
      ;;
    t)
      echo "-t : $OPTARG" >&2
      FLAGS=$OPTARG
      ;;
    e)
      echo "-e : $OPTARG" >&2
      ARMEABI=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$opts" >&2
      exit 1
      ;;
    :)
      echo "Option -$opts requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ "$OS" == "android" ]; then

if [ -z ${NDK} ]; then
  NDK=`which ndk-build`
  NDK=`dirname $NDK`
  if [ $IS_LINUX ]; then
    NDK=`readlink -f $NDK`
  fi
  echo "Please set NDK environment variable to the root directory of the Android NDK. Otherwise defaulting to location of ndk-build"
fi

if [ -z ${ANDROID_API} ]; then
    export ANDROID_API=21
  echo "Please set ANDROID_API environment variable . Otherwise defaulting to ${ANDROID_API}"

fi

function getLDflags()
{ 
  case $1 in
armeabi-v7a)
  echo "-L$SYSROOT/usr/lib64 -llog"
  ;;
x86_64)
  echo "-L$SYSROOT/usr/lib64 -llog"
  ;;
x86)
  echo "-L$SYSROOT/usr/lib -llog"
  ;;
esac
}


AARCH[armeabi-v7a]=arm       
AEABI[armeabi-v7a]=armeabi-v7a 
AMARCH[armeabi-v7a]=armv7-a    
ATRIPLET[armeabi-v7a]=armv7a-none-linux-android${ANDROID_API}
AEABISPECIFIC[armeabi-v7a]="-mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb " 
AFLAGS[armeabi-v7a]="-Wno-error "
ACOMPILER_TRIP[armeabi-v7a]=arm-linux-androideabi

AARCH[x86]=x86      
AEABI[x86]=x86   
AMARCH[x86]=i686
ATRIPLET[x86]=i686-none-linux-android${ANDROID_API}
AEABISPECIFIC[x86]=""
AFLAGS[x86]="-Wno-error -Wno-implicit-function-declaration  --gcc-toolchain=${NDK}/toolchains/x86-4.9/prebuilt/linux-x86_64"
ACOMPILER_TRIP[x86]=i686-linux-android

AARCH[x86_64]=x86_64      
AEABI[x86_64]=x86_64   
AMARCH[x86_64]=x86-64  
ATRIPLET[x86_64]=x86_64-none-linux-android${ANDROID_API}
AEABISPECIFIC[x86_64]=""
AFLAGS[x86_64]="-Wno-error -Wno-implicit-function-declaration"
ACOMPILER_TRIP[x86_64]=x86_64-linux-android


if [ -z ${ARMEABI} ]; then
  SETEABI="x86_64"
    SETEABI="armeabi-v7a"
    
    export ARMEABI=${AEABI[${SETEABI}]}
    ARCH=${AARCH[${SETEABI}]}
    MARCH=${AMARCH[${SETEABI}]}
    TRIPLET=${ATRIPLET[${SETEABI}]}
    EABISPECIFIC=${AEABISPECIFIC[${SETEABI}]}
    COMPILER_TRIP=${ACOMPILER_TRIP[${SETEABI}]}
    echo "Please set ARMEABI environment variable to the arm architecture. Otherwise defaulting to ${ARMEABI}"
else
    case $ARCHS in
    *"$ARMEABI"*) 
     ;;
    *) 
      echo "Not a Valid Architecture"
      exit 1;;
    esac
    export ARMEABI=${AEABI[${ARMEABI}]}
    ARCH=${AARCH[${ARMEABI}]}
    MARCH=${AMARCH[$ARMEABI]}
    TRIPLET=${ATRIPLET[${ARMEABI}]}
    EABISPECIFIC=${AEABISPECIFIC[${ARMEABI}]}  
    COMPILER_TRIP=${ACOMPILER_TRIP[${ARMEABI}]}
fi

if [ -z ${TARGET} ]; then
    export TARGET=${TRIPLET}
  echo "Please set TARGET environment variable to triplet of the target compiler. Otherwise defaulting to ${TARGET}"
fi

if [ -z ${HOST} ]; then
    export HOST=${TRIPLET}
  echo "Please set HOST environment variable to the triplet of the host system Otherwise defaulting to the target: ${HOST}"
fi

# This is just an empty directory where I want the built objects to be installed
if [ -z ${PREFIX} ]; then
        export PREFIX=/usr
  echo "Please set PREFIX environment variable to the output directory. Otherwise defaulting to ${PREFIX}"
fi
 # create toolchain
if [ ! -d ${NDK}/${TARGET} ]; then
  $NDK/build/tools/make_standalone_toolchain.py  --arch ${ARCH} --api ${ANDROID_API} --install-dir ${NDK}/${TARGET}
fi

 
export SYSROOT=${NDK}/${TARGET}/sysroot
export PATH=${SYSROOT}/usr/bin:${TOOLCHAIN_PATH}:${PATH}
export TOOLCHAIN_PREFIX=${NDK}/${TARGET}/bin
  
export AR=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-ar
export AS=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-as
export NM=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-nm
CC=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-gcc
CXX=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-g++
export RANLIB=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-ranlib
export STRIP=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-strip
export OBJDUMP=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-objdump
export OBJCOPY=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-objcopy
export ADDR2LINE=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-addr2line
export READELF=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-readelf
export SIZE=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-size
export STRINGS=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-strings
export ELFEDIT=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-elfedit
export GCOV=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-gcov
export GDB=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-gdb
export GPROF=${TOOLCHAIN_PREFIX}/${COMPILER_TRIP}-gprof
# Don't mix up .pc files from your host and build target

export PKG_CONFIG_PATH="${SYSROOT}/usr/lib/pkgconfig"
export XML2_CONFIG="${SYSROOT}/usr/bin/xml2-config"
  
export PYTHON_CFLAGS="-I$${NDK}/${TARGET}/include/python2.7"
export PYTHON_LDFLAGS="-L${NDK}/${TARGET}/lib/python2.7"
 

CFLAGS="${CFLAGS}  -fPIE -fPIC -march=${MARCH} ${EABISPECIFIC} ${AFLAGS[${ARMEABI}]}  $(getLDflags ${ARMEABI}) --sysroot=${SYSROOT} ${PYTHON_CFLAGS}"
export CPPFLAGS=" ${CFLAGS} -I${NDK}/${TARGET}/include/c++/4.9.x"
LDDFLAGS="-fPIC -pie -march=${MARCH} ${EABISPECIFIC}  ${AFLAGS[${ARMEABI}]} $(getLDflags ${ARMEABI}) --sysroot=${SYSROOT} ${PYTHON_LDFLAGS} ${LDFLAGS}"
 
else

CFLAGS="-g -O0 -w -Wno-error  ${CFLAGS}"
CPPFLAGS="-g -O0 -w -Wno-error  ${CPPFLAGS}"
PREFIX=/usr
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export TARGET=x86_64-pc-linux-gnu

fi
#!/bin/sh
# Run this to generate all the initial makefiles, etc.
 
srcdir=`dirname $0`
test -z "$srcdir" && srcdir=. 

THEDIR=`pwd`
cd $srcdir
DIE=0
 

(autoconf --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo "You must have autoconf installed to compile hidrd."
  echo "Download the appropriate package for your distribution,"
  echo "or see http://www.gnu.org/software/autoconf"
  DIE=1
}

(libtoolize --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo "You must have libtool installed to compile hidrd."
  echo "Download the appropriate package for your distribution,"
  echo "or see http://www.gnu.org/software/libtool"
  DIE=1
}

(automake --version) < /dev/null > /dev/null 2>&1 || {
  echo
  DIE=1
  echo "You must have automake installed to compile hidrd."
  echo "Download the appropriate package for your distribution,"
  echo "or see http://www.gnu.org/software/automake"
}

if test "$DIE" -eq 1; then
  exit 1
fi

#test -f entities.c || {
#  echo "You must run this script in the top-level libxml directory"
#  exit 1
#}


if [ ! -d $srcdir/m4 ]; then
        mkdir -p $srcdir/m4
fi

# Replaced by autoreconf below
autoreconf -if -Wall

mkdir -p build
mkdir -p build/${TARGET}
 
cd build/${TARGET}
   
 echo ${CFLAGS}

  CONFIG_CMD="../../configure --build=${BUILD}  --with-sysroot=${SYSROOT} --host=${HOST}   --prefix=${PREFIX} CXX=$CXX CC=$CC CFLAGS='${CFLAGS}' LDDFLAGS='${LDDFLAGS}'  ${FLAGS}  --with-xml2-config=/home/anthony/Android/Sdk/ndk-bundle/i686-none-linux-android21/sysroot/usr/bin/xml2-config"
  echo "/////////////////////////////////////////////////////"
 echo "running config ${CONFIG_CMD}"
 #exit 1
 eval $CONFIG_CMD
#"$@"
    echo "/////////////////  $OS  $ARMEABI ////////////////////"
    echo "Running 'make' and installing to dist."
   make -j${NCPU}   
   #V=1
 
if [ "$OS" = "android" ]; then 
   make DESTDIR=${PWD}/../../dist/${ARMEABI} install
   # Makefile.am uses ARMEABI 
   # NOT FOR SYSROOT otherwise && make DESTDIR=${SYSROOT} install 
else
  make DESTDIR=${PWD}/../../dist/${TARGET} install 
fi
