cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

message(STATUS "Preparing Google Test 1.8.0")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/gtest)

#-----------------------------
# Define GTest Commands
#-----------------------------

if( UNIX )
  set( GTest_Build_Command make -j2)
elseif( WIN32 )
  set( GTest_Build_Command msbuild ${MSBUILD_OPTIONS} ALL_BUILD.vcxproj)
endif()

#-----------------------------
# Define GTest Output Dir
#-----------------------------

set(GTest_OUTPUT_DIR ${INSTALL_DIR}/gtest)

file(MAKE_DIRECTORY ${GTest_OUTPUT_DIR})
file(MAKE_DIRECTORY ${GTest_OUTPUT_DIR}/include)
file(MAKE_DIRECTORY ${GTest_OUTPUT_DIR}/lib)
    
#-----------------------------
# Define GTest options
#-----------------------------

set(GTest_OPTIONS 
  -Dgtest_build_tests=OFF
  -Dgtest_build_samples=OFF 
  -Dgtest_disable_pthreads=ON
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_INSTALL_PREFIX=${GTest_OUTPUT_DIR}
)

#-----------------------------
# Define GTest MSVC Option
#-----------------------------

if(MSVC)
  set(GTest_OPTIONS ${GTest_OPTIONS} -Dgtest_force_shared_crt=OFF)
endif()

#-----------------------------
# Define GTest Copy operations
#-----------------------------

if(WIN32)
  set(Copy_Command copy)
  set(CopyFolders_Command xcopy)
else()
  set(Copy_Command cp)
  set(CopyFolders_Command cp -r)
endif()

#-----------------------------
# Define Download
#-----------------------------

ExternalProject_Add(
    GTest_Download
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Download step--------------
    DOWNLOAD_DIR      ${SOURCE_DIR}/download
    URL               "https://github.com/google/googletest/archive/release-1.8.0.tar.gz"
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    CONFIGURE_COMMAND ""
    #--Build step-------------
    BUILD_COMMAND     ""
    BUILD_IN_SOURCE   0
    #--Install step---------------
    INSTALL_COMMAND   ""
    INSTALL_DIR       ""
)
#-----------------------------
# Define Project
#-----------------------------

ExternalProject_Add(
    GTest
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Update/Patch step----------
    UPDATE_COMMAND    ""
    DOWNLOAD_COMMAND ""
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    BINARY_DIR        ${SOURCE_DIR}/build
    CMAKE_ARGS        ${GTest_OPTIONS}
    #--Build step-------------
    BUILD_COMMAND     ${GTest_Build_Command}
    BUILD_IN_SOURCE   0
    #--Install step---------------
    INSTALL_COMMAND   ""
    INSTALL_DIR       ${thrift_OUTPUT_DIR}
)

add_dependencies(GTest GTest_Download)
      
set(GTest_ROOT_DIR    ${GTest_OUTPUT_DIR})
set(GTest_INCLUDE_DIR ${GTest_OUTPUT_DIR}/include/)
set(GTest_LIBRARY_DIR ${GTest_OUTPUT_DIR}/lib/)

#-----------------------------
# Define install header files
#-----------------------------

install(DIRECTORY ${SOURCE_DIR}/source/include
        DESTINATION ${GTest_OUTPUT_DIR}/)               

#-----------------------------
# Define install target for GoogleTest for Release/Debug
#-----------------------------

ExternalProject_Get_Property(GTest BINARY_DIR)

if(WIN32)
  set(GTEST_LIBRARY_PATH ${BINARY_DIR}/${CMAKE_BUILD_TYPE}/gtest.lib)
  set(GTEST_MAIN_LIBRARY_PATH ${BINARY_DIR}/${CMAKE_BUILD_TYPE}/gtest_main.lib)
else()
  set(GTEST_LIBRARY_PATH ${BINARY_DIR}/libgtest.a)
  set(GTEST_MAIN_LIBRARY_PATH ${BINARY_DIR}/libgtest_main.a)
endif()

#gtest
project(gtest CXX)
add_library(gtest UNKNOWN IMPORTED)
set_property(TARGET gtest PROPERTY IMPORTED_LOCATION
                ${GTEST_LIBRARY_PATH} )

add_dependencies(gtest GTest)

#gtest_main
project(gtest_main CXX)
add_library(gtest_main UNKNOWN IMPORTED)
set_property(TARGET gtest_main PROPERTY IMPORTED_LOCATION
                ${GTEST_MAIN_LIBRARY_PATH} )

add_dependencies(gtest_main GTest)

install(FILES ${GTEST_LIBRARY_PATH} ${GTEST_MAIN_LIBRARY_PATH} DESTINATION ${GTest_OUTPUT_DIR}/lib)