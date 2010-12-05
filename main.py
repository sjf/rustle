#!/usr/bin/env python
import sys,os
import re


regexes = re.compile('''
(?P<WHITESPACE>   \s+) |
(?P<OPENPARAN>    \( ) |
(?P<CLOSEPARAN>   \) ) |
(?P<INTEGER>      (-|)\d+) |
(?P<BOOLEAN>      \#[tf] ) |
(?P<SYMBOL>       [a-zA-Z_][a-zA-Z0-9!?-]* ) |
(?P<CHARACTER>    \#\\. ) |
(?P<ARITH>        [-+/*]|<|>|<=|>= ) |
(?P<DOUBLEQUOTE>  ") |
''', re.VERBOSE)

str_regexes = re.compile('''
([^"]|\\.|")''', re.VERBOSE)

WHITESPACE = 0
OPENPARAN = 1
CLOSEPARAN = 2
INTEGER = 3
BOOLEAN = 5
SYMBOL = 6
CHARACTER = 7
ARITH = 8
DOUBLEQUOTE = 9

def error(*strs):
    print 'Error: ' + ' '.join([ str(x) for x in strs ])

def fatal_error(*strs):
    error(*strs)
    sys.exit(1)

def tokenise(src):
    tokens = []
    while src:
        match = regexes.match(src)
        if match == None:
            fatal_error("Parse error:",src)
        groups = match.groups()
        print groups

        for i in range(len(groups)):            
            if groups[i] == None:
                continue
            if i == DOUBLEQUOTE:
                src = src[1:]
                value = []; end = False
                while src and not end:
                    if src[0] == '"':
                        src = src[1:]
                        end = True
                    elif src[0] == '\\' and len(src) > 1:
                        value.append(src[1])
                        src = src[2:]
                    else:
                        value.append(src[0])
                        src = src[1:]
                if not end:
                    fatal_error("Unterminated string")
                tokens.append((i,''.join(value)))
            else:
                if i == 4: continue
                value = groups[i]
                src = src[len(value):]
                if i == WHITESPACE:
                    continue
                tokens.append((i, value))
    return tokens

def new_symbol_table(parent, code):
    code.append("//set environment -> new symbol table")
    code.append("//set symbol table parent -> %s" % str(parent))

T_INT = 0

var_count = 0

def new_temp(typ, code):
    name = 't_'+str(var_count)
    global var_count
    var_count += 1
    if typ == T_INT:
        code.append("int %s = 0;" % name)
    else:
        error("Unknown var type",typ)
    return name

arith_functions = {'+':'add','-':'sub','*':'mul','/':'div'}

def function_call(function, args, code):
    if function == 'display':
        code.append('display(%s);' % ', '.join(args))
        return None
    if function in arith_functions.values():
        res = new_temp(T_INT,code)
        print args
        code.append('%s = %s(%s, %s);'%(res,function,args[0],args[1]))
        return res        
    else:
        error("Unsupported function: ",function)
        
def parse0(tokens):
    code = []
    new_symbol_table(None, code)
    while tokens:
        parse(tokens,code)
    print "\n".join(code)
    return code

def pop(l):
    res = l[0]
    del l[0]
    return res

def parse(tokens, code):
    token = pop(tokens)
    print "TOK:",token
    typ = token[0]
    val = token[1]
    if typ == OPENPARAN:
        print "open paran"
        function = parse(tokens, code)
        if not function:
            error("Expected function")
        args = []
        end = False
        while tokens:
            if tokens[0][0] == CLOSEPARAN:
                end = True
                break
            args.append(parse(tokens, code))
        if not end:
            error("Unterminated list")
        pop(tokens) # remove close paran
        return function_call(function,args,code)
        
    elif typ == ARITH:
        return arith_functions[val]

    elif typ == INTEGER:
        return val
    
    elif typ == SYMBOL:
        print "sym"        
        # lookup symbol in table, return dereferencing expression
        return val
    elif typ == CLOSEPARAN:
        print "closeparan"
        return None
    else:
        error("Unhandled",token)
        return None

def replace_ext(name,ext):
    ind = name.rindex('.')
    if ind != -1:
        return name[:ind]+ext
    return name+ext

    
    

def main():
    if len(sys.argv) < 2:
        fatal_error( "Usage:",sys.argv[0],"file.scm")
    file_name = sys.argv[1]
    src = open(file_name).read()
    tokens = tokenise(src)
    print tokens
    instructions = parse0(tokens)
    out_file = replace_ext(file_name,'.c')
    
    fh = open(out_file,'w')
    fh.write(c_start);
    fh.write("\n".join(instructions))
    fh.write(c_end)
    fh.close()
    
    out_exec = replace_ext(file_name,'')
    args = '/usr/bin/gcc -I. builtin.o %s -o %s' % (out_file,out_exec)
    print args
    os.execv('/usr/bin/gcc',args.split(' '))
    
c_start = '''
#include <stdio.h>
#include <builtin.h>

void run_main();

int main(int argc, char** argv) {
  run_main();
  return 0;
}
void run_main(){
'''
c_end = '''
}
'''

main()
