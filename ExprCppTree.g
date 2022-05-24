grammar ExprCppTree;

options {
    language = C;
    output = AST;
    ASTLabelType=pANTLR3_BASE_TREE;
}

@header {
    #include <assert.h>
}

// The suffix '^' means make it a root.
// The suffix '!' means ignore it.

expr: multExpr ((PLUS^ | MINUS^) multExpr)*
    ;

PLUS: '+';
MINUS: '-';

multExpr
    : atom ((TIMES^ | DIV^ ) atom)*
    ;

TIMES: '*';


DIV: '/';

atom: INT
    | ID
    | '('! expr ')'!
    ;

stmt: expr ';' NEWLINE -> expr  // tree rewrite syntax
    | ID ASSIGN expr ';' NEWLINE -> ^(ASSIGN ID expr) // tree notation
    | ';'* NEWLINE ->   // ignore
    | def_stmt
    | print_stmt
    | blocks
    ;

ASSIGN: '=';

block_code: stmt*;
blocks: '{' block_code '}' -> ^(BLOCK block_code);
BLOCK: '&';

print_stmt: PRINT^ expr ';'!;
PRINT: 'print';

def_stmt: DEF^ def_id(','! def_id)* ';'!;
def_id: ID^ (ASSIGN! expr)?;
DEF: 'def';


prog
    : (blocks {pANTLR3_STRING s = $blocks.tree->toStringTree($blocks.tree);
             assert(s->chars);
             printf(" tree \%s\n", s->chars);
            }
        )+
    ;

ID: ('a'..'z'|'A'..'Z')+ ;
INT: '~'? '0'..'9'+ ;
NEWLINE: '\r'? '\n' ;
WS : (' '|'\t')+ {$channel = HIDDEN;};
