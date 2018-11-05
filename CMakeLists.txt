cmake_minimum_required(VERSION 3.4.1)
# Anthony (Anthony@claydonkey.com)
# This cmake creates  a  Makefile for compilations and installation of the  hidrd
# libraries for  the Android NDK toolchain.
#
#
# depending on your requirements.
#   
project(hidrd)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(ExternalProject)

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
        # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
        if (prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
            continue()
        endif ()
        # message ("Checking ${prop}")
        get_property(propval TARGET ${tgt} PROPERTY ${prop} SET)
        if (propval)
            get_target_property(propval ${tgt} ${prop})
            message(STATUS "${tgt} ${prop} = ${propval}")
        endif ()
    endforeach (prop)
endfunction(print_target_properties)
find_package(Git)

set(GITXZ https://git.tukaani.org/xz.git)
set(GITXML2 https://github.com/GNOME/libxml2.git)
set(GITHIDRD https://github.com/MinnowInMotion/hidrd.git)

# Search libraries only under *target* paths.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

option(ANDROID_BUILD "Build for android" ON)
option(HIDRD_REMOTE "Compile from the remote repo clone [Off=compile inline]" OFF)
option(LIBXML2_SYS_INSTALL "Install libXML2 in sysroot if not present" ON)
option(LIBXZ_SYS_INSTALL "Install libXZ libraries in sysroot if not present" ON)

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

option(HIDRD_DEBUG "enable debugging features" ON)
option(HIDRD_SHARED "build shared libraries" ON)
option(HIDRD_STATIC "build static libraries" ON)
option(HIDRD_CONVERT "build hidconvert executable" ON)
option(HIDRD_XML_FORMAT "build XML format support (requires tokens, names and libxml2)" ON)
option(HIDRD_CMAKE_WRAPPER "enable cmake wrapper for android" ON)

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

if (HIDRD_REMOTE)
    set(LIBHIDRD_DIR .deps/hidrd)
else ()
    set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif ()

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
        set(COMPILER-TRIP arm-linux-androideabi)
        set(ARCH arm)
    elseif (ANDROID_ABI STREQUAL x86_64)
        set(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(COMPILER-TRIP x86_64-linux-android)
        set(ARCH x86_64)
    elseif (ANDROID_ABI STREQUAL x86)
        set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
        set(COMPILER-TRIP i686-linux-android)
        set(ARCH x86)
    endif (ANDROID_ABI STREQUAL armeabi-v7a)

    set(ANDROID_LLVM_TOOLCHAIN_PREFIX "${COMPILER_ROOT}/bin/")
    set(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)
    set(CMAKE_C_FLAGS "-g -O0 -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/${ANDROID_HOST_TAG}  ${LOG-LIB}")
    set(CMAKE_C_COMPILER ${ANDROID_LLVM_TOOLCHAIN_PREFIX}${COMPILER-TRIP}-gcc)

    execute_process(COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ARCH} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT})

    find_library(LOG-LIB log)

    set(CMAKE_C_FLAGS "-g -O0 -Wno-null-pointer-arithmetic -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/${ANDROID_HOST_TAG}  ${LOG-LIB}")
    set(HIDRD_CONFIGURE_COMMAND "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" "--prefix=${CMAKE_INSTALL_PREFIX}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}")

else ()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w -Wno-error -Werror=implicit-function-declaration")
    set(HIDRD_CONFIGURE_COMMAND "CC=${CMAKE_C_COMPILER} " "CFLAGS=${CMAKE_C_FLAGS}" "--prefix=${CMAKE_INSTALL_PREFIX}" "${HIDRD_CMAKE_WRAPPER_FLAG}" "${HIDRD_DEBUG_FLAG}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}" "${HIDRD_XML_FORMAT_FLAG}")
endif ()

set(PYTHON_CFLAGS -I${COMPILER_ROOT}/include/python2.7)
set(PYTHON_LDFLAGS -L${COMPILER_ROOT}/lib/python2.7)
set(ENV{PATH} ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH})
set(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})

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
message(STATUS "Current LIBXML2_SYS_INSTALL " ${LIBXML2_SYS_INSTALL})
message(STATUS "Current LIBXZ_SYS_INSTALL " ${LIBXZ_SYS_INSTALL})
message(STATUS "Current CMAKE_CURRENT_BINARY_DIR " ${CMAKE_CURRENT_BINARY_DIR})
message(STATUS "Current CMAKE_INSTALL_PREFIX " ${CMAKE_INSTALL_PREFIX})



if (HIDRD_XML_FORMAT)
    message(STATUS "Building with XML Support")
#NB We dont want to download th erepos again if we respin cmake
    find_package(LIBLZMA )
    #set(CMAKE_PREFIX_PATH "${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX}/")

    #find_package(LIBXML2 PATHS ${CMAKE_PREFIX_PATH} ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2/dist/${ANDROID_ABI}${CMAKE_INSTALL_PREFIX})
    find_package(LIBXML2 QUIET COMPONENTS system filesystem )
    message(STATUS "CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}")
    message(STATUS "ENV{PATH} $ENV{PATH}")
    if (LIBXML2_FOUND)
        message(STATUS "LIBXML2: ${LIBXML2_INCLUDE_DIRS} ")
        add_custom_target(autotools_XZ COMMENT "LIBXZ phony target")
        add_custom_target(autotools_XML2 COMMENT "LIBXML2 phony target" DEPENDS autotools_XZ)
    else ()
        message(STATUS "LIBXML2 not found")
        set(LIBXML2_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxml2)
        set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
        set(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/libxml2)


        set(LIBXZ_DIR ${CMAKE_CURRENT_BINARY_DIR}/.deps/libxz)
        set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
        set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/lzma)

        set(LIBXZ_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${LIBXZ_DIST_DIR} install)

        message(STATUS "Installing libxz from ${GITXZ} \nFrom  ${LIBXZ_DIR}/build/${ANDROID_ABI} \nInto ${LIBXZ_DIST_DIR} ")
        message(STATUS "Installing libxml2 from ${GITXML2} \nFrom ${LIBXML2_DIR}/build/${ANDROID_ABI} \nInto ${LIBXML2_DIST_DIR}")

        if (LIBXZ_SYS_INSTALL)
            set(LIBXZ_INSTALL_COMMAND ${LIBXZ_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} DESTDIR=${CMAKE_SYSROOT} install)
        endif ()

        ExternalProject_Add(autotools_XZ
                GIT_REPOSITORY ${GITXZ}
                PREFIX ${LIBXZ_DIR}/build/${ANDROID_ABI}
                SOURCE_DIR ${LIBXZ_DIR}
                BINARY_DIR ${LIBXZ_DIR}/build/${ANDROID_ABI}
                UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIST_DIR}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/build/${ANDROID_ABI}
                CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
                COMMAND autoreconf -if -Wall ${LIBXZ_DIR}
                COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXZ_DIR}/configure ${HIDRD_CONFIGURE_COMMAND} --prefix=${CMAKE_INSTALL_PREFIX}
                BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${CMAKE_MAKE_PROGRAM} -j8
                INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
                COMMAND ${LIBXZ_INSTALL_COMMAND}
                STAMP_DIR ${STAMP_DIR}
                TMP_DIR ${TMP_DIR}
                )

        set(LIBXML2_INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${LIBXML2_DIST_DIR} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}|g" ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)

        if (LIBXML2_SYS_INSTALL)
            set(LIBXML2_INSTALL_COMMAND ${LIBXML2_INSTALL_COMMAND} && ${CMAKE_MAKE_PROGRAM} DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|${CMAKE_INSTALL_PREFIX}|${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}|g" ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin/xml2-config)
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

if (HIDRD_REMOTE)
    set(URL ${GITHIDRD})
endif ()

set(HIDRD_ARMEABI_FLAG "ARMEABI=${ANDROID_ABI}")

if (HIDRD_XML_FORMAT)
    if (NOT LIBXML2_FOUND)
        set(HIDRD_XML_CONFIG_LOCATION ${LIBXML2_DIST_DIR}/usr/bin/xml2-config)
    else ()
        set(HIDRD_XML_CONFIG_LOCATION ${CMAKE_SYSROOT}/usr/bin/xml2-config)
    endif ()
endif ()

set(HIDRD_XML_CONFIG_LOCATION_FLAG "--with-xml2-config=${HIDRD_XML_CONFIG_LOCATION}")
set(HIDRD_CONFIGURE_COMMAND "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${CMAKE_C_FLAGS}" "--prefix=${CMAKE_INSTALL_PREFIX}" "${HIDRD_CMAKE_WRAPPER_FLAG}" "${HIDRD_DEBUG_FLAG}" "${HIDRD_SHARED_FLAG}" "${HIDRD_STATIC_FLAG}" "${HIDRD_XML_FORMAT_FLAG}" "${HIDRD_XML_CONFIG_LOCATION_FLAG}" "${HIDRD_ARMEABI_FLAG}")

ExternalProject_Add(autotools_HIDRD
        GIT_REPOSITORY ${URL}
        SOURCE_DIR ${LIBHIDRD_DIR}
        BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
        UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIST_DIR}
        PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
        CONFIGURE_COMMAND autoreconf -if -Wall ${LIBHIDRD_DIR}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/configure ${HIDRD_CONFIGURE_COMMAND}
        BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
        COMMAND ${CMAKE_MAKE_PROGRAM} -j8
        INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
        COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${LIBHIDRD_DIST_DIR} install
        STAMP_DIR ${STAMP_DIR}
        TMP_DIR ${TMP_DIR}
        DEPENDS autotools_XML2
        )

