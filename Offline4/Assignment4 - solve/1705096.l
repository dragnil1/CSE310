%option noyywrap 

%{
#include<bits/stdc++.h>
#include "Implementation of Symbol Table.cpp"
#define YYSTYPE SymbolInfo*
#include "y.tab.h"

using namespace std;


//ofstream token, logg;

string name, type, temp1;
string fun_name = "!DEFAULT", fun_type = "!DEFAULT";
bool statement = false;
pair<string,string> func = make_pair("!DEFAULT", "!DEFAULT");
extern YYSTYPE yylval;
extern SymbolTable symboltable;
extern ofstream logg, errors;
extern deque<pair<string, string>> parameters;
extern string expression_type;
void yyerror(char *);

int line_count=1;
int error=0;
int paren_balance = 0;

extern void func_sanity_check(string name, string type, deque<pair<string, string>> parameters);
extern void func_enter_scope(string name, deque<pair<string, string>> &parameters);

string processString(string name)
{
	string temp;
	for(int i = 0; i < name.size(); )
	{
            	if(name[i] == '\\')
            	{
                	if(i + 1 < name.size())
                	{
                    	if(name[i + 1] == 'a')
                    	{
                        	temp += '\a';
                   	}
                   	else if(name[i + 1] == 'b')
                    	{
                        	temp += '\b';
                    	}
                    	else if(name[i + 1] == 'e')
                    	{
                        	temp += '\e';
                    	}
                    	else if(name[i + 1] == 'f')
                    	{
                        	temp += '\f';
                    	}
                    	else if(name[i + 1] == 'n')
                    	{
                        	temp += '\n';
                    	}
                    	else if(name[i + 1] == 'r')
                    	{
                        	temp += '\r';
                    	}
                    	else if(name[i + 1] == 't')
                    	{
                        	temp += '\t';
                    	}
                    	else if(name[i + 1] == 'v')
                    	{
                        	temp += '\v';
                    	}
                    	else if(name[i + 1] == '\\')
                    	{
                        	temp += '\\';
                    	}
                    	else if(name[i + 1] == '\'')
                    	{
                        	temp += '\'';
                    	}
                    	else if(name[i + 1] == '\"')
                    	{
                    	    temp += '\"';
                   	}
                    	else if(name[i + 1] == '\?')
                    	{
                        	temp += '\?';
                    	}
                    	else 
                    	{
                        	if(name[i + 1] != '\n')
                        	{
                            	temp += name[i + 1];
                        	}
                    	}
                    	i += 2;
                	}
                	else
                	{
                    		i++;
                	}
            	}
            	else
            	{
                	temp += name[i];
                	i++;
            	}
    	}
    	return temp;
}

string processChar(string name)
{
    string temp;
    if(name.size() == 3)
    {
        temp += name[1];
    }
    else
    {
                    if(name[2] == 'a')
                    {
                        temp += '\a';
                    }
                    else if(name[2] == 'b')
                    {
                        temp += '\b';
                    }
                    else if(name[2] == 'e')
                    {
                        temp += '\e';
                    }
                    else if(name[2] == 'f')
                    {
                        temp += '\f';
                    }
                    else if(name[2] == 'n')
                    {
                        temp += '\n';
                    }
                    else if(name[2] == 'r')
                    {
                        temp += '\r';
                    }
                    else if(name[2] == 't')
                    {
                        temp += '\t';
                    }
                    else if(name[2] == 'v')
                    {
                        temp += '\v';
                    }
                    else if(name[2] == '\\')
                    {
                        temp += '\\';
                    }
                    else if(name[2] == '\'')
                    {
                        temp += '\'';
                    }
                    else if(name[2] == '\"')
                    {
                        temp += '\"';
                    }
                    else if(name[2] == '\?')
                    {
                        temp += '\?';
                    }
    }
    return temp;
}

/*void print_logg(string type, string name)
{
	logg << endl;
	if(type == "CONST_CHAR")
	{
		logg << "Line no " << line_count << ": Token <" << type << "> Lexeme " << name << " found";
		name = processChar(name);
		logg <<  " --> <CHAR_CONST, " << name << "> " << endl;
	}
	else if(type == "STRING")
	{
		logg << "Line no " << line_count << ": Token <" << type << "> Lexeme " << name << " found";
		name = processString(name);
		logg <<  " --> <STRING, " << name << "> " << endl;
	}
	else
	{
		logg << "Line no " << line_count << ": Token <" << type << "> Lexeme " << name << " found" << endl;
	}
	
}

void print_token(string type, string name)
{
	if(type == "CONST_CHAR")
	{
		name = processChar(name);
		type = "CHAR_CONST";
	
	}
	else if(type == "STRING")
	{

		name = processString(name);
	}
	token << "<" << type << ", " << name << "> ";
	
}

void print_token(string type)
{
	token << "<" << type << "> ";
}

void symbolInsert(string type, string name)
{
	if(symboltable.Insert(name, type, logg))
	{
		symboltable.PrintAllScopeTable(logg);
	}
	
}*/

void incLine(string name)
{
	for(auto chr : name)
	{
		if(chr == '\n')
		{
			line_count++;
		}
	}
}

/*void print_error(string name, string type)
{
    logg << endl;
    logg << "Error at line no " << line_count << ": " << type << " " << name << endl;
    error++;
}*/

string processComment(string name)
{
    string temp;
    if(name.back() == '\n')
    {
        for(int i = 0; i < name.size() - 1; i++)
        {
            temp += name[i];
        }
    }
    else
    {
        temp = name;
    }
    return temp;
}

string processUnfinishedString(string name)
{
    string temp;
    if(name.back() == '\n')
    {
        for(int i = 0; i < name.size() - 1; i++)
        {
            temp += name[i];
        }
    }
    else
    {
        temp = name;
    }
    return temp;
}


%}


