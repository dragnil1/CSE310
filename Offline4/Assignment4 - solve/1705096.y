%{
#include<bits/stdc++.h>
#include "Implementation of Symbol Table.cpp"
#define YYSTYPE SymbolInfo*

using namespace std;

extern int line_count, error, paren_balance, labelCount = 0, tempCount = 0;
extern bool statement;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
ofstream errors, logg, code, opcode;
deque<pair<string, string>> parameters;
vector<pair<string, int>> declaration_list;
vector<string> argument_list, argument_symbol;
string expression_type;
vector<vector<string>> arg_list;
vector<string> stemp;
vector<pair<string, int>> data_segment;
string assembly_code, return_symbol = "", main_code, main_name;
string outdec = "OUTPUT PROC\n;prints AX as singed decimal integer in range -32768 to 32767\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\n PUSH SI\nPUSH BX\n;if AX < 0\nOR AX, AX\nJGE END_IF1\n;then\nPUSH AX\nMOV DL, '-'\nMOV AH, 2\nINT 21H\nPOP AX\nNEG AX\nEND_IF1:\nXOR CX, CX; CX count digits\nMOV BX, 10D; BX has divisor as 10\nREPEAT1:\nXOR DX, DX; prepare high word for dividend\nDIV BX; AX = quotient, DX = remainder\nPUSH DX; save DX in STACK\nINC CX; increment counter\n;until\nOR AX,AX; quotient == 0?\nJNE REPEAT1\n;convert digits to character and print\nMOV AH, 2\nPRINT_LOOP:\nPOP DX\nOR DL, 30H\nINT 21H\nLOOP PRINT_LOOP\n;end for\nMOV AH, 2\nMOV DL, 0DH\nINT 21h\nMOV DL, 0AH\nINT 21h\nPOP BX\nPOP SI\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET\nOUTPUT ENDP\n";

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
        temp1->setScope(symboltable.getCurrentScopeId());
        for(auto a : parameters)
        {
            temp1->addParameterType(a.second);
        }
    }
    else
    {
        temp1->setScope(symboltable.getCurrentScopeId());
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
    for(auto a : parameters)
    {
            temp1->addParameterName(a.first);
    }
}

void func_enter_scope(string name, deque<pair<string, string>> &parameters)
{
    symboltable.enterScope();
    SymbolInfo* temp1 = symboltable.LookUp(name);
    for(auto a : parameters)
    {
            temp1->addParameterScope(symboltable.getCurrentScopeId());
            data_segment.emplace_back(a.first + "_" + symboltable.getCurrentScopeId(), -1);
    }
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
            temp->setScope(symboltable.getCurrentScopeId());
        }
		parameters.pop_front();
	}
}

string newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return string(lb);
}

string newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return string(t);
}

void optimize(string code)
{
    vector<string> lines, ls1, ls2;
    stringstream ss(code);
    string word;
    while (getline(ss,word,'\n')) 
    {
        lines.push_back(word);
    }
    for(int i = 0; i < lines.size(); i++)
    {
        opcode << lines[i] << endl;
        if(i == lines.size() - 1)
        {
            continue;
        }
        if(lines[i].substr(0, 3) == "MOV" && lines[i + 1].substr(0, 3) == "MOV")
        {
            stringstream s1(lines[i]);
            stringstream s2(lines[i + 1]);
            while (s1 >> word) 
            {
                ls1.push_back(word);
            }
            while (s2 >> word) 
            {
                ls2.push_back(word);
            }
            ls1[1] = ls1[1].substr(0, ls1[1].size() - 1);
            ls2[1] = ls2[1].substr(0, ls2[1].size() - 1);
            if(ls1[1] == ls2[2] && ls1[2] == ls2[1])
            {
                cout << i + 1 << endl;
                opcode << "; optimization done here" << endl;
                i++;
                
            }
        }
        ls1.clear();
        ls2.clear();
    }
}

%}

%token ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD CONST_INT RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_FLOAT INCOP DECOP


%nonassoc LOWER_THAN_ELSE

%nonassoc ELSE



%%

