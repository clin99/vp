%skeleton "lalr1.cc"
%require  "3.0"
%debug 
%defines 
%define api.namespace {verilog}
%define parser_class_name {VerilogParser}

%define parse.error verbose

%code requires{
  #include "verilog_data.hpp"

  namespace verilog {
    class ParserVerilogInterface;
    class VerilogScanner;
  }

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif 

}

%parse-param { VerilogScanner &scanner }
%parse-param { ParserVerilogInterface *driver }

%code {
  #include <iostream>
  #include <cstdlib>
  #include <fstream>
  #include <utility>
  #include <tuple>
  
   /* include for all driver functions */
  #include "verilog_driver.hpp"

#undef yylex
#define yylex scanner.yylex
}

%define api.value.type variant
%define parse.assert

%token              END    0     "end of file"
%token<std::string> UPPER
%token<std::string> LOWER
%token<std::string> WORD
%token              NEWLINE
%token              UNDEFINED 

/* Valid name (Identifiers) */
%token<std::string> NAME 
%token<std::string> ESCAPED_NAME  

%token<verilog::Constant> INTEGER BINARY OCTAL DECIMAL HEX REAL EXP

/* Keyword tokens */
%token MODULE ENDMODULE INPUT OUTPUT INOUT REG WIRE WAND WOR TRI TRIOR TRIAND SUPPLY0 SUPPLY1


/* Nonterminal Symbols */
%type<std::string> valid_name  
%type<std::variant<verilog::Net, verilog::Inst>> clauses 

%type<std::pair<verilog::PortDirection, verilog::ConnectionType>> port_type 
%type<verilog::Port> port_decls port_decl 

%type<verilog::NetType> net_type
%type<verilog::Net> net_decls net_decl 

%locations 
%start design

%%


valid_name
  : NAME { $$ = $1; }
  | ESCAPED_NAME { $$ = $1; }
  ;



design 
  : modules;

modules
  :
  | modules module
  ;

module
  : MODULE valid_name ';' clauses ENDMODULE  
    { 
      driver->add_module($2);
    }
  | MODULE valid_name '(' ')' ';' clauses ENDMODULE   
    {
      driver->add_module($2);
    }
  | MODULE valid_name '(' port_names ')' ';' clauses ENDMODULE  
    {
      driver->add_module($2);
    }
  | MODULE valid_name '(' 
      { driver->add_module($2); } 
    port_decls ')' 
      { driver->add_port(std::move($5)); } ';' 
    clauses ENDMODULE 
    { 
      
    }
  ;

// port names are ignored as they will be parsed later in declaration
port_names 
  : valid_name { }
  | port_names ',' valid_name  { }
  ; 


port_type 
  : INPUT      { $$ = std::make_pair(verilog::PortDirection::INPUT, verilog::ConnectionType::NONE); }
  | INPUT WIRE { $$ = std::make_pair(verilog::PortDirection::INPUT, verilog::ConnectionType::WIRE); }
  | OUTPUT     { $$ = std::make_pair(verilog::PortDirection::OUTPUT,verilog::ConnectionType::NONE); }
  | OUTPUT REG { $$ = std::make_pair(verilog::PortDirection::OUTPUT,verilog::ConnectionType::REG);  }
  | INOUT      { $$ = std::make_pair(verilog::PortDirection::INOUT, verilog::ConnectionType::NONE); }
  | INOUT WIRE { $$ = std::make_pair(verilog::PortDirection::INOUT, verilog::ConnectionType::WIRE); }
  | INOUT REG  { $$ = std::make_pair(verilog::PortDirection::INOUT, verilog::ConnectionType::REG);  }
  ;

port_decls
  : port_decl 
    {
      $$ = $1;
    }
  | port_decls ',' port_decl  
    {
      driver->add_port(std::move($1));
      $$ = $3;
    }
  | port_decls ',' valid_name 
    {
      $1.names.emplace_back($3);     
      $$ = $1;
    }
  ;

