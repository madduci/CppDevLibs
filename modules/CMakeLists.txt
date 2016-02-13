cmake_minimum_required(VERSION 3.2.0 FATAL_ERROR)

if(BUILD_ALL OR BUILD_OPENSSL)
    include(openssl.cmake)
endif()

if(BUILD_ALL OR BUILD_BOOST)
    include(boost.cmake)
endif()

if(BUILD_ALL OR BUILD_GTEST)
    include(googletest.cmake)
endif()