%skeleton "lalr1.cc"
%require  "3.0"
%debug 
%defines 
%define api.namespace {verilog}
%define parser_class_name {VerilogParser}

%code requires{
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

%code{
  #include <iostream>
  #include <cstdlib>
  #include <fstream>
   
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
%token<int> INTEGER 
%token<std::string> BINARY OCTAL DECIMAL HEX REAL

/* Keyword tokens */
%token MODULE ENDMODULE INPUT OUTPUT INOUT WIRE


%locations

%%

list_option : END | list END;

list
  : item
  | list item
  ;

item
  : 
  | REAL       { std::cout << "REAL = " << $1 << '\n'; }
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

%%

void verilog::VerilogParser::error(const location_type &l, const std::string &err_message) {
  std::cerr << "Error: " << err_message << " at " << l << "\n";
}


