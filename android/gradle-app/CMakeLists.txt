cmake_minimum_required(VERSION 3.4.1)

project(gradle-app)

set(CMAKE_VERBOSE_MAKEFILE ON)

option(HIDRD_REMOTE "Compile inline or from the remote repo clone" ON)

set (GITXZ https://git.tukaani.org/xz.git)
set (GITXML2 https://github.com/GNOME/libxml2.git)
set (GITHIDRD  https://github.com/MinnowInMotion/hidrd.git)

set(LIBXML2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/libxml2)
set(LIBXZ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/libxz)

set(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI})
set(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI})

set(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}${PREFIX}/include/libxml2)
set(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}${PREFIX}/include/lzma)

set(STAMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/logs)
set(TMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/tmp)
set(PREFIX /usr)

file(MAKE_DIRECTORY ${TMP_DIR})
file(MAKE_DIRECTORY ${STAMP_DIR})
file(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI})

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
message(STATUS "Current ANDROID_ABI " ${ANDROID_ABI} )
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
set(${PYTHON_CFLAGS} -I${COMPILER_ROOT}/include/python2.7)
set(${PYTHON_LDFLAGS} -L${COMPILER_ROOT}/lib/python2.7)

execute_process(
        COMMAND python ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ARCH} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT}
)



include(ExternalProject)

find_package(LIBXML2 QUIET)

if (${LIBXML2_FOUND})
    message(STATUS "LIBXML2: ${LIBXML2_INCLUDE_DIR} ${LIBHIDRD_INCLUDE_DIR}")

else (${LIBXML2_FOUND})
    message(STATUS "Installing liblzma from ${GITXZ}")


    ExternalProject_Add(autotools_LZMA
        GIT_REPOSITORY ${GITXZ}
        GIT_TAG "origin/master"
        SOURCE_DIR ${LIBXZ_DIR}
        BINARY_DIR ${LIBXZ_DIR}/build/${ANDROID_ABI}
        UPDATE_COMMAND  ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/dist/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/build/${ANDROID_ABI}
        PREFIX ${LIBXZ_DIR}/build/${ANDROID_ABI}
        CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && autoreconf -if -Wall ${LIBXZ_DIR} && export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" "--prefix=${PREFIX}"
        BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && ${MAKE} -j8
        INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && ${MAKE}  DESTDIR=${LIBXZ_DIST_DIR} install && ${MAKE}  DESTDIR=${CMAKE_SYSROOT} install
        DEPENDS autotools_LZMA
        STAMP_DIR ${STAMP_DIR}
        TMP_DIR ${TMP_DIR}
        LOG_DOWNLOAD        ON
        LOG_UPDATE          ON
        LOG_CONFIGURE       ON
        LOG_BUILD           ON
        LOG_TEST            ON
        LOG_INSTALL         ON
    )
    message(STATUS "Installing libxml2 from ${GITXML2}")

    ExternalProject_Add(autotools_XML2
    GIT_REPOSITORY ${GITXML2}
    GIT_TAG "origin/master"
    SOURCE_DIR ${LIBXML2_DIR}
    BINARY_DIR ${LIBXML2_DIR}/build/${ANDROID_ABI}
    UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/dist/${ANDROID_ABI}
    PREFIX ${LIBXML2_DIR}/build/${ANDROID_ABI}
    CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && autoreconf -if -Wall ${LIBXML2_DIR} && export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS} ${PYTHON_CFLAGS} ${PYTHON_LDFLAGS}" --with-python=${COMPILER_ROOT}/bin --prefix=${PREFIX}
    BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make -j8
    INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make DESTDIR=${LIBXML2_DIST_DIR} install && make DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|${PREFIX}|${CMAKE_SYSROOT}${PREFIX}|g" ${CMAKE_SYSROOT}${PREFIX}/bin/xml2-config
    DEPENDS autotools_LZMA
      STAMP_DIR ${STAMP_DIR}
        TMP_DIR ${TMP_DIR}
    )
    #
endif (${LIBXML2_FOUND})


 #can either be built inline or from external git repo
if (HIDRD_REMOTE)
    set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.deps/hidrd)
    set(HIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})
    message(STATUS "Installing hidrd from ${GITHIDRD}")
    ExternalProject_Add(autotools_HIDRD
            GIT_REPOSITORY ${GITHIDRD}
            GIT_TAG "origin/master"
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && autoreconf -if -Wall ${LIBHIDRD_DIR} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=${PREFIX}
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make DESTDIR=${LIBHIDRD_DIST_DIR} install && make DESTDIR=${CMAKE_SYSROOT} install
            DEPENDS autotools_XML2
              STAMP_DIR ${STAMP_DIR}
        TMP_DIR ${TMP_DIR}
            )
else (HIDRD_REMOTE)
    set(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../)
     set(HIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI})
    ExternalProject_Add(autotools_HIDRD
            GIT_TAG "origin/master"
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && autoreconf -if -Wall ${LIBHIDRD_DIR} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=${PREFIX}
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}${PREFIX}/bin:$ENV{PATH} && make DESTDIR=${LIBHIDRD_DIST_DIR} install && make DESTDIR=${CMAKE_SYSROOT} install
            DEPENDS autotools_XML2
              STAMP_DIR ${STAMP_DIR}
        TMP_DIR ${TMP_DIR}
            )
endif (HIDRD_REMOTE)

set(LIBHIDRD_INCLUDE_DIR ${LIBHIDRD_DIST_DIR}/include)
set(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}${PREFIX})

file(GLOB hidrd_libfiles ${LIBHIDRD_DIST_DIR}/lib/*.so)

foreach (hidrd_file ${hidrd_libfiles})
    get_filename_component(libname ${hidrd_file} NAME_WE)
    message(STATUS "so: ${libname} file: ${hidrd_file}")
    add_library(${libname} SHARED IMPORTED)
    set_target_properties(${libname} PROPERTIES IMPORTED_LOCATION ${hidrd_file})
    set(hidrd_libs ${libname} ${hidrd_libs})
endforeach (hidrd_file ${hidrd_libfiles})



add_library(hidrd_jni SHARED ${SOURCES})
add_dependencies(hidrd_jni autotools_HIDRD)
add_dependencies(autotools_HIDRD autotools_XML2)
add_dependencies(autotools_XML2 autotools_LZMA)

find_library(log-lib log)

target_link_libraries(hidrd_jni ${log-lib} ${LIBXML2_LIBRARIES} ${hidrd_libs})
target_include_directories(hidrd_jni PUBLIC ${LIBHIDRD_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIR})

add_custom_command(
        TARGET autotools_XML2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBXML2_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}

)

add_custom_command(
        TARGET autotools_LZMA POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBXZ_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}

)

add_custom_command(
        TARGET hidrd_jni POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${PREFIX}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}${PREFIX}/share/xml/schema/hidrd.xsd ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.xml ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.code ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.hex ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets

)




install(DIRECTORY ${LIBXZ_DIST_DIR}/ DESTINATION "./BLAH")