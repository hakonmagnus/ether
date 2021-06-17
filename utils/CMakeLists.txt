cmake_minimum_required(VERSION 3.12)
project(utils VERSION 1.0.0 LANGUAGES CXX)

# General
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll")

# Set build type
if (NOT DEFINED ${CMAKE_BUILD_TYPE})
    set(${CMAKE_BUILD_TYPE} Debug)
endif ()

# Options
option(BUILD_TESTS "Build the tests" ON)
option(BUILD_DOCS "Build the Doxygen documentation" ON)

# Tests and documentation
include(TestDocs)

# Subdirectories
add_subdirectory(diskimg)

set(INCLUDE_DIRECTORIES
    ${CMAKE_SOURCE_DIR}/diskimg/include)

# C++ linting
include(Cppcheck)
include(Clang)

# Code coverage
if (CMAKE_BUILD_TYPE MATCHES Coverage)
    include(CodeCoverage)
    setup_target_for_coverage(coverage unit_tests coverage_out)
endif ()
