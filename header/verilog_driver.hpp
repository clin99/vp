#ifndef PARSER_VERILOG_HPP_
#define PARSER_VERILOG_HPP_

#include <string>
#include <cstddef>
#include <fstream>
#include <variant>
#include <unordered_map>
#include <experimental/filesystem>

#include "verilog_scanner.hpp"
#include "verilog_parser.tab.hh"

namespace verilog {

class ParserVerilogInterface {
  public:
    virtual ~ParserVerilogInterface(){
      if(_scanner) delete _scanner;
      if(_parser) delete _parser;
    }
    virtual void add_module(std::string&&) = 0;
    // port names, begin index, end index, port type (IOB), connection type (wire, reg)
    virtual void add_port(Port&&) = 0;
    virtual void add_net(Net&&) = 0;
    virtual void add_assignment(Assignment&&) = 0;
    virtual void add_instance(Instance&&) = 0;

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



struct SampleParser : public ParserVerilogInterface {
  virtual ~SampleParser(){}

  void add_module(std::string&& name){
    std::cout << "Module name = " << name << '\n';
  }

  void add_port(Port&& port) {
    if(show)
      std::cout << "\nAdd Port: \n" << port << '\n';
    ports.push_back(std::move(port));
  }  

  void add_net(Net&& net) {
    if(show)
      std::cout << "\nAdd Net: \n" << net << '\n';
    nets.push_back(std::move(net));
  }  

  void add_assignment(Assignment&& ast) {
    if(show)
      std::cout << "\nAdd assignment: \n" << ast << '\n';
    assignments.push_back(std::move(ast));
  }  

  void add_instance(Instance&& inst) {
    if(show)
      std::cout << "\nAdd instance: \n" << inst << '\n';
    insts.push_back(std::move(inst));
  }
  
  bool show {false};

  std::vector<Port> ports;
  std::vector<Net> nets;
  std::vector<Assignment> assignments;
  std::vector<Instance> insts;
};



// ------------------------------------------------------------------------------------------------

// Struct: Gate
struct Gate {
  std::string name;
  std::string cell;
  std::unordered_map<std::string, std::string> cellpin2net;
  std::unordered_map<std::string, std::string> net2cellpin;
};

// Struct: Module
struct Module {
  std::string name;
  std::vector<std::string> ports;
  std::vector<std::string> wires;
  std::vector<std::string> inputs;
  std::vector<std::string> outputs;
  std::vector<Gate> gates;
  //std::string info() const;

  //void read(const std::filesystem::path&);
};



struct OpenTimerParser : public ParserVerilogInterface {
  OpenTimerParser() = default;
  virtual ~OpenTimerParser(){}

  void add_module(std::string&& name){ module.name = std::move(name); }

  void add_port(Port&& port) {
    if(port.dir == verilog::PortDirection::INPUT) {
      module.inputs.insert(module.inputs.end(), port.names.begin(), port.names.end());
    }
    else if(port.dir == verilog::PortDirection::OUTPUT) {
      module.outputs.insert(module.outputs.end(), port.names.begin(), port.names.end());
    }
    else{
      module.inputs.insert(module.inputs.end(), port.names.begin(), port.names.end());
      module.outputs.insert(module.outputs.end(), port.names.begin(), port.names.end());
    }
    std::move(port.names.begin(), port.names.end(), std::back_inserter(module.ports));
  }

  void add_net(Net&& net) {
    if(net.type == verilog::NetType::WIRE){
      std::move(net.names.begin(), net.names.end(), std::back_inserter(module.wires));
    }
  }

  void add_assignment(Assignment&& ast) {}

  void add_instance(Instance&& inst) {
    auto &g = module.gates.emplace_back();
    g.name = inst.module_name;
    g.cell = inst.inst_name;

    std::string pin; 
    std::string net;
    for(size_t i=0; i<inst.net_names.size(); i++) {
      auto &net_name = inst.net_names[i][0];

      if(i < inst.net_names.size()) {
        auto &pin_name = inst.pin_names[i];
        switch(pin_name.index()) {
          case 0: pin = std::get<0>(pin_name); break;
          case 1: pin = std::get<1>(pin_name).name; break;
          case 2: pin = std::get<2>(pin_name).name; break;
        }

        switch(net_name.index()) {
          case 0: net = std::get<0>(net_name); break;
          case 1: net = std::get<1>(net_name).name; break;
          case 2: net = std::get<2>(net_name).name; break;
          case 3: net = std::get<3>(net_name).value; break;
        }

        g.cellpin2net.insert({pin, net});
        g.net2cellpin.insert({std::move(net), std::move(pin)});
      }
    }
  }

  Module module;
};


} 
#endif 
