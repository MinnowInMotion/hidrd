cmake_minimum_required(VERSION 3.4.1)
# Anthony (Anthony@claydonkey.com)
# This cmake is a bootstrap for the c++/c 
# standalone toolchain for  Android NDK.
# initializing relevant variables
#
# Setup Toolchain.

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(STAMP_DIR .deps/logs)
set(TMP_DIR .deps/tmp)
unset(CMAKE_C_COMPILER)

set(ANDROID_ABI x86 CACHE STRING "ABI Format")
set_property(CACHE ANDROID_ABI PROPERTY STRINGS armeabi-v7a win64 x86_64 x86 armeabi-v7a)
string(REPLACE REGEX "[A-Za-z]+\-" "" ANDROID_NATIVE_API_LEVEL ${ANDROID_PLATFORM})

if (NOT ANDROID_NATIVE_API_LEVEL)
set(ANDROID_NATIVE_API_LEVEL 26 CACHE STRING "Android API level")
set_property(CACHE ANDROID_NATIVE_API_LEVEL PROPERTY STRINGS 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28)
endif ()
set(ANDROID_NDK /home/anthony/Android/Sdk/ndk-bundle)

set(XML_SCHEMA_PATH /storage/emulated/0/Android/data/com.claydonkey.hidrd/files/hidrd.xsd CACHE STRING "path of the hidrd xsd schema residing on target")
option(CMAKE_SHARED "build shared libraries" ON)
option(CMAKE_STATIC "build static libraries" ON)

if (CMAKE_SHARED)
set(SHARED_FLAG "--enable-shared")
else ()
set(SHARED_FLAG "--disable-shared")
endif ()

if (CMAKE_STATIC)
set(STATIC_FLAG "--enable-static")
else ()
set(STATIC_FLAG "--disable-static")
endif ()

message(STATUS "Current HIDRD_XML_FORMAT_FLAG " ${HIDRD_XML_FORMAT_FLAG})

set(CMAKE_FIND_LIBRARY_PREFIXES lib)
set(CMAKE_FIND_LIBRARY_SUFFIXES .so;.a)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
set(CMAKE_DEBUG_FLAG "-g -O0 -DDEBUG=1")
endif ()

