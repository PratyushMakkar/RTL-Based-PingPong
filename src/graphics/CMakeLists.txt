cmake_minimum_required(VERSION 3.15)

project(RTLPingPong)
find_package(PkgConfig REQUIRED)
find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS})

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

pkg_check_modules(SDL2TTF REQUIRED SDL2_ttf)
include_directories(${SDL2TTF_INCLUDE_DIRS})

add_executable(RTLPingPong main.cpp)

set_property(TARGET RTLPingPong PROPERTY CXX_STANDARD 11)

target_sources(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/defs.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/gameState.cpp
)

target_include_directories(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(RTLPingPong PUBLIC
  ${SDL2_LIBRARIES}
  ${SDL2TTF_LIBRARIES}
)

add_subdirectory(drawables)