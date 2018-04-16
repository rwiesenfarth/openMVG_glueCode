cmake_minimum_required(VERSION 3.2.2)

project(cereal)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/../../${GLUE_DEPLOY_DIR}")

install(DIRECTORY "repo/include/cereal" DESTINATION "include")
