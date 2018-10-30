CMAKE_MINIMUM_REQUIRED(VERSION 3.4.1)
project(hidrd-android)

SET(CMAKE_VERBOSE_MAKEFILE ON)

SET(HIDRD_REMOTE "YES" CACHE BOOL "Compile inline or from the remote repo clone")
#SET_PROPERTY(CACHE HIDRD_REMOTE "YES"  BOOL "Enable Remote")

MESSAGE(STATUS "HIDRD_REMOTE='${HIDRD_REMOTE}'")

SET(LIBXML2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ndk/libxml2)
SET(LIBXZ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ndk/libxz)

SET(LIBXML2_DIST_DIR ${LIBXML2_DIR}/dist/${ANDROID_ABI}/usr)
SET(LIBXZ_DIST_DIR ${LIBXZ_DIR}/dist/${ANDROID_ABI}/usr)

SET(LIBXML2_INCLUDE_DIR ${LIBXML2_DIST_DIR}/include/libxml2)
SET(LIBXZ_INCLUDE_DIR ${LIBXZ_DIST_DIR}/include/lzma)

SET(LOG_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ndk/logs)
SET(TMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ndk/tmp)

FILE(MAKE_DIRECTORY ${NDK}/${TARGET})
FILE(MAKE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI})

IF (ANDROID_ABI MATCHES "armeabi-v7a")
    SET(COMPILER_ROOT ${ANDROID_NDK}/armv7a-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    SET(COMPILER-TRIP arm-linux-androideabi)
    SET(ARCH arm)
ELSEIF (ANDROID_ABI MATCHES "x86_64")
    SET(COMPILER_ROOT ${ANDROID_NDK}/x86_64-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    SET(COMPILER-TRIP x86_64-linux-android)
    SET(ARCH x86_64)
ELSEIF (ANDROID_ABI MATCHES "x86")
    SET(COMPILER_ROOT ${ANDROID_NDK}/i686-none-linux-android${ANDROID_NATIVE_API_LEVEL})
    SET(COMPILER-TRIP i686-linux-android)
    SET(ARCH x86)
ENDIF (ANDROID_ABI MATCHES "armeabi-v7a")

SET(CMAKE_SYSROOT ${COMPILER_ROOT}/sysroot)
SET(SOURCES src/main/cpp/hidrd_jni.c)

#for Find_Package NB  This is not good for portability
#SET(CMAKE_MODULE_PATH ${ANDROID_NDK}/../cmake/3.6.4111459/share/cmake-3.6/Modules)

MESSAGE(STATUS "Current CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}")
MESSAGE(STATUS "Current SYSROOT ${CMAKE_SYSROOT}")
MESSAGE(STATUS "Current ANDROID_ABI ${ANDROID_ABI}")
MESSAGE(STATUS "Current ANDROID_NATIVE_API_LEVEL ${ANDROID_NATIVE_API_LEVEL}")
MESSAGE(STATUS "Current CMAKE_C_COMPILER ${CMAKE_C_COMPILER}")
MESSAGE(STATUS "Current CMAKE_C_FLAGS ${CMAKE_C_FLAGS}")
MESSAGE(STATUS "Current ENV PATH" $ENV{PATH})
MESSAGE(STATUS "Current TMP_DIR" ${TMP_DIR})
MESSAGE(STATUS "Current LOG_DIR" ${LOG_DIR})


### trying to build entirely from cmake and gradle  ####
SET(EXTERNAL_CC_FLAGS "-g -O0 -w -Wno-error --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/linux-x86_64 -L${CMAKE_SYSROOT}/usr/lib  -llog")
SET(CMAKE_C_COMPILER ${COMPILER_ROOT}/bin/${COMPILER-TRIP}-gcc)
SET(${PYTHON_CFLAGS} -I${COMPILER_ROOT}/include/python2.7)
SET(${PYTHON_LDFLAGS} -L${COMPILER_ROOT}/lib/python2.7)

INCLUDE(ExternalProject)

EXTERNALPROJECT_ADD(autotools_LZMA
        GIT_REPOSITORY https://git.tukaani.org/xz.git
        SOURCE_DIR ${LIBXZ_DIR}
        BINARY_DIR ${LIBXZ_DIR}/build/${ANDROID_ABI}
        UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBXZ_DIR}/dist/${ANDROID_ABI}
        PREFIX ${LIBXZ_DIR}/build/${ANDROID_ABI}
        CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && autoreconf -if -Wall ${LIBXZ_DIR} && export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" "--prefix=/usr"
        BUILD_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make -j8
        INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make DESTDIR=${LIBXZ_DIR}/dist/${ANDROID_ABI} install && make DESTDIR=${CMAKE_SYSROOT} install
        STAMP_DIR ${LOG_DIR}
        TMP_DIR ${TMP_DIR}
        )

EXTERNALPROJECT_ADD(autotools_XML2
        GIT_REPOSITORY https://github.com/GNOME/libxml2.git
        SOURCE_DIR ${LIBXML2_DIR}
        BINARY_DIR ${LIBXML2_DIR}/build/${ANDROID_ABI}
        UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBXML2_DIR}/dist/${ANDROID_ABI}
        PREFIX ${LIBXML2_DIR}/build/${ANDROID_ABI}
        CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && autoreconf -if -Wall ${LIBXML2_DIR} && export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS} ${PYTHON_CFLAGS} ${PYTHON_LDFLAGS}" --with-python=${COMPILER_ROOT}/bin --prefix=/usr
        BUILD_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make -j8
        INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make DESTDIR=${LIBXML2_DIR}/dist/${ANDROID_ABI} install && make DESTDIR=${CMAKE_SYSROOT} install && sed -i -e "s|/usr|${CMAKE_SYSROOT}/usr|g" ${CMAKE_SYSROOT}/usr/bin/xml2-config
        DEPENDS autotools_LZMA
        STAMP_DIR ${LOG_DIR}
        TMP_DIR ${TMP_DIR}
        )

