#include <iostream>
#include <cstdlib>
#include <cstring>

#include "verilog_driver.hpp"

int main(const int argc, const char **argv){

  for(const auto&p : std::experimental::filesystem::directory_iterator("../script/benchmark/")){
    verilog::SampleParser parser;
    parser.read(p);
  }

  return( EXIT_SUCCESS );
}
