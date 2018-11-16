#ifndef PARSER_VERILOG_HPP_
#define PARSER_VERILOG_HPP_

#include <string>
#include <cstddef>
#include <experimental/filesystem>

#include "verilog_scanner.hpp"
#include "verilog_parser.tab.hh"

namespace verilog {

class ParserVerilogInterface {
  public:
    virtual void add_module(std::string&) = 0;
    virtual void add_input(std::string&) = 0;

    void read(const std::experimental::filesystem::path&){}
};

struct ParserVerilog : public ParserVerilogInterface {
  void add_module(std::string&){}
  void add_input(std::string&){}
   
};

} 
#endif 
