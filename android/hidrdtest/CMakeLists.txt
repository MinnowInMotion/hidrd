cmake_minimum_required(VERSION 3.4.1)
project(hidrd_adrlocal)

#include(hidrd.cmake)
include(../../cmake/standalone-bootstrap.cmake)

add_library(hidrd_adrlocal SHARED ../../lib/adr/adr.c  )
#add_library(hidrd_adrlocal SHARED src/main/cpp/blank.c  )

find_package(LIBXML2)

find_package(HIDRD)
message(STATUS "LIBXML2_DIR ${LIBXML2_DIR}")
message(STATUS "HIDRD_ADR_LIB ${HIDRD_ADR_LIB}")
message(STATUS "HIDRD_LIBS ${HIDRD_LIBS}")

target_link_libraries(hidrd_adrlocal  PUBLIC ${LOG_LIB}
        ${HIDRD_LIBS}
        ${LIBXML2_LIBRARIES}
        ${HIDRD_ADR_LIB}
        ${HIDRD_OPT_LIB}
        ${HIDRD_USAGE_LIB}
        ${HIDRD_FMT_LIB}
        ${HIDRD_ITEM_LIB}
        ${HIDRD_STRM_LIB}
        ${HIDRD_UTIL_LIB})
target_include_directories(hidrd_adrlocal PUBLIC   ../../include  ../../cmake-build-release/.deps/hidrd/dist/x86/usr/include  ${LIBXML2_INCLUDE_DIRS})

