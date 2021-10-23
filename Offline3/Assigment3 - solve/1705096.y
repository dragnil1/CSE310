%{
#include<bits/stdc++.h>
#include "Implementation of Symbol Table.cpp"
#define YYSTYPE SymbolInfo*

using namespace std;

extern int line_count, error, paren_balance;
extern bool statement;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
ofstream errors, logg;
deque<pair<string, string>> parameters;
vector<pair<string, int>> declaration_list;
vector<string> argument_list;
string expression_type;
vector<vector<string>> arg_list;
vector<string> stemp;

SymbolTable symboltable(30);



void yyerror(char *s)
{
	string sl = s;
	cout << "error " << line_count << " " << sl << endl;
	//write your code
}

vector<string> checkParameter(deque<pair<string, string>> parameters)
{
    map<string,int> count;
    vector<string> temp;
    for(auto params : parameters)
    {
        count[params.first]++;
    }
    for(auto a : count)
    {
        if(a.second > 1)
        {
            temp.push_back(a.first);
        }
    }
    return temp;
}

vector<int> checkParameterType(vector<string> param1, deque<pair<string, string>> param2)
{
    vector<int> temp;
    cout << param1.size() << " " << param2.size() << endl;
    for(int i = 0; i < param1.size(); i++)
    {
        if(param1[i] != param2[i].second)
        {
            temp.push_back(i + 1);
        }
    }
    return temp;
}

vector<int> checkArgumentType(vector<string> param1, vector<string> param2)
{
    vector<int> temp;
    cout << param1.size() << " " << param2.size() << endl;
    for(int i = 0; i < param1.size(); i++)
    {
        if(param1[i] != param2[i])
        {
            temp.push_back(i + 1);
        }
    }
    return temp;
}

void func_sanity_check(string name, string type, deque<pair<string, string>> parameters)
{
    /*vector<string> temp = checkParameter(parameters);
    if(!temp.empty())
    {
        ///Error at line 20: Multiple declaration of a in parameter
        errors << "Error at line " << line_count << ": Multiple declaration of ";
        for(auto str : temp)
        {
            errors << str << " ";
        }
        errors << "in parameter" << endl << endl;
        error++;
    }*/
    bool ok = symboltable.Insert(name, "ID");
    SymbolInfo* temp1 = symboltable.LookUp(name);
    if(ok)
    {
        temp1->setParameterNumber(parameters.size());
        temp1->setTypeSpecifier(type);
        for(auto a : parameters)
        {
            temp1->addParameterType(a.second);
        }
    }
    else
    {
        if(temp1->getParameterNumber() == -1)
        {
            logg << "Error at line " << line_count << ": Multiple declaration of " << name << endl << endl;
            errors << "Error at line " << line_count << ": Multiple declaration of " << name << endl << endl;
            error++;
        }
        else
        {
            if(temp1->getTypeSpecifier() != type)
            {
                ///Error at line 24: Return type mismatch with function declaration in function foo3
                logg << "Error at line " << line_count << ": Return type mismatch with function declaration in function " << name << endl << endl;
                errors << "Error at line " << line_count << ": Return type mismatch with function declaration in function " << name << endl << endl;
                error++;
            }
            if(temp1->getParameterNumber() != parameters.size())
            {
                //Error at line 32: Total number of arguments mismatch with declaration in function var
                logg << "Error at line " << line_count << ": Total number of arguments mismatch with declaration in function " << name << endl << endl;
                errors << "Error at line " << line_count << ": Total number of arguments mismatch with declaration in function " << name << endl << endl;
                error++;
            }
             else
            {
                vector<int> temp2 =  checkParameterType(temp1->getParameters(), parameters);
                if(!temp2.empty())
                {
                     //Error at line 45: 1th argument mismatch in function func
                    logg << "Error at line " << line_count << ": ";
                    errors << "Error at line " << line_count << ": ";
                    for(int i = 0; i < temp2.size(); i++)
                    {
                        logg << temp2[i] << "th";
                        errors << temp2[i] << "th";
                        if(i == temp2.size() - 1)
                        {
                            logg << " ";
                            errors << " ";
                        }
                        else
                        {
                            logg << ", ";
                            errors << ", ";
                        }
                    }
                    logg << "parameter mismatch in function " << name << endl << endl;
                    errors << "parameter mismatch in function " << name << endl << endl;
                    error++;
                }
            }
        } 
    }
}

void func_enter_scope(deque<pair<string, string>> &parameters)
{
    symboltable.enterScope();
	while(!parameters.empty())
	{
		bool ok = symboltable.Insert(parameters.front().first, "ID");
        if(!ok)
        {
            ///Error at line 20: Multiple declaration of a in parameter
            logg << "Error at line " << line_count << ": Multiple declaration of " << parameters.front().first << " in parameter" << endl << endl; 
            errors << "Error at line " << line_count << ": Multiple declaration of " << parameters.front().first << " in parameter" << endl << endl;
            error++;
        }
        else
        {
            SymbolInfo* temp = symboltable.LookUp(parameters.front().first);
            temp->setTypeSpecifier(parameters.front().second);
        }
		parameters.pop_front();
	}
}

%}

