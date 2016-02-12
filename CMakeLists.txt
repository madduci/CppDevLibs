cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)

set(PROJECTNAME "CppDevLibs")

project(${PROJECT_NAME} CXX)

set(${PROJECT_NAME}_MAJOR_VERSION 0)
set(${PROJECT_NAME}_MINOR_VERSION 1)
set(${PROJECT_NAME}_PATCH_LEVEL 0)
set(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_MAJOR_VERSION}.${${PROJECT_NAME}_MINOR_VERSION}.${${PROJECT_NAME}_PATCH_LEVEL})

include(Settings/user_options.cmake)
include(Settings/build.cmake)
include(Settings/install.cmake)

#Set Output Directory based on build type and Architecture

if(CMAKE_BUILD_TYPE MATCHES "Debug")
	set(INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/Debug/${CMAKE_CXX_COMPILER_ID})
else()
	set(INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/Release/${CMAKE_CXX_COMPILER_ID})
endif()

message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Install Directory: ${INSTALL_DIR}")

#Required for building all the modules
include(ExternalProject)

include(Modules/Boost.cmake)
include(Modules/OpenSSL.cmake)
include(Modules/libevent.cmake)
include(Modules/Thrift.cmake)
include(Modules/GoogleTest.cmake)