CONST_INT [0-9]+
CONST_FLOAT ([0-9]+\.([0-9]*E[+-]?[0-9]+|[0-9]+))|(\.([0-9]+E[+-]?[0-9]+|[0-9]+))|([0-9]+E[+-]?[0-9]+)
CONST_CHAR '([ -&\(-\[\]-~]|\\n|\\t|\\\\|\\'|\\a|\\f|\\r|\\b|\\v|\\0)'


ADDOP \+|-
MULOP \*|\/|%
INCOP \+\+
DECOP --
RELOP <=|<|>=|>|==|!=
ASSIGNOP = 
LOGICOP &&|\|\|
NOT !
LPAREN \(
RPAREN \)
LCURL \{
RCURL \}
LTHIRD \[
RTHIRD \] 
COMMA ,
SEMICOLON ;


ID [A-Za-z_]([A-Za-z_]|[0-9])*


STRING \"([ -!#-\[\]-~\t\v\f\r]|\\(\\)*([ -!#-\[\]-~\t\v\f\r]|\n[ -!#-\[\]-~\t\v\f\r]|\"))*(\\(\\)*\n\"|\")


COMMENT (\/\/([ -\[\]-~\t\v\f\r]|\\(\\|\n\\)*([ -\[\]-~\t\v\f\r]|\n[ -\[\]-~\t\v\f\r]))*(\n|\\(\\|\n\\)*\n))|(\/\*([\t\v\f\r\n -\)\+-\.0-~]|\/|\*(\*)*[\t\v\f\r\n -\)\+-\.0-~])*\*(\*)*\/)


WHITESPACE [ \t\n\v\f\r]+




TOO_MANY_DECIMAL_POINT [0-9]*\.[0-9]*\.([0-9]|\.)*
ILL_FORMED ([0-9]+\.|\.)([0-9]+E[-+]?[0-9]*(\.|E[-+])|E[-+])([0-9]|\.|E[-+])*|[0-9]+E[-+][0-9]*(\.|E[-+])([0-9]|\.|E[-+])*
INVALID_SUFFIX ({CONST_INT}|{CONST_FLOAT})[A-Za-z_]+
INVALID_PREFIX [#$.0-9@\\`]+[A-Za-z_]([A-Za-z_]|[0-9])*
MULTI_CHAR_CONST '([ -&\(-\[\]-~]|\\n|\\t|\\\\|\\'|\\a|\\f|\\r|\\b|\\v|\\0)([ -&\(-\[\]-~]|\\n|\\t|\\\\|\\'|\\a|\\f|\\r|\\b|\\v|\\0)+'
EMPTY_CHAR_CONST ''
UNFINISHED_CHAR '[!-&\(-\[\]-~]|'\\n|'\\t|'\\\\|'\\'|'\\a|'\\f|'\\r|'\\b|'\\v|'\\0|'
UNFINISHED_STRING \"([ -!#-\[\]-~]|\\(\\)*([ -!#-\[\]-~]|\n[ -!#-\[\]-~]|\"))*(\\(\\)*\n\n|\n)
UNFINISHED_COMMENT \/\*(([\t\n\v\f\r -\)\+-\.0-~]|\/)|(\*)+[\t\n\v\f\r -\)\+-\.0-~])*
UNRECOGNIZED_CHARACTER [^\+\-\*\/%<>=\(\)\{\}\[\],;]