%token ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD CONST_INT RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_FLOAT INCOP DECOP


%nonassoc LOWER_THAN_ELSE

%nonassoc ELSE



%%

start : program
	{
		logg << "Line " << line_count << ": start : program" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;
	}
	;

program : program unit
	{
		logg << "Line " << line_count << ": program : program unit" << endl << endl; 
		$$->setName($1->getName() + $2->getName()); 
		logg << $$->getName() << endl << endl;
	}
	| unit
	{
		logg << "Line " << line_count << ": program : unit" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;
	}
	;
	
unit : var_declaration
		{
			logg << "Line " << line_count << ": unit : var_declaration" << endl << endl; 
			$$->setName($1->getName()); 
			logg << $$->getName() << endl << endl;
		}
     | func_declaration
	 {
		logg << "Line " << line_count << ": unit : func_declaration" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;
	 }
     | func_definition
	 {
		logg << "Line " << line_count << ": unit : func_definition" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					logg << "Line " << line_count << ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" << endl << endl; 
                    vector<string> temp = checkParameter(parameters);
                    if(!temp.empty())
                    {
                        ///Error at line 20: Multiple declaration of a in parameter
                        logg << "Error at line " << line_count << ": Multiple declaration of ";
                        errors << "Error at line " << line_count << ": Multiple declaration of ";
                        for(auto str : temp)
                        {
                            logg << str << " ";
                            errors << str << " ";
                        }
                        logg << "in parameter" << endl << endl;
                        errors << "in parameter" << endl << endl;
                        error++;
                    }
                    bool ok = symboltable.Insert($2->getName(), "ID");
                    if(!ok)
                    {
                        //Error at line 28: Multiple declaration of z
                        logg << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << endl << endl;
                        errors << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << endl << endl;
                        error++;
                    }
                    else
                    {
                        SymbolInfo* temp1 = symboltable.LookUp($2->getName());
                        temp1->setParameterNumber(parameters.size());
                        temp1->setTypeSpecifier($1->getTypeSpecifier());
                        while(!parameters.empty())
                        {
                            temp1->addParameterType(parameters.front().second);
                            parameters.pop_front();
                        }
                    }
					$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + "\n");
                    $$->setType("NONTERMINAL"); 
					logg << $$->getName() << endl << endl;
                    parameters.clear();
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			logg << "Line " << line_count << ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON" << endl << endl; 
			bool ok = symboltable.Insert($2->getName(), "ID");
            if(!ok)
            {
                //Error at line 28: Multiple declaration of z
                logg << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << endl << endl;
                errors << "Error at line " << line_count << ": Multiple declaration of " << $2->getName() << endl << endl;
                error++;
            }
            else
            {
                SymbolInfo* temp1 = symboltable.LookUp($2->getName());
                temp1->setParameterNumber(parameters.size());
                temp1->setTypeSpecifier($1->getTypeSpecifier());
                while(!parameters.empty())
                {
                    temp1->addParameterType(parameters.front().second);
                    parameters.pop_front();
                }
            }
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + "\n"); 
            $$->setType("NONTERMINAL");
			logg << $$->getName() << endl << endl;
            parameters.clear();
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
				{
					logg << "Line " << line_count << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
					//symboltable.Insert($2->getName(), $2->getType()); 
					$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName());
					logg << $$->getName() << endl << endl;
                    parameters.clear();
				}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
			logg << "Line " << line_count << ": func_definition : type_specifier ID LPAREN RPAREN compound_statement" << endl << endl; 
			//symboltable.Insert($2->getName(), $2->getType());
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
			logg << $$->getName() << endl << endl;
            parameters.clear();
		}
 		;				

