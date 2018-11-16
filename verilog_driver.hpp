#ifndef PARSER_VERILOG_HPP_
#define PARSER_VERILOG_HPP_

#include <string>
#include <cstddef>
#include <fstream>
#include <experimental/filesystem>

#include "verilog_scanner.hpp"
#include "verilog_parser.tab.hh"

namespace verilog {

class ParserVerilogInterface {
  public:
    virtual ~ParserVerilogInterface(){
      if(!_scanner) delete _scanner;
      if(!_parser) delete _parser;
    }
    virtual void add_module(std::string&) = 0;
    virtual void add_input(std::string&) = 0;

    void read(const std::experimental::filesystem::path&); 

  private:
    VerilogScanner* _scanner {nullptr};
    VerilogParser*  _parser {nullptr};

};

inline void ParserVerilogInterface::read(const std::experimental::filesystem::path& p){
  if(! std::experimental::filesystem::exists(p)){
    return ;
  }

  std::ifstream ifs(p);
  if(!_scanner){
    _scanner = new VerilogScanner(&ifs);
  }
  if(!_parser){
    _parser = new VerilogParser(*_scanner, *this);
  }
  _parser->parse();
}

struct ParserVerilog : public ParserVerilogInterface {
  void add_module(std::string&){}
  void add_input(std::string&){}
   
};






} 
#endif 
