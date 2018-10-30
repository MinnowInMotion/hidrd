#!/bin/sh

echo running: "$0"

export COMPILE_TOOL=x86_64-w64-mingw32
export PREFIX=/mingw64
export PATH=${PREFIX}/bin:${PATH}
# Apparently android-8 works fine, there are other versions, look them up
#export SYSROOT=${PREFIX}/sysroot/usr
#export CFLAGS="-fPIE -pie -I${ANDROID_PREFIX}/include/python2.7 -DHAVE_IEEEFP_H=0 -DHAVE_SSIZE_T -DPY_FORMAT_SIZE_T=l -DPY_FORMAT_LONG_LONG=ll"
#export CROSS_PATH=${PREFIX}/bin/${CROSS_COMPILE}
#export PYTHON_INCLUDES=${PREFIX}/include/python2.7
#export PYTHON_LIBS="-L${PREFIX}/lib/python2.7 -L${PREFIX}/lib"

# Non-exhaustive lists of compiler + binutils
# Depending on what you compile, you might need more binutils than that
export CXX=${COMPILE_TOOL}-g++.exe
export AR=${COMPILE_TOOL}-ar.exe
export AS=${COMPILE_TOOL}-as.exe
export NM=${COMPILE_TOOL}-nm.exe
export CC=${COMPILE_TOOL}-gcc.exe
export CXX=${COMPILE_TOOL}-g++.exe
export LD=${COMPILE_TOOL}-ld.exe
export RANLIB=${COMPILE_TOOL}-ranlib.exe


#export XML2_CONFIG="/./bin/xml2-config"
export LIBXML2_CFLAGS="-I./include/libxml2 -static-libgcc"
export LIBXML2_LIBS="-L./lib -lxml2 -lz -liconv "


# Don't mix up .pc files from your host and build target
#export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

# You can clone the full Android sources to get bionic if you want.. I didn't
# want to so I just got linker.h from here: http://gitorious.org/0xdroid/bionic
# Note that this was only required to build boehm-gc with dynamic linking support.
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/include -w  -static-libgcc"
export CXXFLAGS="-O3 -L${PREFIX}/include -w -Wno-error -static-libg++"
export LDFLAGS="${LDFLAGS}  -L${PREFIX}/lib -lz"

./configure  --prefix=${PREFIX}  --target=mingw64  --enable-debug "$@"
