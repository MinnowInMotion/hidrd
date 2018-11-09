cmake_minimum_required(VERSION 3.4.1)
# Anthony (Anthony@claydonkey.com)
# This cmake creates a Makefile for compilation and installation of the hidrd-build
# libraries for the Android NDK toolchain.
#
# depending on your requirements.
#
project(hidrd-build)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(ExternalProject)

set(GITXZ https://git.tukaani.org/xz.git)
set(GITXML2 https://github.com/GNOME/libxml2.git)
set(GITHIDRD https://github.com/MinnowInMotion/hidrd.git)

# Search libraries only under *target* paths.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(STAMP_DIR .deps/logs)
set(TMP_DIR .deps/tmp)

file(MAKE_DIRECTORY ${TMP_DIR})
file(MAKE_DIRECTORY ${STAMP_DIR})

if (ANDROID_BUILD)

    unset(CMAKE_C_COMPILER)
    set(ANDROID_ABI x86 CACHE STRING "ABI Format")
    set_property(CACHE ANDROID_ABI PROPERTY STRINGS armeabi-v7a win64 x86_64 x86 armeabi-v7a)
    set(ANDROID_NATIVE_API_LEVEL 26 CACHE STRING "Android API level")
    set_property(CACHE ANDROID_NATIVE_API_LEVEL PROPERTY STRINGS 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28)
    set(ANDROID_NDK /home/anthony/Android/Sdk/ndk-bundle CACHE PATH "Android NDK Location")

    if (ANDROID_APP_NAME)
        set(ANDROID_JNILIBS_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/android/${ANDROID_APP_NAME}/src/main/jniLibs CACHE STRING "Android JNILIBS location")
        set(ANDROID_ASSETS_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/android/${ANDROID_APP_NAME}/src/main/assets CACHE STRING "Android assets location")
    endif ()

    set(XML_SCHEMA_PATH /storage/emulated/0/Android/data/com.claydonkey.hidrd/files/hidrd.xsd CACHE STRING "path of the hidrd xsd schema residing on target")

endif ()

option(ANDROID_BUILD "Build for android" ON)
option(HIDRD_REMOTE "Compile from the remote repo clone [Off=compile inline]" OFF)
option(SYSROOT_INSTALL "Install libXML2 and libXZ into sysroot if not present" ON)
option(HIDRD_SHARED "build shared libraries" ON)
option(HIDRD_STATIC "build static libraries" ON)
option(HIDRD_CONVERT "build hidconvert executable" ON)
option(HIDRD_XML_FORMAT "build XML format support (requires tokens, names and libxml2)" ON)
option(HIDRD_CMAKE_WRAPPER "enable cmake wrapper for android" ON)

#set(CMAKE_BUILD_TYPE "Debug")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
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

if (HIDRD_REMOTE)
    set(HIDRDURL ${GITHIDRD})
else ()

    if (NOT XML_SCHEMA_PATH STREQUAL "")
        set(XML_SCHEMA_PATH_FLAG "--with-android-xml-schema-path=${XML_SCHEMA_PATH}")
    endif ()


    #  set(HIDRDURL "")
endif ()

message(STATUS "Current HIDRD_XML_FORMAT_FLAG " ${HIDRD_XML_FORMAT_FLAG})
# --disable-option-checking  ignore unrecognized --enable/--with options
# --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
# --enable-FEATU " RE[=ARG]  include FEATURE [ARG=yes]
# --enable-silent-rules   less verbose build output (undo: "make V=1")
# --disable-silent-rules  verbose build output (undo: "make V=0")
# --enable-dependency-tracking  do not reject slow dependency extractors
# --disable-dependency-tracking                     speeds up one-time build
# --enable-shared[=PKGS]  build shared libraries [default=yes]
# --enable-static[=PKGS]  build static libraries [default=yes]
# --enable-fast-install[=PKGS]                        optimize for fast installation [default=yes]
# --disable-libtool-lock  avoid locking (might break parallel builds)
# --enable-debug          enable debugging features
# --enable-tests-install  enable installation of tests
# --disable-opt           disable building options library (required by                         streams)
# --disable-streams       disable building stream library (required by                          formats)
# --disable-formats       disable building format library (required by                          hidrd-convert)
# --disable-hidrd-convert disable building hidrd-convert tool (requires                        formats)
# --enable-cmake-wrapper  enable cmake wrapper for android
# --disable-tokens        disable tokens (required by XML format)
# --disable-names         disable names (required by XML format)
# --disable-xml-format    disable building XML format support (requires                         tokens, names and libxml2)
# --disable-spec-format   disable building specification example format                          support (requires tokens and names)
# --disable-code-format   disable building source code format support                         (requires specification example format)
# --disable-option-checking  ignore unrecognized --enable/--with options --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
# --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
# --enable-silent-rules   less verbose build output (undo: "make V=1")
# --disable-silent-rules  verbose build output (undo: "make V=0")
# --enable-dependency-tracking                        do not reject slow dependency extractors
# --disable-dependency-tracking                        speeds up one-time build
# --enable-shared[=PKGS]  build shared libraries [default=yes] --enable-static[=PKGS]  build static libraries [default=yes]
# --enable-fast-install[=PKGS]                        optimize for fast installation [default=yes]
# --disable-libtool-lock  avoid locking (might break parallel builds) --enable-debug          enable debugging features
# --enable-tests-install  enable installation of tests--disable-opt           disable building options library (required by                        streams)
# --disable-streams       disable building stream library (required by                        formats)
# --disable-formats       disable building format library (required by                        hidrd-convert)
# --disable-hidrd-convert disable building hidrd-convert tool (requires                        formats)
# --enable-cmake-wrapper  enable cmake wrapper for android
# --disable-tokens        disable tokens (required by XML format)
# --disable-names         disable names (required by XML format)
# --disable-xml-format    disable building XML format support (requires                         tokens, names and libxml2)
# --disable-spec-format   disable building specification example format  #                         support (requires tokens and names)
# --disable-code-format   disable building source code format support  #                         (requires specification example format)

if (ANDROID_BUILD)

    # Toolchain.
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

    elseif (ANDROID_ABI STREQUAL arm64-v8a)
        set(COMPILER_ROOT ${ANDROID_NDK}/aarch64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE aarch64-linux-android)
        set(ANDROID_SYSROOT_ABI arm64)
        set(CMAKE_INSTALL_LIBDIR lib64)
        set(CMAKE_SYSTEM_PROCESSOR aarch64)

    elseif (ANDROID_ABI STREQUAL x86_64)
        set(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE x86_64-linux-android)
        set(ANDROID_SYSROOT_ABI x86_64)
        set(CMAKE_INSTALL_LIBDIR lib64)
        set(CMAKE_SYSTEM_PROCESSOR x86_64)

    elseif (ANDROID_ABI STREQUAL x86)
        set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(ANDROID_TRIPLE i686-linux-android)
        set(ANDROID_SYSROOT_ABI x86)
        set(CMAKE_INSTALL_LIBDIR lib)
        set(CMAKE_SYSTEM_PROCESSOR i686)
        set(CMAKE_SIZEOF_VOID_P 4)

    endif (ANDROID_ABI STREQUAL armeabi-v7a)

    set(CMAKE_GCC_TOOLCHAIN ${ANDROID_NDK}/toolchains/${ANDROID_TRIPLE}-4.9/prebuilt/${ANDROID_HOST_TAG})
    set(ANDROID_LLVM_TOOLCHAIN_PREFIX "${COMPILER_ROOT}/bin/")
    set(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)
    set(CMAKE_C_FLAGS "-g -O0  -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${CMAKE_GCC_TOOLCHAIN}  ${LOG_LIB}")

    if (NOT EXISTS COMPILER_ROOT)
        message(STATUS "Installing standalone toochain for ${ANDROID_SYSROOT_ABI} apilevel-${ANDROID_NATIVE_API_LEVEL} ...")
        execute_process(COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ANDROID_SYSROOT_ABI} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT})
    endif ()
    #      if(SYSROOT_INSTALL)
    #   set(CMAKE_INSTALL_PREFIX  ${CMAKE_SYSROOT})
    #  endif
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
message(STATUS "Current COMPILER_ROOT " ${COMPILER_ROOT})
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
message(STATUS "Current SYSROOT_INSTALL " ${SYSROOT_INSTALL})
message(STATUS "Current CMAKE_CURRENT_BINARY_DIR " ${CMAKE_CURRENT_BINARY_DIR})
message(STATUS "Current CMAKE_INSTALL_PREFIX " ${CMAKE_INSTALL_PREFIX})
message(STATUS "Current CMAKE_SIZEOF_VOID_P ${CMAKE_SIZEOF_VOID_P}")
message(STATUS "Current CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "Current CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}")
message(STATUS "Current XML_SCHEMA_PATH ${XML_SCHEMA_PATH}")
message(STATUS "Current ANDROID_ASSETS_LOCATION ${ANDROID_ASSETS_LOCATION}")
message(STATUS "Current ANDROID_JNILIBS_LOCATION ${ANDROID_JNILIBS_LOCATION}")

if (HIDRD_XML_FORMAT)
    message(STATUS "Building with XML Support")
    message(STATUS "Current CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} Support")
    set(LIBXML2_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2)
    set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
    set(LIBXML2_INSTALL_PREFIX ${LIBXML2_DIR}/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
    set(LIBXML2_INCLUDE_DIRS ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/libxml2)
    set(LIBXZ_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxz)
    set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
    set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/lzma)
    list(APPEND CMAKE_FIND_ROOT_PATH "${LIBXML2_INSTALL_PREFIX}")
    list(APPEND CMAKE_FIND_ROOT_PATH "${LIBXZ_DIST_DIR_PREFIX}")

    if (EXISTS ${LIBXML2_INSTALL_PREFIX}/bin/xml2-config)
        set(XML2_CONFIG_LOCATION ${LIBXML2_INSTALL_PREFIX}/bin/xml2-config)
    else ()
        set(XML2_CONFIG_LOCATION ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)
    endif ()

    message(STATUS "Current XML2_CONFIG_LOCATION ${XML2_CONFIG_LOCATION}")
    find_package(LIBXML2)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBLZMA liblzma)

    message(STATUS "Current PkgConfig ${PKG_CONFIG_EXECUTABLE}")

    if (LIBLZMA_FOUND)
        message(STATUS "Current LIBLZMA_PREFIX  ${LIBLZMA_PREFIX}")
    endif ()

    if (LIBXML2_FOUND)
        message(STATUS "Current LIBXML2_LIBRARIES:  ${LIBXML2_LIBRARIES}")
        message(STATUS "Current LIBXML2_INCLUDE_DIRS: ${LIBXML2_INCLUDE_DIRS}")
        add_custom_target(autotools_XZ COMMENT "LIBXZ cached target")
        add_custom_target(autotools_XML2 COMMENT "LIBXML2 cached target" DEPENDS autotools_XZ)
    else ()

        message(STATUS "LIBXML2 not found")
        #reset the vars
        set(LIBXML2_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2)
        set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
        set(LIBXML2_INSTALL_PREFIX ${LIBXML2_DIR}/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
        set(LIBXML2_INCLUDE_DIRS ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/libxml2)

        set(LIBXZ_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxz)
        set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
        set(LIBXZ_INSTALL_PREFIX ${LIBXZ_DIR}/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
        set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/lzma)
        # I hate this I can never seem to get it right... Why does sysroot not play with prefix!!!! Silly sed in the mean time
        set(LIBXZ_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${LIBXZ_DIST_DIR} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}|g" ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/liblzma.pc)

        message(STATUS "Installing libxz from ${GITXZ} \n${LIBXZ_DIR}/build/${ANDROID_ABI} ==> ${LIBXZ_DIST_DIR} ")
        message(STATUS "Installing libxml2 from ${GITXML2} \n${LIBXML2_DIR}/build/${ANDROID_ABI} ==> ${LIBXML2_DIST_DIR}")

        if (SYSROOT_INSTALL)
            # I hate this I can never seem to get it right... Why does sysroot not play with prefix!!!! Silly sed in the mean time
            set(LIBXZ_INSTALL_COMMAND ${LIBXZ_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}|g" ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/liblzma.pc)
        endif ()


        ExternalProject_Add(autotools_XZ
                GIT_REPOSITORY ${GITXZ}
                PREFIX ${LIBXZ_DIR}/build/${ANDROID_ABI}
                SOURCE_DIR ${LIBXZ_DIR}
                BINARY_DIR ${LIBXZ_DIR}/build/${ANDROID_ABI}
                UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIST_DIR}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/build/${ANDROID_ABI}
                CONFIGURE_COMMAND autoreconf -if -Wall ${LIBXZ_DIR}
                COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXZ_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} "--prefix=${CMAKE_INSTALL_PREFIX}"
                BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${CMAKE_MAKE_PROGRAM} -j8
                INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXZ_INSTALL_COMMAND}
                STAMP_DIR ${STAMP_DIR}
                TMP_DIR ${TMP_DIR}
                )
        # I hate this I can never seem to get it right... Why does sysroot not play with prefix!!!! Silly sed in the mean time
        set(LIBXML2_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${LIBXML2_DIST_DIR} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}|g" ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/bin/xml2-config && sed -i -e "s|Linux||g" ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)

        if (SYSROOT_INSTALL)
            # I hate this I can never seem to get it right... Why does sysroot not play with prefix!!!! Silly sed in the mean time
            set(LIBXML2_INSTALL_COMMAND ${LIBXML2_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}|g" ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config && sed -i -e "s|Linux||g" ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)
        endif ()

        ExternalProject_Add(autotools_XML2
                GIT_REPOSITORY ${GITXML2}
                PREFIX ${LIBXML2_DIR}/build/${ANDROID_ABI}
                SOURCE_DIR ${LIBXML2_DIR}
                BINARY_DIR ${LIBXML2_DIR}/build/${ANDROID_ABI}
                UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIST_DIR}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/build/${ANDROID_ABI}
                CONFIGURE_COMMAND autoreconf -if -Wall ${LIBXML2_DIR}
                COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXML2_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} "--prefix=${CMAKE_INSTALL_PREFIX}" --with-python=${COMPILER_ROOT}/bin --with-lzma=${LIBXZ_DIST_DIR}
                BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${CMAKE_MAKE_PROGRAM} -j8
                INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXML2_INSTALL_COMMAND}
                STAMP_DIR ${STAMP_DIR}
                TMP_DIR ${TMP_DIR}
                DEPENDS autotools_XZ
                )

        add_custom_command(
                TARGET autotools_XML2 POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
                DEPENDS autotools_XML2
        )

        add_custom_command(
                TARGET autotools_XZ POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
                DEPENDS autotools_XZ
        )
    endif ()

