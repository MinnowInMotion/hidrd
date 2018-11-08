cmake_minimum_required(VERSION 3.4.1)
# Anthony (Anthony@claydonkey.com)
# This cmake creates a Makefile for compilation and installation of the hidrd-build
# libraries for the Android NDK toolchain.
#
# depending on your requirements.
#
project(hidrdtest)



# Search libraries only under *target* paths.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)


if (ANDROID_BUILD)

    unset(CMAKE_C_COMPILER)
    set(ANDROID_ABI x86 CACHE STRING "ABI Format")
    set_property(CACHE ANDROID_ABI PROPERTY STRINGS armeabi-v7a win64 x86_64 x86 armeabi-v7a)
    set(ANDROID_NATIVE_API_LEVEL 21 CACHE STRING "Android API level")
    set_property(CACHE ANDROID_NATIVE_API_LEVEL PROPERTY STRINGS 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28)
    set(ANDROID_NDK /home/anthony/Android/Sdk/ndk-bundle CACHE PATH "Android NDK Location")

    file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rc/main/jniLibs/${ANDROID_ABI})


endif ()

option(ANDROID_BUILD "Build for android" ON)
option(HIDRD_REMOTE "Compile from the remote repo clone [Off=compile inline]" OFF)
option(HIDRD_SYSROOT_INSTALL "Install libXML2 and libXZ into sysroot if not present" OFF)
option(HIDRD_DEBUG "enable debugging features" ON)
option(HIDRD_SHARED "build shared libraries" ON)
option(HIDRD_STATIC "build static libraries" ON)
option(HIDRD_CONVERT "build hidconvert executable" ON)
option(HIDRD_XML_FORMAT "build XML format support (requires tokens, names and libxml2)" ON)
option(HIDRD_CMAKE_WRAPPER "enable cmake wrapper for android" ON)
option(HIDRD_CP_LOCAL_JNILIB "copy shared libraries to local jnilib" ON)

if (HIDRD_DEBUG)
    set(HIDRD_DEBUG_FLAG "--enable-debug")
endif ()

if (HIDRD_SHARED)
    set(HIDRD_SHARED_FLAG "--enable-shared")
else ()
    set(HIDRD_SHARED_FLAG "--disable-shared")
endif ()

if (HIDRD_STATIC)
    set(HIDRD_STATIC_FLAG "--enable-static")
else ()
    set(HIDRD_STATIC_FLAG "--disable-static")
endif ()

if (HIDRD_CONVERT)
    set(HIDRD_CONVERT_FLAG "--enable-hidrd-convert")
else ()
    set(HIDRD_CONVERT_FLAG "--disable-hidrd-convert")
endif ()

if (NOT HIDRD_XML_FORMAT)
    set(HIDRD_XML_FORMAT_FLAG "--disable-xml-format")
endif ()

if (HIDRD_CMAKE_WRAPPER)
    set(HIDRD_CMAKE_WRAPPER_FLAG "--enable-cmake-wrapper")
endif ()


message(STATUS "Current HIDRD_XML_FORMAT_FLAG " ${HIDRD_XML_FORMAT_FLAG})

if (ANDROID_BUILD)

    # Toolchain.
    if (CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
        set(ANDROID_HOST_TAG linux-x86_64)
    elseif (CMAKE_HOST${LIBXML2_INCLUDE_DIR}_${LIBXML2_INCLUDE_DIR}SYSTEM_NAME STREQUAL Darwin)
        set(ANDROID_HOST_TAG darwin-x86_64)
    elseif (CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
        set(ANDROID_HOST_TAG windows-x86_64)
    endif (CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)

    if (ANDROID_ABI STREQUAL armeabi-v7a)
        set(COMPILER_ROOT ${ANDROID_NDK}/armv7a-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE armv7-linux-androideabi)
        set(COMPILER_ROOT arm)
        set(CMAKE_SYSTEM_PROCESSOR armv7-a)
    elseif (ANDROID_ABI STREQUAL arm64-v8a)
        set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE aarch64-linux-android)
        set(ANDROID_SYSROOT_ABI arm64)
        set(CMAKE_INSTALL_LIBDIR lib64)
        set(CMAKE_SYSTEM_PROCESSOR aarch64)
    elseif (ANDROID_ABI STREQUAL x86_64)
        set(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE x86_64-linux-android)
        set(ANDROID_SYSROOT_ABI x86_64)
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    elseif (ANDROID_ABI STREQUAL x86)
        set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE i686-linux-android)
        set(ANDROID_SYSROOT_ABI x86)
        set(CMAKE_INSTALL_LIBDIR lib)
        set(CMAKE_SYSTEM_PROCESSOR i686)
        set(CMAKE_SIZEOF_VOID_P 4)
    endif (ANDROID_ABI STREQUAL armeabi-v7a)

    set(ANDROID_LLVM_TOOLCHAIN_PREFIX "${COMPILER_ROOT}/bin/")
    set(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)
    set(CMAKE_C_FLAGS "-g -O0  -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/${ANDROID_HOST_TAG}  ${LOG_LIB}")


    if (NOT EXISTS COMPILER_ROOT)
        message(STATUS "Installing standalone toochain for ${ANDROID_SYSROOT_ABI} apilevel-${ANDROID_NATIVE_API_LEVEL} ...")
        execute_process(COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ANDROID_SYSROOT_ABI} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT})

    endif ()

    unset(CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER ${ANDROID_LLVM_TOOLCHAIN_PREFIX}${ANDROID_TRIPLE}-gcc)

    set(HIDRD_CONFIGURE_COMMAND "--host=${ANDROID_TRIPLE}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}")

    list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dist/${ANDROID_SYSROOT_ABI}${CMAKE_INSTALL_PREFIX}")

    find_library(LOG_LIB log)

