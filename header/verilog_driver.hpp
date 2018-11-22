#ifndef PARSER_VERILOG_HPP_
#define PARSER_VERILOG_HPP_

#include <string>
#include <cstddef>
#include <fstream>
#include <variant>
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
    virtual void add_module(const std::string&) = 0;
    virtual void add_input(const std::string&) = 0;
    // port names, begin index, end index, port type (IOB), connection type (wire, reg)
    virtual void add_port(Port&&) = 0;
    virtual void add_net(Net&&) = 0;
    virtual void add_assignment(Assignment&&) = 0;


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
    _parser = new VerilogParser(*_scanner, this);
  }
  _parser->parse();
}


struct ParserVerilog : public ParserVerilogInterface {
  void add_module(const std::string& name){
    std::cout << "Module name = " << name << '\n';
  }
  void add_input(const std::string&){}
  void add_port(Port&& port) {
    std::cout << "\nAdd Port: \n" << port << '\n';
  }  

  void add_net(Net&& net) {
    std::cout << "\nAdd Net: \n" << net << '\n';
  }  

  void add_assignment(Assignment&& ast) {
    std::cout << "\nAdd assignment: \n" << ast << '\n';
  }  

};






} 
#endif 
