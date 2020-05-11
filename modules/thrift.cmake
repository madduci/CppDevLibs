cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

set(THRIFT_VERSION 0.13.0)

message(STATUS "Preparing thrift ${THRIFT_VERSION}")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/thrift)
#-----------------------------
# Define thrift Commands
#-----------------------------

if( UNIX )
  set( thrift_Build_Command make -j2)
  set( thrift_Install_Command make install)
elseif( WIN32 )  
  set( thrift_Build_Command msbuild ${MSBUILD_OPTIONS} ALL_BUILD.vcxproj)
  set( thrift_Install_Command)
endif()

#-----------------------------
# Define thrift Output Dir
#-----------------------------

set(thrift_OUTPUT_DIR ${INSTALL_DIR}/thrift)

#-----------------------------
# Define thrift options
#-----------------------------

set(thrift_OPTIONS 
  -DBUILD_COMPILER=ON
  -DBUILD_LIBRARIES=ON 
  -DWITH_CPP=ON
  -DWITH_OPENSSL=ON
  -DWITH_BOOSTTHREADS=OFF
  -DBoost_INCLUDE_DIR=${Boost_INCLUDE_DIR}
  -DBOOST_ROOT=${BOOST_OUTPUT_DIR}
  -DBOOST_LIBRARYDIR=${BOOST_LIBRARYDIR}
  -DBoost_USE_MULTITHREADED=ON
  -DLIBEVENT_INCLUDE_DIRS=${LIBEVENT_INCLUDE_DIRS}
  -DLIBEVENT_LIBRARIES=${LIBEVENT_LIBRARIES}
  -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}
  -DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}
  -DOPENSSL_LIBRARIES=${OPENSSL_LIBRARIES}
  -DBUILD_TESTING=OFF 
  -DBUILD_EXAMPLES=OFF
  -DBUILD_TUTORIALS=OFF
  -DWITH_QT4=OFF
  -DWITH_QT5=OFF
  -DWITH_STDTHREADS=ON
  -DWITH_JAVA=OFF
  -DWITH_PYTHON=OFF
  -DWITH_C_GLIB=OFF
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_INSTALL_PREFIX=${thrift_OUTPUT_DIR}
)

#-----------------------------
# Define thrift Static/Dynamic Linking
#-----------------------------

if("${BUILD_SHARED_LIBS}" MATCHES "ON")
  message(STATUS "Building Shared libraries")
  set(thrift_OPTIONS ${thrift_OPTIONS} 
    -DWITH_STATIC_LIB=OFF
    -DBoost_USE_STATIC_LIBS=OFF
    -DWITH_SHARED_LIB=ON
  )
else()
  message(STATUS "Building Static libraries")
  set(thrift_OPTIONS ${thrift_OPTIONS} 
    -DWITH_STATIC_LIB=ON
    -DBoost_USE_STATIC_RUNTIME=ON
    -DBoost_USE_STATIC_LIBS=ON
    -DWITH_SHARED_LIB=OFF
    if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
      set(Boost_USER_DEBUG_RUNTIME ON)
    endif()
  )
  if(MSVC)
    set(thrift_OPTIONS ${thrift_OPTIONS} -DWITH_MT=ON)
  endif()
endif()

if(WIN32)
    add_definitions(/DBOOST_USE_WINAPI_VERSION=0x0600) # Fix for Boost 1.60
endif()

#-----------------------------
# Define Download
#-----------------------------

ExternalProject_Add(
    thrift_Download
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Download step--------------
    DOWNLOAD_DIR      ${SOURCE_DIR}/download
    URL               "https://github.com/apache/thrift/archive/v${THRIFT_VERSION}.tar.gz"
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
    thrift
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Update/Patch step----------
    UPDATE_COMMAND    ""
    DOWNLOAD_COMMAND ""
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    BINARY_DIR        ${SOURCE_DIR}/build
    CMAKE_ARGS        ${thrift_OPTIONS}
    #--Build step-------------
    BUILD_COMMAND     ${thrift_Build_Command}
    BUILD_IN_SOURCE   0
    #--Install step---------------
    INSTALL_COMMAND   ${thrift_Install_Command}
    INSTALL_DIR       ${thrift_OUTPUT_DIR}
)

add_dependencies(thrift thrift_Download libevent OpenSSL Boost)

set(thrift_ROOT_DIR    ${thrift_OUTPUT_DIR})
set(thrift_INCLUDE_DIR ${thrift_OUTPUT_DIR}/include/)
set(thrift_LIBRARY_DIR ${thrift_OUTPUT_DIR}/lib/)