find_package(LIBXML2 QUIET)
set(LIBHIDRD_INCLUDE_DIR ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include)

if (NOT EXISTS ${LIBHIDRD_INCLUDE_DIR})
    set(LIBHIDRD_INCLUDE_DIR ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/include)
endif (NOT EXISTS ${LIBHIDRD_INCLUDE_DIR})

if (HIDRD_XML_ENABLE)
    if (NOT LIBXML2_INCLUDE_DIR)
        set(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/libxml2)
    endif (NOT LIBXML2_INCLUDE_DIR)

    if (NOT EXISTS ${LIBXML2_INCLUDE_DIR})
        set(LIBXML2_INCLUDE_DIR ${CMAKE_SYSROOT}${CMAKE_INSTALL_PREFIX}/include/libxml2)
    endif (NOT EXISTS ${LIBXML2_INCLUDE_DIR})

    message(STATUS "LIBXML2 include: ${LIBXML2_INCLUDE_DIR}")
    message(STATUS "HIDRD include: ${LIBHIDRD_INCLUDE_DIR}")
endif ()

file(GLOB files ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so)

foreach (hfile ${files})
    get_filename_component(libname ${hfile} NAME_WE)
    message(STATUS "Adding Dependency so: ${libname} file: ${hidrd_file}")
    add_library(${libname} SHARED IMPORTED)
    set_property(TARGET ${libname} PROPERTY IMPORTED_LOCATION ${hfile})
    set(HIDRD_LIBRARIES ${libname} ${HIDRD_LIBRARIES})

