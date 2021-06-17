find_program(GCOV_PATH gcov)
find_program(LCOV_PATH lcov)
find_program(GENHTML_PATH genhtml)
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

if (NOT GCOV_PATH)
    message(FATAL_ERROR "gcov not found. Aborting...")
endif ()

if (NOT CMAKE_COMPILER_IS_GNUCXX)
    message(WARNING "Compiler is not GNU GCC.")
    
    if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        message(FATAL_ERROR "Compiler is not GNU GCC. Aborting...")
    endif ()
endif ()

set(CMAKE_CXX_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C++ compiler during coverage builds."
    FORCE)
set(CMAKE_C_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C compiler during coverage builds."
    FORCE)
set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used for linking binaries during coverage builds."
    FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used by the shared libraries linker during coverage builds."
    FORCE)
mark_as_advanced(
    CMAKE_CXX_FLAGS_COVERAGE
    CMAKE_C_FLAGS_COVERAGE
    CMAKE_EXE_LINKER_FLAGS_COVERAGE,
    CMAKE_SHARED_LINKER_FLAGS_COVERAGE)

if (NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
    message(WARNING "Code coverage results with an optimized build may be misleading.")
endif ()

function(SETUP_TARGET_FOR_COVERAGE _targetname _testrunner _outputname)
    if (NOT LCOV_PATH)
        message(FATAL_ERROR "lcov not found. Aborting...")
    endif ()
    
    if (NOT GENHTML_PATH)
        message(FATAL_ERROR "genhtml not found. Aborting...")
    endif ()
    
    add_custom_target(${_targetname}
        ${LCOV_PATH} --directory . --zerocounters
        COMMAND ${CMAKE_COMMAND} -E remove ${_outputname}.info ${_outputname}.info.cleaned
        
        COMMAND ${_testrunner} ${ARGV3}
        
        COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_outputname}.info
        COMMAND ${LCOV_PATH} --remove ${_outputname}.info '*/test/*' '/usr/*' --output-file ${CMAKE_BINARY_DIR}/${_outputname}.info.cleaned
        COMMAND ${GENHTML_PATH} -o ${_outputname} ${_outputname}.info.cleaned
        
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report.")
    
    add_custom_command(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Open ./${_outputname}/index.html to view coverage report.")
endfunction()
