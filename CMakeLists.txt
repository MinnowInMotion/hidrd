cmake_minimum_required(VERSION 3.4.1)
project(hidrd)

option(HIDRD_REMOTE "Compile inline or from the remote repo clone" ON)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(ExternalProject)

set(PREFIX /usr)
set(MAKE_EXE make)
set(GITXZ https://git.tukaani.org/xz.git)
set(GITXML2 https://github.com/GNOME/libxml2.git)
set(GITHIDRD https://github.com/MinnowInMotion/hidrd.git)

set(LIBXZ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/libxz)
set(LIBXML2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/libxml2)
set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})
set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/hidrd)
set(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})
set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${PREFIX}/include/lzma)
set(STAMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/logs)
set(TMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/tmp)

file(MAKE_DIRECTORY ${TMP_DIR})
file(MAKE_DIRECTORY ${STAMP_DIR})
file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI})

set( ANDROID_ABI "x86")CACHE STRING "ABI Format")
set_property(CACHE TESTAPP_ASMFORMAT PROPERTY STRINGS armeabi-v7a win64 x86_64  x86 armeabi-v7a)

if (ANDROID_ABI MATCHES "armeabi-v7a")
    set(COMPILER_ROOT ${ANDROID_NDK}/armv7a-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    set(COMPILER-TRIP arm-linux-androideabi)
    set(ARCH arm)
elseif (ANDROID_ABI MATCHES "x86_64")
    set(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    set(COMPILER-TRIP x86_64-linux-android)
    set(ARCH x86_64)
elseif (ANDROID_ABI MATCHES "x86")
    set(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    set(COMPILER-TRIP i686-linux-android)
    set(ARCH x86)
endif (ANDROID_ABI MATCHES "armeabi-v7a")

set(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)
set(SOURCES src/main/cpp/hidrd_jni.c)

#for Find_Package NB  This is not good for portability
#set(CMAKE_MODULE_PATH ${ANDROID_NDK}/../cmake/3.6.4111459/share/cmake-3.6/Modules)

find_package(Git)

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


### trying to build entirely from cmake and gradle  ####
set(EXTERNAL_CC_FLAGS "-g -O0 -w -Wno-error -Wno-unused-command-line-argument --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/linux-x86_64 -L${CMAKE_SYSROOT}${PREFIX}/lib  -llog")
set(CMAKE_C_COMPILER ${COMPILER_ROOT}/bin/${COMPILER-TRIP}-gcc)
set(PYTHON_CFLAGS -I${COMPILER_ROOT}/include/python2.7)
set(PYTHON_LDFLAGS -L${COMPILER_ROOT}/lib/python2.7)

execute_process(
        COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ARCH} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT}
)


find_package(LIBXML2 QUIET)
message(STATUS "FOUND LIBXML ${LIBXML2_FOUND}")

if (${LIBXML2_FOUND})

    message(STATUS "LIBXML2: ${LIBXML2_INCLUDE_DIR} ${LIBHIDRD_INCLUDE_DIR}")
    add_custom_target(autotools_LZMA
            COMMENT "a phony target")
    add_custom_target(autotools_XML2
            COMMENT "a phony target"
            DEPENDS autotools_LZMA)

else (${LIBXML2_FOUND})
    set(LIBXML2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/libxml2)
    set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
    set(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}${PREFIX}/include/libxml2)
    message(STATUS "Installing liblzma from ${GITXZ}")
    externalproject_add(autotools_LZMA
            GIT_REPOSITORY ${GITXZ}
            PREFIX ${LIBXZ_DIR}/build/${ANDROID_ABI}
            SOURCE_DIR ${LIBXZ_DIR}
            BINARY_DIR ${LIBXZ_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIST_DIR}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
            COMMAND autoreconf -if -Wall ${LIBXZ_DIR}
            COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=${PREFIX}
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} DESTDIR=${LIBXZ_DIST_DIR} install
            COMMAND ${MAKE_EXE} DESTDIR=${CMAKE_SYSROOT} install
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            )
    message(STATUS "Installing libxml2 from ${GITXML2}")


    externalproject_add(autotools_XML2
            GIT_REPOSITORY ${GITXML2}
            PREFIX ${LIBXML2_DIR}/build/${ANDROID_ABI}
            SOURCE_DIR ${LIBXML2_DIR}
            BINARY_DIR ${LIBXML2_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIST_DIR}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
            COMMAND autoreconf -if -Wall ${LIBXML2_DIR}
            COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS} ${PYTHON_CFLAGS} ${PYTHON_LDFLAGS}" --with-python=${COMPILER_ROOT}/bin --prefix=${PREFIX}
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} DESTDIR=${CMAKE_SYSROOT} install
            COMMAND sed -i -e "s|${PREFIX}|${CMAKE_SYSROOT}${PREFIX}|g" ${CMAKE_SYSROOT}${PREFIX}/bin/xml2-config
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            DEPENDS autotools_LZMA
            )

    add_custom_command(
            TARGET autotools_XML2 POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${LIBXML2_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
            DEPENDS autotools_XML2
    )

    add_custom_command(
            TARGET autotools_LZMA POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${LIBXZ_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
            DEPENDS autotools_LZMA
    )


endif (${LIBXML2_FOUND})


#can either be built inline or from external git repo
if (HIDRD_REMOTE)
    set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/hidrd)
    set(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})
    message(STATUS "Installing hidrd from ${GITHIDRD}")
    externalproject_add(autotools_HIDRD
            GIT_REPOSITORY ${GITHIDRD}
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIST_DIR}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
            COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND autoreconf -if -Wall ${LIBHIDRD_DIR}
            COMMAND ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=${PREFIX} --enable-cmake-wrapper
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE} DESTDIR=${CMAKE_SYSROOT} install
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            DEPENDS autotools_XML2
            )
    find_package(LIBXML2)
