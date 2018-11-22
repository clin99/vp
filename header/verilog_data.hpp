#ifndef DATA_VERILOG_HPP_
#define DATA_VERILOG_HPP_

#include <string>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <variant>
#include <experimental/filesystem>


namespace verilog {
  enum class ConstantType {
    NONE,
    INTEGER,
    BINARY,
    OCTAL, 
    DECIMAL,
    HEX, 
    REAL,
    EXP
  };

  inline std::ostream& operator<<(std::ostream& os, const ConstantType& t) {  
    switch(t){
      case ConstantType::NONE:    os << "NONE";    break; 
      case ConstantType::INTEGER: os << "INTEGER"; break;
      case ConstantType::BINARY:  os << "BINARY";  break; 
      case ConstantType::OCTAL:   os << "OCTAL";   break; 
      case ConstantType::DECIMAL: os << "DECIMAL"; break;
      case ConstantType::HEX:     os << "HEX";     break; 
      case ConstantType::REAL:    os << "REAL";    break;
      case ConstantType::EXP:     os << "EXP";     break; 
    }
    return os;  
  }  
  
  struct Constant {
    Constant() = default;  // Need this default constructor for return token
    Constant(std::string&& v, ConstantType t) : value(v), type(t) {}
    std::string value;
    ConstantType type {ConstantType::NONE};
  };

  inline std::ostream& operator<<(std::ostream& os, const Constant& c) {  
    std::cout << " constant value: " << c.value << " type: " << c.type;
    return os;  
  }  

  enum class PortDirection {
    INPUT,
    OUTPUT,
    INOUT
  };

  inline std::ostream& operator<<(std::ostream& os, const PortDirection& dir) {  
    switch(dir){
      case PortDirection::INPUT:  os << "INPUT";  break; 
      case PortDirection::OUTPUT: os << "OUTPUT"; break;
      case PortDirection::INOUT:  os << "INOUT";  break; 
    }
    return os;  
  }  
    
  enum class ConnectionType {
    NONE,
    WIRE,
    REG
  };

  inline std::ostream& operator<<(std::ostream& os, const ConnectionType& ct) {  
    switch(ct){
      case ConnectionType::NONE:  os << "NONE"; break;
      case ConnectionType::WIRE:  os << "WIRE"; break;
      case ConnectionType::REG:   os << "REG";  break; 
    }
    return os;  
  } 

  struct Port {
    std::vector<std::string> names;
    int beg {-1};
    int end {-1};
    PortDirection dir;
    ConnectionType type {ConnectionType::NONE};
  };

  inline std::ostream& operator<<(std::ostream& os, const Port& port) {  
    os << "beg: " << port.beg << "  end: " << port.end << '\n';
    os << "Dir: " << port.dir << "  type: " << port.type << '\n';
    for(const auto& n: port.names){
      os << n << '\n';
    }
    return os;  
  }


  enum class NetType {
    NONE,
    REG,
    WIRE, 
    WAND,
    WOR,
    TRI,
    TRIOR,
    TRIAND,
    SUPPLY0,
    SUPPLY1
  };

  inline std::ostream& operator<<(std::ostream& os, const NetType& t) {  
    switch(t){
      case NetType::NONE:    os << "NONE";    break; 
      case NetType::REG:     os << "REG";     break; 
      case NetType::WIRE:    os << "WIRE";    break;
      case NetType::WAND:    os << "WAND";    break;
      case NetType::WOR:     os << "WOR";     break;
      case NetType::TRI:     os << "TRI";     break;
      case NetType::TRIAND:  os << "TRIAND";  break;
      case NetType::TRIOR:   os << "TRIOR";   break;
      case NetType::SUPPLY0: os << "SUPPLY0"; break;
      case NetType::SUPPLY1: os << "SUPPLY1"; break;
    }
    return os;  
  } 

  struct Net {
    std::vector<std::string> names;
    int beg {-1};
    int end {-1};
    NetType type {NetType::NONE};
  };

  inline std::ostream& operator<<(std::ostream& os, const Net& net) {  
    os << "beg: " << net.beg << "  end: " << net.end << '\n';
    os << "type: " << net.type << '\n';
    for(const auto& n: net.names){
      os << n << '\n';
    }
    return os;  
  }


  struct Assignment {
    std::string lhs;
    int lbeg {-1};
    int lend {-1};

    std::vector<std::string> rhs;
    int rbeg {-1};
    int rend {-1};
  };

  //inline std::ostream& operator<<(std::ostream& os, const Assignment& ast) {  
  //  os << ast.lhs << '[' << ast.lbeg << ',' << ast.lend << ']' << '='
  //     << ast.rhs << '[' << ast.rbeg << ',' << ast.rend << ']' ;
  //  return os;  
  //}

  struct Inst {
  };


} 
#endif  


