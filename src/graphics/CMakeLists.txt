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

#Add Verilator to cmake
target_include_directories(RTLPingPong PUBLIC
  "/opt/local/share/verilator/include" REQUIRED
)

target_sources(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/defs.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/gameState.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/threadInterface/renderThreads.cpp
  "/opt/local/share/verilator/include/verilated.cpp"
  "/opt/local/share/verilator/include/verilated_vcd_c.cpp"
  "/opt/local/share/verilator/include/verilated_threads.cpp"
)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(RTLPingPong PUBLIC Threads::Threads)

target_include_directories(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/threadInterface
  )

target_link_libraries(RTLPingPong PUBLIC
  ${SDL2_LIBRARIES}
  ${SDL2TTF_LIBRARIES}
)

add_subdirectory(drawables)
add_subdirectory(obj_dir)