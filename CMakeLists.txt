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

find_package(Git)

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

if (HIDRD_REMOTE)
    set(HIDRDURL ${GITHIDRD})
else ()
    set(HIDRDURL "")
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
        set(ANDROID_TRIPLE armv7-linux-androideabi)
        set(ANDROID_SYSROOT_ABI arm)
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

    set(CMAKE_C_COMPILER ${ANDROID_LLVM_TOOLCHAIN_PREFIX}${ANDROID_TRIPLE}-gcc)
    message(STATUS "Installing standalone toochain for ${ANDROID_SYSROOT_ABI} apilevel-${ANDROID_NATIVE_API_LEVEL} ...")
    execute_process(COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ANDROID_SYSROOT_ABI} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT})

    set(CMAKE_C_FLAGS "-g -O0 -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/${ANDROID_HOST_TAG}  ${LOG_LIB}")
    set(HIDRD_CONFIGURE_COMMAND "--host=${ANDROID_TRIPLE}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" "--prefix=${CMAKE_INSTALL_PREFIX}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}")


    list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dist/${ANDROID_SYSROOT_ABI}${CMAKE_INSTALL_PREFIX}")

    find_library(LOG_LIB log)

    message(STATUS "Current LOG_LIB ${LOG_LIB}")
else ()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w -Wno-error -Werror=implicit-function-declaration")
    set(HIDRD_CONFIGURE_COMMAND "CC=${CMAKE_C_COMPILER} " "CFLAGS=${CMAKE_C_FLAGS}" "--prefix=${CMAKE_INSTALL_PREFIX}" "${HIDRD_CMAKE_WRAPPER_FLAG}" "${HIDRD_DEBUG_FLAG}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}" "${HIDRD_XML_FORMAT_FLAG}")
endif ()

set(PYTHON_CFLAGS -I${COMPILER_ROOT}/include/python2.7)
set(PYTHON_LDFLAGS -L${COMPILER_ROOT}/lib/python2.7)
set(ENV{PATH} ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH})

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}")


message(STATUS "Current CMAKE_MODULE_PATH " ${CMAKE_MODULE_PATH})
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
message(STATUS "ENV{PATH} $ENV{PATH}")


if (HIDRD_XML_FORMAT)
    message(STATUS "Building with XML Support")
    #NB We dont want to download the repos again if we respin cmake
    #find_package(LIBXML2 PATHS ${CMAKE_PREFIX_PATH} ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
    # find_package(LIBXML2 QUIET COMPONENTS system filesystem)
    find_package(LIBXML2)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBLZMA liblzma)

    if (LIBLZMA_FOUND)
        message(STATUS "LIBLZMA_PREFIX  ${LIBLZMA_PREFIX}")
    endif ()

    if (LIBXML2_FOUND)

        message(STATUS "LIBXML2: ${LIBXML2_INCLUDE_DIRS} ${LIBXML2_LIBRARIES}")
        add_custom_target(autotools_XZ COMMENT "LIBXZ cached target")
        add_custom_target(autotools_XML2 COMMENT "LIBXML2 cached target" DEPENDS autotools_XZ)
        set(LIBXZ_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxz)
        set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
        set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/lzma)

    else ()

        message(STATUS "LIBXML2 not found")
        set(LIBXML2_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2)
        set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
        set(LIBXML2_INSTALL_PREFIX ${LIBXML2_DIR}/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
        set(LIBXML2_INCLUDE_DIRS ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/libxml2)
        #set(LIBXML2_LIBRARIES

        set(LIBXZ_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxz)
        set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
        set(LIBXZ_INSTALL_PREFIX ${LIBXZ_DIR}/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
        set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/lzma)

        set(LIBXZ_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${LIBXZ_DIST_DIR} install)

        message(STATUS "Installing libxz from ${GITXZ} \nFrom  ${LIBXZ_DIR}/build/${ANDROID_ABI} \nInto ${LIBXZ_DIST_DIR} ")
        message(STATUS "Installing libxml2 from ${GITXML2} \nFrom ${LIBXML2_DIR}/build/${ANDROID_ABI} \nInto ${LIBXML2_DIST_DIR}")

        if (HIDRD_SYSROOT_INSTALL)
            set(LIBXZ_INSTALL_COMMAND ${LIBXZ_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${CMAKE_SYSROOT} install)
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
                COMMAND ${LIBXZ_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} ARMEABI=${ANDROID_ABI} --prefix=${CMAKE_INSTALL_PREFIX}
                BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${CMAKE_MAKE_PROGRAM} -j8
                INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXZ_INSTALL_COMMAND}
                STAMP_DIR ${STAMP_DIR}
                TMP_DIR ${TMP_DIR}
                )

        set(LIBXML2_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${LIBXML2_DIST_DIR} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}|g" ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/bin/xml2-config && sed -i -e "s|Linux||g" ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)

        if (HIDRD_SYSROOT_INSTALL)
            set(LIBXML2_INSTALL_COMMAND ${LIBXML2_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}|g" ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)
        endif ()

        ExternalProject_Add(autotools_XML2
                GIT_REPOSITORY ${GITXML2}
                PREFIX ${LIBXML2_DIR}/build/${ANDROID_ABI}
                SOURCE_DIR ${LIBXML2_DIR}
                BINARY_DIR ${LIBXML2_DIR}/build/${ANDROID_ABI}
                UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIST_DIR}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/build/${ANDROID_ABI}
                CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
                COMMAND autoreconf -if -Wall ${LIBXML2_DIR}
                COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXML2_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} --with-python=${COMPILER_ROOT}/bin --prefix=${CMAKE_INSTALL_PREFIX} --with-lzma=${LIBXZ_DIST_DIR}
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