IF (HIDRD_REMOTE)
    SET(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ndk/hidrd)
    #can either be built inline or from external git repo
    EXTERNALPROJECT_ADD(autotools_HIDRD
            GIT_REPOSITORY https://github.com/MinnowInMotion/hidrd.git
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && autoreconf -if -Wall ${LIBHIDRD_DIR} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=/usr
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make DESTDIR=${LIBHIDRD_DIR}/dist/${ANDROID_ABI} install && make DESTDIR=${CMAKE_SYSROOT} install
            DEPENDS autotools_XML2
            STAMP_DIR ${LOG_DIR}
            TMP_DIR ${TMP_DIR}

            )
ELSE (HIDRD_REMOTE)
    #this is the root of the repo
    SET(LIBHIDRD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../)
    EXTERNALPROJECT_ADD(autotools_HIDRD
            SOURCE_DIR ${LIBHIDRD_DIR}
            BINARY_DIR ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            UPDATE_COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/build/${ANDROID_ABI} && ${CMAKE_COMMAND} -E make_directory ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}
            PREFIX ${LIBHIDRD_DIR}/build/${ANDROID_ABI}
            CONFIGURE_COMMAND export ARMEABI=${ANDROID_ABI} && export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && autoreconf -if -Wall ${LIBHIDRD_DIR} && ../../configure "--host=${COMPILER-TRIP}${ANDROID_NATIVE_API_LEVEL}" "--with-sysroot=${CMAKE_SYSROOT}" "CC=${CMAKE_C_COMPILER}" "CFLAGS=${EXTERNAL_CC_FLAGS}" --prefix=/usr
            BUILD_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make -j8
            INSTALL_COMMAND export PATH=${CMAKE_SYSROOT}/usr/bin:$ENV{PATH} && make DESTDIR=${LIBHIDRD_DIR}/dist/${ANDROID_ABI} install && make DESTDIR=${CMAKE_SYSROOT} install
            DEPENDS autotools_XML2
            STAMP_DIR ${LOG_DIR}
            TMP_DIR ${TMP_DIR}

            )
ENDIF (HIDRD_REMOTE)

SET(LIBHIDRD_INCLUDE_DIR ${LIBHIDRD_DIST_DIR}/include)
SET(LIBHIDRD_DIST_DIR ${LIBHIDRD_DIR}/dist/${ANDROID_ABI}/usr)

FILE(GLOB hidrd_libfiles ${LIBHIDRD_DIST_DIR}/lib/*.so)

FOREACH (hidrd_file ${hidrd_libfiles})
    GET_FILENAME_COMPONENT(libname ${hidrd_file} NAME_WE)
    MESSAGE(STATUS "  so: ${libname} file: ${hidrd_file}")
    ADD_LIBRARY(${libname} SHARED IMPORTED)
    SET_TARGET_PROPERTIES(${libname} PROPERTIES IMPORTED_LOCATION ${hidrd_file})
    SET(hidrd_libs ${libname} ${hidrd_libs})
ENDFOREACH (hidrd_file ${hidrd_libfiles})

FIND_PACKAGE(LIBXML2)

IF (${LIBXML2_FOUND})
    MESSAGE(STATUS "LIBXML2: ${LIBXML2_INCLUDE_DIR} ${LIBHIDRD_INCLUDE_DIR}")
ELSE (${LIBXML2_FOUND})
    MESSAGE(STATUS "RERUN CMAKE")
ENDIF (${LIBXML2_FOUND})

EXECUTE_PROCESS(
        COMMAND ${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch ${ARCH} --api ${ANDROID_NATIVE_API_LEVEL} --install-dir ${COMPILER_ROOT}
)

ADD_LIBRARY(hidrd_jni SHARED ${SOURCES})
ADD_DEPENDENCIES(autotools_XML2 autotools_LZMA)
ADD_DEPENDENCIES(autotools_HIDRD autotools_XML2)
ADD_DEPENDENCIES(hidrd_jni autotools_HIDRD)
FIND_LIBRARY(log-lib log)

TARGET_LINK_LIBRARIES(hidrd_jni ${log-lib} ${LIBXML2_LIBRARIES} ${hidrd_libs})
TARGET_INCLUDE_DIRECTORIES(hidrd_jni PUBLIC ${LIBHIDRD_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIR})

ADD_CUSTOM_COMMAND(
        TARGET autotools_XML2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBXML2_DIST_DIR}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
        DEPENDS autotools_XML2
)

ADD_CUSTOM_COMMAND(
        TARGET autotools_LZMA POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBXZ_DIST_DIR}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
        DEPENDS autotools_LZMA
)

ADD_CUSTOM_COMMAND(
        TARGET hidrd_jni POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}/lib/*.so ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIST_DIR}/share/xml/schema/hidrd.xsd ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.xml ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.code ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        COMMAND ${CMAKE_COMMAND} -E copy ${LIBHIDRD_DIR}/res/mouse_descriptor.hex ${CMAKE_CURRENT_SOURCE_DIR}/src/main/assets
        DEPENDS hidrd_jni
)