parameter_list  : parameter_list COMMA type_specifier ID
				{
                    if($3->getTypeSpecifier() == "VOID")
                    {
                        logg << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                        errors << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                        error++;
                    }
					logg << "Line " << line_count << ": parameter_list  : parameter_list COMMA type_specifier ID" << endl << endl; 
					parameters.emplace_back($4->getName(), $3->getTypeSpecifier());
					$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
                    $$->setType("NONTERMINAL");
					logg << $$->getName() << endl << endl;
				}
		| parameter_list COMMA type_specifier
		{
            if($3->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                errors << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                error++;
            }
			logg << "Line " << line_count << ": parameter_list  : parameter_list COMMA type_specifier" << endl << endl; 
            parameters.emplace_back("!DEFAULT", $3->getTypeSpecifier());
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType("NONTERMINAL");
			logg << $$->getName() << endl << endl;
		}
 		| type_specifier ID
		 {
            if($1->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                errors << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                error++;
            }
			logg << "Line " << line_count << ": parameter_list  : type_specifier ID" << endl << endl; 
			parameters.emplace_back($2->getName(), $1->getTypeSpecifier());
			$$->setName($1->getName() + " " + $2->getName()); 
            $$->setType("NONTERMINAL"); 
			logg << $$->getName() << endl << endl;
		 }
		| type_specifier
		{
            if($1->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                errors << "Error at line " << line_count << ": Parameter type cannot be void" << endl << endl;
                error++;
            }
			logg << "Line " << line_count << ": parameter_list  : type_specifier" << endl << endl; 
            parameters.emplace_back("!DEFAULT", $1->getTypeSpecifier());
			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
			logg << $$->getName() << endl << endl;
		}
 		;

 		
compound_statement : LCURL statements RCURL
					{
						logg << "Line " << line_count << ": compound_statement : LCURL statements RCURL" << endl << endl; 
						$$->setName($1->getName() + "\n" + $2->getName() + " " + $3->getName() + "\n");
                        $$->setType("NONTERMINAL");
						logg << $$->getName() << endl << endl;
                        symboltable.PrintAllScopeTable(logg);
	                    symboltable.exitScope();
					}
 		    | LCURL RCURL
			 {
				logg << "Line " << line_count << ": compound_statement : LCURL RCURL" << endl << endl; 
				$$->setName($1->getName() + "\n" + $2->getName() + "\n"); 
                $$->setType("NONTERMINAL");
				logg << $$->getName() << endl << endl;
                symboltable.PrintAllScopeTable(logg);
	            symboltable.exitScope();
			 }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			logg << "Line " << line_count << ": var_declaration : type_specifier declaration_list SEMICOLON" << endl << endl; 
            if($1->getTypeSpecifier() != "VOID")
            {  
                for(auto ids : declaration_list)
                {
                    bool ok = symboltable.Insert(ids.first, "ID");
                    if(!ok)
                    {
                        //Error at line 28: Multiple declaration of z
                        logg << "Error at line " << line_count << ": Multiple declaration of " << ids.first << endl << endl;
                        errors << "Error at line " << line_count << ": Multiple declaration of " << ids.first << endl << endl;
                        error++;
                    }
                    else
                    {
                        SymbolInfo* temp = symboltable.LookUp(ids.first);
                        temp->setArraySize(ids.second);
                        temp->setTypeSpecifier($1->getTypeSpecifier());
                    }
                }
            }
            else
            {
                //Error at line 42: Variable type cannot be void
                logg << "Error at line " << line_count << ": Variable type cannot be void" << endl << endl;
                errors << "Error at line " << line_count << ": Variable type cannot be void" << endl << endl;
                error++;
            }
            declaration_list.clear();
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + "\n");
            $$->setType("NONTERMINAL");
			logg << $$->getName() << endl << endl;
		}
 		 ;
 		 