message(STATUS "Current HIDRD_CONFIGURE_COMMAND " ${HIDRD_CONFIGURE_COMMAND})
#can either be built inline or from external git repo

set(HIDRD_ARMEABI_FLAG "--with-armeabi=${ANDROID_ABI}")

if (HIDRD_XML_FORMAT)
    list(APPEND CMAKE_FIND_ROOT_PATH "${LIBXML2_INSTALL_PREFIX}")
    list(APPEND CMAKE_FIND_ROOT_PATH "${LIBXZ_DIST_DIR_PREFIX}")
    set(HIDRD_XML_CONFIG_LOCATION ${LIBXML2_INSTALL_PREFIX}/bin/xml2-config)
    if (HIDRD_SYSROOT_INSTALL)
        set(HIDRD_XML_CONFIG_LOCATION ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)
    endif ()
    message(STATUS "HIDRD_XML_CONFIG_LOCATION ${HIDRD_XML_CONFIG_LOCATION}")
endif (HIDRD_XML_FORMAT)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  ${LOG_LIB}")

find_package(HIDRD)

if (HIDRD_FOUND)
    message(STATUS "HIDRD: ${HIDRD_INCLUDE_DIRS} ${HIDRD_LIBS}")
    add_custom_target(autotools_HIDRD COMMENT "HIDRD cached target")
    set(HIDRD_DIST_DIR ${HIDRD_DIR}/dist/${ANDROID_ABI})