if (CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
set(ANDROID_HOST_TAG linux-x86_64)
elseif (CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
set(ANDROID_HOST_TAG darwin-x86_64)
elseif (CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
set(ANDROID_HOST_TAG windows-x86_64)
endif (CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)

if (ANDROID_ABI STREQUAL armeabi-v7a)
set(COMPILER_ROOT ${ANDROID_NDK}/armv7a-none-linux-android${ANDROID_NATIVE_API_LEVEL})
set(ANDROID_TRIPLE arm-linux-androideabi)
set(ANDROID_SYSROOT_ABI arm)
set(CMAKE_INSTALL_LIBDIR lib)
set(CMAKE_SYSTEM_PROCESSOR armv7-a)
set(CMAKE_GCC_TOOLCHAIN arm-linux-androideabi-4.9)
set(CMAKE_C_EXTRA_FLAGS "-g -O0 -DANDROID -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -mfpu=neon -Wa,--noexecstack -Wformat -Werror=format-security ${CMAKE_DEBUG_FLAG}")
elseif (ANDROID_ABI STREQUAL arm64-v8a)
set(COMPILER_ROOT ${ANDROID_NDK}/aarch64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
set(ANDROID_TRIPLE aarch64-linux-android)
set(ANDROID_SYSROOT_ABI arm64)
set(CMAKE_INSTALL_LIBDIR lib64)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_GCC_TOOLCHAIN aarch64-linux-android-4.9)
elseif (ANDROID_ABI STREQUAL x86_64)
set(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
set(ANDROID_TRIPLE x86_64-linux-android)
set(ANDROID_SYSROOT_ABI x86_64)
set(CMAKE_INSTALL_LIBDIR lib64)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_GCC_TOOLCHAIN x86_64-4.9)
elseif (ANDROID_ABI STREQUAL x86)
set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
set(ANDROID_TRIPLE i686-linux-android)
set(ANDROID_SYSROOT_ABI x86)
set(CMAKE_INSTALL_LIBDIR lib)
set(CMAKE_SYSTEM_PROCESSOR i686)
set(CMAKE_SIZEOF_VOID_P 4)
set(CMAKE_GCC_TOOLCHAIN x86-4.9)
set(CMAKE_C_EXTRA_FLAGS "-g -O0 -DANDROID   ${CMAKE_DEBUG_FLAG}")

endif (ANDROID_ABI STREQUAL armeabi-v7a)

set(CMAKE_GCC_TOOLCHAIN ${ANDROID_NDK}/toolchains/${CMAKE_GCC_TOOLCHAIN}/prebuilt/${ANDROID_HOST_TAG})
set(ANDROID_LLVM_TOOLCHAIN_PREFIX "${COMPILER_ROOT}/bin/")
set(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)

if (CMAKE_C_FLAGS)
string(REGEX REPLACE "\-isystem((.|\/)+)android" "" CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
string(REGEX REPLACE "eabi" "" CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
 endif()

find_library(LOG_LIB log REQUIRED)
message(STATUS "Current LOG_LIB_DIR ${LOG_LIB}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_EXTRA_FLAGS}  -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${CMAKE_GCC_TOOLCHAIN}  ${LOG_LIB}")
set(CMAKE_CONFIGURE_COMMAND "--host=${ANDROID_TRIPLE}${ANDROID_NATIVE_API_LEVEL}" "--prefix=${CMAKE_INSTALL_PREFIX}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" "${SHARED_FLAG}" "${STATIC_FLAG}")

if (NOT EXISTS COMPILER_ROOT)
message(STATUS "Installing standalone toochain for ${ANDROID_SYSROOT_ABI} apilevel-${ANDROID_NATIVE_API_LEVEL} ...")
execute_process(COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ANDROID_SYSROOT_ABI} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT})
endif ()

unset(CMAKE_C_COMPILER)
set(CMAKE_C_COMPILER ${ANDROID_LLVM_TOOLCHAIN_PREFIX}${ANDROID_TRIPLE}-gcc)

set(ENV{PKG_CONFIG_PATH} "/home/anthony/DocumentsCMAKE_SYSROOT/Source/Android/ndk/hidrd/cmake-build-release/.deps/libxz/dist/x86/usr/lib/pkgconfig")

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}")
set(CMAKE_PREFIX_PATH ${CMAKE_SYSROOT})
message(STATUS "Current ANDROID_NDK " ${ANDROID_NDK})
message(STATUS "Current COMPILER_ROOT " ${COMPILER_ROOT})
message(STATUS "Current SYSROOT " ${CMAKE_SYSROOT})
message(STATUS "Current ANDROID_ABI " ${ANDROID_ABI})
message(STATUS "Current ANDROID_NATIVE_API_LEVEL " ${ANDROID_NATIVE_API_LEVEL})
message(STATUS "Current CMAKE_C_COMPILER " ${CMAKE_C_COMPILER})
message(STATUS "Current CMAKE_C_FLAGS " ${CMAKE_C_FLAGS})
message(STATUS "Current ENV PATH " $ENV{PATH})
message(STATUS "Current TMP_DIR " ${TMP_DIR})
message(STATUS "Current STAMP_DIR " ${STAMP_DIR})
message(STATUS "Current CMAKE_INSTALL_LIBDIR " ${CMAKE_INSTALL_LIBDIR})
message(STATUS "Current CMAKE_CURRENT_BINARY_DIR " ${CMAKE_CURRENT_BINARY_DIR})
message(STATUS "Current CMAKE_INSTALL_PREFIX " ${CMAKE_INSTALL_PREFIX})
message(STATUS "Current CMAKE_SIZEOF_VOID_P ${CMAKE_SIZEOF_VOID_P}")
message(STATUS "Current CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "Current CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}")


list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}")
set(CMAKE_PREFIX_PATH ${CMAKE_SYSROOT})

# Get all propreties that cmake supports
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

# Convert command output into a CMake list
STRING(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
STRING(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

function(print_properties)
message(STATUS "properties: CMAKE_PROPERTY_LIST = ${CMAKE_PROPERTY_LIST}")
endfunction(print_properties)

function(print_target_properties tgt)
if (NOT TARGET ${tgt})
message(ERROR "There is no target named '${tgt}'")
return()
endif ()

foreach (prop ${CMAKE_PROPERTY_LIST})
string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
if (prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
continue()
endif ()
get_property(propval TARGET ${tgt} PROPERTY ${prop} SET)
if (propval)
get_target_property(propval ${tgt} ${prop})
message(STATUS "${tgt} ${prop} = ${propval}")
endif ()
endforeach (prop)
endfunction(print_target_properties)