type_specifier	: INT 
		{ 
			logg << "Line " << line_count << ": type_specifier : INT" << endl << endl; 
			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("INT");
			logg << $$->getName() << endl << endl;
		}	
 		| FLOAT 
 		{ 
 			logg << "Line " << line_count << ": type_specifier : FLOAT" << endl << endl; 
 			$$->setName($1->getName()); 
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("FLOAT");
 			logg << $$->getName() << endl << endl;
 		}
 		| VOID 
 		{ 
			logg << "Line " << line_count << ": type_specifier : VOID" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("VOID");
 			logg << $$->getName() << endl << endl;
 		}
 		;
 		
declaration_list : declaration_list COMMA ID 
		{ 
			logg << "Line " << line_count << ": declaration_list : declaration_list COMMA ID" << endl << endl; 
            declaration_list.emplace_back($3->getName(), -1);
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType($$->getType());
			logg << $$->getName() << endl << endl;
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
 		{ 
			logg << "Line " << line_count << ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" << endl << endl;


            stringstream convert($5->getName()); 
            int num;
            convert >> num;


            $3->setArraySize(num); 
            declaration_list.emplace_back($3->getName(), num);
			///symboltable.Insert($3->getName(), $3->getType());
 		  	$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName());
 		  	logg << $$->getName() << endl << endl;
 		}
 		  | ID	
 		{ 
 		  	logg << "Line " << line_count << ": declaration_list : ID" << endl << endl;
            declaration_list.emplace_back($1->getName(), -1);
 		  	$$->setName($1->getName());
 		  	logg << $$->getName() << endl << endl;
 		} 
 		  | ID LTHIRD CONST_INT RTHIRD 
 		{ 
 		  	logg << "Line " << line_count << ": declaration_list : ID LTHIRD CONST_INT RTHIRD" << endl << endl; 
            
            stringstream convert($3->getName()); 
            int num;
            convert >> num;


            declaration_list.emplace_back($1->getName(), num);
			///symboltable.Insert($1->getName(), $1->getType());
 		  	$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
            $$->setType("NONTERMINAL");
 		  	logg << $$->getName() << endl << endl;
 		} 
 		  ;
 		  
statements : statement
		{ 
 			logg << "Line " << line_count << ": statements : statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
 			logg << $$->getName() << endl << endl;
 		} 
	   | statements statement
	   	{ 
 			logg << "Line " << line_count << ": statements : statements statement" << endl << endl; 
 			$$->setName($1->getName() + $2->getName());
            $$->setType($1->getType());
 			logg << $$->getName() << endl << endl;
 		} 
	   ;
	   
statement : var_declaration
		{
			logg << "Line " << line_count << ": statement : var_declaration" << endl << endl; 
 			$$->setName($1->getName()); 
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
		}	
	  | expression_statement
	  {
		  	logg << "Line " << line_count << ": statement : expression_statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
	  }
	  | compound_statement
	  {
		  	logg << "Line " << line_count << ": statement : compound_statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
		  	logg << "Line " << line_count << ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + " " + $7->getName());
 			$$->setType("NONTERMINAL");
            logg << $$->getName() << endl << endl;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
		  	logg << "Line " << line_count << ": statement : IF LPAREN expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement 
	  {
		  	logg << "Line " << line_count << ": statement : IF LPAREN expression RPAREN statement ELSE statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + " " + $7->getName());
 			$$->setType("NONTERMINAL");
            logg << $$->getName() << endl << endl;
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
		  	logg << "Line " << line_count << ": statement : WHILE LPAREN expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		  	logg << "Line " << line_count << ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON" << endl << endl; 
			SymbolInfo* si = symboltable.LookUp($3->getName());
            if(si == NULL)
            {
                //Error at line 51: Undeclared variable k
                logg << "Error at line " << line_count << ": Undeclared variable " << $3->getName() << endl << endl;
                errors << "Error at line " << line_count << ": Undeclared variable " << $3->getName() << endl << endl;
                error++;
            }
            else
            {
                if(!(si->getArraySize() == -1 && si->getParameterNumber() == -1))
                {
                    //Error at line 52: b not an array
                    logg << "Error at line " << line_count << ": Undeclared variable " << $3->getName() << endl << endl;
                    errors << "Error at line " << line_count << ": " << $3->getName() << " not a variable" << endl << endl;
                    error++;
                }
            }
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + "\n");
            $$->setType("NONTERMINAL");
 			logg << $$->getName() << endl << endl;
	  }
	  | RETURN expression SEMICOLON 
	  {
		  	logg << "Line " << line_count << ": statement : RETURN expression SEMICOLON" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + "\n");
            $$->setType("NONTERMINAL");
            if($2->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Return type cannot be void " << endl << endl;
                errors << "Error at line " << line_count << ": Return type cannot be void " << endl << endl;
                error++;
            }
 			logg << $$->getName() << endl << endl;
	  }
	  ;
	  
