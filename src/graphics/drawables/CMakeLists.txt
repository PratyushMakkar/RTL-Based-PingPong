cmake_minimum_required(VERSION 3.15)

target_include_directories(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(RTLPingPong PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/ball.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/drawable.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/paddle.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/playerScore.cpp
)