%%

if {
	name = yytext;
	type = "IF";
	//print_logg(type, name);
	//print_token(type);
    statement = true;
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return IF;
	}
	
	
for {
	name = yytext;
	type = "FOR";
	//print_logg(type, name);
	//print_token(type);
    statement = true;
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return FOR;
	}


do {
	name = yytext;
	type = "DO";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
int {
	name = yytext;
	type = "INT";
    fun_type = type;
    fun_name = "!DEFAULT";
	//print_logg(type, name);
	//print_token(type);
	yylval = new SymbolInfo(name, type);
	return INT;
	}
	
	
float {
	name = yytext;
	type = "FLOAT";
    fun_type = type;
    fun_name = "!DEFAULT";
	//print_logg(type, name);
	//print_token(type);
	yylval = new SymbolInfo(name, type);
	return FLOAT;
	}
	
	
void {
	name = yytext;
	type = "VOID";
    fun_type = type;
    fun_name = "!DEFAULT";
	//print_logg(type, name);
	//print_token(type);
	yylval = new SymbolInfo(name, type);
	return VOID;
	}
	
	
switch {
	name = yytext;
	type = "SWITCH";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
default {
	name = yytext;
	type = "DEFAULT";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
else {
	name = yytext;
	type = "ELSE";
	//print_logg(type, name);
	//print_token(type);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return ELSE;
	}
	
	
while {
	name = yytext;
	type = "WHILE";
	//print_logg(type, name);
	//print_token(type);
    statement = true;
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return WHILE;
	}
	
	
break {
	name = yytext;
	type = "BREAK";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
char {
	name = yytext;
	type = "CHAR";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
double {
	name = yytext;
	type = "DOUBLE";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
return {
	name = yytext;
	type = "RETURN";
	//print_logg(type, name);
	//print_token(type);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return RETURN;
	}
	
	
case {
	name = yytext;
	type = "CASE";
	//print_logg(type, name);
	//print_token(type);
	}
	
	
continue {
	name = yytext;
	type = "CONTINUE";
	//print_logg(type, name);
	//print_token(type);
	}

printf {
	name = yytext;
	type = "PRINTLN";
	//print_logg(type, name);
	//print_token(type);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return PRINTLN;
	}
	
println {
	name = yytext;
	type = "PRINTLN";
	//print_logg(type, name);
	//print_token(type);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return PRINTLN;
	}

{CONST_INT} {
	name = yytext;
	type = "CONST_INT";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return CONST_INT;
	}

{CONST_FLOAT} {
	name = yytext;
	type = "CONST_FLOAT";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return CONST_FLOAT;
	}

{CONST_CHAR} {
	name = yytext;
	type = "CONST_CHAR";
	//print_logg(type, name);
	//print_token(type, name);
	}
	
{ADDOP} {
	name = yytext;
	type = "ADDOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return ADDOP;
	}
	
	
{MULOP} {
	name = yytext;
	type = "MULOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return MULOP;
	}
	
	
{INCOP} {
	name = yytext;
	type = "INCOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return INCOP;
	}
	
{DECOP} {
	name = yytext;
	type = "DECOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return DECOP;
	}
{RELOP} {
	name = yytext;
	type = "RELOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return RELOP;
	}
{ASSIGNOP} {
	name = yytext;
	type = "ASSIGNOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return ASSIGNOP;
	}
{LOGICOP} {
	name = yytext;
	type = "LOGICOP";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return LOGICOP;
	}
{NOT} {
	name = yytext;
	type = "NOT";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return NOT;
	}
{LPAREN} {
	name = yytext;
	type = "LPAREN";
	//print_logg(type, name);
	//print_token(type, name);
    if(!(fun_name == "!DEFAULT" || fun_type == "!DEFAULT"))
    {
        func.first = fun_name;
        func.second = fun_type;
    }
    fun_name = fun_type = "!DEFAULT";
    paren_balance++;
	yylval = new SymbolInfo(name, type);
	return LPAREN;
	}
{RPAREN} {
	name = yytext;
	type = "RPAREN";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
    paren_balance--;
    if(paren_balance == 0)
    {
        statement = false;
    }
	yylval = new SymbolInfo(name, type);
	return RPAREN;
	} 
{LCURL} {
	name = yytext;
	type = "LCURL";
	//print_logg(type, name);
	//print_token(type, name);
    if(!(func.first == "!DEFAULT" || func.second == "!DEFAULT"))
    {
        func_sanity_check(func.first, func.second, parameters);
    }
	func_enter_scope(func.first, parameters);
    parameters.clear();
    fun_name = fun_type = "!DEFAULT";
    func = make_pair(fun_name, fun_type);
	yylval = new SymbolInfo(name, type);
	return LCURL;
	}
{RCURL} {
	name = yytext;
	type = "RCURL";
	///symboltable.PrintAllScopeTable(logg);
	///symboltable.exitScope();
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return RCURL;
	}
{LTHIRD} {
	name = yytext;
	type = "LTHIRD";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return LTHIRD;
	}
{RTHIRD} {
	name = yytext;
	type = "RTHIRD";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return RTHIRD;
	} 
{COMMA} {
	name = yytext;
	type = "COMMA";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return COMMA;
	}
{SEMICOLON} {
	name = yytext;
	type = "SEMICOLON";
	//print_logg(type, name);
	//print_token(type, name);
    fun_name = fun_type = "!DEFAULT";
	yylval = new SymbolInfo(name, type);
	return SEMICOLON;
	}
	
{ID} {
	name = yytext;
	type = "ID";
    fun_name = name;
	//print_logg(type, name);
	//print_token(type, name);
	yylval = new SymbolInfo(name, type);
	return ID;
	}
	
{STRING} {
	name = yytext;
	type = "STRING";
	//print_logg(type, name);
	//print_token(type, name);
	incLine(name);
	}

{COMMENT} {
	name = yytext;
	type = "COMMENT";
	temp1 = processComment(name);
	//print_logg(type, temp1);
	if(temp1 != name)
	{
		line_count++;
	}
	incLine(temp1);
	}
		
{WHITESPACE} {
	name = yytext;
	type = "WHITESPACE";
	incLine(name);
	}

{TOO_MANY_DECIMAL_POINT} {
	name = yytext;
	type = "Too many decimal points";
	//print_error(name, type);
	}

{ILL_FORMED} {
	name = yytext;
	type = "Ill formed number";
	//print_error(name, type);
	}
{INVALID_SUFFIX} {
	name = yytext;
	type = "Invalid prefix on ID or invalid suffix on Number";
	//print_error(name, type);
	}
{INVALID_PREFIX} {
	name = yytext;
	type = "Invalid prefix on ID or invalid suffix on Number";
	//print_error(name, type);
	}
{MULTI_CHAR_CONST} {
	name = yytext;
	type = "Multi character constant error";
	//print_error(name, type);
	}

{UNFINISHED_CHAR} {
	name = yytext;
	type = "Unterminated character";
	//print_error(name, type);
	}
	
{EMPTY_CHAR_CONST} {
	name = yytext;
	type = "Empty character constant error";
	//print_error(name, type);
	}
{UNFINISHED_STRING} {
	name = yytext;
	type = "Unterminated String";
	temp1 = processUnfinishedString(name);
	//print_error(temp1, type);
	incLine(name);
	}
	
{UNFINISHED_COMMENT} {
	name = yytext;
	type = "Unterminated Comment";
	//print_error(name, type);
	incLine(name);
	}	
{UNRECOGNIZED_CHARACTER} {
	name = yytext;
	type = "Unrecognized character";
	//print_error(name, type);
	}	

%%

