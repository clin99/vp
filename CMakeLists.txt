cmake_minimum_required(VERSION 3.9) 

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

project(verilog_parser CXX)

# Turn on the verbose
set(CMAKE_VERBOSE_MAKEFILE ON)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

BISON_TARGET(verilog_parser
             verilog_parser.yy
             ${CMAKE_CURRENT_BINARY_DIR}/verilog_parser.tab.cc)
FLEX_TARGET(verilog_lexer
            verilog_lexer.l
            ${CMAKE_CURRENT_BINARY_DIR}/verilog_lexer.yy.cc)
ADD_FLEX_BISON_DEPENDENCY(verilog_lexer verilog_parser)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(verilog_parser
  main.cpp
  ${FLEX_verilog_lexer_OUTPUTS}
  ${BISON_verilog_parser_OUTPUTS}
)
target_link_libraries(verilog_parser stdc++fs)

target_include_directories(verilog_parser
 PRIVATE
 .
 ${CMAKE_CURRENT_BINARY_DIR})

