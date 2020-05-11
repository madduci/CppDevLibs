message(STATUS "Compiler detected: ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")

#Set Compiler Flags according to the compiler type
include(CheckCXXCompilerFlag)
if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    CHECK_CXX_COMPILER_FLAG("-std=c++17" COMPILER_SUPPORTS_CXX17)
    CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
    CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
    if(COMPILER_SUPPORTS_CXX17)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    elseif(COMPILER_SUPPORTS_CXX14)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
    elseif(COMPILER_SUPPORTS_CXX11)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    else()
        message(ERROR "The compiler ${CMAKE_CXX_COMPILER} has no minimum C++11 support. Please use a different C++ compiler.")
    endif()
    
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -Wall -Werror -g -pg -ftest-coverage -fprofile-arcs")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")   
    
    if(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize-coverage=func")
       set(CMAKE_CXX_COMPILER_ID clang-${CMAKE_CXX_COMPILER_VERSION}-${ARCHITECTURE})
    else()
       set(CMAKE_CXX_COMPILER_ID gcc-${CMAKE_CXX_COMPILER_VERSION}-${ARCHITECTURE})     
    endif()   
     
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "MSVC")
    
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /O0 /W4 /DEBUG:Yes /MP /ZI /MDd")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O3 /MP /MD")
    
    # Set MT flag for Static library compiling if needed
    if(NOT BUILD_SHARED_LIBS)
        string(REPLACE "/MD" "/MT" ${CMAKE_CXX_FLAGS_DEBUG} "${${CMAKE_CXX_FLAGS_DEBUG}}")
        string(REPLACE "/MD" "/MT" ${CMAKE_CXX_FLAGS_RELEASE} "${${CMAKE_CXX_FLAGS_RELEASE}}")
    endif()
    
    add_definitions(/D_WINDOWS /DUSE_EXECEPTIONS)
    if(${CMAKE_CL_64}) #64 bit compiler
        add_definitions(/D_AMD64_ /Damd64 /DWIN32_LEAN_AND_MEAN)
    endif()
    
    set(CMAKE_CXX_COMPILER_ID msvc-${CMAKE_CXX_COMPILER_VERSION}-${ARCHITECTURE})            
endif()