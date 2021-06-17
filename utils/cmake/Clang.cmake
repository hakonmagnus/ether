find_program(CLANG_TIDY NAMES clang-tidy clang-tidy-6.0)
if (CLANG_TIDY)
    add_custom_target(
        tidy
        COMMAND ${CLANG_TIDY}
        ${SOURCE_FILES}
        --
        -std=c++11
        -I ${INCLUDE_DIRECTORIES})
endif ()

find_program(CLANG_FORMAT NAMES clang_format clang-format-6.0)
if (CLANG_FORMAT)
    add_custom_target(
        format
        COMMAND ${CLANG_FORMAT}
        -i
        ${SOURCE_FILES})
endif ()
