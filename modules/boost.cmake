cmake_minimum_required(VERSION 3.2.0 FATAL_ERROR)

message(STATUS "Preparing Boost 1.60")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/Boost)

#-----------------------------
# Define Boost Commands
#-----------------------------

set( Boost_Bootstrap_Command )
if( UNIX )
  set( Boost_Bootstrap_Command ./bootstrap.sh )
  set( Boost_b2_Command ./b2 )
elseif( WIN32 )
  set( Boost_Bootstrap_Command bootstrap.bat )
  set( Boost_b2_Command b2.exe)
endif()

#-----------------------------
# Define Boost Compile Type and Toolset
#-----------------------------

set(BOOST_ARCHITECTURE architecture=x86)
if(CROSSBUILD)
  set(BOOST_ARCHITECTURE architecture=${CMAKE_CROSS_CPU})
endif()

set(BOOST_ADDRESS_MODEL address-model=32)
if(${ARCHITECTURE} STREQUAL "x86_64") #64 bit compiler
  set(BOOST_ADDRESS_MODEL address-model=64)
endif()

if (${CMAKE_CXX_COMPILER_ID} MATCHES "gcc")
  #set(BOOST_TOOLSET toolset=gcc)
elseif (${CMAKE_CXX_COMPILER_ID} MATCHES "clang")
  #set(BOOST_TOOLSET toolset=clang)
elseif(MSVC) #MSVC
  set(BOOST_TOOLSET toolset=msvc)  
  if(MSVC_VERSION EQUAL 1700)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-11.0)
  elseif(MSVC_VERSION EQUAL 1800)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-12.0)
  elseif(MSVC_VERSION EQUAL 1900)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-14.0)
  endif()
elseif(CROSSBUILD)
  set(BOOST_TOOLSET toolset=${CMAKE_CROSS_TOOLSET})
endif()

#-----------------------------
# Define Boost Static/Dynamic Linking
#-----------------------------

set(BOOST_LINK_TYPE link=static runtime-link=static)
if(BUILD_SHARED_LIBS)
  set(BOOST_LINK_TYPE link=shared runtime-link=shared)
endif()

#-----------------------------
# Define Boost Debug/Release and Output Directory
#-----------------------------

set(BOOST_OUTPUT_DIR ${INSTALL_DIR}/Boost)

set(BOOST_BUILD_TYPE variant=release debug-symbols=off)
if(CMAKE_BUILD_TYPE MATCHES "Debug")
  set(BOOST_BUILD_TYPE variant=debug debug-symbols=on)
endif()

#-----------------------------
# Define Boost Build Command
#-----------------------------

set(BOOST_BUILD_OPTIONS ${BOOST_ADDRESS_MODEL} ${BOOST_ARCHITECTURE} ${BOOST_TOOLSET} ${BOOST_BUILD_TYPE} ${BOOST_LINK_TYPE})
set(BOOST_BUILD_FLAGS --threading=multi --warning-as-errors=off)
set(BOOST_BUILD_COMMAND ${Boost_b2_Command} install ${BOOST_BUILD_OPTIONS} ${BOOST_BUILD_FLAGS} -j2)

#-----------------------------
# Define Download
#-----------------------------

ExternalProject_Add(
    Boost_Download
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Download step--------------
    DOWNLOAD_DIR      ${SOURCE_DIR}/download
    URL               "http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz"
    URL_HASH          SHA1=ac74db1324e6507a309c5b139aea41af624c8110
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    CONFIGURE_COMMAND ""
    #--Build step-------------
    BUILD_COMMAND     ""
    BUILD_IN_SOURCE   1
    #--Install step---------------
    INSTALL_COMMAND   ""
    INSTALL_DIR       ""
)

#-----------------------------
# Define Project
#-----------------------------

ExternalProject_Add(
    Boost
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Update/Patch step----------
    UPDATE_COMMAND    ""
    DOWNLOAD_COMMAND ""
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/source
    CONFIGURE_COMMAND ${Boost_Bootstrap_Command} --prefix=${BOOST_OUTPUT_DIR}
    #--Build step-------------
    BUILD_COMMAND     ${BOOST_BUILD_COMMAND}
    BUILD_IN_SOURCE   1
    #--Install step---------------
    INSTALL_COMMAND   ""
    INSTALL_DIR       ${BOOST_OUTPUT_DIR}
)

add_dependencies(Boost Boost_Download)

set(Boost_ROOT        ${BOOST_OUTPUT_DIR})
set(Boost_INCLUDE_DIR ${BOOST_OUTPUT_DIR}/include/)
set(Boost_LIBRARY_DIR ${BOOST_OUTPUT_DIR}/lib/)