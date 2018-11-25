#include <iostream>
#include <cstdlib>
#include <cstring>

#include "verilog_driver.hpp"

int main(const int argc, const char **argv){
  verilog::SampleParser parser;
  if(argc > 1 && std::experimental::filesystem::exists(argv[1])) { 
    //std::cout << argv[1] << '\n';
    parser.read(argv[1]);
    //parser.read("../../../../app/timer.v");
  }
  //parser.read("../example/wordlist.txt");
  return( EXIT_SUCCESS );
}