expression_statement : SEMICOLON
						{
							logg << "Line " << line_count << ": expression_statement : SEMICOLON" << endl << endl; 
 							$$->setName($1->getName() + "\n");
                            $$->setType("NONTERMINAL");
                            $$->setTypeSpecifier($1->getTypeSpecifier());
 							logg << $$->getName() << endl << endl;
						}			
			| expression SEMICOLON 
			{
				logg << "Line " << line_count << ": expression_statement : expression SEMICOLON" << endl << endl; 
 				$$->setName($1->getName() + " " + $2->getName() + "\n");
                $$->setType("NONTERMINAL");
                $$->setTypeSpecifier($1->getTypeSpecifier());
 				logg << $$->getName() << endl << endl;
			}
			;
	  
variable : ID
		{
			logg << "Line " << line_count << ": variable : ID" << endl << endl; 
			SymbolInfo* si = symboltable.LookUp($1->getName());
            if(si == NULL)
            {
                //Error at line 51: Undeclared variable k
                $$->setTypeSpecifier("UNDECLARED");
                logg << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
                errors << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
                error++;
            }
            else
            {
                $$->setTypeSpecifier(si->getTypeSpecifier());
                if(!(si->getArraySize() == -1 && si->getParameterNumber() == -1))
                {
                    //Error at line 52: b not an array
                    logg << "Error at line " << line_count << ": " << $1->getName() << " not a variable" << endl << endl;
                    errors << "Error at line " << line_count << ": " << $1->getName() << " not a variable" << endl << endl;
                    error++;
                }
            }
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            ///$$->setTypeSpecifier(si->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		}
	 | ID LTHIRD expression RTHIRD 
	 {
		 	logg << "Line " << line_count << ": variable : ID LTHIRD expression RTHIRD" << endl << endl; 
 			SymbolInfo* si = symboltable.LookUp($1->getName());
            if(si == NULL)
            {
                //Error at line 51: Undeclared variable k
                $$->setTypeSpecifier("UNDECLARED");
                logg << "Error at line " << line_count << ": Undeclared array " << $1->getName() << endl << endl;
                errors << "Error at line " << line_count << ": Undeclared array " << $1->getName() << endl << endl;
                error++;
            }
            else
            {
                $$->setTypeSpecifier(si->getTypeSpecifier());
                if(si->getArraySize() == -1)
                {
                    //Error at line 52: b not an array
                    logg << "Error at line " << line_count << ": " << $1->getName() << " not an array" << endl << endl;
                    errors << "Error at line " << line_count << ": " << $1->getName() << " not an array" << endl << endl;
                    error++;
                }
                else
                {
                    if($3->getTypeSpecifier() != "INT")
                    {
                        logg << "Error at line " << line_count << ": Expression inside third brackets not an integer" << endl << endl;
                        errors << "Error at line " << line_count << ": Expression inside third brackets not an integer" << endl << endl;
                        error++;
                    }
                }
            }
            $$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
            $$->setType("NONTERMINAL");
            ///$$->setTypeSpecifier(si->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
	 }
	 ;
	 
expression : logic_expression	
			{
				logg << "Line " << line_count << ": expression : logic_expression" << endl << endl; 
                if($1->getType() == "NOTFUNC" && $1->getTypeSpecifier() == "VOID")
                {
                    logg << "Error at line " << line_count << ": Void function used in expression" << endl << endl;
                    errors << "Error at line " << line_count << ": Void function used in expression" << endl << endl;
                    error++;
                }
 				$$->setName($1->getName());
                $$->setType($1->getType());
                $$->setTypeSpecifier($1->getTypeSpecifier());
                expression_type = $1->getTypeSpecifier();
 				logg << $$->getName() << endl << endl;
			}
	   | variable ASSIGNOP logic_expression 
	   {
		   	logg << "Line " << line_count << ": expression : variable ASSIGNOP logic_expression" << endl << endl; 
            if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Void function used in expression" << endl << endl;
                errors << "Error at line " << line_count << ": Void function used in expression" << endl << endl;
                error++;
            }
            else if(($1->getTypeSpecifier() != $3->getTypeSpecifier()) && $1->getTypeSpecifier() == "INT" && !($1->getTypeSpecifier() == "UNDECLARED" || $3->getTypeSpecifier() == "UNDECLARED"))
            {
                logg << "Error at line " << line_count << ": Type Mismatch" << endl << endl;
                errors << "Error at line " << line_count << ": Type Mismatch" << endl << endl;
                error++;
            }
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
	   }	
	   ;
			
