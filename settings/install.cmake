#-----------------------------
# Enable Relative Paths
#-----------------------------

#set default install prefix
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)
#don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)
#when building, don't use RPATH - only during install phase
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
#add automatically determined parts of the RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()
