set(diskutil_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

add_executable(diskimg ${diskutil_SOURCES})

set(SOURCE_FILES ${SOURCE_FILES} ${diskutil_SOURCES} PARENT_SCOPE)