logic_expression : rel_expression
				{
					logg << "Line " << line_count << ": logic_expression : rel_expression" << endl << endl; 
 					$$->setName($1->getName());
                    $$->setType($1->getType());
                    $$->setTypeSpecifier($1->getTypeSpecifier());
 					logg << $$->getName() << endl << endl;
				}
		 | rel_expression LOGICOP rel_expression 	
		 {
			logg << "Line " << line_count << ": logic_expression : rel_expression LOGICOP rel_expression" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType("NOTFUNC");
            if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID")
            {
                $$->setTypeSpecifier("VOID");
            }
            else
            {
                $$->setTypeSpecifier("INT");
            }
 			logg << $$->getName() << endl << endl;
		 }
		 ;
			
rel_expression : simple_expression 
				{
					logg << "Line " << line_count << ": rel_expression : simple_expression" << endl << endl; 
 					$$->setName($1->getName());
                    $$->setType($1->getType());
                    $$->setTypeSpecifier($1->getTypeSpecifier());
 					logg << $$->getName() << endl << endl;
				}
		| simple_expression RELOP simple_expression	
		{
			logg << "Line " << line_count << ": rel_expression : simple_expression RELOP simple_expression" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType("NOTFUNC");
            if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID")
            {
                $$->setTypeSpecifier("VOID");
            }
            else
            {
                $$->setTypeSpecifier("INT");
            }
 			logg << $$->getName() << endl << endl;
		}
		;
				
simple_expression : term
					{
						logg << "Line " << line_count << ": simple_expression : term" << endl << endl; 
 						$$->setName($1->getName());
                        $$->setType($1->getType());
                        $$->setTypeSpecifier($1->getTypeSpecifier());
 						logg << $$->getName() << endl << endl;
					}
		  | simple_expression ADDOP term 
		  {
			  	logg << "Line " << line_count << ": simple_expression : simple_expression ADDOP term" << endl << endl; 
 				$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
                $$->setType("NOTFUNC");
                if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID")
                {
                    $$->setTypeSpecifier("VOID");
                }
                else if($1->getTypeSpecifier() == "FLOAT" || $3->getTypeSpecifier() == "FLOAT")
                {
                    $$->setTypeSpecifier("FLOAT");
                }
                else
                {
                    $$->setTypeSpecifier("INT");
                }
 			    logg << $$->getName() << endl << endl;
		  }
		  ;
					