endif ()


find_package(Git)
#can either be built inline or from external git repo

set(HIDRD_ARMEABI_FLAG "--with-armeabi=${ANDROID_ABI}")


find_package(HIDRD)

if (HIDRD_FOUND)
    add_custom_target(autotools_HIDRD COMMENT "HIDRD cached target")
    if (EXISTS ${CMAKE_CURRENT_BINARY_DIR}/.deps/hidrd})
        set(HIDRD_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/hidrd)
        set(HIDRD_DIST_DIR ${HIDRD_DIR}/dist/${ANDROID_ABI})
        set(HIDRD_INSTALL_PREFIX ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX})
    else ()
        set(HIDRD_DIR ${CMAKE_SYSROOT})
        set(HIDRD_DIST_DIR ${HIDRD_DIR})
        set(HIDRD_INSTALL_PREFIX ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX})
    endif ()


    list(APPEND CMAKE_FIND_ROOT_PATH "${HIDRD_INSTALL_PREFIX}")

    #string(RANDOM LENGTH 5   EXVAR )
    if (ANDROID_JNILIBS_LOCATION AND NOT ANDROID_JNILIBS_LOCATION STREQUAL "")
        file(MAKE_DIRECTORY ${ANDROID_JNILIBS_LOCATION})
        message(STATUS "Creating  ANDROID_JNILIBS_LOCATION directory: ${ANDROID_JNILIBS_LOCATION}")
    endif ()
    if (ANDROID_ASSETS_LOCATION AND NOT ANDROID_ASSETS_LOCATION STREQUAL "")

        file(MAKE_DIRECTORY ${ANDROID_ASSETS_LOCATION})
        message(STATUS "Creating  ANDROID_ASSETS_LOCATION directory: ${ANDROID_ASSETS_LOCATION}")
    endif ()
    set(distname hidrd-export${EXVAR})
