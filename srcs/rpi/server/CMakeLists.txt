cmake_minimum_required(VERSION 3.16)

project(server LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Threads REQUIRED)

include(FetchContent)

find_package(pigpio QUIET)
if (NOT TARGET pigpio::core)
    message(STATUS "pigpio was not found. Fetching from git")
    FetchContent_Declare(
        pigpio
        GIT_REPOSITORY https://github.com/bog-dan-ro/pigpio.git
        GIT_TAG master
        )
    set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Build STATIC libraries")
    FetchContent_MakeAvailable(pigpio)
endif()

add_executable(server main.cpp)
target_link_libraries(server PRIVATE pigpio::core Threads::Threads rt)

install(TARGETS server
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
