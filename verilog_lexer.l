%{
/* C++ string header, for string ops below */
#include <string>

/* Implementation of yyFlexScanner */ 
#include "verilog_scanner.hpp"
#undef  YY_DECL
#define YY_DECL int verilog::VerilogScanner::yylex(verilog::VerilogParser::semantic_type * const lval, verilog::VerilogParser::location_type *loc )

/* typedef to make the returns for the tokens shorter */
using token = verilog::VerilogParser::token;

/* define yyterminate as this instead of NULL */
#define yyterminate() return( token::END )

/* msvc2010 requires that we exclude this header file. */
#define YY_NO_UNISTD_H

/* update location on matching */
#define YY_USER_ACTION loc->step(); loc->columns(yyleng);
%}

/* Make the generated scanner run in debug mode. */
%option debug
/* Cause the default rule (that unmatched scanner input is echoed to stdout) to be suppressed. */
%option nodefault
/* Inform flex that a derived NAME is implemented as a subclass of yyFlexLexer, so flex will place your actions in the member function foo::yylex() instead of yyFlexLexer::yylex(). */
%option yyclass="verilog::VerilogScanner"
/* Set yywrap always returns 1. yywrap is called when reaching EOF */
%option noyywrap
/* Suppress the warning message yyunput is defined but not used */
%option nounput
%option never-interactive
%option c++

/* Define inclusive/exclusive states */
%x in_comment

/* Predefined rules */
NEWLINE         "\n|\r\n"
SPACE           " |\t|\v|\f"
COMMENT_BEGIN   "/*"
COMMENT_END     "*/"


/* Token rule section begins */
%%
%{  /** Code executed at the beginning of yylex **/
  yylval = lval;
%}

<*>{SPACE} { /* ignore any space */ }
{NEWLINE}  { // Update line numbers 
             loc->lines();
             return( token::NEWLINE );
           }

{COMMENT_BEGIN} { BEGIN(in_comment); }
<in_comment><<EOF>> { 
                      BEGIN(INITIAL);
                      std::cerr << "Unclosed comment at line " << loc->end.line << " col " << loc->end.column << '\n';
                      yyterminate();
                    }
<in_comment>{NEWLINE} { loc->lines(); }
<in_comment>. { /* ignore characters in comment */ }
<in_comment>{COMMENT_END} { BEGIN(INITIAL); }

[a-z]       {
               return( token::LOWER );
            }

[A-Z]       {
               return( token::UPPER );
            }

[a-zA-Z]+   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               return( token::WORD );
            }


.           {
               return( token::CHAR );
            }
%%

