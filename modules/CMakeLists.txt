cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

if(BUILD_ALL OR BUILD_OPENSSL OR BUILD_LIBEVENT OR BUILD_THRIFT)
    include(openssl.cmake)
endif()

if(BUILD_ALL OR BUILD_BOOST)
    include(boost.cmake)
endif()

if(BUILD_ALL OR BUILD_GTEST)
    include(googletest.cmake)
endif()

if(BUILD_ALL OR BUILD_LIBEVENT OR BUILD_THRIFT)
    include(libevent.cmake)
endif()