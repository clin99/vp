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
%parse-param { ParserVerilogInterface &driver }

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

%token               END    0     "end of file"
%token               UPPER
%token               LOWER
%token <std::string> WORD
%token               NEWLINE
%token               CHAR

%locations

%%

list_option : END | list END;

list
  : item
  | list item
  ;

item
  : UPPER   { }
  | LOWER   { }
  | WORD    { }
  | NEWLINE { }
  | CHAR    { }
  ;

%%


void verilog::VerilogParser::error(const location_type &l, const std::string &err_message) {
  std::cerr << "Error: " << err_message << " at " << l << "\n";
}