else ()
    set(distname hidrd-build)

    set(HIDRD_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/hidrd)
    set(HIDRD_DIST_DIR ${HIDRD_DIR}/dist/${ANDROID_ABI})
    set(HIDRD_INSTALL_PREFIX ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX})

    list(APPEND CMAKE_FIND_ROOT_PATH "${HIDRD_INSTALL_PREFIX}")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${LOG_LIB}")
    set(XML2_CONFIG_LOCATION_FLAG "--with-xml2-config=${XML2_CONFIG_LOCATION}")


    set(HIDRD_CONFIGURE_COMMAND ${HIDRD_CONFIGURE_COMMAND} "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" ${HIDRD_CMAKE_WRAPPER_FLAG} ${HIDRD_XML_FORMAT_FLAG} ${XML2_CONFIG_LOCATION_FLAG} ${HIDRD_ARMEABI_FLAG} ${XML_SCHEMA_PATH_FLAG})


    if (NOT HIDRD_REMOTE)
        message(STATUS "Current HIDRD_DIR ${HIDRD_DIR}")
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/include DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/cmake DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/lib DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/m4 DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/src DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/db DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/configure.ac DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/Makefile.am DESTINATION ${HIDRD_DIR})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/distcheck-all DESTINATION ${HIDRD_DIR})

    endif ()
    ExternalProject_Add(autotools_HIDRD
            GIT_REPOSITORY ${HIDRDURL}
            SOURCE_DIR ${HIDRD_DIR}
            BINARY_DIR ${HIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${HIDRD_DIR}/build/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${HIDRD_DIST_DIR}
            PREFIX ${HIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND autoreconf -if -Wall ${HIDRD_DIR}
            COMMAND ${HIDRD_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} "--prefix=${CMAKE_INSTALL_PREFIX}"
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
            COMMAND ${CMAKE_MAKE_PROGRAM} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
            COMMAND ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${HIDRD_DIST_DIR} install
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            DEPENDS autotools_XML2
            )


    if (NOT EXISTS ${HIDRD_INCLUDE_DIRS})
        set(HIDRD_INCLUDE_DIRS ${HIDRD_INSTALL_PREFIX}/include)
    endif (NOT EXISTS ${HIDRD_INCLUDE_DIRS})

    file(GLOB files ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so)

    foreach (hfile ${files})
        get_filename_component(libname ${hfile} NAME_WE)
        message(STATUS "Adding Dependency so: ${libname} file: ${hidrd_file}")
        add_library(${libname} SHARED IMPORTED)
        set_property(TARGET ${libname} PROPERTY IMPORTED_LOCATION ${hfile})
        set(HIDRD_LIBS ${libname} ${HIDRD_LIBS})
    endforeach ()

endif (HIDRD_FOUND)
message(STATUS "Current XML2_CONFIG_LOCATION :")
execute_process(COMMAND ${XML2_CONFIG_LOCATION} --libs RESULT_VARIABLE RVAR)
execute_process(COMMAND ${XML2_CONFIG_LOCATION} --cflags RESULT_VARIABLE RVAR)

find_package(LIBXML2 QUIET)

if (HIDRD_XML_ENABLE)
    if (NOT LIBXML2_INCLUDE_DIRS)
        set(LIBXML2_INCLUDE_DIRS ${LIBXML2_INSTALL_PREFIX}/include/libxml2)
    endif (NOT LIBXML2_INCLUDE_DIRS)

    if (NOT EXISTS ${LIBXML2_INCLUDE_DIRS})
        set(LIBXML2_INCLUDE_DIRS ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/include/libxml2)
    endif (NOT EXISTS ${LIBXML2_INCLUDE_DIRS})

    message(STATUS "Current LIBXML2_INCLUDE_DIRS ${LIBXML2_INCLUDE_DIRS}")

endif (HIDRD_XML_ENABLE)

message(STATUS "Current HIDRD_INSTALL_PREFIX ${HIDRD_INSTALL_PREFIX}")
message(STATUS "Current HIDRD_LIBS ${HIDRD_LIBS}")
message(STATUS "Current HIDRD_INCLUDE_DIRS ${HIDRD_INCLUDE_DIRS}")

set(SOURCES src/adr.c)

add_library(${distname} SHARED ${SOURCES})
add_dependencies(${distname} autotools_HIDRD)
target_link_libraries(${distname} ${LOG_LIB} ${LIBXML2_LIBRARIES} ${HIDRD_LIBS})
message(STATUS "Current LIBXML2_INCLUDE_DIRS ${LIBXML2_INCLUDE_DIRS}")

if (HIDRD_XML_FORMAT)
    target_include_directories(${distname} PRIVATE ${HIDRD_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS})
    add_dependencies(autotools_HIDRD autotools_XML2)
else ()
    target_include_directories(${distname} PRIVATE ${HIDRD_INCLUDE_DIRS})
endif (HIDRD_XML_FORMAT)

#print_target_properties(hidrd-build)
#INSTALL CMAKE MODULES AND LIBRARY
set(CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/hidrd")
set(INCLUDE_INSTALL_DIR "include")
set(INSTALL_DIR "")
## LIBRARY VERSION
set(hidrd_SOVERSION 0)
set(hidrd_API_VERSION 2)
set(hidrd_lib_PATCH_VERSION 0)
set(hidrd_VERSION ${hidrd_SOVERSION}.${hidrd_API_VERSION}.${hidrd_PATCH_VERSION})
# GENERATE hidrd-config* FILES
configure_package_config_file(
        cmake/hidrd-config.cmake.in
        ${CMAKE_BINARY_DIR}/hidrd-config.cmake
        INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR}
        PATH_VARS INCLUDE_INSTALL_DIR INSTALL_DIR
)

write_basic_package_version_file(
        ${CMAKE_BINARY_DIR}/hidrd-config-version.cmake
        VERSION ${hidrd_VERSION}
        COMPATIBILITY SameMajorVersion
)

install(EXPORT hidrd-targets
        FILE hidrd-targets.cmake
        DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
        )

install(
        FILES
        ${CMAKE_BINARY_DIR}/hidrd-config.cmake
        ${CMAKE_BINARY_DIR}/hidrd-config-version.cmake
        DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
        COMPONENT Devel
)
install(DIRECTORY ${HIDRD_INSTALL_PREFIX}/bin
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        )

install(DIRECTORY ${HIDRD_INSTALL_PREFIX}/lib
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        )

install(DIRECTORY ${HIDRD_INSTALL_PREFIX}/include/hidrd
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )

if (HIDRD_XML_FORMAT)
    install(DIRECTORY share
            DESTINATION ${CMAKE_INSTALL_PREFIX}
            )
    install(DIRECTORY ${HIDRD_INSTALL_PREFIX}/share/xml
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}
            )
endif (HIDRD_XML_FORMAT)

install(TARGETS ${distname}
        EXPORT hidrd-targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_BINARY_DIR}
        )