term : unary_expression
		{
			logg << "Line " << line_count << ": term : unary_expression" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		}
     |  term MULOP unary_expression
	 	{
			logg << "Line " << line_count << ": term : term MULOP unary_expression" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType("NOTFUNC");
            int sum = 0;
            if($2->getName() == "%")
            {
                if(!($1->getTypeSpecifier() == "INT" && $3->getTypeSpecifier() == "INT"))
                {
                    ///Error at line 60: Non-Integer operand on modulus operator
                    logg << "Error at line " << line_count << ": Non-Integer operand on modulus operator" << endl << endl;
                    errors << "Error at line " << line_count << ": Non-Integer operand on modulus operator" << endl << endl;
                    error++;
                }
                else
                {
                    for(auto c : $3->getName())
                    {
                        sum += (c - '0');
                    }
                    if(sum == 0)
                    {
                        ///Error at line 59: Modulus by Zero
                        logg << "Error at line " << line_count << ": Modulus by Zero" << endl << endl; 
                        errors << "Error at line " << line_count << ": Modulus by Zero" << endl << endl;
                        error++;
                    }
                }
            }
            if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID")
            {
                $$->setTypeSpecifier("VOID");
            }
            else if($2->getName() != "%" && ($1->getTypeSpecifier() == "FLOAT" || $3->getTypeSpecifier() == "FLOAT"))
            {
                $$->setTypeSpecifier("FLOAT");
            }
            else
            {
                $$->setTypeSpecifier("INT");
            }
 			logg << $$->getName() << endl << endl;
		}
     ;

unary_expression : ADDOP unary_expression
					{
						logg << "Line " << line_count << ": unary_expression : ADDOP unary_expression" << endl << endl; 
 						$$->setName($1->getName() + " " + $2->getName());
                        $$->setType("NOTFUNC");
                        $$->setTypeSpecifier($2->getTypeSpecifier());
 						logg << $$->getName() << endl << endl;
					}
		 | NOT unary_expression
		 {
			logg << "Line " << line_count << ": unary_expression : NOT unary_expression" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName());
            $$->setType("NOTFUNC");
            $$->setTypeSpecifier($2->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		 } 
		 | factor 
		 {
			logg << "Line " << line_count << ": unary_expression : factor" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		 }
		 ;
	
