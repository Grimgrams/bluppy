cmake_minimum_required(VERSION 3.16)
project(blubbyd LANGUAGES C OBJC)

# libs
find_library(FOUNDATION_FRAMEWORK Foundation)
# libpq
include_directories(/opt/homebrew/Cellar/libpq/16.1_1/include/)
include_directories(/opt/homebrew/Cellar/libpq/16.1_1/lib/)

file(GLOB SOURCE_FILES "*.m")

add_executable(bluppyd ${SOURCE_FILES})

target_link_libraries(bluppyd ${FOUNDATION_FRAMEWORK}  /opt/homebrew/Cellar/libpq/16.1_1/lib/libpq.5.dylib)