message(STATUS "HIDRD_INSTALL_PREFIX ${HIDRD_INSTALL_PREFIX}")


# add_custom_command(
# TARGET  hidrd-build
#           COMMAND  ${CMAKE_MAKE_PROGRAM}  ${HIDRD_DIR}/build/${ANDROID_ABI} DESTDIR=${HIDRD_DIR}/dist/${ANDROID_ABI} install
# )
if (NOT ANDROID_JNILIBS_LOCATION STREQUAL "" AND ANDROID_JNILIBS_LOCATION)
    if (HIDRD_CONVERT)
        add_custom_command(
                TARGET ${distname} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/bin/hidrd-convert ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}/libhidrd-convert.so
        )
    endif ()

    add_custom_command(
            TARGET ${distname} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/android/hidrdtest/src/main/assets
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_adr.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_fmt.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_item.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_opt.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_strm.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_usage.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/libhidrd_util.so ${ANDROID_JNILIBS_LOCATION}/${ANDROID_ABI}
    )
endif ()

if (NOT ANDROID_ASSETS_LOCATION STREQUAL "" AND ANDROID_ASSETS_LOCATION)
    add_custom_command(
            TARGET ${distname} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.code ${ANDROID_ASSETS_LOCATION}
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.hex ${ANDROID_ASSETS_LOCATION}
    )

    if (HIDRD_XML_ENABLE)
        add_custom_command(
                TARGET ${distname} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/xml/schema/hidrd.xsd ${ANDROID_ASSETS_LOCATION}
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.xml ${ANDROID_ASSETS_LOCATION}
        )
    endif (HIDRD_XML_ENABLE)
endif ()


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