endforeach ()

message(STATUS "current LIBHIDRD_DIST_DIR ${LIBHIDRD_DIST_DIR}")
message(STATUS "current HIDRD_LIBRARIES ${HIDRD_LIBRARIES}")

set(SOURCES src/adr.c)

add_library(hidrd SHARED ${SOURCES})
add_dependencies(hidrd autotools_HIDRD)
target_link_libraries(hidrd PUBLIC ${LIBXML2_LIBRARIES} ${HIDRD_LIBRARIES})

if (LIBXML2_FOUND)
    target_include_directories(hidrd PRIVATE ${LIBHIDRD_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIR})
else ()
    target_include_directories(hidrd PRIVATE ${LIBHIDRD_INCLUDE_DIR})
endif ()

#INSTALL CMAKE MODULES AND LIBRARY
set(CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/hidrd")

## LIBRARY VERSION
set(hidrd_SOVERSION 1)
set(hidrd_API_VERSION 0)
set(hidrd_lib_PATCH_VERSION 0)
set(hidrd_VERSION ${hidrd_SOVERSION}.${hidrd_API_VERSION}.${hidrd_PATCH_VERSION})
# GENEREATE btstack-config* FILES
configure_package_config_file(
        cmake/hidrd-config.cmake.in
        ${CMAKE_BINARY_DIR}/hidrd-config.cmake
        INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR}
        PATH_VARS CMAKE_INSTALL_INCLUDEDIR
)

write_basic_package_version_file(
        ${CMAKE_BINARY_DIR}/hidrd-config-version.cmake
        VERSION ${hidrd_VERSION}
        COMPATIBILITY SameMajorVersion
)

print_target_properties(hidrd)

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

install(FILES
        res/mouse_descriptor.code
        res/mouse_descriptor.hex
        DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}"
        COMPONENT Devel
        )

install(DIRECTORY ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        )

install(DIRECTORY ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/include/hidrd
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )


if (HIDRD_XML_FORMAT)
    install(FILES
            res/share/xml/schema/hidrd.xsd
            res/mouse_descriptor.xml
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}"
            )
endif ()


install(TARGETS hidrd
        EXPORT hidrd-targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_BINARY_DIR}
        )


add_custom_command(
        TARGET hidrd POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.code ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.hex ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
)

if (HIDRD_XML_ENABLE)
    add_custom_command(
            TARGET hidrd POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${CMAKE_INSTALL_PREFIX}/share/xml/schema/hidrd.xsd ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
            COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.xml ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
    )
endif ()

    