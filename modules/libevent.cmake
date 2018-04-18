cmake_minimum_required(VERSION 3.7.0 FATAL_ERROR)

message(STATUS "Preparing libevent 2.1.8-stable")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/libevent)

#-----------------------------
# Define libevent Commands
#-----------------------------

if( UNIX )
  set( libevent_Build_Command make -j2)
  set( libevent_Install_Command make install)
elseif( WIN32 )
  set( libevent_Build_Command msbuild ${MSBUILD_OPTIONS} ALL_BUILD.vcxproj)
  set( libevent_Install_Command ) #TODO
endif()

#-----------------------------
# Define libevent Output Dir
#-----------------------------

set(libevent_OUTPUT_DIR ${INSTALL_DIR}/libevent)

#-----------------------------
# Define libevent options
#-----------------------------

set(libevent_OPTIONS 
  -DEVENT__DISABLE_OPENSSL=OFF 
  -DEVENT__DISABLE_THREAD_SUPPORT=OFF
  -DEVENT__DISABLE_BENCHMARK=ON
  -DEVENT__DISABLE_TESTS=ON
  -DEVENT__DISABLE_REGRESS=ON
  -DEVENT__DISABLE_SAMPLES=ON
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_INSTALL_PREFIX=${libevent_OUTPUT_DIR}
)

#-----------------------------
# Define libevent Static/Dynamic Linking
#-----------------------------

if(BUILD_SHARED_LIBS)
  set(libevent_OPTIONS ${libevent_OPTIONS} -DEVENT__BUILD_SHARED_LIBRARIES=ON)
endif()

#-----------------------------
# Define Boost Debug/Release
#-----------------------------

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(libevent_OPTIONS ${libevent_OPTIONS} 
    -DEVENT__DISABLE_DEBUG_MODE=ON
    -DEVENT__ENABLE_VERBOSE_DEBUG=ON
  )
endif()

#-----------------------------
# Define Download
#-----------------------------

ExternalProject_Add(
    libevent_Download
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Download step--------------
    DOWNLOAD_DIR      ${SOURCE_DIR}/download
    URL               "https://github.com/libevent/libevent/archive/release-2.1.8-stable.zip"
    #URL_HASH          SHA1=bea0ae37b0446d796461b669f931a20cdaf27376
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    BINARY_DIR        ${SOURCE_DIR}/build
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
    libevent
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Update/Patch step----------
    UPDATE_COMMAND    ""
    DOWNLOAD_COMMAND ""
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    CMAKE_ARGS        ${libevent_OPTIONS}
    #--Build step-------------
    BUILD_COMMAND     ${libevent_Build_Command}
    BUILD_IN_SOURCE   0
    #--Install step---------------
    INSTALL_COMMAND   ${libevent_Install_Command}
    INSTALL_DIR       ${libevent_OUTPUT_DIR}
)

add_dependencies(libevent libevent_Download OpenSSL)

set(libevent_ROOT_DIR    ${libevent_OUTPUT_DIR})
set(libevent_INCLUDE_DIR ${libevent_OUTPUT_DIR}/include/)
set(libevent_LIBRARY_DIR ${libevent_OUTPUT_DIR}/lib/)
  
