# Project-level CMake configuration.
#
# This file configures the Windows C++ app to host the Flutter engine.

cmake_minimum_required(VERSION 3.14)
project(agent_prompt LANGUAGES CXX)

# This value is used when generating builds using this CMake file.
# It is not used by Flutter tooling.
set(FLUTTER_VERSION "1.0.0" CACHE STRING "version")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

add_subdirectory(flutter)
add_subdirectory(runner)