port_decl 
  : port_type valid_name 
    {
      $$.dir  = std::get<0>($1);
      $$.type = std::get<1>($1);
      $$.names.emplace_back($2); 
    }
  | port_type '[' INTEGER ':' INTEGER ']' valid_name  
    {
      $$.dir  = std::get<0>($1);
      $$.type = std::get<1>($1);
      $$.beg = std::stoi($3.value);
      $$.end = std::stoi($5.value);
      $$.names.emplace_back($7); 
    }
  ;

clauses 
  : // empty
  | clauses clause 

  ; 

clause
  : declaration
  | instance
  ;


declaration 
  : port_decls ';' { driver->add_port(std::move($1)); } 
  | net_decls  ';' { driver->add_net(std::move($1)); }
  ;


net_type 
  :  WIRE    { $$ = verilog::NetType::WIRE;    }
  |  WAND    { $$ = verilog::NetType::WAND;    }
  |  WOR     { $$ = verilog::NetType::WOR;     }
  |  TRI     { $$ = verilog::NetType::TRI;     }
  |  TRIOR   { $$ = verilog::NetType::TRIOR;   }
  |  TRIAND  { $$ = verilog::NetType::TRIAND;  }
  |  SUPPLY0 { $$ = verilog::NetType::SUPPLY0; }
  |  SUPPLY1 { $$ = verilog::NetType::SUPPLY1; }
  ;

net_decls
  : net_decl 
    {
      $$ = $1;
    }
  | net_decls ',' net_decl  
    {
      driver->add_net(std::move($1));
      $$ = $3;
    }
  | net_decls ',' valid_name 
    {
      $1.names.emplace_back($3);     
      $$ = $1;
    }
  ;

net_decl 
  : net_type valid_name 
    {
      $$.type = $1;
      $$.names.emplace_back($2); 
    }
  | net_type '[' INTEGER ':' INTEGER ']' valid_name  
    {
      $$.type = $1;
      $$.beg = std::stoi($3.value);
      $$.end = std::stoi($5.value);
      $$.names.emplace_back($7); 
    }
  ;


/*
  | clauses clause_assign
clause_assign
  : ASSIGN assignments ';'

assignments
  : assignment 
  | assignments ',' assignment 
  ;

assignment
  : 

*/


instance 
  :
  ;




/*
list_option : END | list END;

list
  : item
  | list item
  ;

item
  : 
  | EXP       { std::cout << "EXP = " << $1 << '\n'; }
  | REAL      { std::cout << "REAL = " << $1 << '\n'; }
  | HEX       { std::cout << "HEX = " << $1 << '\n'; }
  | DECIMAL   { std::cout << "DECIMAL = " << $1 << '\n'; }
  | OCTAL     { std::cout << "OCTAL = " << $1 << '\n'; }
  | BINARY    { std::cout << "BINARY = " << $1 << '\n'; }
  | INTEGER   { std::cout << "INT = " << $1 << '\n'; }
  | NAME      { std::cout << "NAMED = " << $1 << '\n'; }
  | ESCAPED_NAME  { std::cout << "ESCAPED_NAME =\"" << $1 << "\"\n"; }

  | UPPER     { std::cout << "upper " << $1 << '\n'; }
  | LOWER     { std::cout << "lower " << $1 << '\n'; }
  | WORD      { std::cout << "word  " << $1 << '\n'; }
  | NEWLINE   { std::cout << "newline \n"; }
  | UNDEFINED { std::cout << "UNDEFINED " << '\n'; }
  ;

*/ 
%%

void verilog::VerilogParser::error(const location_type &l, const std::string &err_message) {
  std::cerr << "Parser error: " << err_message  << '\n'
            << "  begin at line " << l.begin.line <<  " col " << l.begin.column  << '\n' 
            << "  end   at line " << l.end.line <<  " col " << l.end.column << "\n";
}