else (HIDRD_REMOTE)
    set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../)
    set(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})
    externalproject_add(autotools_HIDRD
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIST_DIR}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI}
            COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND autoreconf -if -Wall ${LIBHIDRD_DIR}
            COMMAND ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=${PREFIX} --enable-cmake-wrapper
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH}
            COMMAND ${MAKE_EXE} DESTDIR=${LIBHIDRD_DIST_DIR} install
            STAMP_DIR ${STAMP_DIR}
            TMP_DIR ${TMP_DIR}
            DEPENDS autotools_XML2
            )
    find_package(LIBXML2)
endif (HIDRD_REMOTE)


set(LIBHIDRD_INCLUDE_DIR ${LIBHIDRD_DIST_DIR}${PREFIX}/include)
if (NOT EXISTS ${LIBHIDRD_INCLUDE_DIR})
    set(LIBHIDRD_INCLUDE_DIR ${CMAKE_SYSROOT}${PREFIX}/include)
endif ()

if (NOT LIBXML2_INCLUDE_DIR)
    set(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}${PREFIX}/include/libxml2)
endif ()

if (NOT EXISTS ${LIBXML2_INCLUDE_DIR})
    set(LIBXML2_INCLUDE_DIR ${CMAKE_SYSROOT}${PREFIX}/include/libxml2)
endif ()

message(STATUS "xml include:${LIBXML2_INCLUDE_DIR} hidrd include:${LIBHIDRD_INCLUDE_DIR}")

file(GLOB hidrd_libfiles ${LIBHIDRD_DIST_DIR}${PREFIX}/lib/*.so)
foreach (hidrd_file ${hidrd_libfiles})
    get_filename_component(libname ${hidrd_file} NAME_WE)
    message(STATUS "so: ${libname} file: ${hidrd_file}")
    add_library(${libname} SHARED IMPORTED)
    set_target_properties(${libname} PROPERTIES IMPORTED_LOCATION ${hidrd_file})
    set(hidrd_libs ${libname} ${hidrd_libs})
endforeach (hidrd_file ${hidrd_libfiles})

#add_library(hidrd_jni SHARED ${SOURCES})
add_dependencies(hidrd autotools_HIDRD)
add_dependencies(autotools_HIDRD autotools_XML2)

add_library(hidrd-targets INTERFACE)
target_link_libraries(hidrd-targets ${LIBXML2_LIBRARIES} ${hidrd_libs}))

#INSTALL CMAKE MODULES AND LIBRARY
set(LIB_DESTINATION "${CMAKE_INSTALL_LIBDIR}")
set(CMAKECONFIG_INSTALL_DIR "${LIB_DESTINATION}/cmake/bitflip")
set(INCLUDE_INSTALL_DIR "include")


install(TARGETS hidrd
    EXPORT hidrd-targets
    ARCHIVE DESTINATION ${LIB_DESTINATION}
    LIBRARY DESTINATION ${LIB_DESTINATION}
    RUNTIME DESTINATION bin
    )
#find_library(log-lib log)

#target_link_libraries(hidrd_jni ${log-lib} ${LIBXML2_LIBRARIES} ${hidrd_libs})
#target_include_directories(hidrd_jni PRIVATE ${LIBHIDRD_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIR})


#add_custom_command(
 #       TARGET hidrd_jni POST_BUILD
  #      COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
   #     COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${PREFIX}/share/xml/schema/hidrd.xsd ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
  #      COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.xml ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
   #     COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.code ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
    #    COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.hex ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
#)