factor	: variable
		{
			logg << "Line " << line_count << ": factor : variable" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		}
	| ID LPAREN argument_list RPAREN
	{
		logg << "Line " << line_count << ": factor : ID LPAREN argument_list RPAREN" << endl << endl; 
		///symboltable.Insert($1->getName(), $1->getType());
        SymbolInfo* si = symboltable.LookUp($1->getName());
        if(si == NULL)
        {
            //Error at line 51: Undeclared variable k
            $$->setTypeSpecifier("UNDECLARED");
            logg << "Error at line " << line_count << ": Undeclared function " << $1->getName() << endl << endl;
            errors << "Error at line " << line_count << ": Undeclared function " << $1->getName() << endl << endl;
            error++;
        }
        else
        {
            $$->setTypeSpecifier(si->getTypeSpecifier());
            ///cout << "*******" << si->getTypeSpecifier() << endl << endl;
            
            if(si->getParameterNumber() == -1)
            {
                //Error at line 52: b not an array
                logg << "Error at line " << line_count << ": " << $1->getName() << " not a function" << endl << endl;
                errors << "Error at line " << line_count << ": " << $1->getName() << " not a function" << endl << endl;
                error++;
            }
            else
            {
                if(si->getTypeSpecifier() == "VOID" && statement)
                {
                    logg << "Error at line " << line_count << ": Conditional expression cannot be void" << endl << endl;
                    errors << "Error at line " << line_count << ": Conditional expression cannot be void" << endl << endl;
                    error++;
                }
                if(si->getParameterNumber() != argument_list.size())
                {
                    //Error at line 49: Total number of arguments mismatch in function correct_foo
                    cout << endl << "&&&& " << si->getParameterNumber() << " " << argument_list.size() << endl << endl;
                    for(auto a : argument_list)
                    {
                        cout << a << endl;
                    }
                    logg << "Error at line " << line_count << ": Total number of arguments mismatch in function " << $1->getName() << endl << endl;
                    errors << "Error at line " << line_count << ": Total number of arguments mismatch in function " << $1->getName() << endl << endl;
                    error++;
                }
                else
                {
                    vector<int> temp = checkArgumentType(si->getParameters(), argument_list);
                    if(!temp.empty())
                    {
                        //Error at line 45: 1th argument mismatch in function func
                        logg << "Error at line " << line_count << ": ";
                        errors << "Error at line " << line_count << ": ";
                        for(int i = 0; i < temp.size(); i++)
                        {
                            logg << temp[i] << "th";
                            errors << temp[i] << "th";
                            if(i == temp.size() - 1)
                            {
                                logg << " ";
                                errors << " ";
                            }
                            else
                            {
                                logg << ", ";
                                errors << ", ";
                            }
                        }
                        logg << "argument mismatch in function " << $1->getName() << endl << endl;
                        errors << "argument mismatch in function " << $1->getName() << endl << endl;
                        error++;
                    }
                }
                for(auto a : argument_list)
                {
                    if(a == "VOID")
                    {
                        logg << "Error at line " << line_count << ": Argument cannot be void" << endl << endl;
                        errors << "Error at line " << line_count << ": Argument cannot be void" << endl << endl;
                        error++;
                    }
                }
                
            }
        }
        argument_list.clear();
 		$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
        $$->setType("FUNC");
 		logg << $$->getName() << endl << endl;
	}
	| LPAREN expression RPAREN
	{
		logg << "Line " << line_count << ": factor : LPAREN expression RPAREN" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
        $$->setType($2->getType());
        $$->setTypeSpecifier($2->getTypeSpecifier());
 		logg << $$->getName() << endl << endl;
	}
	| CONST_INT
	{
		logg << "Line " << line_count << ": factor : CONST_INT" << endl << endl; 
 		$$->setName($1->getName());
        $$->setType("NONTERMINAL");
        $$->setTypeSpecifier("INT");
 		logg << $$->getName() << endl << endl;
	} 
	| CONST_FLOAT
	{
		logg << "Line " << line_count << ": factor : CONST_FLOAT" << endl << endl; 
 		$$->setName($1->getName());
        $$->setType("NONTERMINAL");
        $$->setTypeSpecifier("FLOAT");
 		logg << $$->getName() << endl << endl;
	}
	| variable INCOP
	{
		logg << "Line " << line_count << ": factor : variable INCOP" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName());
        $$->setType($1->getType());
        $$->setTypeSpecifier($1->getTypeSpecifier());
 		logg << $$->getName() << endl << endl;
	} 
	| variable DECOP
	{
		logg << "Line " << line_count << ": factor : variable DECOP" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName());
        $$->setType($1->getType());
        $$->setTypeSpecifier($1->getTypeSpecifier());
 		logg << $$->getName() << endl << endl;
	}
	;
	
argument_list : arguments
				{
					logg << "Line " << line_count << ": argument_list : arguments" << endl << endl; 
 					$$->setName($1->getName());
 					logg << $$->getName() << endl << endl;
				}
			  |
			  {
                    
				  	logg << "Line " << line_count << ": argument_list : " << endl << endl; 
 					///$$->name = $1->name;
                    //cout << "here" << endl;
                    //$$->setName("");
                    $$ = new SymbolInfo("", "");
                    /*if($$ == NULL)
                    {
                        cout << " Hmm " << endl;
                    }*/
 					logg << $$->getName() << endl << endl;
			  }
			  ;
	
arguments : arguments COMMA logic_expression
			{
				logg << "Line " << line_count << ": arguments : arguments COMMA logic_expression" << endl << endl; 
                argument_list.push_back($3->getTypeSpecifier());
 				$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
 				logg << $$->getName() << endl << endl;
			}
	      | logic_expression
		  {
			  	logg << "Line " << line_count << ": arguments : logic_expression" << endl << endl; 
                argument_list.push_back($1->getTypeSpecifier());
 				$$->setName($1->getName());
 				logg << $$->getName() << endl << endl;
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{

	if(argc!=2)
	{
		printf("Please provide input file name and try again\n");
		return 0;
	}
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL)
	{
		printf("Cannot open specified file\n");
		return 0;
	}
	logg.open("log.txt");
    errors.open("error.txt");
	yyin = fin;
	yyparse();
	symboltable.PrintAllScopeTable(logg);
	logg << endl << "Total lines: " << line_count << endl;
	logg << "Total errors: " << error << endl;
	logg.close();
    errors.close();
	return 0;
}