else ()

    if (HIDRD_REMOTE)
        set(HIDRD_DIR .deps/hidrd)
    else ()
        set(HIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    endif ()

    set(HIDRD_DIST_DIR ${HIDRD_DIR}/dist/${ANDROID_ABI})
    set(HIDRD_INSTALL_PREFIX ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX})

    set(HIDRD_XML_CONFIG_LOCATION_FLAG "--with-xml2-config=${HIDRD_XML_CONFIG_LOCATION}")

    if (HIDRD_XML_FORMAT)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
        set(HIDRD_CONFIGURE_COMMAND "--host=${ANDROID_TRIPLE}${ANDROID_NATIVE_API_LEVEL}" --with-sysroot=${CMAKE_SYSROOT} "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" --prefix=${CMAKE_INSTALL_PREFIX} ${HIDRD_CMAKE_WRAPPER_FLAG} ${HIDRD_DEBUG_FLAG} ${HIDRD_SHARED_FLAG} ${HIDRD_STATIC_FLAG} ${HIDRD_XML_FORMAT_FLAG} ${HIDRD_XML_CONFIG_LOCATION_FLAG} ${HIDRD_ARMEABI_FLAG})
    endif (HIDRD_XML_FORMAT)
    if (HIDRD_SYSROOT_INSTALL)

    endif ()

    ExternalProject_Add(autotools_HIDRD
            GIT_REPOSITORY ${HIDRDURL}
            SOURCE_DIR ${HIDRD_DIR}
            BINARY_DIR ${HIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${HIDRD_DIR}/build/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${HIDRD_DIST_DIR}
            PREFIX ${HIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND autoreconf -if -Wall ${HIDRD_DIR}
            COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/configure ${HIDRD_CONFIGURE_COMMAND}
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
            COMMAND ${CMAKE_MAKE_PROGRAM} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
            COMMAND ${CMAKE_MAKE_PROGRAM} -j8 DESTDIR=${HIDRD_DIST_DIR} install
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            DEPENDS autotools_XML2
            )


    set(HIDRD_INCLUDE_DIRS ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include)

    if (NOT EXISTS ${HIDRD_INCLUDE_DIRS})
        set(HIDRD_INCLUDE_DIRS ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/include)
    endif (NOT EXISTS ${HIDRD_INCLUDE_DIRS})


    file(GLOB files ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so)
    message(STATUS "searching  HIDRD_DIST_DIR/CMAKE_INSTALL_PREFIX ${HIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/ ")

    foreach (hfile ${files})
        get_filename_component(libname ${hfile} NAME_WE)
        message(STATUS "Adding Dependency so: ${libname} file: ${hidrd_file}")
        add_library(${libname} SHARED IMPORTED)
        set_property(TARGET ${libname} PROPERTY IMPORTED_LOCATION ${hfile})
        set(HIDRD_LIBS ${libname} ${HIDRD_LIBS})
    endforeach ()


endif (HIDRD_FOUND)

find_package(LIBXML2 QUIET)

if (HIDRD_XML_ENABLE)
    if (NOT LIBXML2_INCLUDE_DIRS)
        set(LIBXML2_INCLUDE_DIRS ${LIBXML2_INSTALL_PREFIX}/include/libxml2)
    endif (NOT LIBXML2_INCLUDE_DIRS)

    if (NOT EXISTS ${LIBXML2_INCLUDE_DIRS})
        set(LIBXML2_INCLUDE_DIRS ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/include/libxml2)
    endif (NOT EXISTS ${LIBXML2_INCLUDE_DIRS})

    message(STATUS "current LIBXML2_INCLUDE_DIRS ${LIBXML2_INCLUDE_DIRS}")

endif (HIDRD_XML_ENABLE)

message(STATUS "current HIDRD_INSTALL_PREFIX ${HIDRD_INSTALL_PREFIX}")
message(STATUS "current HIDRD_LIBS ${HIDRD_LIBS}")
message(STATUS "current HIDRD_INCLUDE_DIRS ${HIDRD_INCLUDE_DIRS}")

set(SOURCES src/adr.c)

add_library(hidrd SHARED ${SOURCES})
add_dependencies(hidrd autotools_HIDRD)
target_link_libraries(hidrd ${LOG_LIB} ${LIBXML2_LIBRARIES} ${HIDRD_LIBS})

message(STATUS "LIBXML2_INCLUDE_DIRS ${LIBXML2_INCLUDE_DIRS}")

if (HIDRD_XML_FORMAT)
    target_include_directories(hidrd PRIVATE ${HIDRD_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS})
    add_dependencies(autotools_HIDRD autotools_XML2)
else ()
    target_include_directories(hidrd-build PRIVATE ${HIDRD_INCLUDE_DIRS})
endif (HIDRD_XML_FORMAT)


#print_target_properties(hidrd-build)
#INSTALL CMAKE MODULES AND LIBRARY
set(CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/hidrd")
set(INCLUDE_INSTALL_DIR "include")

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
        PATH_VARS INCLUDE_INSTALL_DIR
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

install(TARGETS hidrd
        EXPORT hidrd-targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_BINARY_DIR}
        )

if (HIDRD_CP_LOCAL_JNILIB)

    add_custom_command(
            TARGET hidrd POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/jniLibs/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/assets
            COMMAND ${CMAKE_COMMAND} -E copy ${HIDRD_INSTALL_PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/jniLibs/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.code ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/assets
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.hex ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/assets
    )

    if (HIDRD_XML_ENABLE)
        add_custom_command(
                TARGET hidrd-build POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/xml/schema/hidrd.xsd ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/share/mouse_descriptor.xml ${CMAKE_CURRENT_SOURCE_DIR}/android/gradle-app/src/main/assets
        )
    endif (HIDRD_XML_ENABLE)

endif (HIDRD_CP_LOCAL_JNILIB)


# Get all propreties that cmake supports
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

# Convert command output into a CMake list
STRING(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
STRING(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

function(print_properties)
    message(STATUS "CMAKE_PROPERTY_LIST = ${CMAKE_PROPERTY_LIST}")
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
