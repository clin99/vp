#include <iostream>
#include <cstdlib>
#include <cstring>

#include "verilog_driver.hpp"

int main(const int argc, const char **argv){
  verilog::SampleParser parser;
  parser.read("../../../../app/timer.v");
  //parser.read("../example/wordlist.txt");
  return( EXIT_SUCCESS );
}
