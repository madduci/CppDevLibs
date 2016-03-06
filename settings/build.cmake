set(CMAKE_COLOR_MAKEFILE ON)

#-----------------------------
# Setting the default build type
#-----------------------------

if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "Setting build type to 'Release' as none was specified")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build")
  set(CMAKE_CONFIGURATION_TYPES "Release")
endif(NOT CMAKE_BUILD_TYPE)

#-----------------------------
# Detect Platform
#-----------------------------

include(${CMAKE_SOURCE_DIR}/settings/definitions/architecture.cmake)
target_architecture(ARCHITECTURE)
message(STATUS "Architecture detected: ${ARCHITECTURE}")

set(SYSTEM_ARCHITECTURE 32bit)
if( ${ARCHITECTURE} STREQUAL "x86_64" )
  set(SYSTEM_ARCHITECTURE 64bit)
endif()
message(STATUS "Architecture detected: ${ARCHITECTURE}")

#-----------------------------
# Apply options for compilers
#-----------------------------

include(CheckCXXCompilerFlag)
include(${CMAKE_SOURCE_DIR}/settings/definitions/compiler_flags.cmake)

if(MSVC)
    set(MSBUILD_OPTIONS /p:Configuration=Release)
    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        set(MSBUILD_OPTIONS /p:Configuration=Debug)
    endif()
endif(MSVC)

#-----------------------------
# Detect Required tools
#-----------------------------

include(${CMAKE_SOURCE_DIR}/settings/definitions/requirements.cmake)