else ()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w -Wno-error -Werror=implicit-function-declaration")
    set(HIDRD_CONFIGURE_COMMAND "CC=${CMAKE_C_COMPILER} " "CFLAGS=${CMAKE_C_FLAGS}" "${HIDRD_CMAKE_WRAPPER_FLAG}" "${HIDRD_DEBUG_FLAG}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}" "${HIDRD_XML_FORMAT_FLAG}")
endif ()

set(PYTHON_CFLAGS -I${COMPILER_ROOT}/include/python2.7)
set(PYTHON_LDFLAGS -L${COMPILER_ROOT}/lib/python2.7)
set(ENV{PATH} ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH})
set(ENV{PKG_CONFIG_PATH} "/home/anthony/Documents/Source/Android/ndk/hidrd/cmake-build-release/.deps/libxz/dist/x86/usr/lib/pkgconfig")

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}")
set(CMAKE_PREFIX_PATH ${CMAKE_SYSROOT})
message(STATUS "Current ANDROID_NDK " ${ANDROID_NDK})
message(STATUS "Current SYSROOT " ${CMAKE_SYSROOT})
message(STATUS "Current ANDROID_ABI " ${ANDROID_ABI})
message(STATUS "Current ANDROID_NATIVE_API_LEVEL " ${ANDROID_NATIVE_API_LEVEL})
message(STATUS "Current CMAKE_C_COMPILER " ${CMAKE_C_COMPILER})
message(STATUS "Current CMAKE_C_FLAGS " ${CMAKE_C_FLAGS})
message(STATUS "Current ENV PATH " $ENV{PATH})
message(STATUS "Current TMP_DIR " ${TMP_DIR})
message(STATUS "Current STAMP_DIR " ${STAMP_DIR})
message(STATUS "Current GIT_EXECUTABLE " ${GIT_EXECUTABLE})
message(STATUS "Current CMAKE_INSTALL_LIBDIR " ${CMAKE_INSTALL_LIBDIR})
message(STATUS "Current HIDRD_SYSROOT_INSTALL " ${HIDRD_SYSROOT_INSTALL})
message(STATUS "Current CMAKE_CURRENT_BINARY_DIR " ${CMAKE_CURRENT_BINARY_DIR})
message(STATUS "Current CMAKE_INSTALL_PREFIX " ${CMAKE_INSTALL_PREFIX})
message(STATUS "CMAKE_SIZEOF_VOID_P ${CMAKE_SIZEOF_VOID_P}")
message(STATUS "CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}")


find_library(LOG_LIB log)
find_package(LIBXML2 REQUIRED)
find_package(HIDRD )

#lets compile our project
set(SOURCES src/main/cpp/hidrd_jni.c)
add_library(hidrd_jni SHARED ${SOURCES})

message(STATUS  "LIBXML2_INCLUDE_DIRS ${LIBXML2_INCLUDE_DIRS}")
message(STATUS  "HIDRD_DIR ${HIDRD_DIR}")

target_link_libraries(hidrd_jni ${LOG_LIB} ${LIBXML2_LIBRARIES} ${HIDRD_LIBS})
target_include_directories(hidrd_jni PRIVATE ${HIDRD_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS})




