start : program
	{
         $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": start : program" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;

        /*Assembly Code*/
        $$->setCode(".MODEL SMALL\n.STACK 100H\n.DATA\n");
        for(auto declared_var : data_segment)
        {
            $$->setCode($$->getCode() + declared_var.first + " DW");
            if(declared_var.second == -1)
            {
                $$->setCode($$->getCode() + " ?\n");
            }
            else
            {
                $$->setCode($$->getCode() + " " + to_string(declared_var.second) + " DUP " + "(?)\n");
            }
        }
        $$->setCode($$->getCode() + ".CODE\n");
        $$->setCode($$->getCode() + main_code);
        $$->setCode($$->getCode() + $1->getCode() + outdec);
        
        $$->setCode($$->getCode() + "END " + main_name + "\n");
        if(error == 0)
        {
            code << $$->getCode();
            optimize($$->getCode());
        }
	}
	;

program : program unit
	{
         $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": program : program unit" << endl << endl; 
		$$->setName($1->getName() + $2->getName()); 

        $$->setCode($1->getCode() + $2->getCode());

		logg << $$->getName() << endl << endl;
	}
	| unit
	{
         $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": program : unit" << endl << endl; 
		$$->setName($1->getName());

        $$->setCode($1->getCode());

		logg << $$->getName() << endl << endl;
	}
	;
	
unit : var_declaration
		{
             $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": unit : var_declaration" << endl << endl; 
			$$->setName($1->getName()); 
			logg << $$->getName() << endl << endl;
		}
     | func_declaration
	 {
          $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": unit : func_declaration" << endl << endl; 
		$$->setName($1->getName()); 
		logg << $$->getName() << endl << endl;
	 }
     | func_definition
	 {
          $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": unit : func_definition" << endl << endl; 
		$$->setName($1->getName()); 

        if($1->getType() == "main")
        {
            main_code = $1->getCode();
            main_name = "MAIN";
        }
        else
        {
            $$->setCode($1->getCode());
        }

		logg << $$->getName() << endl << endl;
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
                     $$ = new SymbolInfo("", "");
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
             $$ = new SymbolInfo("", "");
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
                     $$ = new SymbolInfo("", "");
					logg << "Line " << line_count << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
					//symboltable.Insert($2->getName(), $2->getType()); 
					$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName());
                    $$->setType($2->getName());

                    SymbolInfo* temp1 = symboltable.LookUp($2->getName());
                    $$->setTypeSpecifier(temp1->getName() + "_" + temp1->getScope());

                    if($2->getName() == "main")
                    {
                        $$->setCode("MAIN PROC\nMOV AX, @DATA\nMOV DS, AX\n");
                    }
                    else
                    {
                        $$->setCode(temp1->getName() + "_" + temp1->getScope() + " PROC\n");
                    }

                    $$->setCode($$->getCode() + $6->getCode());
                    if($1->getTypeSpecifier() != "VOID")
                    {
                        $$->setCode($$->getCode() + "MOV AX, " + return_symbol + "\n");
                        $$->setCode($$->getCode() + "MOV " + temp1->getName() + "_ret_" + temp1->getScope() + ", AX\n");
                        
                    }
                    if($2->getName() == "main")
                    {               
                        $$->setCode($$->getCode() + ";DOS EXIT\n");
                        $$->setCode($$->getCode() + "MOV AH, 4CH\n");
                        $$->setCode($$->getCode() + "INT 21H\n");
                        $$->setCode($$->getCode() + "MAIN ENDP\n");
                    }
                    else
                    {
                        $$->setCode($$->getCode() + "RET\n");
                        $$->setCode($$->getCode() + temp1->getName() + "_" + temp1->getScope() + " ENDP\n");
                    }
                    data_segment.emplace_back(temp1->getName() + "_ret_" + temp1->getScope(), -1);

					logg << $$->getName() << endl << endl;
                    parameters.clear();
				}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
             $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": func_definition : type_specifier ID LPAREN RPAREN compound_statement" << endl << endl; 
			//symboltable.Insert($2->getName(), $2->getType());
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
            $$->setType($2->getName());

            SymbolInfo* temp1 = symboltable.LookUp($2->getName());
            $$->setTypeSpecifier(temp1->getName() + "_" + temp1->getScope());

            if($2->getName() == "main")
            {
                $$->setCode("MAIN PROC\nMOV AX, @DATA\nMOV DS, AX\n");
            }
            else
            {
                $$->setCode(temp1->getName() + "_" + temp1->getScope() + " PROC\n");
            }
            $$->setCode($$->getCode() + "PUSH AX\n");
            $$->setCode($$->getCode() + "PUSH BX\n");
            $$->setCode($$->getCode() + "PUSH CX\n");
            $$->setCode($$->getCode() + "PUSH DX\n");
            $$->setCode($$->getCode() + $5->getCode());
            $$->setCode($$->getCode() + "POP DX\n");
            $$->setCode($$->getCode() + "POP CX\n");
            $$->setCode($$->getCode() + "POP BX\n");
            $$->setCode($$->getCode() + "POP AX\n");
            if(return_symbol != "")
            {
                $$->setCode($$->getCode() + "MOV AX, " + return_symbol + "\n");
                $$->setCode($$->getCode() + "MOV " + temp1->getName() + "_ret_" + temp1->getScope() + ", AX\n");  
                return_symbol = "";    
            }
            if($2->getName() == "main")
            {
                $$->setCode($$->getCode() + ";DOS EXIT\n");
                $$->setCode($$->getCode() + "MOV AH, 4CH\n");
                $$->setCode($$->getCode() + "INT 21H\n");
                $$->setCode($$->getCode() + "MAIN ENDP\n");
            }
            else
            {
                $$->setCode($$->getCode() + temp1->getName() + "_" + temp1->getScope() + " ENDP\n");
            }
            data_segment.emplace_back(temp1->getName() + "_ret_" + temp1->getScope(), -1);


			logg << $$->getName() << endl << endl;
            parameters.clear();
		}
 		;				

parameter_list  : parameter_list COMMA type_specifier ID
				{
                     $$ = new SymbolInfo("", "");
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
             $$ = new SymbolInfo("", "");
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
              $$ = new SymbolInfo("", "");
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
             $$ = new SymbolInfo("", "");
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
                        $$ = new SymbolInfo("", "");
                        
						logg << "Line " << line_count << ": compound_statement : LCURL statements RCURL" << endl << endl; 
						$$->setName($1->getName() + "\n" + $2->getName() + " " + $3->getName() + "\n");
                        $$->setType("NONTERMINAL");

                        $$->setCode($2->getCode());

						logg << $$->getName() << endl << endl;
                        symboltable.PrintAllScopeTable(logg);
	                    symboltable.exitScope();
					}
 		    | LCURL RCURL
			 {
                 $$ = new SymbolInfo("", "");
				logg << "Line " << line_count << ": compound_statement : LCURL RCURL" << endl << endl; 
				$$->setName($1->getName() + "\n" + $2->getName() + "\n"); 
                $$->setType("NONTERMINAL");

                //$$->setCode($2->getCode());

				logg << $$->getName() << endl << endl;
                symboltable.PrintAllScopeTable(logg);
	            symboltable.exitScope();
			 }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
            $$ = new SymbolInfo("", "");
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
                        temp->setScope(symboltable.getCurrentScopeId());
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

            /*Assembly Code Part*/
            for(auto ids : declaration_list)
            {
                data_segment.emplace_back(ids.first + "_" + symboltable.getCurrentScopeId(), ids.second);
            }


            declaration_list.clear();
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + "\n");
            $$->setType("NONTERMINAL");
			logg << $$->getName() << endl << endl;
		}
 		 ;
 		 
type_specifier	: INT 
		{ 
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": type_specifier : INT" << endl << endl; 
			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("INT");
			logg << $$->getName() << endl << endl;
		}	
 		| FLOAT 
 		{ 
             $$ = new SymbolInfo("", "");
 			logg << "Line " << line_count << ": type_specifier : FLOAT" << endl << endl; 
 			$$->setName($1->getName()); 
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("FLOAT");
 			logg << $$->getName() << endl << endl;
 		}
 		| VOID 
 		{ 
             $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": type_specifier : VOID" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            $$->setTypeSpecifier("VOID");
 			logg << $$->getName() << endl << endl;
 		}
 		;
 		
declaration_list : declaration_list COMMA ID 
		{ 
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": declaration_list : declaration_list COMMA ID" << endl << endl; 
            declaration_list.emplace_back($3->getName(), -1);
			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
            $$->setType($$->getType());
			logg << $$->getName() << endl << endl;
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
 		{ 
             $$ = new SymbolInfo("", "");
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
             $$ = new SymbolInfo("", "");
 		  	logg << "Line " << line_count << ": declaration_list : ID" << endl << endl;
            declaration_list.emplace_back($1->getName(), -1);
 		  	$$->setName($1->getName());
 		  	logg << $$->getName() << endl << endl;
 		} 
 		  | ID LTHIRD CONST_INT RTHIRD 
 		{ 
             $$ = new SymbolInfo("", "");
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
            $$ = new SymbolInfo("", "");
 			logg << "Line " << line_count << ": statements : statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());

            $$->setCode($1->getCode());

 			logg << $$->getName() << endl << endl;
 		} 
	   | statements statement
	   	{ 
            $$ = new SymbolInfo("", "");
 			logg << "Line " << line_count << ": statements : statements statement" << endl << endl; 
 			$$->setName($1->getName() + $2->getName());
            $$->setType($1->getType());

            $$->setCode($1->getCode() + $2->getCode());

 			logg << $$->getName() << endl << endl;
 		} 
	   ;
	   
statement : var_declaration
		{
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": statement : var_declaration" << endl << endl; 
 			$$->setName($1->getName()); 
            $$->setType("NONTERMINAL");

            $$->setCode($1->getCode());
            $$->setSymbol($1->getSymbol());

 			logg << $$->getName() << endl << endl;
		}	
	  | expression_statement
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : expression_statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");

            $$->setCode($1->getCode());
            $$->setSymbol($1->getSymbol());

 			logg << $$->getName() << endl << endl;
	  }
	  | compound_statement
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : compound_statement" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");

            $$->setCode($1->getCode());
            $$->setSymbol($1->getSymbol());

 			logg << $$->getName() << endl << endl;
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + " " + $7->getName());
 			$$->setType("NONTERMINAL");

            $$->setCode($3->getCode());
            string label1 = newLabel();
            string label2 = newLabel();
            $$->setCode($$->getCode() + label1 + ":\n");
            $$->setCode($$->getCode() + $4->getCode());
            $$->setCode($$->getCode() + "CMP " + $4->getSymbol() + ", 0\n");
            $$->setCode($$->getCode() + "JE " + label2 + "\n");
            $$->setCode($$->getCode() + $7->getCode());
            $$->setCode($$->getCode() + $5->getCode());
            $$->setCode($$->getCode() + "JMP " + label1 + "\n");
            $$->setCode($$->getCode() + label2 + ":\n");

            logg << $$->getName() << endl << endl;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
             $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : IF LPAREN expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
            $$->setType("NONTERMINAL");

            string label = newLabel();
            $$->setCode($3->getCode());
            $$->setCode($$->getCode() + "CMP " + $3->getSymbol() + ", 0\n");
            $$->setCode($$->getCode() + "JE " + label + "\n");
            $$->setCode($$->getCode() + $5->getCode());
            $$->setCode($$->getCode() + label + ":\n");

 			logg << $$->getName() << endl << endl;
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement 
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : IF LPAREN expression RPAREN statement ELSE statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + " " + $7->getName());
 			$$->setType("NONTERMINAL");

            string label1 = newLabel();
            string label2 = newLabel();
            $$->setCode($3->getCode());
            $$->setCode($$->getCode() + "CMP " + $3->getSymbol() + ", 0\n");
            $$->setCode($$->getCode() + "JE " + label1 + "\n");
            $$->setCode($$->getCode() + $5->getCode());
            $$->setCode($$->getCode() + "JMP " + label2 + "\n");
            $$->setCode($$->getCode() + label1 + ":\n");
            $$->setCode($$->getCode() + $7->getCode());
            $$->setCode($$->getCode() + label2 + ":\n");

            logg << $$->getName() << endl << endl;
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : WHILE LPAREN expression RPAREN statement" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName());
            $$->setType("NONTERMINAL");

            string label1 = newLabel();
            string label2 = newLabel();
            $$->setCode(label1 + ":\n");
            $$->setCode($$->getCode() + $3->getCode());
            $$->setCode($$->getCode() + "CMP " + $3->getSymbol() + ", 0\n");
            $$->setCode($$->getCode() + "JL " + label2 + "\n");
            $$->setCode($$->getCode() + $5->getCode());
            $$->setCode($$->getCode() + "JMP " + label1 + "\n");
            $$->setCode($$->getCode() + label2 + ":\n");

 			logg << $$->getName() << endl << endl;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
            $$ = new SymbolInfo("", "");
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
                $$->setCode("MOV AX, " + si->getName() + "_" + si->getScope() + "\n");
                $$->setCode($$->getCode() + "CALL OUTPUT\n");
            }
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + "\n");
            $$->setType("NONTERMINAL");

            

 			logg << $$->getName() << endl << endl;
	  }
	  | RETURN expression SEMICOLON 
	  {
            $$ = new SymbolInfo("", "");
		  	logg << "Line " << line_count << ": statement : RETURN expression SEMICOLON" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + "\n");
            $$->setType("NONTERMINAL");
            if($2->getTypeSpecifier() == "VOID")
            {
                logg << "Error at line " << line_count << ": Return type cannot be void " << endl << endl;
                errors << "Error at line " << line_count << ": Return type cannot be void " << endl << endl;
                error++;
            }

            $$->setCode($2->getCode());
            return_symbol = $2->getSymbol();

 			logg << $$->getName() << endl << endl;
	  }
	  ;
	  
expression_statement : SEMICOLON
						{
                            $$ = new SymbolInfo("", "");
							logg << "Line " << line_count << ": expression_statement : SEMICOLON" << endl << endl; 
 							$$->setName($1->getName() + "\n");
                            $$->setType("NONTERMINAL");
                            $$->setTypeSpecifier($1->getTypeSpecifier());

                            $$->setCode($1->getCode());

 							logg << $$->getName() << endl << endl;
						}			
			| expression SEMICOLON 
			{
                $$ = new SymbolInfo("", "");
				logg << "Line " << line_count << ": expression_statement : expression SEMICOLON" << endl << endl; 
 				$$->setName($1->getName() + " " + $2->getName() + "\n");
                $$->setType("NONTERMINAL");
                $$->setTypeSpecifier($1->getTypeSpecifier());

                $$->setCode($1->getCode());
                $$->setSymbol($1->getSymbol());

 				logg << $$->getName() << endl << endl;
			}
			;
	  
variable : ID
		{
            $$ = new SymbolInfo("", "");
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
                $$->setSymbol(si->getName() + "_" + si->getScope());
            }
 			$$->setName($1->getName());
            $$->setType("NONTERMINAL");
            

            /*Assembly Code*/
            $$->setCode($1->getCode());
            

            ///$$->setTypeSpecifier(si->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
		}
	 | ID LTHIRD expression RTHIRD 
	 {
            $$ = new SymbolInfo("", "");
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
                string temp = newTemp();
                data_segment.emplace_back(temp, -1);

                /*Assembly Code*/
                $$->setCode($1->getCode() + $3->getCode());
                $$->setCode($$->getCode() + "MOV BX, " + $3->getSymbol() + "\n");
                $$->setCode($$->getCode() + "ADD BX, BX\n");
                $$->setCode($$->getCode() + "MOV AX, " + si->getName() + "_" + si->getScope() + "[BX]\n");
                $$->setCode($$->getCode() + "MOV " + temp + ", AX\n");
                $$->setSymbol(temp);
            }
            $$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
            $$->setType("NONTERMINAL");
            $$->setSymbol($1->getName() + "_" + symboltable.getCurrentScopeId());


            


            ///$$->setTypeSpecifier(si->getTypeSpecifier());
 			logg << $$->getName() << endl << endl;
	 }
	 ;
	 
expression : logic_expression	
			{
                $$ = new SymbolInfo("", "");
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

                $$->setSymbol($1->getSymbol());
                $$->setCode($1->getCode());

 				logg << $$->getName() << endl << endl;
			}
	   | variable ASSIGNOP logic_expression 
	   {
           $$ = new SymbolInfo("", "");
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

            string temp = newTemp();
            data_segment.emplace_back(temp, -1);
            $$->setCode($1->getCode() + $3->getCode());
            $$->setCode($$->getCode() + "MOV AX, " + $3->getSymbol() + "\n");
            $$->setCode($$->getCode() + "MOV " + $1->getSymbol() + ", AX\n");
            $$->setCode($$->getCode() + "MOV " + temp + ", 1\n");
            $$->setSymbol(temp);

 			logg << $$->getName() << endl << endl;
	   }	
	   ;
			
logic_expression : rel_expression
				{
                    $$ = new SymbolInfo("", "");
					logg << "Line " << line_count << ": logic_expression : rel_expression" << endl << endl; 
 					$$->setName($1->getName());
                    $$->setType($1->getType());
                    $$->setTypeSpecifier($1->getTypeSpecifier());

                    $$->setSymbol($1->getSymbol());
                    $$->setCode($1->getCode());

 					logg << $$->getName() << endl << endl;
				}
		 | rel_expression LOGICOP rel_expression 	
		 {
             $$ = new SymbolInfo("", "");
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

            string temp = newTemp();
            string label1 = newLabel();
            string label2 = newLabel();
            data_segment.emplace_back(temp, -1);
            $$->setSymbol(temp);
            $$->setCode($1->getCode() + $3->getCode());
            if($2->getName() == "&&")
            {
                $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                $$->setCode($$->getCode() + "MOV BX, " + $3->getSymbol() + "\n");
                //$$->setCode($$->getCode() + "AND AX, BX\n");
                $$->setCode($$->getCode() + "CMP AX, 0\n");
                $$->setCode($$->getCode() + "JE " + label1+ "\n");
                $$->setCode($$->getCode() + "CMP BX, 0\n");
                $$->setCode($$->getCode() + "JE " + label1+ "\n");
                $$->setCode($$->getCode() + "MOV " + temp + ", 1\n");
                $$->setCode($$->getCode() + "JMP " + label2 + "\n");
                $$->setCode($$->getCode() + label1 + ":\n");
                $$->setCode($$->getCode() + "MOV " + temp + ", 0\n");
                $$->setCode($$->getCode() + label2 + ":\n");
            }
            else if($2->getName() == "||")
            {
                $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                $$->setCode($$->getCode() + "MOV BX, " + $3->getSymbol() + "\n");
                //$$->setCode($$->getCode() + "OR AX, BX\n");
                $$->setCode($$->getCode() + "CMP AX, 0\n");
                $$->setCode($$->getCode() + "JG " + label1+ "\n");
                $$->setCode($$->getCode() + "CMP BX, 0\n");
                $$->setCode($$->getCode() + "JG " + label1+ "\n");
                $$->setCode($$->getCode() + "MOV " + temp + ", 0\n");
                $$->setCode($$->getCode() + "JMP " + label2 + "\n");
                $$->setCode($$->getCode() + label1 + ":\n");
                $$->setCode($$->getCode() + "MOV " + temp + ", 1\n");
                $$->setCode($$->getCode() + label2 + ":\n");
            }
            

 			logg << $$->getName() << endl << endl;
		 }
		 ;
			
rel_expression : simple_expression 
				{
                    $$ = new SymbolInfo("", "");
					logg << "Line " << line_count << ": rel_expression : simple_expression" << endl << endl; 
 					$$->setName($1->getName());
                    $$->setType($1->getType());
                    $$->setTypeSpecifier($1->getTypeSpecifier());

                    $$->setSymbol($1->getSymbol());
                    $$->setCode($1->getCode());

 					logg << $$->getName() << endl << endl;
				}
		| simple_expression RELOP simple_expression	
		{
            $$ = new SymbolInfo("", "");
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

            string temp = newTemp();
            data_segment.emplace_back(temp, -1);
            string label1 = newLabel();
            string label2 = newLabel();
            $$->setSymbol(temp);
            $$->setCode($1->getCode() + $3->getCode());
            $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
            $$->setCode($$->getCode() + "MOV BX, " + $3->getSymbol() + "\n");
            $$->setCode($$->getCode() + "CMP AX, BX\n");
            if($2->getName() == "<=")
            {
                $$->setCode($$->getCode() + "JLE " + label1 + "\n");
            }
            else if($2->getName() == "<")
            {
                $$->setCode($$->getCode() + "JL " + label1 + "\n");
            }
            else if($2->getName() == ">=")
            {
                $$->setCode($$->getCode() + "JGE " + label1 + "\n");
            }
            else if($2->getName() == ">")
            {
                $$->setCode($$->getCode() + "JG " + label1 + "\n");
            }
            else if($2->getName() == "==")
            {
                $$->setCode($$->getCode() + "JE " + label1 + "\n");
            }
            else if($2->getName() == "!=")
            {
                $$->setCode($$->getCode() + "JNE " + label1 + "\n");
            }
            $$->setCode($$->getCode() + "MOV " + temp + ", 0\n");
            $$->setCode($$->getCode() + "JMP " + label2 + "\n");
            $$->setCode($$->getCode() + label1 + ":\n");
            $$->setCode($$->getCode() + "MOV " + temp + ", 1\n");
            $$->setCode($$->getCode() + label2 + ":\n");

 			logg << $$->getName() << endl << endl;
		}
		;
				
simple_expression : term
					{
                        $$ = new SymbolInfo("", "");
						logg << "Line " << line_count << ": simple_expression : term" << endl << endl; 
 						$$->setName($1->getName());
                        $$->setType($1->getType());
                        $$->setTypeSpecifier($1->getTypeSpecifier());

                        $$->setSymbol($1->getSymbol());
                        $$->setCode($1->getCode());

 						logg << $$->getName() << endl << endl;
					}
		  | simple_expression ADDOP term 
		  {
                $$ = new SymbolInfo("", "");
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

                string temp = newTemp();
                data_segment.emplace_back(temp, -1);
                $$->setSymbol(temp);
                $$->setCode($1->getCode() + $3->getCode());
                if($2->getName() == "+")
                {
                    $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                    $$->setCode($$->getCode() + "MOV BX," + $3->getSymbol() + "\n");
                    $$->setCode($$->getCode() + "ADD AX, BX\n");
                    $$->setCode($$->getCode() + "MOV " + temp + ", AX\n");
                }
                else if($2->getName() == "-")
                {
                    $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                    $$->setCode($$->getCode() + "MOV BX," + $3->getSymbol() + "\n");
                    $$->setCode($$->getCode() + "SUB AX, BX\n");
                    $$->setCode($$->getCode() + "MOV " + temp + ", AX\n");
                }


 			    logg << $$->getName() << endl << endl;
		  }
		  ;
					
term : unary_expression
		{
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": term : unary_expression" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());

            $$->setSymbol($1->getSymbol());
            $$->setCode($1->getCode());

 			logg << $$->getName() << endl << endl;
		}
     |  term MULOP unary_expression
	 	{
            $$ = new SymbolInfo("", "");
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


            string temp = newTemp();
            data_segment.emplace_back(temp, -1);
            $$->setSymbol(temp);
            $$->setCode($1->getCode() + $3->getCode());
            if($2->getName() == "%" || $2->getName() == "/")
            {
                $$->setCode($$->getCode() + "XOR DX, DX\n");
                $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                $$->setCode($$->getCode() + "CWD\n");
                $$->setCode($$->getCode() + "IDIV " + $3->getSymbol() + "\n");
                if($2->getName() == "%")
                {
                    $$->setCode($$->getCode() + "MOV " + $$->getSymbol() + ", DX\n");
                }
                else
                {
                    $$->setCode($$->getCode() + "MOV " + $$->getSymbol() + ", AX\n");
                }
                
            }
            else if($2->getName() == "*")
            {
                $$->setCode($$->getCode() + "MOV AX, " + $1->getSymbol() + "\n");
                $$->setCode($$->getCode() + "IMUL " + $3->getSymbol() + "\n");
                $$->setCode($$->getCode() + "MOV " + $$->getSymbol() + ", AX\n");
            }



 			logg << $$->getName() << endl << endl;
		}
     ;

unary_expression : ADDOP unary_expression
					{
                        $$ = new SymbolInfo("", "");
						logg << "Line " << line_count << ": unary_expression : ADDOP unary_expression" << endl << endl; 
 						$$->setName($1->getName() + " " + $2->getName());
                        $$->setType("NOTFUNC");
                        $$->setTypeSpecifier($2->getTypeSpecifier());

                        $$->setSymbol($2->getSymbol());
                        $$->setCode($2->getCode());
                        if($1->getName() == "-")
                        {
                            $$->setCode($$->getCode() + "NEG " + $2->getSymbol() + "\n");
                        }

 						logg << $$->getName() << endl << endl;
					}
		 | NOT unary_expression
		 {
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": unary_expression : NOT unary_expression" << endl << endl; 
 			$$->setName($1->getName() + " " + $2->getName());
            $$->setType("NOTFUNC");
            $$->setTypeSpecifier($2->getTypeSpecifier());

            $$->setSymbol($2->getSymbol());
            $$->setCode($2->getCode());
            $$->setCode($$->getCode() + "NOT " + $2->getSymbol() + "\n");

 			logg << $$->getName() << endl << endl;
		 } 
		 | factor 
		 {
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": unary_expression : factor" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());

            $$->setSymbol($1->getSymbol());
            $$->setCode($1->getCode());

 			logg << $$->getName() << endl << endl;
		 }
		 ;
	
factor	: variable
		{
            $$ = new SymbolInfo("", "");
			logg << "Line " << line_count << ": factor : variable" << endl << endl; 
 			$$->setName($1->getName());
            $$->setType($1->getType());
            $$->setTypeSpecifier($1->getTypeSpecifier());

            $$->setSymbol($1->getSymbol());
            $$->setCode($1->getCode());

 			logg << $$->getName() << endl << endl;
		}
	| ID LPAREN argument_list RPAREN
	{
        $$ = new SymbolInfo("", "");
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

        string temp = newTemp();
        data_segment.emplace_back(temp, -1);
        for(int i = 0; i < min(si->getParameterName().size(), argument_symbol.size()); i++)
        {
            $$->setCode($$->getCode() + "MOV AX" + ", " + argument_symbol[i] + "\n");
            $$->setCode($$->getCode() + "MOV " + si->getParameterName()[i] + "_" + si->getParameterScope()[i] + ", AX" + "\n");
        }
        SymbolInfo *temp1 = symboltable.LookUp($1->getName());
        if(temp1 != NULL)
        {
            $$->setCode($$->getCode() + "CALL " + temp1->getName() + "_" + temp1->getScope() + "\n");
            $$->setCode($$->getCode() + "MOV AX, " + temp1->getName() + "_ret_" + temp1->getScope() + "\n");
        }
        $$->setCode($$->getCode() + "MOV " + temp + ", AX\n");
        $$->setSymbol(temp);


        argument_symbol.clear();
        argument_list.clear();
 		$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName());
        $$->setType("FUNC");
 		logg << $$->getName() << endl << endl;
	}
	| LPAREN expression RPAREN
	{
        $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": factor : LPAREN expression RPAREN" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
        $$->setType($2->getType());
        $$->setTypeSpecifier($2->getTypeSpecifier());

    
        $$->setSymbol($2->getSymbol());
        $$->setCode($2->getCode());


 		logg << $$->getName() << endl << endl;
	}
	| CONST_INT
	{
        $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": factor : CONST_INT" << endl << endl; 
 		$$->setName($1->getName());
        $$->setType("NONTERMINAL");
        $$->setTypeSpecifier("INT");

        string temp = newTemp();
        data_segment.emplace_back(temp, -1);
        $$->setSymbol(temp);
        $$->setCode("MOV " + temp + ", " + $1->getName() + "\n");


 		logg << $$->getName() << endl << endl;
	} 
	| CONST_FLOAT
	{
        $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": factor : CONST_FLOAT" << endl << endl; 
 		$$->setName($1->getName());
        $$->setType("NONTERMINAL");
        $$->setTypeSpecifier("FLOAT");

        string temp = newTemp();
        data_segment.emplace_back(temp, -1);
        $$->setSymbol(temp);
        $$->setCode("MOV " + temp + ", " + $1->getName() + "\n");

 		logg << $$->getName() << endl << endl;
	}
	| variable INCOP
	{
        $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": factor : variable INCOP" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName());
        $$->setType($1->getType());
        $$->setTypeSpecifier($1->getTypeSpecifier());

        $$->setSymbol($1->getSymbol());
        $$->setCode($1->getCode());
        $$->setCode($$->getCode() + "INC " + $1->getSymbol() + "\n");


 		logg << $$->getName() << endl << endl;
	} 
	| variable DECOP
	{
        $$ = new SymbolInfo("", "");
		logg << "Line " << line_count << ": factor : variable DECOP" << endl << endl; 
 		$$->setName($1->getName() + " " + $2->getName());
        $$->setType($1->getType());
        $$->setTypeSpecifier($1->getTypeSpecifier());

        $$->setSymbol($1->getSymbol());
        $$->setCode($1->getCode());
        $$->setCode($$->getCode() + "DEC " + $1->getSymbol() + "\n");

 		logg << $$->getName() << endl << endl;
	}
	;
	
argument_list : arguments
				{
                    $$ = new SymbolInfo("", "");
					logg << "Line " << line_count << ": argument_list : arguments" << endl << endl; 
 					$$->setName($1->getName());
 					logg << $$->getName() << endl << endl;
				}
			  |
			  {
                    $$ = new SymbolInfo("", "");
				  	logg << "Line " << line_count << ": argument_list : " << endl << endl; 
 					logg << $$->getName() << endl << endl;
			  }
			  ;
	
arguments : arguments COMMA logic_expression
			{
                $$ = new SymbolInfo("", "");
				logg << "Line " << line_count << ": arguments : arguments COMMA logic_expression" << endl << endl; 
                argument_list.push_back($3->getTypeSpecifier());
                argument_symbol.push_back($3->getSymbol());
 				$$->setName($1->getName() + " " + $2->getName() + " " + $3->getName());
 				logg << $$->getName() << endl << endl;
			}
	      | logic_expression
		  {
                $$ = new SymbolInfo("", "");
			  	logg << "Line " << line_count << ": arguments : logic_expression" << endl << endl; 
                argument_list.push_back($1->getTypeSpecifier());
                argument_symbol.push_back($1->getSymbol());
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
    code.open("code.asm");
    opcode.open("optimized_code.asm");
	yyin = fin;
	yyparse();
	symboltable.PrintAllScopeTable(logg);
	logg << endl << "Total lines: " << line_count << endl;
	logg << "Total errors: " << error << endl;
	logg.close();
    errors.close();
    code.close();
    opcode.close();
	return 0;
}

