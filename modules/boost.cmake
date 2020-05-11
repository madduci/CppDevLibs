cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

set(BOOST_VERSION 1.73.0)
set(BOOST_PACKAGE_VERSION 1_73_0)

message(STATUS "Preparing Boost ${BOOST_VERSION}")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/Boost)

#-----------------------------
# Define Boost Modules
#-----------------------------

set(BOOST_MODULES --with-libraries=chrono,date_time,filesystem,log,program_options,system,thread)
set(BOOST_LIBRARIES 
  --with-chrono
  --with-date_time
  --with-filesystem
  --with-log
  --with-program_options
  --with-system
  --with-thread)

#-----------------------------
# Define Boost Commands
#-----------------------------

set( Boost_Bootstrap_Command )
if( UNIX )
  set( Boost_Bootstrap_Command ./bootstrap.sh ${BOOST_MODULES} --prefix=${BOOST_OUTPUT_DIR})
  set( Boost_b2_Command ./b2 )
elseif( WIN32 )
  set( Boost_Bootstrap_Command bootstrap.bat )
  set( Boost_b2_Command b2.exe ${BOOST_MODULES} --prefix=${BOOST_OUTPUT_DIR} --libdir=${BOOST_OUTPUT_DIR}/lib --includedir=${BOOST_OUTPUT_DIR}/include)
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

if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  set(BOOST_TOOLSET toolset=gcc)
elseif (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
  set(BOOST_TOOLSET toolset=clang cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++")
elseif(MSVC) #MSVC
  set(BOOST_TOOLSET toolset=msvc)  
  if(MSVC_VERSION EQUAL 1700)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-11.0)
  elseif(MSVC_VERSION EQUAL 1800)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-12.0)
  elseif(MSVC_VERSION EQUAL 1900)
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-14.0)
  else()
    set(BOOST_TOOLSET ${BOOST_TOOLSET}-15.0)
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
set(BOOST_BUILD_FLAGS --threading=multi --warnings=off --warning-as-errors=off  define=BOOST_USE_WINAPI_VERSION=0x0600 stage)
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
    URL               "https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_PACKAGE_VERSION}.tar.gz"
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
    DOWNLOAD_COMMAND  ""
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
set(BOOST_ROOT        ${BOOST_OUTPUT_DIR})
set(Boost_INCLUDE_DIR ${BOOST_OUTPUT_DIR}/include/)
set(Boost_LIBRARY_DIR ${BOOST_OUTPUT_DIR}/lib/)
if(WIN32)
  set(Boost_INCLUDE_DIR ${BOOST_OUTPUT_DIR}/include/${Boost_INCLUDE_DIR_FOLDER_VERSION}/)
endif()

add_definitions(-DBOOST_TT_HAS_OPERATOR_HPP_INCLUDED)
