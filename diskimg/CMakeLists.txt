cmake_minimum_required(VERSION 3.5)
project(diskimg)

add_executable(diskimg
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Disk.cpp)

target_include_directories(diskimg PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include)
