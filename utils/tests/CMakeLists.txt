add_subdirectory("${PROJECT_SOURCE_DIR}/extern/googletest" "extern/googletest")

mark_as_advanced(
    BUILD_GMOCK BUILD_GTEST BUILD_SHARED_LIBS
    gmock_build_tests gtest_build_samples gtest_build_tests
    gtest_disable_pthreads gtest_force_shared_crt gtest_hide_internal_symbols)

set_target_properties(gtest PROPERTIES FOLDER extern)
set_target_properties(gtest_main PROPERTIES FOLDER extern)
set_target_properties(gmock PROPERTIES FOLDER extern)
set_target_properties(gmock_main PROPERTIES FOLDER extern)

set(TEST_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/diskimg_test.cpp)

add_executable(unit_tests ${TEST_FILES})
target_link_libraries(unit_tests gtest_main gtest gmock)
target_include_directories(unit_tests PUBLIC
    ${CMAKE_SOURCE_DIR}/diskimg/include)
