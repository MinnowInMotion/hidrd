cmake_minimum_required(VERSION 3.4.1)
project(hidrdtest)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/standalone-bootstrap.cmake)

add_library(hidrd_jni SHARED src/main/cpp/hidrd_jni.c)
find_package(LIBXML2)
find_library(log-lib log)
find_package(HIDRD)


target_link_libraries(hidrd_jni ${LOG_LIB} ${LIBXML2_LIBRARIES} ${HIDRD_LIBS})
target_include_directories(hidrd_jni PRIVATE ${HIDRD_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS})