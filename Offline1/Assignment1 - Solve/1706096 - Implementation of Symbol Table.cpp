#include<bits/stdc++.h>

using namespace std;


class SymbolInfo
{
    string Name, Type;
    SymbolInfo *next;
public:

    SymbolInfo(string name, string type)
    {
        Name = name;
        Type = type;
        next = NULL;
    }

    string getName()
    {
        return Name;
    }

    string getType()
    {
        return Type;
    }

    void setName(string name)
    {
        this->Name = name;
    }

    void setType(string type)
    {
        this->Type = type;
    }

    SymbolInfo *getNext()
    {
        return next;
    }

    void setNext(SymbolInfo *next)
    {
        this->next = next;
    }

    ~SymbolInfo()
    {
        ///delete next;
    }
};


class ScopeTable
{
    int total_bucket, numberofdeletedchild;
    vector<SymbolInfo*> scopetable;
    ScopeTable *parentScope;
    string id;
public:
    ScopeTable(int total_bucket, string id, ScopeTable *parentScope = NULL)
    {
        scopetable.assign( total_bucket, NULL);
        this->total_bucket = total_bucket;
        this->id = id;
        this->parentScope = parentScope;
        numberofdeletedchild = 0;
        cout << "New ScopeTable with id "+ id + " created" << endl;
    }

    int getHash(string name)
    {
        int sum_ascii = 0;
        for(auto chr : name)
        {
            sum_ascii += chr;
        }
        return sum_ascii%total_bucket;
    }

    bool Insert(string name, string type)
    {
        if(!LookUp(name))
        {
            int scopetableindex = getHash(name);
            int chainindex = 0;
            SymbolInfo *temp = new SymbolInfo(name, type);
            SymbolInfo *x = *(&scopetable[scopetableindex]);
            if(scopetable[scopetableindex] == NULL)
            {
                scopetable[scopetableindex] = temp;
                cout << "Inserted in ScopeTable# " + id +" at position " + to_string(scopetableindex) + ", " + to_string(chainindex) << endl;
            }
            else
            {
                while(x->getNext() != NULL)
                {
                    x = x->getNext();
                    chainindex++;
                }
                x->setNext(temp);
                chainindex++;
                cout << "Inserted in ScopeTable# " + id +" at position " + to_string(scopetableindex) + ", " + to_string(chainindex) << endl;
            }

            return true;
        }
        else
        {
            cout << "<" + name + "> already exists in current ScopeTable" << endl;
            return false;
        }
    }

    SymbolInfo* LookUp(string name)
    {
        int scopetableindex = getHash(name);
        SymbolInfo *x = scopetable[scopetableindex];
        int chainindex = 0;
        while(x != NULL)
        {
            if(name == x->getName())
            {
                break;
            }
            x = x->getNext();
            chainindex++;
        }
        if(x != NULL)
        {
            cout << "Found in ScopeTable# " << id <<" at position " + to_string(scopetableindex) + ", " + to_string(chainindex) << endl;
        }
        return x;
    }

    bool Delete(string name)
    {
        int scopetableindex = getHash(name);
        int chainindex = 0;
        SymbolInfo *x = *(&scopetable[scopetableindex]);
        SymbolInfo *prev = NULL;
        if(x != NULL && x->getName() == name)
        {
            scopetable[scopetableindex] = scopetable[scopetableindex]->getNext();
            cout << "Found in ScopeTable# " + id +" at position " + to_string(scopetableindex) + ", " + to_string(chainindex) << endl;
            cout << "Deleted Entry " + to_string(scopetableindex) + ", " + to_string(chainindex) + " from current ScopeTable" << endl;
            delete x;
            return true;
        }
        while(x != NULL && x->getName() != name)
        {
            prev = x;
            x = x->getNext();
            chainindex++;
        }
        if(x == NULL)
        {
            ///cout << "Not found in ScopeTable# " << id << endl;
            cout << name << " not found" << endl;
            delete x;
            return false;
        }
        ///prev->next = x->next;
        prev->setNext(x->getNext());
        cout << "Found in ScopeTable# " + id +" at position " + to_string(scopetableindex) + ", " + to_string(chainindex) << endl;
        cout << "Deleted Entry " + to_string(scopetableindex) + ", " + to_string(chainindex) + " from current ScopeTable" << endl;
        delete x;
        return true;
    }

    int getNumberOfDeletedChild()
    {
        return numberofdeletedchild;
    }

    void setNumberOfDeletedChild(int n)
    {
        numberofdeletedchild = n;
    }

    ScopeTable* getParentScope()
    {
        return parentScope;
    }

    void Print()
    {
        cout << "ScopeTable # " << id << endl;
        for(int i = 0; i < scopetable.size(); i++)
        {
            SymbolInfo *temp = scopetable[i];
            cout << i << " --> ";
            while(temp != NULL)
            {
                cout << " < " << temp->getName() << " : " << temp->getType() << "> ";
                ///temp = temp->next;
                temp = temp->getNext();
            }
            cout << endl;
        }
    }

    string getId()
    {
        return id;
    }

    ~ScopeTable()
    {
        for(int i = 0; i < scopetable.size(); i++)
        {
            delete scopetable[i];
        }
        scopetable.clear();
        cout << "ScopeTable with id " + id + " removed" << endl;
    }
};


class SymbolTable
{
    ScopeTable *currentScope;
    int bucket_size;
public:
    SymbolTable(int bucket_size)
    {
        this->bucket_size = bucket_size;
        currentScope = new ScopeTable(bucket_size, "1", NULL);
    }
    void enterScope()
    {
        string id;
        id = currentScope->getId() + "." + to_string(currentScope->getNumberOfDeletedChild() + 1);
        ScopeTable *temp = new ScopeTable(bucket_size, id, currentScope);
        currentScope = temp;
    }
    void exitScope()
    {
        ScopeTable *temp = currentScope->getParentScope();
        delete currentScope;
        currentScope = temp;
        if(currentScope != NULL)
        {
            currentScope->setNumberOfDeletedChild(currentScope->getNumberOfDeletedChild() + 1);
        }
    }
    bool Insert(string name, string type)
    {
        return currentScope->Insert(name, type);
    }
    bool Remove(string name)
    {
        return currentScope->Delete(name);
    }
    SymbolInfo* LookUp(string name)
    {
        ScopeTable *temp = currentScope;
        SymbolInfo *x = temp->LookUp(name);
        while(temp != NULL)
        {
            if(x != NULL)
            {
                break;
            }
            else
            {
                temp = temp->getParentScope();
                if(temp != NULL)
                {
                    x = temp->LookUp(name);
                }
            }
        }
        if(x == NULL)
        {
            cout << "Not found" << endl;
        }
        return x;
    }
    void PrintCurrentScopeTable()
    {
        currentScope->Print();
    }
    void PrintAllScopeTable()
    {
        ScopeTable *temp = currentScope;
        while(temp != NULL)
        {
            temp->Print();
            cout << endl;
            temp = temp->getParentScope();
        }
    }
    ~SymbolTable()
    {
        ScopeTable *temp = currentScope->getParentScope();
        while(temp != NULL)
        {
            delete currentScope;
            currentScope = temp;
            temp = currentScope->getParentScope();
        }
        delete currentScope;
        delete temp;
        cout << "Symboltable removed" << endl;
    }
};


int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    int n;
    string str, name, type;
    cin >> n;
    SymbolTable symboltable(n);
    while(cin >> str)
    {
        if(str == "I")
        {
            cin >> name >> type;
            cout << str << " " << name << " " << type << endl;
            symboltable.Insert(name, type);
        }
        else if(str == "L")
        {
            cin >> name;
            cout << str << " " << name << endl;
            symboltable.LookUp(name);
        }
        else if(str == "D")
        {
            cin >> name;
            cout << str << " " << name << endl;
            symboltable.Remove(name);
        }
        else if(str == "P")
        {
            cin >> name;
            cout << str << " " << name << endl;
            if(name == "A")
            {
                symboltable.PrintAllScopeTable();
            }
            else
            {
                symboltable.PrintCurrentScopeTable();
            }
        }
        else if(str == "S")
        {
            cout << str << endl;
            symboltable.enterScope();
        }
        else if(str == "E")
        {
            cout << str << endl;
            symboltable.exitScope();
        }
    }
    return 0;
}
